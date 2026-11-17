package com.example.wellbeing_app

import android.app.Activity
import android.app.AlertDialog
import android.os.Bundle

class HealthPrivacyActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        AlertDialog.Builder(this)
            .setTitle("Luma · Privacidad de salud")
            .setMessage("Luma solicita acceso de solo lectura a pasos, frecuencia cardíaca y sesiones de sueño para mostrarlos en Mi reloj. Solo lee las categorías que autorizas. Los datos se consultan al abrir o actualizar esa pantalla y se mantienen en memoria durante la sesión. No se envían a servidores ni se escriben datos en Health Connect. Puedes retirar el acceso desde Health Connect o con Desconectar Luma. La app funciona sin estos permisos. Los registros pueden proceder del teléfono o de apps compatibles con tu reloj.")
            .setPositiveButton("Entendido") { _, _ -> finish() }
            .setOnCancelListener { finish() }
            .show()
    }
}
