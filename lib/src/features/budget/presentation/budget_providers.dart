import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase_providers.dart';
import '../data/budget_repository.dart';
import '../domain/budget_model.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(ref.watch(firestoreProvider), ref.watch(firebaseAuthProvider));
});

final activeBudgetProvider = StreamProvider<Budget?>((ref) {
  return ref.watch(budgetRepositoryProvider).watchActive();
});
