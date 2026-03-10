import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:splitbrain/src/features/auth/presentation/sign_in_screen.dart';

void main() {
  Widget buildTestApp() {
    return const ProviderScope(
      child: MaterialApp(
        home: SignInScreen(),
      ),
    );
  }

  testWidgets('renders sign in screen correctly', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.byType(Form), findsOneWidget);
    expect(find.byKey(const Key('emailField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);
    expect(find.byKey(const Key('submitAuthButton')), findsOneWidget);
    expect(find.byKey(const Key('toggleAuthModeButton')), findsOneWidget);
  });

  testWidgets('submit button can be tapped on sign in screen', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump(const Duration(milliseconds: 800));

    final submitButton = find.byKey(const Key('submitAuthButton'));
    expect(submitButton, findsOneWidget);

    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(Form), findsOneWidget);
    expect(find.byKey(const Key('emailField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);
  });

  testWidgets('switches to sign up and shows full name field', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump(const Duration(milliseconds: 800));

    final toggleButton = find.byKey(const Key('toggleAuthModeButton'));
    expect(toggleButton, findsOneWidget);

    await tester.ensureVisible(toggleButton);
    await tester.tap(toggleButton, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('fullNameField')), findsOneWidget);
    expect(find.byKey(const Key('emailField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
  });

  testWidgets('accepts text entry in sign up mode', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump(const Duration(milliseconds: 800));

    await tester.tap(find.byKey(const Key('toggleAuthModeButton')));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.enterText(find.byKey(const Key('fullNameField')), 'Ziad Mohamed');
    await tester.enterText(find.byKey(const Key('emailField')), 'test@test.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'password1');
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Ziad Mohamed'), findsOneWidget);
    expect(find.text('test@test.com'), findsOneWidget);
    expect(find.text('password1'), findsOneWidget);
  });
}