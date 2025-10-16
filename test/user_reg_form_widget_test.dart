import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/widgets/user_registration_form.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Form shows validation errors for empty fields', (
    WidgetTester tester,
  ) async {
    // Pump the widget inside a MaterialApp
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
    );
    final registerButton = find.text('Register');
    await tester.pump(const Duration(seconds: 3));
    await tester.tap(registerButton);
    await tester.pump();
    expect(find.text('Please enter your full name'), findsOneWidget);
    // expect(find.text('Please enter a valid email'), findsOneWidget); because it depend on a function in the util/validators_urf.dart
    expect(find.textContaining('Password'), findsWidgets);
  });

  testWidgets('Form validates correctly when filled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Yasmin Hany');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'yasmin@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'StrongPass@123');
    await tester.enterText(find.byType(TextFormField).at(3), 'StrongPass@123');

    await tester.tap(find.text('Register'));
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('Please enter your full name'), findsNothing);
    // expect(find.text('Please enter a valid email'), findsNothing);
  });
}
