import 'package:flutter_test/flutter_test.dart';
import 'package:splitbrain/src/features/quick_input/data/voice_expense_parser.dart';

void main() {
  const parser = VoiceExpenseParser();
  const categories = ['coffee', 'food', 'groceries', 'transport', 'shopping'];

  group('VoiceExpenseParser.parse', () {
    test('detects english food expense', () {
      final result = parser.parse('I spent 120 on food', categories);

      expect(result.amount, 120);
      expect(result.categoryId, 'food');
    });

    test('detects arabic coffee expense', () {
      final result = parser.parse('دفعت 45 قهوة', categories);

      expect(result.amount, 45);
      expect(result.categoryId, 'coffee');
    });

    test('does not return unavailable category', () {
      final result = parser.parse('Spent 30 on coffee', ['food']);

      expect(result.amount, 30);
      expect(result.categoryId, isNull);
    });

    test('supports decimal amounts', () {
      final result = parser.parse('Spent 19.75 on uber', categories);

      expect(result.amount, 19.75);
      expect(result.categoryId, 'transport');
    });
  });
}
