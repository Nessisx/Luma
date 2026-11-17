import 'package:flutter_test/flutter_test.dart';
import 'package:luma/services/health_service.dart';

void main() {
  final start = DateTime(2026, 11, 16);
  final end = start.add(const Duration(hours: 24));
  test('sleep sessions merge duplicate and overlapping sources', () {
    expect(
        mergedDuration([
          (start, start.add(const Duration(hours: 4))),
          (start, start.add(const Duration(hours: 4))),
          (
            start.add(const Duration(hours: 3)),
            start.add(const Duration(hours: 8))
          ),
          (
            start.add(const Duration(hours: 10)),
            start.add(const Duration(hours: 11))
          ),
        ], start, end),
        const Duration(hours: 9));
  });
  test('sleep sessions are clipped to the requested period', () {
    expect(
        mergedDuration([
          (
            start.subtract(const Duration(hours: 2)),
            start.add(const Duration(hours: 2))
          ),
          (
            end.subtract(const Duration(hours: 1)),
            end.add(const Duration(hours: 2))
          ),
          (end, start),
        ], start, end),
        const Duration(hours: 3));
    expect(mergedDuration([], start, end), Duration.zero);
  });
}
