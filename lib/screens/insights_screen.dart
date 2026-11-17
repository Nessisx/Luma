import 'package:flutter/material.dart';
import '../models/wellbeing_models.dart';
import '../services/reflection_messages.dart';
import '../theme/app_theme.dart';
import '../widgets/message_deck.dart';
import '../widgets/mood_face.dart';

class InsightsScreen extends StatefulWidget {
  final WellbeingSnapshot snapshot;
  final List<InsightItem> insights;
  final List<CheckInRecord> history;
  final void Function(String action, String details) onRegisterSupportAction;
  const InsightsScreen(
      {required this.snapshot,
      required this.insights,
      required this.history,
      required this.onRegisterSupportAction,
      super.key});
  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  int _days = 7;
  @override
  Widget build(BuildContext context) {
    final records = dailyCheckIns(widget.history, days: _days);
    final messages = reflectionMessages(records);
    final average = records.isEmpty
        ? null
        : records.map((r) => r.mood).reduce((a, b) => a + b) / records.length;
    final sleep = records.isEmpty
        ? null
        : records.map((r) => r.sleepHours).reduce((a, b) => a + b) /
            records.length;
    return ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: [
          const Text('TU ESPACIO PARA ENTENDERTE',
              style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.forest)),
          const SizedBox(height: 10),
          Text('Cada día cuenta una historia',
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 10),
          const Text(
              'Observa lo que cambia, reconoce lo que te acompaña. Sin compararte con nadie más.',
              style: TextStyle(height: 1.5)),
          const SizedBox(height: 20),
          Wrap(
              spacing: 8,
              children: [7, 30]
                  .map((days) => ChoiceChip(
                      label: Text('Últimos $days días'),
                      selected: _days == days,
                      onSelected: (_) => setState(() => _days = days)))
                  .toList()),
          const SizedBox(height: 18),
          Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppTheme.forest, Color(0xFF39815C)]),
                  borderRadius: BorderRadius.circular(28)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tu panorama',
                        style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Text(
                        records.isEmpty
                            ? 'Aún hay páginas por escribir'
                            : '${records.length} ${records.length == 1 ? 'día registrado' : 'días registrados'}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(color: Colors.white)),
                    const SizedBox(height: 10),
                    Text(
                        records.isEmpty
                            ? 'Haz un check-in y aquí aparecerá tu resumen. Mientras tanto, explora los mensajes para ti.'
                            : 'Se usa el último check-in de cada día. Los días sin registro quedan fuera del promedio.',
                        style:
                            const TextStyle(color: Colors.white, height: 1.5)),
                    if (average != null) ...[
                      const SizedBox(height: 22),
                      Wrap(spacing: 24, runSpacing: 16, children: [
                        _HeroStat(
                            value: '${average.toStringAsFixed(1)}/10',
                            label: 'Ánimo medio'),
                        _HeroStat(
                            value: '${sleep!.toStringAsFixed(1)} h',
                            label: 'Sueño registrado medio'),
                      ]),
                    ],
                  ])),
          const SizedBox(height: 24),
          if (records.isNotEmpty) ...[
            Text('El recorrido de tu ánimo',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text('Valores de tus check-ins · escala de 1 a 10'),
            const SizedBox(height: 14),
            _MoodChart(records: records.reversed.toList()),
            const SizedBox(height: 24),
          ],
          MessageDeck(messages: messages),
          const SizedBox(height: 24),
          Text(
              records.isEmpty
                  ? 'Ideas para tu próximo check-in'
                  : 'Lo que cuentan tus registros',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Toca una tarjeta para abrir una reflexión.'),
          const SizedBox(height: 12),
          ...messages.map((item) => _ReflectionTile(item: item)),
          if (records.isNotEmpty && widget.insights.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text('Lectura del último análisis',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
                'Este análisis corresponde al último check-in, no al período seleccionado.'),
            const SizedBox(height: 12),
            ...widget.insights.map((item) => _ReflectionTile(item: item)),
          ],
          if (records.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Pequeñas páginas de tu historia',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...records.take(5).map((record) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MoodFace(
                              mood: ((record.mood - 1) / 2).floor(), size: 46),
                          const SizedBox(width: 14),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(
                                    '${record.date.day}/${record.date.month} · Ánimo ${record.mood.round()}/10',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const SizedBox(height: 6),
                                Text(
                                    record.note.isEmpty
                                        ? 'Ese día también te diste un momento para ti.'
                                        : record.note,
                                    style: const TextStyle(height: 1.5)),
                              ])),
                        ])))),
            const SizedBox(height: 12),
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.favorite_outline,
                              color: AppTheme.forest),
                          const SizedBox(height: 12),
                          Text(widget.snapshot.supportTitle,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(widget.snapshot.supportBody),
                        ]))),
          ],
          const SizedBox(height: 20),
          const Text(
              'Estas reflexiones describen tus respuestas; no explican sus causas ni sustituyen una evaluación profesional.',
              style: TextStyle(fontSize: 12, height: 1.5)),
        ]);
  }
}

class _HeroStat extends StatelessWidget {
  final String value, label;
  const _HeroStat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12))
      ]);
}

class _ReflectionTile extends StatelessWidget {
  final InsightItem item;
  const _ReflectionTile({required this.item});
  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: PageStorageKey('${item.label}${item.title}'),
        leading:
            const Icon(Icons.auto_awesome_outlined, color: AppTheme.forest),
        title: Text(item.title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(item.label),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(item.body, style: const TextStyle(height: 1.6))],
      ));
}

class _MoodChart extends StatelessWidget {
  final List<CheckInRecord> records;
  const _MoodChart({required this.records});
  @override
  Widget build(BuildContext context) => Card(
      margin: EdgeInsets.zero,
      child: Padding(
          padding: const EdgeInsets.all(18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('10 · Ánimo más alto', style: TextStyle(fontSize: 11)),
            const SizedBox(height: 8),
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: records
                        .map((r) => Semantics(
                              label:
                                  '${r.date.day}/${r.date.month}: ánimo ${r.mood.round()} de 10',
                              child: ExcludeSemantics(
                                  child: Padding(
                                      padding: const EdgeInsets.only(right: 14),
                                      child: Column(children: [
                                        Text('${r.mood.round()}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 6),
                                        Container(
                                            width: 28,
                                            height: 100 *
                                                (r.mood.clamp(1, 10) / 10),
                                            decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Color(0xFF9AC879),
                                                      AppTheme.forest
                                                    ]),
                                                borderRadius:
                                                    BorderRadius.circular(9))),
                                        const SizedBox(height: 8),
                                        Text('${r.date.day}/${r.date.month}',
                                            style:
                                                const TextStyle(fontSize: 10)),
                                      ]))),
                            ))
                        .toList())),
            const SizedBox(height: 10),
            const Text('1 · Ánimo más bajo', style: TextStyle(fontSize: 11)),
          ])));
}
