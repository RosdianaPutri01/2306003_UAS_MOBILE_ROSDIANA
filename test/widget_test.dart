import 'package:flutter_test/flutter_test.dart';
import 'package:rosdiana_uas_mobile/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });
}