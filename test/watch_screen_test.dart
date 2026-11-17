import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma/models/wellbeing_models.dart';
import 'package:luma/screens/home_screen.dart';
import 'package:luma/screens/watch_screen.dart';
import 'package:luma/theme/app_theme.dart';

void main() {
  testWidgets('home keeps food optional and exposes watch without history',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var openedFood = false;
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
            body: HomeScreen(
          snapshot: WellbeingSnapshot.initial(),
          insights: const [],
          history: const [],
          onOpenCheckIn: () {},
          onRegisterSupportAction: (action, details) {},
          onOpenCamera: () => openedFood = true,
        ))));
    expect(find.text('Mi reloj y mi salud'), findsOneWidget);
    final food = find.text('Explorar mi comida');
    await tester.ensureVisible(food);
    await tester.tap(food);
    expect(openedFood, isTrue);
  });
  testWidgets(
      'watch screen explains unsupported platform without fake readings',
      (tester) async {
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light(), home: const WatchScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Health Connect no está disponible'), findsOneWidget);
    expect(find.text('Sin permiso'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Sesiones de sueño'), 200);
    expect(find.text('Sesiones de sueño'), findsOneWidget);
    expect(find.textContaining('lpm'), findsNothing);
  });
}
