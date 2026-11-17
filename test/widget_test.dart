import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luma/app.dart';

void main() {
  testWidgets('first launch shows consent before health permissions',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const WellbeingApp());
    await tester.pumpAndSettle();
    expect(find.text('Acepto'), findsOneWidget);
    expect(find.byType(ConsentScreen), findsOneWidget);
  });
}
