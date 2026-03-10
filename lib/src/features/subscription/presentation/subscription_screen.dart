import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Premium Access',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.violetPrimary, AppTheme.violetDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: AppTheme.brandShadow,
              ),
              child: Column(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 56),
                  const SizedBox(height: 24),
                  Text(
                    'Upgrade to Pro',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Unlock advanced analytics, unlimited categories, and cloud sync.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildFeatureRow(context, Icons.analytics_rounded, 'Advanced Analytics', 'Deep dive into your spending habits.'),
            _buildFeatureRow(context, Icons.cloud_done_rounded, 'Cloud Sync', 'Access your data from any device.'),
            _buildFeatureRow(context, Icons.category_rounded, 'Unlimited Categories', 'Organize your finances your way.'),
            const SizedBox(height: 40),
            _buildPlanCard(context, 'Monthly Plan', '4.99 / mo', false),
            const SizedBox(height: 16),
            _buildPlanCard(context, 'Yearly Plan', '39.99 / yr', true),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: FilledButton(
                onPressed: () {},
                child: const Text('Start Free Trial'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Recurring billing. Cancel anytime.',
              style: GoogleFonts.plusJakartaSans(color: cs.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String title, String sub) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.violetPrimary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.violetPrimary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16, color: cs.onSurface)),
                Text(sub, style: GoogleFonts.plusJakartaSans(color: cs.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, String title, String price, bool isBestValue) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isBestValue ? AppTheme.violetPrimary : cs.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isBestValue)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.violetPrimary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('BEST VALUE', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                  ),
                Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 17, color: cs.onSurface)),
                const SizedBox(height: 4),
                Text(price, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 20, color: AppTheme.violetPrimary)),
              ],
            ),
          ),
          Radio<bool>(value: true, groupValue: isBestValue, onChanged: (_) {}),
        ],
      ),
    );
  }
}
