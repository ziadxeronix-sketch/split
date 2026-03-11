import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';
import '../../budget/presentation/budget_providers.dart';
import '../../categories/presentation/categories_providers.dart';
import '../../../core/notifications/notification_coordinator.dart';
import '../../gamification/presentation/gamification_providers.dart';
import '../../quick_input/presentation/receipt_scan_sheet.dart';
import '../../quick_input/presentation/voice_input_sheet.dart';
import 'transactions_providers.dart';

class AddExpenseSheet extends ConsumerStatefulWidget {
  const AddExpenseSheet({super.key, this.initialCategoryId});

  final String? initialCategoryId;

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  late String _cat;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _cat = widget.initialCategoryId ?? 'food';
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final raw = _amount.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter a valid amount'),
          backgroundColor: AppTheme.pinkAlert,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(transactionsRepositoryProvider).add(
        amount: amount,
        categoryId: _cat,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );

      // Gamification + smart notifications
      await ref.read(notificationCoordinatorProvider).evaluateAfterExpenseAdded(
        latestAmount: amount,
        categoryId: _cat,
      );
      final statsRepo = ref.read(statsRepositoryProvider);
      final before = await statsRepo.watch().first;
      final updated = await statsRepo.onExpenseAdded(createdAt: DateTime.now());
      final gainedXp = updated.points - before.points;

      if (!mounted) return;

      Navigator.of(context).pop();
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            gainedXp > 0
                ? 'Expense added • +$gainedXp XP'
                : 'Expense added',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppTheme.violetPrimary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Add another',
            textColor: Colors.white,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                backgroundColor: AppTheme.whiteMain,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                builder: (_) => AddExpenseSheet(initialCategoryId: _cat),
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppTheme.pinkAlert,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final catsAsync = ref.watch(categoriesProvider);
    final currency = ref.read(activeBudgetProvider).asData?.value?.currencySymbol ?? '€';

    return Container(
      padding: EdgeInsets.fromLTRB(24, 8, 24, bottom + 32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Add New Expense',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text(
                  'AMOUNT',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                TextField(
                  controller: _amount,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixText: currency,
                    prefixStyle: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textMuted),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _buildLabel('Category'),
          const SizedBox(height: 8),
          catsAsync.when(
            data: (cats) {
              if (cats.isNotEmpty && !cats.any((c) => c.id == _cat)) {
                _cat = widget.initialCategoryId != null &&
                        cats.any((c) => c.id == widget.initialCategoryId)
                    ? widget.initialCategoryId!
                    : cats.first.id;
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _cat,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMuted),
                    borderRadius: BorderRadius.circular(16),
                    items: [
                      for (final c in cats)
                        DropdownMenuItem(
                          value: c.id,
                          child: Text(
                            c.name,
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: AppTheme.textDark)
                          ),
                        ),
                    ],
                    onChanged: (v) => setState(() => _cat = v ?? _cat),
                  ),
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),

          const SizedBox(height: 20),
          _buildLabel('Note'),
          const SizedBox(height: 8),
          TextField(
            controller: _note,
            textInputAction: TextInputAction.done,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 15),
            decoration: const InputDecoration(
              hintText: 'What was this for?',
              prefixIcon: Icon(Icons.notes_rounded, size: 20),
            ),
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              _QuickAction(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Scan Receipt',
                onTap: () => _openSheet(const ReceiptScanSheet()),
              ),
              const SizedBox(width: 12),
              _QuickAction(
                icon: Icons.keyboard_voice_rounded,
                label: 'Voice Input',
                onTap: () => _openSheet(const VoiceInputSheet()),
              ),
            ],
          ),

          const SizedBox(height: 32),
          SizedBox(
            height: 64,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _saving
                  ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary, strokeWidth: 3))
                  : Text(
                      'Confirm Expense',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _openSheet(Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (_) => sheet,
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.violetPrimary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.violetPrimary.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppTheme.violetPrimary),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.violetPrimary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
