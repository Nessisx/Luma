import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma/models/wellbeing_models.dart';
import 'package:luma/services/reflection_messages.dart';
import 'package:luma/screens/insights_screen.dart';
import 'package:luma/widgets/message_deck.dart';
import 'package:luma/theme/app_theme.dart';

CheckInRecord record(DateTime date, double mood, {String note = ''}) =>
    CheckInRecord(
        date: date,
        mood: mood,
        sleepHours: 7,
        activityMinutes: 30,
        socialMinutes: 60,
        energy: 5,
        stress: 4,
        score: 60,
        note: note,
        riskLevel: RiskLevel.stable);
void main() {
  test(
      'daily summaries exclude actions and keep latest actual check-in per date',
      () {
    final now = DateTime(2026, 11, 16, 20);
    final records = dailyCheckIns([
      record(DateTime(2026, 11, 16, 18), 9, note: 'Acción: camera_photo'),
      record(DateTime(2026, 11, 16, 16), 6),
      record(DateTime(2026, 11, 16, 12), 3),
      record(DateTime(2026, 10, 1), 8),
      record(DateTime(2026, 11, 17), 8),
    ], now: now, days: 7);
    expect(records.length, 1);
    expect(records.first.mood, 6);
    expect(reflectionMessages([]).length, greaterThanOrEqualTo(3));
    expect(reflectionMessages(records).any((m) => m.label == 'Comparación'),
        isFalse);
  });
  testWidgets('messages advance and wrap without overflow on small screens',
      (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
            body: SingleChildScrollView(
                child: MessageDeck(messages: reflectionMessages([]))))));
    final first = reflectionMessages([]).first.title;
    expect(find.text(first), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Otro mensaje'));
      await tester.pumpAndSettle();
    }
    expect(find.text(first), findsOneWidget);
  });
  testWidgets('insights period filter changes data and has honest empty state',
      (tester) async {
    final now = DateTime.now();
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
            body: InsightsScreen(
                snapshot: WellbeingSnapshot.initial(),
                insights: [],
                history: [record(now.subtract(const Duration(days: 12)), 6)],
                onRegisterSupportAction: (a, b) {}))));
    expect(find.text('Aún hay páginas por escribir'), findsOneWidget);
    await tester.tap(find.text('Últimos 30 días'));
    await tester.pumpAndSettle();
    expect(find.text('1 día registrado'), findsOneWidget);
  });
}
