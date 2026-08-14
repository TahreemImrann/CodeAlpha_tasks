import 'package:flutter_test/flutter_test.dart';
import 'package:flash_cards_app/main.dart';

void main() {
  testWidgets('Flashcard app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FlashcardApp());

    // Verify that the title is displayed.
    expect(find.text('Flashcard Quiz'), findsOneWidget);
  });
}