class AuthValidators {
  static String? validateFullName(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Full name is required';
    if (text.length < 3) return 'Full name must be at least 3 characters';
    final cleaned = text.replaceAll(RegExp(r"[\s\-']"), '');
    if (!RegExp(r'^[\p{L}]+$', unicode: true).hasMatch(cleaned)) {
      return 'Full name can only contain letters and spaces';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(text)) return 'Enter a valid email address';
    return null;
  }

  static String? validatePassword(String? value, {bool isSignUp = false}) {
    final text = value ?? '';
    if (text.isEmpty) return 'Password is required';
    if (text.length < 8) return 'Password must be at least 8 characters';
    if (isSignUp) {
      final hasLetter = RegExp(r'[A-Za-z]').hasMatch(text);
      final hasNumber = RegExp(r'\d').hasMatch(text);
      if (!hasLetter || !hasNumber) {
        return 'Password must contain at least one letter and one number';
      }
    }
    return null;
  }
}
