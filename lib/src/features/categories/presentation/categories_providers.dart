import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase_providers.dart';
import '../data/categories_repository.dart';
import '../domain/category_model.dart';

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepository(ref.watch(firestoreProvider), ref.watch(firebaseAuthProvider));
});

final categoriesProvider = StreamProvider<List<ExpenseCategory>>((ref) {
  return ref.watch(categoriesRepositoryProvider).watchAll();
});
