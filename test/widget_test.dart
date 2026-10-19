import 'package:flutter_test/flutter_test.dart';
import 'package:shanika_constructions/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ShanikaApp());
    expect(find.text('Shanika Constructions'), findsWidgets);
  });
}
