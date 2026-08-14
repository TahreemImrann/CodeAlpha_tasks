import 'package:flutter_test/flutter_test.dart';
import 'package:language_learning_app/main.dart';
void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LanguageLearningApp());

    // Verify app title exists
    expect(find.text('LingoLearn French 🇫🇷'), findsOneWidget);
  });
}