import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../theme/app_theme.dart';
import '../../../core/notifications/notification_coordinator.dart';
import '../../categories/presentation/categories_providers.dart';
import '../../transactions/presentation/transactions_providers.dart';
import '../../gamification/presentation/gamification_providers.dart';

class VoiceInputSheet extends ConsumerStatefulWidget {
  const VoiceInputSheet({super.key});

  @override
  ConsumerState<VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends ConsumerState<VoiceInputSheet> {
  final stt.SpeechToText _stt = stt.SpeechToText();
  bool _ready = false;
  bool _listening = false;
  String _text = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_init);
  }

  Future<void> _init() async {
    final ok = await _stt.initialize();
    if (!mounted) return;
    setState(() => _ready = ok);
  }

  Future<void> _toggle() async {
    if (!_ready) return;
    if (_listening) {
      await _stt.stop();
      if (!mounted) return;
      setState(() => _listening = false);
      return;
    }
    setState(() => _listening = true);
    await _stt.listen(
      onResult: (r) {
        if (!mounted) return;
        setState(() => _text = r.recognizedWords);
      },
    );
  }

  (double? amount, String? catId) _parse(String s, List<String> categoryIds, Map<String, String> keywordsToCat) {
    final normalized = s.toLowerCase();
    final m = RegExp(r'(\d+[\.,]?\d*)').firstMatch(normalized);
    final amount = m == null ? null : double.tryParse(m.group(1)!.replaceAll(',', '.'));

    String? cat;

    // 1) حاول تطابق كلمات مفتاحية مخصصة بالكategories الحالية
    for (final entry in keywordsToCat.entries) {
      if (normalized.contains(entry.key)) {
        cat = entry.value;
        break;
      }
    }

    // 2) fallback على أسماء الـ categories أو الـ id داخل النص
    if (cat == null) {
      for (final id in categoryIds) {
        if (normalized.contains(id.toLowerCase())) {
          cat = id;
          break;
        }
      }
    }

    if (cat != null && !categoryIds.contains(cat)) cat = null;
    return (amount, cat);
  }

  Future<void> _save() async {
    final cats = ref.read(categoriesProvider).asData?.value ?? const [];
    final ids = cats.map((e) => e.id).toList();

    // جهّز خريطة كلمات مفتاحية إنجليزية فقط → id كاتيجوري (يدوي + من أسماء الكاتيجوري)
    final Map<String, String> keywords = {
      'coffee': 'coffee',
      'food': 'food',
      'lunch': 'food',
      'dinner': 'food',
      'grocery': 'groceries',
      'groceries': 'groceries',
      'supermarket': 'groceries',
      'transport': 'transport',
      'uber': 'transport',
      'taxi': 'transport',
      'train': 'transport',
      'bus': 'transport',
      'shopping': 'shopping',
      'mall': 'shopping',
      'pharmacy': 'health',
    };

    // ضيف أسماء الكاتيجوريز الحالية ككلمات مفتاحية
    for (final c in cats) {
      final nameKey = c.name.toLowerCase();
      keywords[nameKey] = c.id;
    }

    final parsed = _parse(_text, ids, keywords);
    if (parsed.$1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not detect an amount.'), backgroundColor: AppTheme.pinkAlert),
      );
      return;
    }
    final amount = parsed.$1!;
    final catId = parsed.$2 ?? (ids.isNotEmpty ? ids.first : 'other');

    setState(() => _saving = true);
    try {
      await ref.read(transactionsRepositoryProvider).add(
            amount: amount,
            categoryId: catId,
            note: _text.trim().isEmpty ? null : _text.trim(),
            source: 'voice',
          );
      await ref.read(notificationCoordinatorProvider).evaluateAfterExpenseAdded(
        latestAmount: amount,
        categoryId: catId,
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
                ? 'Voice expense added • +$gainedXp XP'
                : 'Voice expense added',
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
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
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
            'Voice Expense',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          Center(
            child: GestureDetector(
              onTap: _ready ? _toggle : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: _listening ? AppTheme.pinkAlert.withOpacity(0.1) : AppTheme.violetPrimary.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _listening ? AppTheme.pinkAlert : AppTheme.violetPrimary.withOpacity(0.2),
                    width: 4,
                  ),
                ),
                child: Icon(
                  _listening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  size: 64,
                  color: _listening ? AppTheme.pinkAlert : AppTheme.violetPrimary,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          Text(
            _listening ? 'Listening...' : 'Tap the mic and speak',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: _listening ? AppTheme.pinkAlert : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Example: "Spent 25 on coffee"',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(color: AppTheme.textMuted, fontSize: 14),
          ),
          
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(minHeight: 120),
            decoration: BoxDecoration(
              color: AppTheme.greySecondary,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.withOpacity(0.05)),
            ),
            child: Text(
              _text.isEmpty ? 'Waiting for your voice...' : _text,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _text.isEmpty ? AppTheme.textMuted : AppTheme.textDark,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          SizedBox(
            height: 60,
            child: FilledButton(
              onPressed: (_text.trim().isEmpty || _saving) ? null : _save,
              child: _saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Add Voice Expense'),
            ),
          ),
        ],
      ),
    );
  }
}
