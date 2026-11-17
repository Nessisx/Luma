import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

enum HealthConnection {
  disconnected,
  ready,
  installRequired,
  unavailable,
  error
}

/// Read-only Health Connect access. Access does not imply a paired watch.
class HealthService extends ChangeNotifier {
  HealthService._private();
  static final instance = HealthService._private();
  final Health _health = Health();
  static const types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_SESSION
  ];
  bool _configured = false;
  bool busy = false;
  HealthConnection connection = HealthConnection.disconnected;
  Set<HealthDataType> granted = {};
  int? steps;
  double? heartRate;
  DateTime? heartRateAt;
  Duration? sleep;
  DateTime? syncedAt;
  String? message;
  Set<String> sources = {};

  Future<void> init() async {
    if (_configured || !Platform.isAndroid) return;
    await _health.configure();
    _configured = true;
  }

  Future<void> refresh({bool requestAccess = false}) async {
    if (busy) return;
    busy = true;
    message = null;
    _clear();
    notifyListeners();
    try {
      if (!Platform.isAndroid) {
        connection = HealthConnection.unavailable;
        return;
      }
      await init();
      final status = await _health.getHealthConnectSdkStatus();
      if (status != HealthConnectSdkStatus.sdkAvailable) {
        connection = status ==
                HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired
            ? HealthConnection.installRequired
            : HealthConnection.unavailable;
        return;
      }
      if (requestAccess) {
        await Permission.activityRecognition.request();
        await _health.requestAuthorization(types,
            permissions: types.map((_) => HealthDataAccess.READ).toList());
      }
      for (final type in types) {
        if (await _health
                .hasPermissions([type], permissions: [HealthDataAccess.READ]) ==
            true) granted.add(type);
      }
      if (granted.isEmpty) {
        connection = HealthConnection.disconnected;
        return;
      }
      connection = HealthConnection.ready;
      final now = DateTime.now();
      if (granted.contains(HealthDataType.STEPS)) {
        steps = await _health.getTotalStepsInInterval(
            DateTime(now.year, now.month, now.day), now);
      }
      final others =
          granted.where((type) => type != HealthDataType.STEPS).toList();
      final points = others.isEmpty
          ? <HealthDataPoint>[]
          : await _health.getHealthDataFromTypes(
              types: others,
              startTime: now.subtract(const Duration(hours: 24)),
              endTime: now);
      sources = points
          .map((point) => point.sourceName)
          .where((name) => name.isNotEmpty)
          .toSet();
      final pulse = points
          .where((point) =>
              point.type == HealthDataType.HEART_RATE &&
              point.value is NumericHealthValue)
          .toList()
        ..sort((a, b) => b.dateTo.compareTo(a.dateTo));
      if (pulse.isNotEmpty) {
        heartRate =
            (pulse.first.value as NumericHealthValue).numericValue.toDouble();
        heartRateAt = pulse.first.dateTo;
      }
      final sessions = points
          .where((point) => point.type == HealthDataType.SLEEP_SESSION)
          .toList();
      if (sessions.isNotEmpty)
        sleep = mergedDuration(
            sessions.map((point) => (point.dateFrom, point.dateTo)),
            now.subtract(const Duration(hours: 24)),
            now);
      syncedAt = now;
    } catch (error) {
      debugPrint('Health Connect: $error');
      _clear();
      connection = HealthConnection.error;
      message =
          'No pudimos leer tus datos. Revisa Health Connect y vuelve a intentarlo.';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> install() async {
    try {
      await init();
      await _health.installHealthConnect();
    } catch (_) {
      message = 'Busca Health Connect en la tienda de tu teléfono.';
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    if (busy) return;
    busy = true;
    notifyListeners();
    try {
      await _health.revokePermissions();
      _clear();
      connection = HealthConnection.disconnected;
      message = null;
    } catch (_) {
      message = 'Retira los permisos de Luma desde Health Connect.';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void _clear() {
    steps = null;
    heartRate = null;
    heartRateAt = null;
    sleep = null;
    syncedAt = null;
    sources = {};
    granted = {};
  }
}

/// Avoid double-counting overlapping sessions from different sources.
Duration mergedDuration(
    Iterable<(DateTime, DateTime)> intervals, DateTime start, DateTime end) {
  final clipped = intervals
      .map((r) =>
          (r.$1.isBefore(start) ? start : r.$1, r.$2.isAfter(end) ? end : r.$2))
      .where((r) => r.$2.isAfter(r.$1))
      .toList()
    ..sort((a, b) => a.$1.compareTo(b.$1));
  DateTime? from;
  DateTime? to;
  var total = Duration.zero;
  for (final range in clipped) {
    if (to == null || range.$1.isAfter(to)) {
      if (from != null && to != null) total += to.difference(from);
      from = range.$1;
      to = range.$2;
    } else if (range.$2.isAfter(to)) {
      to = range.$2;
    }
  }
  if (from != null && to != null) total += to.difference(from);
  return total;
}
