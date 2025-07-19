import 'package:flutter_test/flutter_test.dart';

import 'package:quiz_app/main.dart';
import 'package:quiz_app/screens/splash_screen.dart'; // ✅ Add this

void main() {
  testWidgets('App renders splash screen on startup', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // SplashScreen should show first during Firebase auth init
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
