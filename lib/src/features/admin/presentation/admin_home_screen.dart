import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/firebase_providers.dart';
import '../../../theme/app_theme.dart';

final _usersQueryProvider = StreamProvider.autoDispose<List<QueryDocumentSnapshot<Map<String, dynamic>>>>((ref) {
  final db = ref.watch(firestoreProvider);
  return db.collection('users').orderBy('createdAt', descending: true).limit(100).snapshots().map((s) => s.docs);
});

final _isAdminProvider = StreamProvider.autoDispose<bool>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final db = ref.watch(firestoreProvider);
  final uid = auth.currentUser?.uid;
  if (uid == null) return Stream.value(false);
  return db.collection('users').doc(uid).snapshots().map((d) {
    final role = (d.data() ?? {})['role'];
    return role == 'admin';
  });
});

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(_isAdminProvider);

    return Scaffold(
      backgroundColor: AppTheme.whiteMain,
      appBar: AppBar(
        title: Text(
          'Admin Console',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 24),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Sign out',
              onPressed: () async => ref.read(firebaseAuthProvider).signOut(),
              icon: const Icon(Icons.logout_rounded, color: AppTheme.pinkAlert),
            ),
          ),
        ],
      ),
      body: isAdmin.when(
        data: (ok) => ok ? const _UsersList() : const _AccessDenied(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed: $e')),
      ),
    );
  }
}

class _AccessDenied extends StatelessWidget {
  const _AccessDenied();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.pinkAlert.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_person_rounded, size: 64, color: AppTheme.pinkAlert),
              ),
              const SizedBox(height: 32),
              Text(
                'Access Restricted',
                style: GoogleFonts.nunito(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This area is for administrators only. Please contact support if you believe this is an error.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: AppTheme.textMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsersList extends ConsumerWidget {
  const _UsersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(_usersQueryProvider);
    return users.when(
      data: (docs) {
        if (docs.isEmpty) {
          return Center(
            child: Text(
              'No users found',
              style: GoogleFonts.nunito(color: AppTheme.textMuted),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (_, i) {
            final d = docs[i].data();
            final email = (d['email'] ?? '') as String;
            final role = (d['role'] ?? 'user') as String;
            final createdAt = (d['createdAt'] is Timestamp)
                ? (d['createdAt'] as Timestamp).toDate()
                : DateTime.now();

            final isAdmin = role == 'admin';

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.greySecondary,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isAdmin ? AppTheme.violetPrimary : AppTheme.tealSuccess.withOpacity(0.1),
                    child: Text(
                      email.isNotEmpty ? email[0].toUpperCase() : '?',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        color: isAdmin ? Colors.white : AppTheme.tealSuccess,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          email.isEmpty ? docs[i].id : email,
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Joined ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                          style: GoogleFonts.nunito(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAdmin ? AppTheme.violetPrimary.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isAdmin ? AppTheme.violetPrimary.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      role.toUpperCase(),
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isAdmin ? AppTheme.violetPrimary : AppTheme.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed: $e')),
    );
  }
}
