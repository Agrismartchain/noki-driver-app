import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/api_providers.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';
import 'package:noki_driver_app/core/errors/app_failure.dart';
import 'package:noki_driver_app/features/driver_context/home_screen.dart';

import '../../fixtures/fake_driver_api_client.dart';
import '../../fixtures/sample_responses.dart';
import '../../fixtures/test_harness.dart';

void main() {
  testWidgets('renders the driver greeting, assigned vehicle and work feed count', (tester) async {
    final client = FakeDriverApiClient()
      ..driverContextResponse = DriverContextResponseDto.fromJson(sampleDriverContext())
      ..availabilityResponse = DriverAvailabilityResponseDto.fromJson(sampleAvailability())
      ..workFeedResponse = DriverWorkFeedListResponseDto.fromJson(sampleWorkFeedList());

    await pumpWithProviders(
      tester,
      const HomeScreen(),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    expect(find.text('Hello, Amine Tazi'), findsOneWidget);
    expect(find.textContaining('Dacia Logan'), findsOneWidget);
    expect(find.text('2 open work items'), findsOneWidget);
  });

  testWidgets('shows a real empty state - no vehicle - when the actor has none assigned', (tester) async {
    final client = FakeDriverApiClient()
      ..driverContextResponse = DriverContextResponseDto.fromJson(sampleDriverContext(withVehicle: false))
      ..availabilityResponse = DriverAvailabilityResponseDto.fromJson(sampleAvailability())
      ..workFeedResponse = DriverWorkFeedListResponseDto.fromJson(sampleWorkFeedList());

    await pumpWithProviders(
      tester,
      const HomeScreen(),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    expect(find.text('No vehicle assigned yet'), findsOneWidget);
  });

  testWidgets('shows an error view with retry when the driver context call fails', (tester) async {
    final client = FakeDriverApiClient()..driverContextFailure = const AppFailure(AppFailureType.server);

    await pumpWithProviders(
      tester,
      const HomeScreen(),
      overrides: [driverApiClientProvider.overrideWithValue(client)],
    );

    expect(find.text('Something went wrong on our side. Try again shortly.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
