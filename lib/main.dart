import 'package:flutter/material.dart';
import 'package:luma/models/wellbeing_models.dart';
import 'app.dart';

void main() async {
  // Asegura que los canales nativos de Flutter estén listos antes de cargar el modelo
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar los modelos ONNX de forma segura desde la memoria
  // Daily check-ins use explicit rules until the model feature pipeline is validated.
  await nutritionInference.initModel();

  // NOTA: Si 'WellbeingApp' te sigue saliendo en rojo, cámbialo por 'App' o 'MyApp'
  // dependiendo de cómo se llame la clase principal dentro de tu archivo app.dart
  runApp(const WellbeingApp());
}
