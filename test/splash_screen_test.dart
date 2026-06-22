import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:allawi_pdf_reader/main.dart';

void main() {
  testWidgets('App boots and shows the splash screen first', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AllawiPdfReaderApp()));

    // Splash screen shows the app name before navigating to Home.
    expect(find.text('ALLAWI PDF Reader'), findsOneWidget);
    expect(find.text('Read PDFs Faster, Smarter, Better.'), findsOneWidget);

    // Avoid pumping past the splash timer here — that triggers real
    // navigation plus platform-channel calls (SharedPreferences, sqflite)
    // that aren't available in the plain widget-test environment.
  });

  testWidgets('Splash screen contains a progress indicator', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AllawiPdfReaderApp()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
