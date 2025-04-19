import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neotopia/main.dart';

void main() {
  testWidgets('Login screen displays correctly', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(NeoflexGame());

    // Verify that the Neoflex logo is displayed.
    expect(find.byType(Image), findsOneWidget);

    // Verify that the email and password fields are displayed.
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Пароль'), findsOneWidget);

    // Verify that the login button is displayed.
    expect(find.widgetWithText(ElevatedButton, 'Войти'), findsOneWidget);

    // Verify that the register button is displayed.
    expect(find.widgetWithText(TextButton, 'Нет аккаунта? Зарегистрируйтесь'),
        findsOneWidget);
  });

  testWidgets('Navigate to register screen', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(NeoflexGame());

    // Tap the register button.
    await tester.tap(
        find.widgetWithText(TextButton, 'Нет аккаунта? Зарегистрируйтесь'));
    await tester.pumpAndSettle();

    // Verify that the register screen is displayed.
    expect(find.widgetWithText(TextField, 'Логин'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Зарегистрироваться'),
        findsOneWidget);
  });
}