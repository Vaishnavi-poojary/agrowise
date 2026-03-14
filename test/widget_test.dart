import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrowise/main.dart';

void main() {
  testWidgets('AgroWise app loads correctly', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const AgroWiseApp());

    // Verify that the app name appears
    expect(find.text('AGROWISE'), findsOneWidget);
  });
}
