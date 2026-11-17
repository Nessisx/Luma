import '../models/wellbeing_models.dart';

/// Keep real check-ins separate from support actions recorded in the same list.
List<CheckInRecord> dailyCheckIns(List<CheckInRecord> history,
    {int days = 30, DateTime? now}) {
  final today = now ?? DateTime.now();
  final start = DateTime(today.year, today.month, today.day)
      .subtract(Duration(days: days - 1));
  final records = history
      .where((r) =>
          !r.note.startsWith('Acción:') &&
          !r.date.isBefore(start) &&
          !r.date.isAfter(today))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
  final dates = <String>{};
  return records
      .where((r) => dates.add('${r.date.year}-${r.date.month}-${r.date.day}'))
      .toList();
}

List<InsightItem> reflectionMessages(List<CheckInRecord> records) {
  if (records.isEmpty)
    return [
      InsightItem(
          title: 'Tu historia empieza contigo',
          body:
              'Un check-in es una pequeña pausa para escucharte. No necesitas tener un buen día para registrarlo.',
          label: 'Para empezar'),
      InsightItem(
          title: 'Un número no te define',
          body:
              'Tu registro es una foto de un momento. No resume todo lo que eres ni todo lo que pasa en tu vida.',
          label: 'Recordatorio'),
      InsightItem(
          title: 'Hazlo a tu manera',
          body:
              'Puedes escribir una nota breve o solo responder las preguntas. Tú decides cuánto compartir.',
          label: 'Tu espacio'),
    ];
  final latest = records.first;
  final result = <InsightItem>[
    InsightItem(
        title: latest.mood <= 4
            ? 'Aquí también caben los días difíciles'
            : 'Date crédito por escucharte',
        body:
            'En tu último check-in marcaste ${latest.mood.round()}/10 de ánimo. ${latest.mood <= 4 ? 'Puedes reconocer cómo te sientes sin exigirte resolverlo todo hoy.' : '¿Qué momento de ese día te gustaría recordar? Una nota puede ayudarte a volver a él.'}',
        label: 'Ánimo'),
    InsightItem(
        title: latest.energy <= 4
            ? 'Un ritmo que puedas sostener'
            : 'Elige dónde poner tu energía',
        body:
            'Registraste ${latest.energy.round()}/10 de energía. ${latest.energy <= 4 ? '¿Qué tarea puede esperar y cuál merece tu atención ahora?' : 'Piensa en una sola cosa a la que quieras dedicarle un momento de atención.'}',
        label: 'Energía'),
    InsightItem(
        title: 'Tu descanso también tiene contexto',
        body:
            'Anotaste ${latest.sleepHours.toStringAsFixed(1)} horas de sueño. Más allá de la cantidad, ¿cómo sentiste ese descanso al despertar?',
        label: 'Descanso'),
    InsightItem(
        title: latest.stress >= 7
            ? 'No tienes que cargar con todo a la vez'
            : 'Reconoce tus espacios de calma',
        body:
            'Tu último registro de estrés fue ${latest.stress.round()}/10. ${latest.stress >= 7 ? '¿Hay algo que puedas simplificar o compartir con alguien de confianza?' : '¿Qué te dio un poco de calma ese día? Vale la pena reconocerlo.'}',
        label: 'Estrés'),
  ];
  if (records.length >= 2) {
    final delta = latest.mood - records[1].mood;
    result.add(InsightItem(
        title: 'Dos momentos, dos versiones de tu día',
        body:
            'Tu ánimo ${delta > 0 ? 'subió ${delta.abs().round()} puntos' : delta < 0 ? 'bajó ${delta.abs().round()} puntos' : 'se mantuvo igual'} respecto al registro del día anterior disponible. Dos registros describen un cambio; todavía no explican su causa.',
        label: 'Comparación'));
  }
  return result;
}
