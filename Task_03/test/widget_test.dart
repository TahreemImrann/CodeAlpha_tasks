import 'package:flutter_test/flutter_test.dart';
import 'package:random_quote_generator/main.dart';

void main() {
  testWidgets('Random quote generator app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const QuoteGeneratorApp());

    // Verify app title exists
    expect(find.text('Daily Inspiration'), findsOneWidget);
  });
}