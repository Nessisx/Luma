import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma/models/wellbeing_models.dart';
import 'package:luma/services/check_in_assessment.dart';
import 'package:luma/screens/home_screen.dart';
import 'package:luma/theme/app_theme.dart';

CheckInDraft draft(
        {double mood = 8,
        double sleep = 7.5,
        double activity = 60,
        double social = 30,
        double energy = 7,
        double stress = 4}) =>
    CheckInDraft(
        mood: mood,
        sleepHours: sleep,
        activityMinutes: activity,
        socialMinutes: social,
        energy: energy,
        stress: stress,
        note: '');
void main() {
  test(
      'reported example has consistent favorable metrics, message and label on first check-in',
      () {
    final result = CheckInAssessment(draft());
    expect(result.sleepScore, 100);
    expect(result.activityScore, 100);
    expect(result.socialScore, 100);
    expect(result.stressLoad, 40);
    expect(result.overallScore, closeTo(85.5, .001));
    expect(result.riskLevel, RiskLevel.stable);
    expect(result.message, contains('buen equilibrio'));
    expect(result.message, isNot(contains('señales suaves')));
    expect(CheckInAssessment(draft()).overallScore, result.overallScore);
  });
  test('app reference bands do not demand excessive sleep or activity', () {
    for (final hours in [7.0, 7.5, 8.0, 9.0]) {
      expect(CheckInAssessment(draft(sleep: hours)).sleepScore, 100);
    }
    expect(CheckInAssessment(draft(activity: 240)).activityScore, 100);
    expect(CheckInAssessment(draft(social: 0)).socialScore, 100);
    expect(CheckInAssessment(draft(sleep: 4)).sleepScore, lessThan(100));
  });
  test(
      'more reported stress increases load and reduces score; distress is not hidden',
      () {
    final calm = CheckInAssessment(draft(stress: 2));
    final stressed = CheckInAssessment(draft(stress: 9));
    expect(stressed.stressLoad, greaterThan(calm.stressLoad));
    expect(stressed.overallScore, lessThan(calm.overallScore));
    expect(stressed.riskLevel, isNot(RiskLevel.stable));
    expect(CheckInAssessment(draft(mood: 2)).riskLevel, RiskLevel.low);
    expect(CheckInAssessment(draft(energy: 2)).message,
        contains('2/10 de energía'));
  });
  testWidgets(
      'home renders favorable first check-in as stable on a small phone',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final a = CheckInAssessment(draft());
    final snapshot = WellbeingSnapshot.initial().copyWith(
        overallScore: a.overallScore,
        sleepScore: a.sleepScore,
        activityScore: a.activityScore,
        socialScore: a.socialScore,
        stressLoad: a.stressLoad,
        moodScore: 80,
        message: a.message,
        riskLevel: a.riskLevel,
        supportTitle: a.supportTitle,
        supportBody: a.supportBody);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
            body: HomeScreen(
                snapshot: snapshot,
                insights: a.insights,
                history: [
                  CheckInRecord(
                      date: DateTime.now(),
                      mood: 8,
                      sleepHours: 7.5,
                      activityMinutes: 60,
                      socialMinutes: 30,
                      energy: 7,
                      stress: 4,
                      score: a.overallScore,
                      note: '',
                      riskLevel: a.riskLevel)
                ],
                onOpenCheckIn: () {},
                onOpenCamera: () {},
                onRegisterSupportAction: (a, b) {}))));
    await tester.pumpAndSettle();
    expect(find.text('Estable'), findsOneWidget);
    expect(find.text('Vigilar'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
