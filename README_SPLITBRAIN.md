# SplitBrain (Flutter + Firebase) — Milestone 1 Foundation

This repo contains the **Milestone 1 (Project Setup & Technical Foundation)** deliverables for SplitBrain:

## Included

- Clean architecture (feature-first) + Riverpod
- GoRouter routing with auth redirect
- Theme (light/dark) + premium UI defaults
- Firebase Auth (email/password)
- Firestore: transactions, categories, budgets, stats (streaks/badges)
- Dashboard: remaining/spent/budget for Day/Week/Month (real-time)
- Categories: default seeding + CRUD
- Quick input:
  - Voice input (speech-to-text) → detects amount + category keywords
  - Receipt scan (ML Kit OCR) → extracts total estimate
- Smart local alerts (low / over daily budget)
- Gamification foundation: streak + basic badges
- Admin panel foundation (Flutter Web entrypoint)

## Run

```bash
flutter pub get
flutter run
```

### Run Admin Panel (Flutter Web)

```bash
flutter run -d chrome -t lib/admin_main.dart
```

> To access admin panel, set your Firestore user document field: `role = "admin"`.

## Firestore structure (main)

- `users/{uid}` user profile
- `users/{uid}/categories/{catId}`
- `users/{uid}/budgets/{budgetId}`
- `users/{uid}/transactions/{txId}`
- `users/{uid}/meta/stats` (streaks/badges)

## Notes

- RevenueCat paywall + entitlement gating is scaffolded (settings → Subscription). Wiring live purchases requires your RevenueCat project keys.
