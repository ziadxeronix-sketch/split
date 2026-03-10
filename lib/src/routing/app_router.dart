import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/firebase_providers.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/budget/presentation/budget_screen.dart';
import '../features/categories/presentation/categories_screen.dart';
import '../features/home/presentation/home_shell.dart';
import '../features/splash/splash_screen.dart';
import '../features/subscription/presentation/subscription_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/sign-in', builder: (_, __) => const SignInScreen()),
      GoRoute(
        path: '/app',
        builder: (_, __) => const HomeShell(),
        routes: [
          GoRoute(path: 'budget', builder: (_, __) => const BudgetScreen()),
          GoRoute(path: 'categories', builder: (_, __) => const CategoriesScreen()),
          GoRoute(path: 'subscription', builder: (_, __) => const SubscriptionScreen()),
        ],
      ),
    ],
    redirect: (context, state) {
      if (authAsync.isLoading) return state.matchedLocation == '/splash' ? null : '/splash';
      if (authAsync.hasError) return '/sign-in';

      final user = authAsync.value;
      final isAuthed = user != null;
      final loc = state.matchedLocation;

      if (!isAuthed) {
        return (loc == '/sign-in') ? null : '/sign-in';
      }

      if (loc == '/sign-in' || loc == '/splash') return '/app';
      return null;
    },
  );
});
