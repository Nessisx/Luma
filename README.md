# WellBeing 🌿

**WellBeing** es una aplicación móvil desarrollada con Flutter diseñada para el monitoreo emocional y el bienestar personal. Utiliza inteligencia artificial (modelos ONNX) para analizar patrones de salud y nutrición, proporcionando una experiencia personalizada basada en datos del usuario.

## 🚀 Guía de Instalación y Uso

### Requisitos del Sistema
*   **Android:** Versión 8.0 (API 26) o superior.
*   **Espacio disponible:** Aproximadamente 150MB para la instalación.

### Instrucciones de Instalación (APK)
1. Descarga el archivo `app-release.apk` (o el específico para tu arquitectura desde el apartado de Releases si está disponible).
2. En tu dispositivo Android, permite la instalación de aplicaciones de orígenes desconocidos (Ajustes > Seguridad).
3. Abre el archivo descargado e instálalo.

### Credenciales de Prueba
*   La aplicación **no requiere inicio de sesión** obligatorio para las funciones principales en esta versión, permitiendo un acceso rápido al monitoreo local.

### Funciones Principales a Evaluar
*   **Dashboard de Bienestar:** Visualización del score de salud y tendencias actuales.
*   **Check-in Diario:** Registro de estado de ánimo, niveles de energía y estrés.
*   **Análisis con IA:** El sistema procesa datos locales mediante modelos ONNX (`nutrition_model` y `bilstm_wellbeing`) para ofrecer insights.
*   **Cámara y Escaneo:** Módulo para captura o selección de imágenes para análisis nutricional.
*   **Notificaciones:** Recordatorios configurables para mantener el hábito del registro.

---

## 📺 Video Demostrativo
Puedes ver el funcionamiento completo de la aplicación en el siguiente enlace:
> **[Enlace al video en YouTube/Drive]** *(Sustituye este texto por tu link real)*

El video demuestra:
1. Flujo completo de navegación.
2. Funcionamiento de los botones y módulos.
3. Interacción con los modelos de IA integrados.

---

## 🛠️ Estructura del Proyecto (Desarrollo)
Si deseas ejecutar el código fuente:

1.  **Clonar el repositorio:**
    ```bash
    git clone https://github.com/Nessisx/WellBeing.git
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
*   `bilstm_wellbeing.onnx`: Para el análisis de tendencias de bienestar.
*   `nutrition_model.onnx`: Para el procesamiento de datos nutricionales.

---
**Desarrollado para:** Proyecto de Inteligencia Artificial - 7mo Semestre.
