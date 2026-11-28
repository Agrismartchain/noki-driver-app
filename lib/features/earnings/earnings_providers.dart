import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_providers.dart';
import '../../core/api/finance/driver_finance_models.dart';
import '../driver_context/driver_context_repository.dart';

class DriverEarningsSnapshot {
  const DriverEarningsSnapshot({
    required this.summary,
    required this.earnings,
    required this.codCollections,
    required this.payouts,
    required this.eligibility,
  });

  final DriverFinanceSummaryDto summary;
  final List<DriverEarningItemDto> earnings;
  final List<DriverCodCollectionItemDto> codCollections;
  final List<DriverPayoutItemDto> payouts;
  final DriverPayoutEligibilityDto eligibility;
}

final driverEarningsSnapshotProvider = FutureProvider.autoDispose
    .family<DriverEarningsSnapshot, DriverScope>((ref, scope) async {
      final api = ref.watch(driverApiClientProvider);
      final summary = await api.driverFinanceSummary(
        organizationId: scope.organizationId,
        countryCode: scope.countryCode,
      );
      final results = await Future.wait<dynamic>([
        api.driverFinanceEarnings(
          organizationId: scope.organizationId,
          countryCode: scope.countryCode,
        ),
        api.driverFinanceCod(
          organizationId: scope.organizationId,
          countryCode: scope.countryCode,
        ),
        api.driverPayouts(
          organizationId: scope.organizationId,
          countryCode: scope.countryCode,
        ),
        api.driverPayoutEligibility(
          organizationId: scope.organizationId,
          countryCode: scope.countryCode,
        ),
      ]);

      return DriverEarningsSnapshot(
        summary: summary,
        earnings: results[0] as List<DriverEarningItemDto>,
        codCollections: results[1] as List<DriverCodCollectionItemDto>,
        payouts: results[2] as List<DriverPayoutItemDto>,
        eligibility: results[3] as DriverPayoutEligibilityDto,
      );
    });

String generateDriverIdempotencyKey(String prefix) {
  final random = Random.secure();
  final hex = List<String>.generate(
    16,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  return '$prefix-${DateTime.now().millisecondsSinceEpoch}-$hex';
}
