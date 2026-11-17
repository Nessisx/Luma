import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma/models/wellbeing_models.dart';
import 'package:luma/screens/check_in_screen.dart';
import 'package:luma/theme/app_theme.dart';

void main() {
  testWidgets(
      'interactive check-in preserves choices between steps and submits values',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    CheckInDraft? saved;
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
            body: CheckInScreen(
          snapshot: WellbeingSnapshot.initial(),
          onSubmit: (draft) {
            saved = draft;
          },
        ))));
    expect(find.byType(Slider), findsNothing);
    await tester.tap(find.text('Muy bien'));
    await tester.pumpAndSettle();
    Future<void> press(String label) async {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    await press('Continuar');
    await press('6 h');
    await press('Continuar');
    expect(find.text('6 h 0 min'), findsOneWidget);
    await press('Atrás');
    expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '6 h'))
            .selected,
        isTrue);
    await press('Continuar');
    await tester.enterText(find.byType(TextField), 'Un paseo tranquilo');
    await press('Guardar check-in');
    expect(saved!.mood, 10);
    expect(saved!.sleepHours, 6);
    expect(saved!.activityMinutes, 45);
    expect(saved!.note, 'Un paseo tranquilo');
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'saving prevents duplicate submissions and retains answers after failure',
      (tester) async {
    final pending = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: CheckInScreen(
      snapshot: WellbeingSnapshot.initial(),
      onSubmit: (_) {
        calls++;
        return pending.future;
      },
    ))));
    for (var i = 0; i < 2; i++) {
      await tester.ensureVisible(find.text('Continuar'));
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
    }
    await tester.enterText(find.byType(TextField), 'Conservar esta nota');
    await tester.ensureVisible(find.text('Guardar check-in'));
    await tester.tap(find.text('Guardar check-in'));
    await tester.pump();
    expect(find.text('Guardando…'), findsOneWidget);
    expect(calls, 1);
    pending.completeError(Exception('offline'));
    await tester.pumpAndSettle();
    expect(find.text('Guardar check-in'), findsOneWidget);
    expect(find.text('Conservar esta nota'), findsOneWidget);
    expect(find.textContaining('No pudimos guardar'), findsOneWidget);
  });
}
