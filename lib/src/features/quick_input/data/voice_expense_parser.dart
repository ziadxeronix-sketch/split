import 'dart:math' as math;

import '../../categories/domain/category_model.dart';
import '../domain/voice_expense_parse_result.dart';

class VoiceExpenseParser {
  VoiceExpenseParseResult parse({
    required String transcript,
    required List<ExpenseCategory> categories,
  }) {
    final normalized = _normalize(transcript);
    final amount = _extractAmount(normalized);

    final categoryScores = <String, double>{};
    final scoreReasons = <String, List<String>>{};

    for (final category in categories) {
      final localReasons = <String>[];
      final score = _scoreCategory(category, normalized, localReasons);
      if (score > 0) {
        categoryScores[category.id] = score;
        scoreReasons[category.id] = localReasons;
      }
    }

    String? categoryId;
    double confidence = 0;
    var reason = 'No strong category signal found.';

    if (categoryScores.isNotEmpty) {
      final sorted = categoryScores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final best = sorted.first;
      final runnerUp = sorted.length > 1 ? sorted[1].value : 0.0;

      categoryId = best.key;
      confidence =
          (best.value / math.max(best.value + runnerUp, 1)).clamp(0.35, 0.98);

      final bestReasons = scoreReasons[best.key] ?? <String>[];
      reason = bestReasons.isEmpty
          ? 'Matched category ${best.key} with score ${best.value.toStringAsFixed(1)}'
          : '${bestReasons.join(' • ')} • score ${best.value.toStringAsFixed(1)}';
    }

    if (amount != null && confidence == 0 && categoryId != null) {
      confidence = 0.62;
    } else if (amount != null && categoryId == null) {
      confidence = 0.40;
      reason = 'Amount found, but category stayed uncertain.';
    }

    return VoiceExpenseParseResult(
      transcript: transcript.trim(),
      amount: amount,
      categoryId: categoryId,
      confidence: confidence,
      reason: reason,
    );
  }

  double _scoreCategory(
    ExpenseCategory category,
    String normalized,
    List<String> reasons,
  ) {
    var score = 0.0;

    final categoryId = _normalize(category.id);
    final categoryName = _normalize(category.name);
    final categoryIcon = _normalize(category.icon);

    final aliases = _aliasesFor(category);

    for (final token in aliases) {
      final normalizedToken = _normalize(token).trim();
      if (normalizedToken.isEmpty) continue;

      if (_containsPhrase(normalized, normalizedToken)) {
        final tokenScore = normalizedToken.contains(' ') ? 3.0 : 2.2;
        score += tokenScore;
        reasons.add('Matched "$normalizedToken"');
      }
    }

    if (_containsPhrase(normalized, categoryId.trim())) {
      score += 2.8;
      reasons.add('Matched category id');
    }

    if (_containsPhrase(normalized, categoryName.trim())) {
      score += 2.6;
      reasons.add('Matched category name');
    }

    if (_containsPhrase(normalized, categoryIcon.trim())) {
      score += 1.2;
      reasons.add('Matched category icon');
    }

    final words = normalized.trim().split(RegExp(r'\s+'));
    final idWords = categoryId.trim().split(RegExp(r'[_\-\s]+'));
    final nameWords = categoryName.trim().split(RegExp(r'[_\-\s]+'));

    for (final word in {...idWords, ...nameWords}) {
      final normalizedWord = _normalize(word).trim();
      if (normalizedWord.length < 3) continue;
      if (words.contains(normalizedWord)) {
        score += 0.9;
        reasons.add('Matched word "$normalizedWord"');
      }
    }

    return score;
  }

