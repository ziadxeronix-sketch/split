import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase_providers.dart';
import '../data/stats_repository.dart';
import '../domain/stats_model.dart';

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepository(ref.watch(firestoreProvider), ref.watch(firebaseAuthProvider));
});

final statsProvider = StreamProvider<UserStats>((ref) {
  return ref.watch(statsRepositoryProvider).watch();
});
