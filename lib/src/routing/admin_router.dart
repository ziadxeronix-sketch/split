import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/firebase_providers.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/admin/presentation/admin_home_screen.dart';

final adminRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/admin',
    refreshListenable: GoRouterRefreshStream(authState.asData?.value == null
        ? ref.read(firebaseAuthProvider).authStateChanges()
        : ref.read(firebaseAuthProvider).authStateChanges()),
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const SignInScreen()),
      GoRoute(path: '/admin', builder: (_, __) => const AdminHomeScreen()),
    ],
    redirect: (context, state) {
      final user = authState.asData?.value;
      final goingLogin = state.matchedLocation == '/login';
      if (user == null) {
        return goingLogin ? null : '/login';
      }
      if (goingLogin) return '/admin';
      return null;
    },
  );
});

/// Minimal refresh helper for GoRouter with streams.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
