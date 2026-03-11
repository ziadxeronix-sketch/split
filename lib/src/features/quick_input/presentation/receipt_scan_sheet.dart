import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../../../theme/app_theme.dart';
import '../../../core/notifications/notification_coordinator.dart';
import '../../categories/presentation/categories_providers.dart';
import '../../transactions/presentation/transactions_providers.dart';
import '../../gamification/presentation/gamification_providers.dart';

class ReceiptScanSheet extends ConsumerStatefulWidget {
  const ReceiptScanSheet({super.key});

  @override
  ConsumerState<ReceiptScanSheet> createState() => _ReceiptScanSheetState();
}

class _ReceiptScanSheetState extends ConsumerState<ReceiptScanSheet> {
  final _picker = ImagePicker();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  String _cat = 'other';
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickAndScan() async {
    final img = await _picker.pickImage(source: ImageSource.camera);
    if (img == null) return;
    setState(() => _busy = true);
    try {
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final input = InputImage.fromFile(File(img.path));
      final result = await recognizer.processImage(input);
      await recognizer.close();

      final text = result.text;
      _note.text = text.split('\n').take(3).join(' · ');

      // 1) استخرج كل الأرقام المحتملة مع السطر اللي فيها
      final lines = text.split('\n');
      final amountRegex = RegExp(r'(\d+[\.,]\d{2})');
      double best = 0;
      double? keywordAmount;

      final totalKeywords = [
        'total',
        'grand total',
        'amount due',
        'balance due',
        'subtotal',
      ];

      for (final line in lines) {
        final matches = amountRegex.allMatches(line);
        if (matches.isEmpty) continue;

        final hasKeyword = totalKeywords.any((k) => line.toLowerCase().contains(k));

        for (final m in matches) {
          final v = double.tryParse(m.group(1)!.replaceAll(',', '.')) ?? 0;
          if (hasKeyword) {
            // لو السطر فيه كلمة "الإجمالي" أو "TOTAL" اعتبره المرشح الأقوى
            if (keywordAmount == null || v >= (keywordAmount ?? 0)) {
              keywordAmount = v;
            }
          }
          if (v > best) best = v;
        }
      }

      final chosen = keywordAmount ?? best;
      if (chosen > 0) _amount.text = chosen.toStringAsFixed(2);

      // 2) حاول تخمين الكاتيجوري بناءً على النص والفئات الحالية
      final cats = ref.read(categoriesProvider).asData?.value ?? const [];
      if (cats.isNotEmpty) {
        final lower = text.toLowerCase();
        String? suggested;

        // كلمات مفتاحية عامة (إنجليزي فقط)
        if (lower.contains('restaurant') || lower.contains('meal') || lower.contains('food')) {
          suggested = 'food';
        } else if (lower.contains('coffee') || lower.contains('cafe')) {
          suggested = 'coffee';
        } else if (lower.contains('market') || lower.contains('supermarket') || lower.contains('grocery')) {
          suggested = 'groceries';
        } else if (lower.contains('uber') || lower.contains('taxi') || lower.contains('bus') || lower.contains('train')) {
          suggested = 'transport';
        } else if (lower.contains('pharmacy')) {
          suggested = 'health';
        }

        // طابقها مع الكاتيجوريات الفعلية إن وُجدت، أو جرب الأسماء مباشرةً
        String? catId;
        if (suggested != null && cats.any((c) => c.id == suggested)) {
          catId = suggested;
        } else {
          for (final c in cats) {
            final name = c.name.toLowerCase();
            if (lower.contains(name)) {
              catId = c.id;
              break;
            }
          }
        }

        if (catId != null) {
          setState(() {
            _cat = catId!;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan failed: $e'), backgroundColor: AppTheme.pinkAlert),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    final raw = _amount.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount'), backgroundColor: AppTheme.pinkAlert),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(transactionsRepositoryProvider).add(
            amount: amount,
            categoryId: _cat,
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
            source: 'ocr',
          );
      await ref.read(notificationCoordinatorProvider).evaluateAfterExpenseAdded(
        latestAmount: amount,
        categoryId: _cat,
      );
      final statsRepo = ref.read(statsRepositoryProvider);
      final before = await statsRepo.watch().first;
      final updated = await statsRepo.onExpenseAdded(createdAt: DateTime.now());
      final gainedXp = updated.points - before.points;
      if (!mounted) return;
      Navigator.pop(context);
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            gainedXp > 0
                ? 'Receipt scanned • +$gainedXp XP'
                : 'Receipt scanned',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppTheme.violetPrimary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.pinkAlert),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final cats = ref.watch(categoriesProvider).asData?.value ?? const [];
    if (cats.isNotEmpty && !cats.any((c) => c.id == _cat)) {
      _cat = cats.first.id;
    }

    return Container(
      padding: EdgeInsets.fromLTRB(24, 8, 24, bottom + 32),
      decoration: const BoxDecoration(
        color: AppTheme.whiteMain,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Scan Receipt',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          if (!_busy && _amount.text.isEmpty)
            GestureDetector(
              onTap: _pickAndScan,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppTheme.violetPrimary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.violetPrimary.withOpacity(0.1), width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt_rounded, color: AppTheme.violetPrimary, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Tap to capture receipt',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.violetPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_busy)
            Container(
              height: 160,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
            
          const SizedBox(height: 24),
          _buildLabel('Detected Amount'),
          const SizedBox(height: 8),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: '0.00',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
          ),
          
          const SizedBox(height: 20),
          _buildLabel('Category'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _cat,
            items: [
              for (final c in cats) 
                DropdownMenuItem(value: c.id, child: Text(c.name, style: GoogleFonts.nunito(fontWeight: FontWeight.w600)))
            ],
            onChanged: (v) => setState(() => _cat = v ?? _cat),
          ),
          
          const SizedBox(height: 20),
          _buildLabel('Note'),
          const SizedBox(height: 8),
          TextField(
            controller: _note,
            decoration: const InputDecoration(
              hintText: 'Add details...',
              prefixIcon: Icon(Icons.description_outlined),
            ),
          ),
          
          const SizedBox(height: 32),
          SizedBox(
            height: 60,
            child: FilledButton(
              onPressed: _busy ? null : _save,
              child: _busy
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirm & Save'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppTheme.textDark,
      ),
    );
  }
}