  List<String> _aliasesFor(ExpenseCategory category) {
    final categoryId = _normalize(category.id).trim();
    final categoryName = _normalize(category.name).trim();
    final categoryIcon = _normalize(category.icon).trim();
    final descriptor = '$categoryId $categoryName $categoryIcon';

    final base = <String>{
      category.id.toLowerCase(),
      category.name.toLowerCase(),
      category.icon.toLowerCase(),
      categoryId,
      categoryName,
      categoryIcon,
    };

    bool hasAny(List<String> terms) {
      return terms.any((term) =>
          _containsPhrase(' $descriptor ', _normalize(term).trim()));
    }

    final semanticGroups = <List<String>>[
      [
        'food', 'foods', 'meal', 'meals', 'lunch', 'dinner', 'breakfast',
        'brunch', 'restaurant', 'restaurants', 'snack', 'snacks', 'burger',
        'pizza', 'sandwich', 'eat', 'eating', 'dining', 'مطعم', 'مطاعم',
        'اكل', 'أكل', 'اكله', 'وجبه', 'وجبة', 'فطار', 'افطار', 'غدا',
        'غداء', 'عشا', 'عشاء',
      ],
      [
        'coffee', 'cafe', 'cafes', 'latte', 'espresso', 'tea', 'starbucks',
        'drink', 'drinks', 'كوفي', 'قهوه', 'قهوة', 'نسكافيه', 'شاي',
        'مشروب', 'مشروبات',
      ],
      [
        'groceries', 'grocery', 'supermarket', 'market', 'carrefour', 'bim',
        'spinneys', 'hyper', 'household', 'home supplies', 'بقاله', 'بقالة',
        'سوبر ماركت', 'ماركت', 'مشتريات البيت', 'طلبات البيت',
      ],
      [
        'transport', 'transportation', 'uber', 'taxi', 'bus', 'metro',
        'train', 'fuel', 'gas', 'petrol', 'parking', 'ride', 'rides',
        'commute', 'مواصلات', 'مواصله', 'اوبر', 'أوبر', 'تاكسي', 'بنزين',
        'جاز', 'ركنه', 'ركنة', 'مترو',
      ],
      [
        'shopping', 'shop', 'mall', 'amazon', 'noon', 'clothes', 'fashion',
        'purchase', 'buy', 'bought', 'تسوق', 'شراء', 'شوبنج', 'هدوم', 'ملابس',
      ],
      [
        'bill', 'bills', 'rent', 'electricity', 'water', 'internet', 'wifi',
        'mobile', 'phone', 'subscription', 'invoice', 'فاتوره', 'فاتورة',
        'إيجار', 'ايجار', 'كهربا', 'كهرباء', 'مياه', 'نت', 'انترنت', 'إنترنت',
        'موبايل',
      ],
      [
        'fun', 'game', 'games', 'movie', 'cinema', 'netflix', 'playstation',
        'entertainment', 'spotify', 'outing', 'ترفيه', 'فيلم', 'سينما',
        'لعب', 'خروجه', 'خروجة',
      ],
      [
        'health', 'doctor', 'clinic', 'hospital', 'medicine', 'pharmacy',
        'medical', 'dentist', 'صيدليه', 'صيدلية', 'دكتور', 'مستشفى', 'دواء',
        'علاج', 'طبيب',
      ],
      [
        'other', 'misc', 'miscellaneous', 'unknown', 'اخرى', 'أخرى',
      ],
    ];

    for (final group in semanticGroups) {
      if (hasAny(group)) {
        base.addAll(group);
      }
    }

    if (descriptor.contains('food') ||
        descriptor.contains('meal') ||
        descriptor.contains('restaurant') ||
        descriptor.contains('اكل') ||
        descriptor.contains('أكل') ||
        descriptor.contains('مطعم')) {
      base.addAll([
        'food', 'meal', 'restaurant', 'lunch', 'dinner', 'breakfast',
        'اكل', 'أكل', 'مطعم', 'وجبه', 'وجبة',
      ]);
    }

    if (descriptor.contains('drink') ||
        descriptor.contains('coffee') ||
        descriptor.contains('cafe') ||
        descriptor.contains('قهوه') ||
        descriptor.contains('قهوة') ||
        descriptor.contains('كوفي')) {
      base.addAll([
        'coffee', 'cafe', 'tea', 'drink', 'drinks', 'قهوة', 'قهوه', 'كوفي', 'شاي',
      ]);
    }

    base.removeWhere((e) => _normalize(e).trim().isEmpty);
    return base.toList(growable: false);
  }

  bool _containsPhrase(String text, String phrase) {
    final normalizedText = _normalize(text);
    final normalizedPhrase = _normalize(phrase).trim();

    if (normalizedPhrase.isEmpty) return false;
    if (normalizedText.trim() == normalizedPhrase) return true;

    return normalizedText.contains(' $normalizedPhrase ');
  }

  double? _extractAmount(String normalized) {
    final blocked = <String>{'day', 'week', 'month'};
    final matches = RegExp(r'(?<!\d)(\d{1,4}(?:[\.,]\d{1,2})?)(?!\d)')
        .allMatches(normalized)
        .toList();

    if (matches.isEmpty) return null;

    final candidates = <double>[];

    for (final match in matches) {
      final raw = match.group(1)!;
      final value = double.tryParse(raw.replaceAll(',', '.'));
      if (value == null || value <= 0) continue;

      final start = math.max(0, match.start - 24);
      final end = math.min(normalized.length, match.end + 24);
      final context = normalized.substring(start, end);

      final hasMoneyCue = RegExp(
        r'(spent|spend|pay|paid|cost|for|egp|usd|dollar|dollars|euro|pound|pounds|جنيه|ج|دولار|يورو|دفعت|صرفت|ب|بـ)',
      ).hasMatch(context);

      final hasDateCue = RegExp(r'(\b\d{1,2}[/-]\d{1,2}\b)').hasMatch(context);
      final nextWord = normalized.substring(match.end).trimLeft().split(' ').firstOrNull ?? '';

      if (blocked.contains(nextWord)) continue;
      if (hasDateCue && !hasMoneyCue) continue;

      candidates.add(hasMoneyCue ? value + 0.01 : value);
    }

    if (candidates.isEmpty) return null;

    candidates.sort((a, b) => b.compareTo(a));
    final picked = candidates.first;
    return double.parse(picked.toStringAsFixed(2));
  }

  String _normalize(String input) {
    var result = input.toLowerCase();

    const arabicDigits = {
      '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
      '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
      '٫': '.', '٬': ',',
    };

    arabicDigits.forEach((key, value) {
      result = result.replaceAll(key, value);
    });

    result = result
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');

    result = result.replaceAll(RegExp(r'[^\p{L}\p{N}\s\.,]', unicode: true), ' ');
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim();

    return ' $result ';
  }
}

extension on List<String> {
  String? get firstOrNull => isEmpty ? null : first;
}
