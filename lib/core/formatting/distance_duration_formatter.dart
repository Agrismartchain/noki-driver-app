import 'package:intl/intl.dart';

/// Shared m/km, min/h and absolute-ETA formatting for navigation (and any
/// future distance/duration display) - locale-aware, no hardcoded copy or
/// units, never miles. Kept small and focused rather than a general-purpose
/// number formatter since this is the only place the app currently needs
/// distance/duration/ETA formatting.
class DistanceDurationFormatter {
  const DistanceDurationFormatter(this.locale);

  final String locale;

  /// "850 m" below 1km, "3.2 km" (one decimal) at or above 1km.
  String distance(num meters) {
    if (meters < 1000) {
      return '${NumberFormat.decimalPattern(locale).format(meters.round())} m';
    }
    final km = meters / 1000;
    return '${NumberFormat('0.0', locale).format(km)} km';
  }

  /// "45 min" below 1h, "1h 05" (h + zero-padded minutes) at or above 1h.
  String duration(num seconds) {
    final totalMinutes = (seconds / 60).round();
    if (totalMinutes < 60) {
      return '$totalMinutes min';
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours}h ${minutes.toString().padLeft(2, '0')}';
  }

  /// Absolute arrival time (e.g. "14:32"), derived from `DateTime.now()` +
  /// [seconds] and formatted per [locale] - never a hardcoded format string.
  String eta(num seconds, {DateTime? now}) {
    final arrival = (now ?? DateTime.now()).add(
      Duration(seconds: seconds.round()),
    );
    return DateFormat.Hm(locale).format(arrival);
  }
}
