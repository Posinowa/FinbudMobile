import 'package:flutter_test/flutter_test.dart';
import 'package:finbud_app/main.dart';

void main() {
  testWidgets('App should start', (WidgetTester tester) async {
    await tester.pumpWidget(const FinbudApp());
    expect(find.text('Finbud'), findsOneWidget);
  });
}