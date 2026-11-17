# Luma 🌿

## Cálculo del check-in diario

El resumen diario usa reglas explícitas sobre las respuestas actuales, sin mezclar el primer registro con valores iniciales en cero. Los índices son convenciones orientativas de la app, no umbrales clínicos: sueño = 100 entre 7 y 9 h (fuera de ese intervalo baja 20 puntos por hora de distancia); actividad = minutos / 60 × 100, con máximo 100; redes = 100 hasta 60 min y luego resta 0,25 puntos por minuto; carga de estrés = estrés × 10 (mayor número = mayor carga).

La puntuación combina ánimo (30 %), sueño (20 %), actividad (15 %), redes (10 %), energía (15 %) y el inverso de la carga de estrés (10 %). Un reporte de ánimo muy bajo o estrés alto no queda oculto por otros hábitos favorables. Puntuación, etiqueta y mensaje se obtienen de la misma evaluación.

Ejemplo de regresión: ánimo 8, energía 7, estrés 4, sueño 7,5 h, actividad 60 min y redes 30 min → sueño 100, actividad 100, redes 100, estrés 40, puntuación 85,5 y etiqueta Estable.

El modelo de bienestar incluido no participa en este resumen: su canal de entrada anterior fabricaba pasos y características temporales sin suficiente historial. Se requiere validar ese canal y la calibración antes de usar sus predicciones. El análisis nutricional ONNX se conserva. Las fotos y las acciones de apoyo ya no generan check-ins con respuestas inventadas.

## Relojes y Health Connect (Android)

En **Inicio → Mi reloj y mi salud** o **Ajustes**, Luma permite autorizar lectura de pasos de hoy, el último pulso y la duración de sesiones de sueño de las últimas 24 horas. Cada categoría puede autorizarse por separado. No se solicitan permisos de escritura ni lectura en segundo plano.

Primero enlaza el reloj con su app oficial y activa en ella el intercambio con Health Connect, si es compatible. Después conecta Health Connect en Luma y pulsa **Sincronizar ahora**. También puedes usar la app sin reloj. Esta integración lee datos del teléfono o de otras apps; no empareja dispositivos por Bluetooth ni garantiza compatibilidad con cualquier reloj.

Los valores solo se mantienen en memoria, no se envían a servidores y no modifican automáticamente la puntuación. Las sesiones de sueño pueden incluir tiempo despierto; las sesiones superpuestas se cuentan una sola vez. Puedes desconectar Luma desde la pantalla del reloj o retirar permisos desde Health Connect.

Validación: pruebas de agregación de sueño, consentimiento inicial, acceso opcional a comida y estados sin Health Connect. La lectura de un smartwatch físico requiere una prueba posterior con hardware compatible.

Referencias: [plugin health](https://pub.dev/packages/health) y [tipos de datos de Health Connect](https://developer.android.com/health-and-fitness/health-connect/data-types?hl=en).

**Luma** es una aplicación móvil desarrollada con Flutter diseñada para el monitoreo emocional y el bienestar personal. Utiliza inteligencia artificial (modelos ONNX) para analizar patrones de salud y nutrición, proporcionando una experiencia personalizada basada en datos del usuario.

## 🚀 Guía de Instalación y Uso

### Requisitos del Sistema

- **Android:** Versión 8.0 (API 26) o superior.
- **Espacio disponible:** Aproximadamente 150MB para la instalación.

### Instrucciones de Instalación (APK)

1. Descarga el archivo `app-release.apk` (o el específico para tu arquitectura desde el apartado de Releases si está disponible).
2. En tu dispositivo Android, permite la instalación de aplicaciones de orígenes desconocidos (Ajustes > Seguridad).
3. Abre el archivo descargado e instálalo.

### Credenciales de Prueba

- La aplicación **no requiere inicio de sesión** obligatorio para las funciones principales en esta versión, permitiendo un acceso rápido al monitoreo local.

### Funciones Principales a Evaluar

- **Dashboard de Bienestar:** Visualización del score de salud y tendencias actuales.
- **Check-in Diario:** Registro de estado de ánimo, niveles de energía y estrés.
- **Análisis con IA:** El sistema procesa datos locales mediante modelos ONNX (`nutrition_model` y `bilstm_wellbeing`) para ofrecer insights.
- **Cámara y Escaneo:** Módulo para captura o selección de imágenes para análisis nutricional.
- **Notificaciones:** Recordatorios configurables para mantener el hábito del registro.

---

## 🛠️ Estructura del Proyecto (Desarrollo)

Si deseas ejecutar el código fuente:

1.  **Clonar el repositorio:**
    ```bash
    git clone https://github.com/Nessisx/Lumio.git
    ```
2.  **Instalar dependencias:**
    ```bash
    flutter pub get
    ```
3.  **Ejecutar:**
    ```bash
    flutter run --release
    ```

---

## 🧠 Modelos de IA Incluidos

La aplicación integra los siguientes modelos en formato ONNX:

- `bilstm_wellbeing.onnx`: Para el análisis de tendencias de bienestar.
- `nutrition_model.onnx`: Para el procesamiento de datos nutricionales.

---

**Desarrollado para:** Proyecto de Inteligencia Artificial - 7mo Semestre.
