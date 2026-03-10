import 'package:flutter_test/flutter_test.dart';
import 'package:splitbrain/src/features/auth/domain/auth_validators.dart';

void main() {
  group('AuthValidators.validateFullName', () {
    test('rejects empty names', () {
      expect(AuthValidators.validateFullName(''), 'Full name is required');
    });

    test('rejects short names', () {
      expect(
        AuthValidators.validateFullName('Zi'),
        'Full name must be at least 3 characters',
      );
    });

    test('accepts valid names', () {
      expect(AuthValidators.validateFullName('Ziad Mohamed'), isNull);
      expect(AuthValidators.validateFullName('زياد محمد'), isNull);
    });
  });

  group('AuthValidators.validateEmail', () {
    test('rejects malformed emails', () {
      expect(
        AuthValidators.validateEmail('not-an-email'),
        'Enter a valid email address',
      );
    });

    test('accepts valid emails', () {
      expect(AuthValidators.validateEmail('ziad@example.com'), isNull);
    });
  });

  group('AuthValidators.validatePassword', () {
    test('requires minimum length', () {
      expect(
        AuthValidators.validatePassword('1234567'),
        'Password must be at least 8 characters',
      );
    });

    test('requires letters and numbers on sign up', () {
      expect(
        AuthValidators.validatePassword('password', isSignUp: true),
        'Password must contain at least one letter and one number',
      );
      expect(
        AuthValidators.validatePassword('12345678', isSignUp: true),
        'Password must contain at least one letter and one number',
      );
    });

    test('accepts strong sign up password', () {
      expect(
        AuthValidators.validatePassword('Pass1234', isSignUp: true),
        isNull,
      );
    });
  });
}
