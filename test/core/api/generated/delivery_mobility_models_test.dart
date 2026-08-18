import 'package:flutter_test/flutter_test.dart';
import 'package:noki_driver_app/core/api/generated/driver_models.generated.dart';

import '../../../fixtures/sample_responses.dart';

void main() {
  group('DriverMissionResponseDto.fromJson', () {
    test('parses pickup-less dropoff/customer/COD fields exactly as the contract defines them', () {
      final mission = DriverMissionResponseDto.fromJson(sampleMission());
      expect(mission.status, DriverMissionResponseDtoStatus.outForDelivery);
      expect(mission.customerFullName, 'Nadia Idrissi');
      expect(mission.customerPhone, '+212600000000');
      expect(mission.addressLine1, '4 Rue Zerktouni');
      // codExpectedAmount has no currency of its own on this DTO (currencyId
      // is a UUID, not a code) - callers must not fabricate a symbol here.
      expect(mission.codExpectedAmount, '120.00');
      expect(mission.currencyId, 'currency-1');
      expect(mission.lines, hasLength(1));
    });

    test('a mission list wraps items in the standard {items,total,page,pageSize} envelope', () {
      final list = DriverMissionListResponseDto.fromJson(sampleMissionList());
      expect(list.total, 1);
      expect(list.items.single.shipmentId, 'shipment-1');
    });
  });

  group('OTP challenge/verification DTOs', () {
    test('a requested challenge starts PENDING', () {
      final challenge = DeliveryHandoffOtpChallengeResponseDto.fromJson(sampleOtpChallenge());
      expect(challenge.status, DeliveryHandoffOtpChallengeResponseDtoStatus.pending);
      expect(challenge.maxAttempts, 3);
    });

    test('a verified challenge reports VERIFIED, not remapped to a mission status', () {
      final verification = DeliveryHandoffOtpVerificationResponseDto.fromJson(sampleOtpVerification());
      expect(verification.status, DeliveryHandoffOtpVerificationResponseDtoStatus.verified);
    });
  });

  group('DriverMissionCompletionResponseDto.fromJson', () {
    test('evidenceType is OTP-only, matching the real backend (no POD evidence type exists)', () {
      final completion = DriverMissionCompletionResponseDto.fromJson(sampleMissionCompletion());
      expect(completion.evidenceType, DriverMissionCompletionResponseDtoEvidenceType.otp);
      expect(completion.status, DriverMissionCompletionResponseDtoStatus.delivered);
    });
  });

  group('DeliveryIncidentResponseDto.fromJson', () {
    test('parses a real incident type/status pair', () {
      final incident = DeliveryIncidentResponseDto.fromJson(sampleDeliveryIncident());
      expect(incident.type, DeliveryIncidentResponseDtoType.delay);
      expect(incident.status, DeliveryIncidentResponseDtoStatus.open);
    });
  });

  group('DriverMobilityOfferDto.fromJson', () {
    test('carries real pickup/dropoff coordinates unlike a delivery mission', () {
      final offer = DriverMobilityOfferDto.fromJson(sampleMobilityOffer());
      expect(offer.serviceType, DriverMobilityOfferDtoServiceType.taxi);
      expect(offer.pickupLatitude, isNotNull);
      expect(offer.estimatedFare?.currencyCode, 'MAD');
    });
  });

  group('MobilityRideDetailDto.fromJson', () {
    test('parses required pickup/dropoff coordinates and a timeline entry', () {
      final ride = MobilityRideDetailDto.fromJson(sampleMobilityRide());
      expect(ride.status, MobilityRideDetailDtoStatus.driverAssigned);
      expect(ride.pickupLatitude, 33.59);
      expect(ride.timeline, hasLength(1));
      expect(ride.timeline.single.toStatus, 'DRIVER_ASSIGNED');
    });

    test('an in-progress ride round-trips through toJson/fromJson', () {
      final original = MobilityRideDetailDto.fromJson(sampleMobilityRide(status: 'IN_PROGRESS'));
      final roundTripped = MobilityRideDetailDto.fromJson(original.toJson());
      expect(roundTripped.status, original.status);
      expect(roundTripped.fareAmount, original.fareAmount);
    });
  });

  group('MobilityIncidentDto.fromJson', () {
    test('parses a real incident type/status pair', () {
      final incident = MobilityIncidentDto.fromJson(sampleMobilityIncident());
      expect(incident.type, MobilityIncidentDtoType.safety);
      expect(incident.status, MobilityIncidentDtoStatus.open);
    });
  });

  group('DriverWorkFeedItemDto.fromJson - offer discrimination', () {
    test('an open offer and an active ride are both workType RIDE but distinct sourceDomain', () {
      final offerItem = DriverWorkFeedItemDto.fromJson(sampleWorkFeedOfferItem());
      final rideItem = DriverWorkFeedItemDto.fromJson(sampleWorkFeedRideItem());
      expect(offerItem.workType, DriverWorkFeedItemDtoWorkType.ride);
      expect(rideItem.workType, DriverWorkFeedItemDtoWorkType.ride);
      expect(offerItem.sourceDomain, 'MOBILITY_OFFER');
      expect(offerItem.underlyingResource.resourceType, 'MobilityRideOffer');
    });
  });
}
