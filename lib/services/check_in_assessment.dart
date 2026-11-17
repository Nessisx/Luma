import '../models/wellbeing_models.dart';

/// Transparent UI indices, not clinical thresholds or model predictions.
/// The daily summary uses today's answers; history belongs in trend views.
class CheckInAssessment {
  final CheckInDraft draft;
  CheckInAssessment(CheckInDraft input)
      : draft = CheckInDraft(
          mood: input.mood.clamp(1, 10),
          sleepHours: input.sleepHours.clamp(0, 12),
          activityMinutes: input.activityMinutes.clamp(0, 240),
          socialMinutes: input.socialMinutes.clamp(0, 360),
          energy: input.energy.clamp(1, 10),
          stress: input.stress.clamp(1, 10),
          note: input.note.trim(),
        );
  double get sleepScore {
    final hours = draft.sleepHours;
    if (hours >= 7 && hours <= 9) return 100;
    final distance = hours < 7 ? 7 - hours : hours - 9;
    return (100 - distance * 20).clamp(0, 100);
  }

  double get activityScore => (draft.activityMinutes / 60 * 100).clamp(0, 100);
  // Low screen time is not penalized; this is an app convention, not a health verdict.
  double get socialScore => draft.socialMinutes <= 60
      ? 100
      : (100 - (draft.socialMinutes - 60) * .25).clamp(0, 100);
  double get stressLoad => draft.stress * 10;
  double get overallScore => (draft.mood * 10 * .30 +
          sleepScore * .20 +
          activityScore * .15 +
          socialScore * .10 +
          draft.energy * 10 * .15 +
          (100 - stressLoad) * .10)
      .clamp(0, 100);
  // A strongly reported difficult day is never concealed by activity or sleep.
  RiskLevel get riskLevel {
    if (draft.mood <= 2 || (draft.stress >= 9 && draft.energy <= 3)) {
      return RiskLevel.low;
    }
    if (draft.mood <= 4 || draft.energy <= 3 || draft.stress >= 8) {
      return RiskLevel.watch;
    }
    return overallScore >= 75 ? RiskLevel.stable : RiskLevel.watch;
  }

  String get message {
    if (riskLevel == RiskLevel.stable) {
      return 'Tus respuestas describen un día con buen equilibrio. Tus hábitos suman y no reportaste energía muy baja ni estrés alto. Este resumen no es una evaluación clínica.';
    }
    if (draft.mood <= 4) {
      return 'Registraste un ánimo de ${draft.mood.round()}/10. Ese dato merece espacio, aunque otros hábitos hayan ido bien. ¿Cómo te gustaría acompañarte hoy?';
    }
    if (draft.stress >= 8) {
      return 'Marcaste ${draft.stress.round()}/10 de estrés. El mensaje se basa en esa respuesta, no en una predicción de riesgo.';
    }
    if (draft.energy <= 3) {
      return 'Marcaste ${draft.energy.round()}/10 de energía. Tu sensación de cansancio cuenta, incluso si descansaste o caminaste.';
    }
    return 'Tu registro combina distintos hábitos y sensaciones. Una puntuación intermedia no significa que estés mal ni permite concluir que exista un problema.';
  }

  String get supportTitle => riskLevel == RiskLevel.stable
      ? 'Un día con buen equilibrio'
      : 'Un momento para escucharte';
  String get supportBody => riskLevel == RiskLevel.stable
      ? 'Reconoce lo que te funcionó hoy. No necesitas una puntuación perfecta para tener un buen día.'
      : 'Observa cómo te sientes y qué necesitas. Un check-in aislado no es un diagnóstico ni permite afirmar una tendencia.';
  List<InsightItem> get insights => [
        InsightItem(
            title: draft.sleepHours >= 7 && draft.sleepHours <= 9
                ? 'Descanso bien representado'
                : 'Tu descanso, con contexto',
            body:
                'Registraste ${draft.sleepHours.toStringAsFixed(1)} h. El índice de la app asigna 100 entre 7 y 9 h; no evalúa la calidad del sueño ni tus necesidades individuales.',
            label: 'Descanso'),
        InsightItem(
            title: draft.activityMinutes >= 30
                ? 'Tu movimiento suma'
                : 'Movimiento a tu ritmo',
            body:
                'Anotaste ${draft.activityMinutes.round()} minutos de actividad. El índice crece hasta 60 minutos y después se mantiene; hacer más no se premia sin límite.',
            label: 'Movimiento'),
        InsightItem(
            title: 'Tu tiempo en redes',
            body:
                'Registraste ${draft.socialMinutes.round()} minutos. La app no resta puntos por una hora o menos. Este índice no determina si el uso de redes te hace bien o mal.',
            label: 'Redes'),
        InsightItem(
            title: 'Así describiste tu energía',
            body:
                'Tu batería fue ${draft.energy.round()}/10. ${draft.energy >= 6 ? 'No la interpretamos como batería baja.' : 'Tu percepción importa más que cualquier expectativa de productividad.'}',
            label: 'Energía'),
        InsightItem(
            title: 'Estrés, sin invertir la escala',
            body:
                'Marcaste ${draft.stress.round()}/10: corresponde a ${stressLoad.round()}/100 de carga. Un número más alto indica más estrés, no más calma.',
            label: 'Estrés'),
      ];
}
