import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/data/transactions_repository.dart';
import '../../../core/firebase_providers.dart';

final transactionsRepositoryProvider =
Provider.autoDispose<TransactionsRepository>((ref) {
  final db = ref.watch(firestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return TransactionsRepository(db, auth);
});

final latestTransactionsProvider =
StreamProvider.autoDispose((ref) {
  final repo = ref.watch(transactionsRepositoryProvider);
  return repo.watchLatest();
});