import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';
import 'auth_controller.dart';
import '../../gamification/presentation/gamification_providers.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;

  late AnimationController _bgController;
  late AnimationController _appearanceController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _appearanceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _appearanceController.dispose();
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false, // يمنع التمرير وتغيير حجم التصميم عند ظهور الكيبورد
      body: Stack(
        children: [
          // الخلفية الاحترافية
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, _) => CustomPaint(
                painter: ProfessionalMeshPainter(
                  animationValue: _bgController.value,
                  isSignUp: _isSignUp,
                ),
              ),
            ),
          ),

          // طبقة التغبيش لزيادة الوضوح
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(color: Colors.white.withOpacity(0.2)),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _appearanceController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 60), // تم تحريك اللوجو للأعلى هنا

                    // شعار المشروع
                    _buildLogo(),

                    const SizedBox(height: 70),

                    // العناوين
                    _buildHeader(),

                    const Spacer(flex: 1),

                    // بطاقة الإدخال الزجاجية
                    _buildGlassCard(async),

                    const SizedBox(height: 20),

                    // أزرار التواصل الاجتماعي
                    _buildSocialSection(),

                    const Spacer(flex: 2),

                    // التبديل بين الدخول والتسجيل
                    _buildFooter(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          if (async.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator(color: AppTheme.violetPrimary)),
            ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png',
      height: 120, // تقليل الارتفاع قليلاً لضمان عدم وجود سكرول
      width: 250,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
      const Icon(Icons.psychology_alt, size: 90, color: AppTheme.violetPrimary),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          _isSignUp ? "Join SplitBrain" : "Welcome Back",
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _isSignUp ? "Neural financial journey starts here" : "Manage your assets with precision",
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard(AsyncValue<void> async) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isSignUp) ...[
              _buildInput(
                controller: _name,
                hint: "Full Name",
                icon: Icons.person_outline,
                validator: (v) {
                  if (!_isSignUp) return null;
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  if (v.trim().length < 3) {
                    return 'Name is too short';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
            ],
            _buildInput(
              controller: _email,
              hint: "Email Address",
              icon: Icons.alternate_email,
              type: TextInputType.emailAddress,
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) {
                  return 'Email is required';
                }
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _buildInput(
              controller: _password,
              hint: "Password",
              icon: Icons.lock_outline,
              isPassword: _obscurePassword,
              validator: (v) {
                final value = v ?? '';
                if (value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 8) {
                  return 'Use at least 8 characters';
                }
                return null;
              },
              suffix: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(height: 20),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    Widget? suffix,
    TextInputType? type,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: type,
        validator: validator,
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14),
          prefixIcon: Icon(icon, color: AppTheme.violetPrimary, size: 18),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [AppTheme.violetPrimary, Color(0xFF4C1D95)]),
        boxShadow: [
          BoxShadow(
            color: AppTheme.violetPrimary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          _isSignUp ? "CREATE ACCOUNT" : "SIGN IN",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialSection() {
    return Row(
      children: [
        Expanded(child: _socialBtn(Icons.g_mobiledata, "Google")),
        const SizedBox(width: 12),
        Expanded(child: _socialBtn(Icons.apple, "Apple")),
      ],
    );
  }

  Widget _socialBtn(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isSignUp ? "Already a member? " : "New to SplitBrain? ",
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _isSignUp = !_isSignUp),
          child: Text(
            _isSignUp ? "Sign In" : "Sign Up",
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.violetPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ctrl = ref.read(authControllerProvider.notifier);
    try {
      if (_isSignUp) {
        await ctrl.signUp(_email.text.trim(), _password.text, _name.text.trim());

        // بعد إنشاء الحساب: تسجيل خروج وتحويل المستخدم لواجهة تسجيل الدخول مع رسالة واضحة
        await ctrl.signOut();
        // تأكد من مسح بيانات gamification القديمة من الذاكرة لأي حساب سابق
        ref.invalidate(statsRepositoryProvider);
        ref.invalidate(statsProvider);
        if (!mounted) return;
        setState(() {
          _isSignUp = false;
          _password.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account created successfully. Please sign in.',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );
      } else {
        await ctrl.signIn(_email.text.trim(), _password.text);
      }
    } catch (_) {
      // الأخطاء تُدار بالفعل عبر AsyncValue في authController، هنا فقط نتأكد أن UI لا ينهار
    }
  }
}

class ProfessionalMeshPainter extends CustomPainter {
  final double animationValue;
  final bool isSignUp;

  ProfessionalMeshPainter({required this.animationValue, required this.isSignUp});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    final offset1 = Offset(
      size.width * 0.2 + (math.sin(animationValue * 2 * math.pi) * 60),
      size.height * 0.2 + (math.cos(animationValue * 2 * math.pi) * 60),
    );
    canvas.drawCircle(offset1, 280, paint..color = AppTheme.violetPrimary.withOpacity(0.2));

    final offset2 = Offset(
      size.width * (isSignUp ? 0.8 : 0.7) + (math.cos(animationValue * 2 * math.pi) * 80),
      size.height * 0.6 + (math.sin(animationValue * 2 * math.pi) * 50),
    );
    canvas.drawCircle(offset2, 250, paint..color = AppTheme.tealSuccess.withOpacity(0.15));

    final offset3 = Offset(
      size.width * 0.4 + (math.sin(animationValue * math.pi) * 100),
      size.height * 0.9,
    );
    canvas.drawCircle(offset3, 220, paint..color = AppTheme.pinkAlert.withOpacity(0.1));
  }

  @override
  bool shouldRepaint(ProfessionalMeshPainter oldDelegate) => true;
}
