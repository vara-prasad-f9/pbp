import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pbp/main.dart';

void main() {
  testWidgets('Splash screen shows app name and logo', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PBPHousyApp());

    // Verify that the app name is shown
    expect(find.text('PBP Housy'), findsOneWidget);
    
    // Verify that the tagline is shown
    expect(find.text('Play & Win Big!'), findsOneWidget);
    
    // Verify that a loading indicator is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
