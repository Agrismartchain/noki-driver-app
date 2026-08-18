import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/features/driver_context/driver_context_repository.dart';
import 'package:noki_driver_app/features/vehicles/vehicles_screen.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/sample_responses.dart';
import '../../fixtures/test_harness.dart';

const _scope = DriverScope(organizationId: 'org-1', countryCode: 'MA');

void main() {
  testWidgets('renders a real vehicle list with make/model/plate/status', (tester) async {
    final client = FakeDriverApiClient()..vehiclesResponse = DriverVehicleListResponseDto.fromJson(sampleVehicleList());

    await pumpWithProviders(
      tester,
      const VehiclesScreen(scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    expect(find.textContaining('Dacia Logan'), findsOneWidget);
    expect(find.textContaining('12345-A-6'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('shows a real empty state, not invented vehicles, when the list is empty', (tester) async {
    final client = FakeDriverApiClient()
      ..vehiclesResponse = const DriverVehicleListResponseDto(items: [], total: 0, page: 1, pageSize: 25);

    await pumpWithProviders(
      tester,
      const VehiclesScreen(scope: _scope),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    expect(find.text('No vehicles on your profile yet'), findsOneWidget);
    expect(find.textContaining('Dacia'), findsNothing);
  });
}
