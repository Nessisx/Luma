import 'package:flutter/material.dart';
import 'package:health/health.dart';
import '../services/health_service.dart';
import '../theme/app_theme.dart';

class WatchCard extends StatelessWidget {
  const WatchCard({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: HealthService.instance,
        builder: (context, _) {
          final service = HealthService.instance;
          final connected = service.connection == HealthConnection.ready;
          return Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              leading: CircleAvatar(
                  backgroundColor: AppTheme.sage.withValues(alpha: .15),
                  child:
                      const Icon(Icons.watch_outlined, color: AppTheme.forest)),
              title: const Text('Mi reloj y mi salud'),
              subtitle: Text(connected
                  ? 'Health Connect · Ver datos y permisos'
                  : 'Conecta tus datos cuando quieras · Opcional'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const WatchScreen())),
            ),
          );
        },
      );
}

class WatchScreen extends StatefulWidget {
  const WatchScreen({super.key});
  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> with WidgetsBindingObserver {
  final service = HealthService.instance;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    service.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) service.refresh();
  }

  String stamp(DateTime time) =>
      '${time.day}/${time.month} · ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Mi reloj')),
        body: ListenableBuilder(
            listenable: service,
            builder: (context, _) {
              final connected = service.connection == HealthConnection.ready;
              final needsInstall =
                  service.connection == HealthConnection.installRequired;
              final unavailable =
                  service.connection == HealthConnection.unavailable;
              return RefreshIndicator(
                onRefresh: () => service.refresh(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [AppTheme.forest, Color(0xFF337E58)]),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.watch_outlined,
                                color: Colors.white, size: 38),
                            const SizedBox(height: 20),
                            Text('Tu bienestar, conectado',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: Colors.white)),
                            const SizedBox(height: 10),
                            const Text(
                                'Reúne los datos que tu teléfono o la app de tu reloj comparten con Health Connect.',
                                style: TextStyle(
                                    color: Colors.white, height: 1.5)),
                          ]),
                    ),
                    const SizedBox(height: 20),
                    Text(
                        service.busy
                            ? 'Sincronizando…'
                            : connected
                                ? 'Acceso autorizado'
                                : needsInstall
                                    ? 'Instala o actualiza Health Connect'
                                    : unavailable
                                        ? 'Health Connect no está disponible'
                                        : 'Conecta a tu ritmo',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(connected
                        ? 'Los valores dependen de lo que comparten tus apps. Tener permisos no significa que haya un reloj enlazado.'
                        : 'Luma funciona sin reloj. Puedes continuar con tus check-ins y conectar una fuente de datos más adelante.'),
                    const SizedBox(height: 16),
                    if (service.busy) const LinearProgressIndicator(),
                    if (service.message != null)
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(service.message!,
                              style: const TextStyle(
                                  color: AppTheme.mutedTerracotta))),
                    Wrap(spacing: 10, runSpacing: 10, children: [
                      if (!unavailable)
                        FilledButton.icon(
                          onPressed: service.busy
                              ? null
                              : () => needsInstall
                                  ? service.install()
                                  : service.refresh(requestAccess: !connected),
                          icon: Icon(needsInstall
                              ? Icons.download_outlined
                              : connected
                                  ? Icons.sync
                                  : Icons.link),
                          label: Text(needsInstall
                              ? 'Instalar Health Connect'
                              : connected
                                  ? 'Sincronizar ahora'
                                  : 'Conectar Health Connect'),
                        ),
                      if (connected)
                        OutlinedButton(
                            onPressed: service.busy
                                ? null
                                : () => service.refresh(requestAccess: true),
                            child: const Text('Revisar permisos')),
                    ]),
                    if (service.syncedAt != null)
                      Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                              'Última lectura: ${stamp(service.syncedAt!)}',
                              style: Theme.of(context).textTheme.bodySmall)),
                    const SizedBox(height: 24),
                    _Metric(
                        icon: Icons.directions_walk_outlined,
                        title: 'Pasos de hoy',
                        value: service.steps?.toString(),
                        detail: 'Desde medianoche',
                        allowed:
                            service.granted.contains(HealthDataType.STEPS)),
                    _Metric(
                        icon: Icons.favorite_outline,
                        title: 'Último pulso',
                        value: service.heartRate == null
                            ? null
                            : '${service.heartRate!.round()} lpm',
                        detail: service.heartRateAt == null
                            ? 'Últimas 24 horas'
                            : stamp(service.heartRateAt!),
                        allowed: service.granted
                            .contains(HealthDataType.HEART_RATE)),
                    _Metric(
                        icon: Icons.bedtime_outlined,
                        title: 'Sesiones de sueño',
                        value: service.sleep == null
                            ? null
                            : '${service.sleep!.inHours} h ${service.sleep!.inMinutes.remainder(60)} min',
                        detail:
                            'Duración de sesiones · últimas 24 h, puede incluir tiempo despierto',
                        allowed: service.granted
                            .contains(HealthDataType.SLEEP_SESSION)),
                    if (connected &&
                        service.steps == null &&
                        service.heartRate == null &&
                        service.sleep == null)
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                              'Todavía no hay datos. Abre la app de tu reloj, sincronízala y habilita que comparta datos con Health Connect. Después vuelve a Luma.')),
                    if (service.sources.isNotEmpty)
                      Text(
                          'Fuentes de pulso y sueño: ${service.sources.join(', ')}'),
                    const SizedBox(height: 20),
                    Text('¿Cómo conecto un reloj?',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    const _Step(
                        number: '1',
                        text:
                            'Enlaza tu reloj con su app oficial en el teléfono.'),
                    const _Step(
                        number: '2',
                        text:
                            'En esa app, habilita compartir datos con Health Connect, si lo permite.'),
                    const _Step(
                        number: '3',
                        text:
                            'Concede a Luma los permisos que quieras y pulsa Sincronizar.'),
                    const SizedBox(height: 12),
                    const Text(
                        'La compatibilidad depende del reloj y de su app. Luma no realiza emparejamiento Bluetooth ni mide el pulso directamente.'),
                    const SizedBox(height: 20),
                    const Text('Tú controlas tus datos',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    const Text(
                        'Solo leemos las categorías autorizadas. Estos datos se muestran en tu dispositivo, no se envían a servidores ni modifican automáticamente tu puntuación. Puedes retirar el acceso desde Health Connect.'),
                    if (connected)
                      TextButton.icon(
                          onPressed: service.busy ? null : service.disconnect,
                          icon: const Icon(Icons.link_off),
                          label: const Text('Desconectar Luma')),
                  ],
                ),
              );
            }),
      );
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final String detail;
  final bool allowed;
  const _Metric(
      {required this.icon,
      required this.title,
      required this.value,
      required this.detail,
      required this.allowed});
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              Icon(icon, color: AppTheme.forest, size: 28),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(value ?? (allowed ? 'Sin registros' : 'Sin permiso'),
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(detail, style: Theme.of(context).textTheme.bodySmall),
                  ])),
            ])),
      );
}

class _Step extends StatelessWidget {
  final String number;
  final String text;
  const _Step({required this.number, required this.text});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(
            radius: 14,
            backgroundColor: AppTheme.sage.withValues(alpha: .2),
            child:
                Text(number, style: const TextStyle(color: AppTheme.forest))),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ]));
}
