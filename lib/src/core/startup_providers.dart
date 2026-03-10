import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseReadyProvider = Provider<bool>((ref) => false);
final startupErrorProvider = Provider<String?>((ref) => null);
