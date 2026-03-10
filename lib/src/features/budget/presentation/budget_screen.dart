import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';
import '../domain/budget_model.dart';
import 'budget_providers.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  late TextEditingController _amount;
  late TextEditingController _currency;
  BudgetPeriod _period = BudgetPeriod.monthly;
  bool _saving = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController();
    _currency = TextEditingController(text: '€');
  }

  @override
  void dispose() {
    _amount.dispose();
    _currency.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncBudget = ref.watch(activeBudgetProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Elegant Background Accents
          Positioned(
            top: -120,
            right: -100,
            child: _GlowCircle(
              color: AppTheme.violetPrimary.withOpacity(0.06),
              size: 500,
            ),
          ),
          Positioned(
            bottom: 150,
            left: -120,
            child: _GlowCircle(
              color: AppTheme.tealSuccess.withOpacity(0.04),
              size: 400,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: asyncBudget.when(
                data: (b) {
                  if (b != null && !_initialized) {
                    _period = b.period;
                    _amount.text = b.amount.toStringAsFixed(0);
                    _currency.text = b.currencySymbol;
                    _initialized = true;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Budget Planning',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                          color: AppTheme.textDark,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Financial Target',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Define your spending limit to gain better control over your finances.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Main Budget Card
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(32),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                      ),
                                    ],
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _buildSectionLabel('BUDGET CYCLE'),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _PeriodTab(
                                              label: 'Weekly',
                                              isSelected: _period == BudgetPeriod.weekly,
                                              onTap: () => setState(() => _period = BudgetPeriod.weekly),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _PeriodTab(
                                              label: 'Monthly',
                                              isSelected: _period == BudgetPeriod.monthly,
                                              onTap: () => setState(() => _period = BudgetPeriod.monthly),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      _buildSectionLabel('AMOUNT & CURRENCY'),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Container(
                                            width: 70,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.01),
                                                  blurRadius: 10,
                                                )
                                              ],
                                            ),
                                            child: TextFormField(
                                              controller: _currency,
                                              maxLength: 1,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18,
                                              ),
                                              decoration: InputDecoration(
                                                counterText: '',
                                                hintText: '€',
                                                fillColor: AppTheme.greySecondary.withOpacity(0.5),
                                                contentPadding: const EdgeInsets.symmetric(vertical: 18),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                  borderSide: BorderSide.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.01),
                                                    blurRadius: 10,
                                                  )
                                                ],
                                              ),
                                              child: TextFormField(
                                                controller: _amount,
                                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: -0.5,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText: '0.00',
                                                  fillColor: AppTheme.greySecondary.withOpacity(0.5),
                                                  prefixIcon: const Icon(Icons.account_balance_wallet_rounded,
                                                      color: AppTheme.violetPrimary, size: 20),
                                                  contentPadding: const EdgeInsets.all(18),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 32),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.violetPrimary.withOpacity(0.3),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                              spreadRadius: -5,
                                            ),
                                          ],
                                        ),
                                        child: FilledButton(
                                          onPressed: _saving ? null : _save,
                                          style: FilledButton.styleFrom(
                                            minimumSize: const Size.fromHeight(56),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                            backgroundColor: AppTheme.violetPrimary,
                                          ),
                                          child: _saving
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                                )
                                              : Text(
                                                  'Update Financial Plan',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildInsightCard(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 100), // Space for FAB
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: AppTheme.textMuted.withOpacity(0.7),
      ),
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.violetPrimary.withOpacity(0.08),
            AppTheme.violetPrimary.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.violetPrimary.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.violetPrimary.withOpacity(0.1),
                  blurRadius: 10,
                )
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.violetPrimary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Insight',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppTheme.violetPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'A realistic budget helps our AI optimize your daily strategy.',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.textDark.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    final symbol = _currency.text.trim().isEmpty ? '€' : _currency.text.trim();

    setState(() => _saving = true);
    try {
      await ref.read(budgetRepositoryProvider).setActive(
            Budget(period: _period, amount: amount, currencySymbol: symbol),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Budget updated successfully!'),
          backgroundColor: AppTheme.tealSuccess,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }
}

class _PeriodTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodTab({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.violetPrimary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.violetPrimary.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 8)
            )
          ] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
            )
          ],
          border: Border.all(
            color: isSelected ? AppTheme.violetPrimary : AppTheme.textDark.withOpacity(0.05),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
            fontSize: 13,
            color: isSelected ? Colors.white : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}
