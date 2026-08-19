import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/features/delivery/delivery_history_screen.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/sample_responses.dart';
import '../../fixtures/test_harness.dart';

const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

void main() {
  testWidgets('lists completed deliveries by customer name and delivered timestamp', (tester) async {
    final client = FakeDriverApiClient()
      ..listOwnMissionsResponse = DriverMissionListResponseDto.fromJson({
        'items': [sampleMission(status: 'DELIVERED')..['deliveredAt'] = '2026-08-01T10:00:00.000Z'],
        'page': 1,
        'pageSize': 25,
        'total': 1,
      });

    await pumpWithProviders(
      tester,
      const DeliveryHistoryScreen(scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    expect(find.text('Nadia Idrissi'), findsOneWidget);
    expect(find.text('2026-08-01T10:00:00.000Z'), findsOneWidget);
  });

  testWidgets('shows a real empty state when there is no delivery history yet', (tester) async {
    final client = FakeDriverApiClient()
      ..listOwnMissionsResponse = DriverMissionListResponseDto.fromJson({'items': [], 'page': 1, 'pageSize': 25, 'total': 0});

    await pumpWithProviders(
      tester,
      const DeliveryHistoryScreen(scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    expect(find.text('No completed deliveries yet'), findsOneWidget);
  });
}
