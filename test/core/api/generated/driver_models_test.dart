import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';

import '../../../fixtures/sample_responses.dart';

void main() {
  group('DriverContextResponseDto.fromJson', () {
    test('parses actor, profile and nested assigned vehicle', () {
      final context = DriverContextResponseDto.fromJson(sampleDriverContext());

      expect(context.actorId, 'actor-1');
      expect(context.displayName, 'Amine Tazi');
      expect(context.profiles, hasLength(1));

      final profile = context.profiles.single;
      expect(profile.organizationId, 'org-1');
      expect(profile.countryCode, 'MA');
      expect(profile.mobilityAvailabilityStatus, DriverContextProfileDtoMobilityAvailabilityStatus.offline);
      expect(profile.serviceTypes, [DriverContextProfileDtoServiceTypes.taxi]);

      final vehicle = profile.assignedVehicle;
      expect(vehicle, isNotNull);
      expect(vehicle!.plate, '12345-A-6');
      expect(vehicle.type, DriverContextVehicleSummaryDtoType.car);
      expect(vehicle.status, DriverContextVehicleSummaryDtoStatus.active);
    });

    test('parses an actor with no Driver profile as an empty list, not an error', () {
      final context = DriverContextResponseDto.fromJson(sampleDriverContext(withProfile: false));
      expect(context.profiles, isEmpty);
    });

    test('round-trips through toJson', () {
      final original = sampleDriverContext();
      final context = DriverContextResponseDto.fromJson(original);
      final roundTripped = DriverContextResponseDto.fromJson(context.toJson());
      expect(roundTripped.actorId, context.actorId);
      expect(roundTripped.profiles.single.countryCode, context.profiles.single.countryCode);
    });
  });

  group('DriverVehicleDto.fromJson', () {
    test('parses a vehicle list item with all fields', () {
      final list = DriverVehicleListResponseDto.fromJson(sampleVehicleList());
      expect(list.total, 1);
      final vehicle = list.items.single;
      expect(vehicle.make, 'Dacia');
      expect(vehicle.model, 'Logan');
      expect(vehicle.status, DriverVehicleDtoStatus.active);
      expect(vehicle.allowedServiceTypes, [DriverVehicleDtoAllowedServiceTypes.taxi]);
      expect(vehicle.year, 2021);
    });
  });

  group('DriverAvailabilityResponseDto.fromJson', () {
    test('maps the mobility availability enum without remapping its values', () {
      final availability = DriverAvailabilityResponseDto.fromJson(sampleAvailability(mobilityStatus: 'AVAILABLE'));
      expect(
        availability.mobilityAvailabilityStatus,
        DriverAvailabilityResponseDtoMobilityAvailabilityStatus.available,
      );
      expect(availability.activeDeliveryMissionCount, 2);
      expect(availability.activeMobilityRideCount, 1);
    });

    test('an unrecognized enum value from the backend maps to unknown, never crashes', () {
      final json = sampleAvailability()..['mobilityAvailabilityStatus'] = 'SOMETHING_NEW';
      final availability = DriverAvailabilityResponseDto.fromJson(json);
      expect(availability.mobilityAvailabilityStatus, DriverAvailabilityResponseDtoMobilityAvailabilityStatus.unknown);
    });
  });

  group('DriverWorkFeedItemDto.fromJson - work-feed foundation', () {
    test('parses a DELIVERY work item without merging it into a Ride shape', () {
      final item = DriverWorkFeedItemDto.fromJson(sampleWorkFeedDeliveryItem());
      expect(item.workType, DriverWorkFeedItemDtoWorkType.delivery);
      expect(item.serviceType, DriverWorkFeedItemDtoServiceType.delivery);
      expect(item.underlyingResource.resourceType, 'DeliveryShipment');
      expect(item.amount?.amount, '120.00');
      expect(item.amount?.currencyCode, 'MAD');
      expect(item.dropoff?.addressLine1, '4 Rue Zerktouni');
    });

    test('parses a RIDE work item, keeping its own resourceType distinct from Delivery', () {
      final item = DriverWorkFeedItemDto.fromJson(sampleWorkFeedRideItem());
      expect(item.workType, DriverWorkFeedItemDtoWorkType.ride);
      expect(item.serviceType, DriverWorkFeedItemDtoServiceType.taxi);
      expect(item.underlyingResource.resourceType, 'MobilityRide');
      expect(item.amount, isNull);
      expect(item.dropoff, isNull);
    });

    test('a work feed list mixes DELIVERY and RIDE items under one boundary', () {
      final list = DriverWorkFeedListResponseDto.fromJson(sampleWorkFeedList());
      expect(list.items, hasLength(2));
      expect(list.items.map((i) => i.workType), [
        DriverWorkFeedItemDtoWorkType.delivery,
        DriverWorkFeedItemDtoWorkType.ride,
      ]);
    });
  });
}
