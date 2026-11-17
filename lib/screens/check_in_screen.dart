import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wellbeing_models.dart';
import '../theme/app_theme.dart';
import '../widgets/mood_face.dart';

class CheckInScreen extends StatefulWidget {
  final WellbeingSnapshot snapshot;
  final FutureOr<void> Function(CheckInDraft) onSubmit;
  const CheckInScreen(
      {required this.snapshot, required this.onSubmit, super.key});
  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  double _mood = 7, _sleepHours = 7.5, _activityMinutes = 45;
  double _socialMinutes = 120, _energy = 6, _stress = 4;
  int _step = 0;
  bool _saving = false;
  final _noteController = TextEditingController();
  final _scroll = ScrollController();
  static const _moods = ['Muy bajo', 'Bajo', 'Regular', 'Bien', 'Muy bien'];
  int get _moodIndex => ((_mood - 1) / 2).floor().clamp(0, 4);
  String get _sleepLabel =>
      '${_sleepHours.floor()} h ${((_sleepHours % 1) * 60).round()} min';

  @override
  void dispose() {
    _noteController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _go(int step) {
    FocusScope.of(context).unfocus();
    setState(() => _step = step);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _change(VoidCallback update) {
    HapticFeedback.selectionClick();
    setState(update);
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Un momento para ti',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('No hay respuestas perfectas. Cuéntanos cómo estás hoy.'),
          const SizedBox(height: 22),
          Row(
              children: List.generate(
                  3,
                  (index) => Expanded(
                          child: Padding(
                        padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
                        child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            height: 6,
                            decoration: BoxDecoration(
                                color: index <= _step
                                    ? AppTheme.forest
                                    : AppTheme.sage.withValues(alpha: .15),
                                borderRadius: BorderRadius.circular(8))),
                      )))),
          const SizedBox(height: 10),
          Text(
              'Paso ${_step + 1} de 3 · ${[
                'Cómo te sientes',
                'Tu día',
                'Tu resumen'
              ][_step]}',
              style: const TextStyle(
                  color: AppTheme.forest, fontWeight: FontWeight.w600)),
          const SizedBox(height: 22),
          AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: KeyedSubtree(
                key: ValueKey(_step),
                child: switch (_step) {
                  0 => _feelings(),
                  1 => _habits(),
                  _ => _review()
                },
              )),
          const SizedBox(height: 24),
          Row(children: [
            if (_step > 0) ...[
              OutlinedButton(
                  onPressed: _saving ? null : () => _go(_step - 1),
                  child: const Text('Atrás')),
              const SizedBox(width: 12),
            ],
            Expanded(
                child: FilledButton.icon(
              onPressed: _saving
                  ? null
                  : _step < 2
                      ? () => _go(_step + 1)
                      : _submit,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(_step == 2
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded),
              label: Text(_saving
                  ? 'Guardando…'
                  : _step == 2
                      ? 'Guardar check-in'
                      : 'Continuar'),
            )),
          ]),
        ]),
      );

  Widget _feelings() => Column(children: [
        _Panel(
            title: '¿Cómo te sientes?',
            subtitle: 'Elige la carita que más se parezca a tu día.',
            child: Column(children: [
              Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: List.generate(5, (index) {
                    final selected = _moodIndex == index;
                    return Semantics(
                        selected: selected,
                        button: true,
                        label: 'Ánimo: ${_moods[index]}',
                        child: ExcludeSemantics(
                            child: Material(
                          color: selected
                              ? AppTheme.sage.withValues(alpha: .14)
                              : AppTheme.background,
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => _change(() =>
                                _mood = [1.0, 3.0, 5.0, 7.0, 10.0][index]),
                            child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 76,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 4),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                        color: selected
                                            ? AppTheme.forest
                                            : Colors.transparent,
                                        width: 2)),
                                child: Column(children: [
                                  MoodFace(
                                      mood: index, size: selected ? 56 : 50),
                                  const SizedBox(height: 8),
                                  Text(_moods[index],
                                      style: const TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center)
                                ])),
                          ),
                        )));
                  })),
              const SizedBox(height: 16),
              Text('${_moods[_moodIndex]} · ${_mood.round()}/10',
                  style: const TextStyle(
                      color: AppTheme.forest, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _adjustment('Ánimo', _mood, 1, 10, 1, (v) => _mood = v),
            ])),
        const SizedBox(height: 16),
        _level(
            'Energía',
            'De poca batería a mucha energía.',
            Icons.bolt_rounded,
            _energy,
            AppTheme.forest,
            (v) => _energy = v,
            'Agotado',
            'Con energía'),
        const SizedBox(height: 16),
        _level(
            'Estrés',
            '¿Cuánta tensión sentiste hoy?',
            Icons.spa_outlined,
            _stress,
            AppTheme.terracotta,
            (v) => _stress = v,
            'Muy poco',
            'Mucho'),
      ]);

  Widget _level(String title, String subtitle, IconData icon, double value,
          Color color, ValueChanged<double> update, String low, String high) =>
      _Panel(
        title: title,
        subtitle: subtitle,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text('${value.round()} de 10',
                style: Theme.of(context).textTheme.titleLarge)
          ]),
          const SizedBox(height: 16),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                  10,
                  (index) => ChoiceChip(
                        label: Text('${index + 1}'),
                        selected: value == index + 1,
                        tooltip: '$title ${index + 1} de 10',
                        showCheckmark: false,
                        onSelected: (_) => _change(() => update(index + 1.0)),
                      ))),
          const SizedBox(height: 10),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(low), Text(high)]),
        ]),
      );

  Widget _habits() => Column(children: [
        _duration(
            'Sueño',
            '¿Cuánto dormiste?',
            Icons.bedtime_outlined,
            _sleepHours,
            _sleepLabel,
            [0, 6, 7.5, 9],
            12,
            .5,
            (v) => _sleepHours = v,
            hours: true),
        const SizedBox(height: 16),
        _duration(
            'Actividad diaria',
            'Cuenta caminatas, ejercicio y movimiento.',
            Icons.directions_walk_rounded,
            _activityMinutes,
            '${_activityMinutes.round()} min',
            [0, 15, 30, 60],
            240,
            5,
            (v) => _activityMinutes = v),
        const SizedBox(height: 16),
        _duration(
            'Uso de redes',
            'Una aproximación está bien.',
            Icons.phone_android_rounded,
            _socialMinutes,
            '${_socialMinutes.round()} min',
            [0, 30, 60, 120],
            360,
            10,
            (v) => _socialMinutes = v),
      ]);

  Widget _duration(
          String title,
          String subtitle,
          IconData icon,
          double value,
          String label,
          List<double> presets,
          double max,
          double step,
          ValueChanged<double> update,
          {bool hours = false}) =>
      _Panel(
        title: title,
        subtitle: subtitle,
        child: Column(children: [
          Icon(icon, size: 32, color: AppTheme.forest),
          const SizedBox(height: 8),
          AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Text(label,
                  key: ValueKey(label),
                  style: Theme.of(context).textTheme.headlineMedium)),
          const SizedBox(height: 14),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: presets
                  .map((preset) => ChoiceChip(
                        label: Text(preset == 0
                            ? 'Nada'
                            : hours
                                ? '${preset.toString().replaceAll('.0', '')} h'
                                : '${preset.round()} min'),
                        selected: value == preset,
                        onSelected: (_) => _change(() => update(preset)),
                      ))
                  .toList()),
          const SizedBox(height: 12),
          _adjustment(title, value, 0, max, step, update),
        ]),
      );

  Widget _adjustment(String title, double value, double min, double max,
          double step, ValueChanged<double> update) =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton.outlined(
            tooltip: 'Reducir $title',
            onPressed: value <= min
                ? null
                : () => _change(() => update((value - step).clamp(min, max))),
            icon: const Icon(Icons.remove)),
        const SizedBox(width: 16),
        Text(
            title == 'Ánimo'
                ? 'Ajustar'
                : step == .5
                    ? '30 min'
                    : '${step.round()} min',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 16),
        IconButton.outlined(
            tooltip: 'Aumentar $title',
            onPressed: value >= max
                ? null
                : () => _change(() => update((value + step).clamp(min, max))),
            icon: const Icon(Icons.add)),
      ]);

  Widget _review() => Column(children: [
        _Panel(
            title: 'Así fue tu día',
            subtitle:
                'Revisa tus respuestas. Puedes volver atrás para cambiarlas.',
            child: Column(children: [
              _summary('Ánimo', '${_moods[_moodIndex]} · ${_mood.round()}/10'),
              _summary('Energía', '${_energy.round()}/10'),
              _summary('Estrés', '${_stress.round()}/10'),
              _summary('Sueño', _sleepLabel),
              _summary('Actividad', '${_activityMinutes.round()} min'),
              _summary('Redes', '${_socialMinutes.round()} min'),
            ])),
        const SizedBox(height: 16),
        _Panel(
            title: '¿Algo más que quieras contar?',
            subtitle: 'Esta nota es opcional.',
            child: TextField(
              controller: _noteController,
              minLines: 3,
              maxLines: 5,
              maxLength: 1000,
              decoration: const InputDecoration(
                  hintText:
                      'Algo que te hizo bien, una preocupación o un momento de tu día…'),
            )),
      ]);
  Widget _summary(String title, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Expanded(child: Text(title)),
        const SizedBox(width: 12),
        Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w600)))
      ]));

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      await widget.onSubmit(CheckInDraft(
          mood: _mood,
          sleepHours: _sleepHours,
          activityMinutes: _activityMinutes,
          socialMinutes: _socialMinutes,
          energy: _energy,
          stress: _stress,
          note: _noteController.text.trim()));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Gracias por dedicarte este momento. Check-in guardado.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'No pudimos guardar el check-in. Tus respuestas siguen aquí para intentarlo de nuevo.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _Panel extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const _Panel(
      {required this.title, required this.subtitle, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.sage.withValues(alpha: .12))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          child,
        ]),
      );
}
