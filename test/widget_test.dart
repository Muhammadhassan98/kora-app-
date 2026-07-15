import 'package:flutter_test/flutter_test.dart';
import 'package:fantkora/main.dart';

void main() {
  testWidgets('Splash page loading smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FantKoraApp());
    await tester.pump(); // let GoRouter build the initial route

    // Verify that the brand name is found.
    expect(find.text('FantKora'), findsOneWidget);

    // Let the splash screen timer run out so the test cleans up cleanly.
    await tester.pump(const Duration(seconds: 2));
  });
}
