class VoiceExpenseParseResult {
  const VoiceExpenseParseResult({
    required this.transcript,
    required this.amount,
    required this.categoryId,
    required this.confidence,
    required this.reason,
  });

  final String transcript;
  final double? amount;
  final String? categoryId;
  final double confidence;
  final String reason;

  bool get hasAmount => amount != null && amount! > 0;
  bool get hasCategory => categoryId != null && categoryId!.isNotEmpty;
}
