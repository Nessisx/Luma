import 'package:flutter/material.dart';

import 'models/wellbeing_models.dart';
import 'screens/check_in_screen.dart';
import 'screens/home_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';
import 'services/check_in_assessment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';

class WellbeingApp extends StatelessWidget {
  const WellbeingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Luma',
      theme: AppTheme.light(),
      home: const SplashDecider(),
    );
  }
}

class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key});

  @override
  State<SplashDecider> createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> {
  bool _initialized = false;
  bool _seen = false;
  bool _consentGiven = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seenSplash') ?? false;
    final consent = prefs.getBool('consentGiven') ?? false;
    setState(() {
      _initialized = true;
      _seen = seen;
      _consentGiven = consent;
    });
  }

  void _completeSplash() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenSplash', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WellbeingShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_consentGiven) {
      return ConsentScreen(onAccepted: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('consentGiven', true);
        setState(() => _consentGiven = true);
      });
    }

    if (_seen) return const WellbeingShell();

    return SplashScreen(onContinue: _completeSplash);
  }
}

class ConsentScreen extends StatelessWidget {
  final VoidCallback onAccepted;

  const ConsentScreen({required this.onAccepted, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo.png', width: 120, height: 120),
                const SizedBox(height: 18),
                Text(
                  'Antes de continuar, necesitamos tu consentimiento para procesar datos localmente y, si das permiso, leer métricas de Health Connect.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 18),
                Text(
                  'Los datos se procesan en tu dispositivo. No subimos información sin pedirlo explícitamente.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onAccepted,
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                    child: Text('Acepto'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const SplashScreen({required this.onContinue, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo.png', width: 160, height: 160),
                const SizedBox(height: 18),
                Text(
                  'Bienvenido — mira tu pulso diario con suavidad',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onContinue,
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                    child: Text('Entrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WellbeingShell extends StatefulWidget {
  const WellbeingShell({super.key});

  @override
  State<WellbeingShell> createState() => _WellbeingShellState();
}

class _WellbeingShellState extends State<WellbeingShell> {
  int _selectedIndex = 0;
  WellbeingSnapshot _snapshot = WellbeingSnapshot.initial();
  final List<CheckInRecord> _history = [];
  final List<InsightItem> _insights = [];
  bool _notificationsEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _initPreferencesAndNotifications();
  }

  Future<void> _initPreferencesAndNotifications() async {
    await NotificationService.init();
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notificationsEnabled') ?? false;
    final hour = prefs.getInt('reminderHour') ?? _reminderTime.hour;
    final minute = prefs.getInt('reminderMinute') ?? _reminderTime.minute;
    setState(() {
      _notificationsEnabled = enabled;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    });

    if (_notificationsEnabled) {
      await _scheduleDailyReminder();
    }
  }

  Future<void> _persistNotificationPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setInt('reminderHour', _reminderTime.hour);
    await prefs.setInt('reminderMinute', _reminderTime.minute);
  }

  Future<void> _clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('seenSplash');
    await prefs.remove('consentGiven');
    await prefs.remove('notificationsEnabled');
    await prefs.remove('reminderHour');
    await prefs.remove('reminderMinute');

    await _cancelReminder();

    setState(() {
      _snapshot = WellbeingSnapshot.initial();
      _history.clear();
      _insights.clear();
      _notificationsEnabled = false;
      _reminderTime = const TimeOfDay(hour: 20, minute: 0);
    });
  }

  Future<void> _scheduleDailyReminder() async {
    final scheduled = NotificationService.nextInstanceOfTime(
        _reminderTime.hour, _reminderTime.minute);
    await NotificationService.scheduleDaily(
      id: 0,
      title: 'Recordatorio amable',
      body: '¿Cómo va tu día? Un check-in rápido ayuda a mantener el pulso.',
      scheduledDate: scheduled,
    );
  }

  Future<void> _cancelReminder() async {
    await NotificationService.cancel(0);
  }

  Future<void> _submitCheckIn(CheckInDraft input) async {
    final assessment = CheckInAssessment(input);
    final draft = assessment.draft;
    setState(() {
      _snapshot = _snapshot.copyWith(
        overallScore: assessment.overallScore,
        sleepScore: assessment.sleepScore,
        activityScore: assessment.activityScore,
        socialScore: assessment.socialScore,
        stressLoad: assessment.stressLoad,
        moodScore: draft.mood * 10,
        message: assessment.message,
        riskLevel: assessment.riskLevel,
        supportTitle: assessment.supportTitle,
        supportBody: assessment.supportBody,
        trend: [..._snapshot.trend, assessment.overallScore]
            .reversed
            .take(7)
            .toList()
            .reversed
            .toList(),
      );
      _history.insert(
          0,
          CheckInRecord(
            date: DateTime.now(),
            mood: draft.mood,
            sleepHours: draft.sleepHours,
            activityMinutes: draft.activityMinutes,
            socialMinutes: draft.socialMinutes,
            energy: draft.energy,
            stress: draft.stress,
            score: assessment.overallScore,
            note: draft.note,
            riskLevel: assessment.riskLevel,
          ));
      if (_history.length > 30) _history.removeLast();
      _insights
        ..clear()
        ..addAll(assessment.insights);
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        snapshot: _snapshot,
        insights: _insights,
        history: _history,
        onOpenCheckIn: () => setState(() => _selectedIndex = 1),
        onRegisterSupportAction: _registerSupportAction,
        onOpenCamera: _openFoodPhoto,
      ),
      CheckInScreen(
        snapshot: _snapshot,
        onSubmit: _submitCheckIn,
      ),
      InsightsScreen(
        snapshot: _snapshot,
        insights: _insights,
        history: _history,
        onRegisterSupportAction: _registerSupportAction,
      ),
      SettingsScreen(
        snapshot: _snapshot,
        notificationsEnabled: _notificationsEnabled,
        reminderTime: _reminderTime,
        onNotificationsChanged: (value) async {
          setState(() => _notificationsEnabled = value);
          if (_notificationsEnabled) {
            await _scheduleDailyReminder();
          } else {
            await _cancelReminder();
          }
          await _persistNotificationPrefs();
        },
        onReminderTimeChanged: (value) async {
          setState(() => _reminderTime = value);
          if (_notificationsEnabled) {
            await _scheduleDailyReminder();
          }
          await _persistNotificationPrefs();
        },
        onClearData: _clearAllData,
      ),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio'),
          NavigationDestination(
              icon: Icon(Icons.edit_note_outlined),
              selectedIcon: Icon(Icons.edit_note),
              label: 'Check-in'),
          NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights),
              label: 'Insights'),
          NavigationDestination(
              icon: Icon(Icons.tune_outlined),
              selectedIcon: Icon(Icons.tune),
              label: 'Ajustes'),
        ],
      ),
    );
  }

  void _registerSupportAction(String action, String details) {
    // A photo or support action is not a check-in and must not invent answers.
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(details)));
  }

  void _openFoodPhoto() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Alimentación')),
          body: SafeArea(
            child: CameraScreen(
              onRegisterSupportAction: _registerSupportAction,
            ),
          ),
        ),
      ),
    );
  }
}
