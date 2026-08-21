// GENERATED CODE - DO NOT EDIT BY HAND.
//
// Produced by tool/generate_api_models.mjs from the canonical OpenAPI document
// locked in contract/lock.json. Run:
//   node tool/generate_api_models.mjs
// to regenerate, or:
//   node tool/generate_api_models.mjs --check
// to detect drift in CI.


// ignore_for_file: type=lint



enum ComputeDriverRouteRequestDtoServiceType {
  delivery,
  taxi,
  taxiMoto,
  unknown;

  static ComputeDriverRouteRequestDtoServiceType fromJson(String value) {
    switch (value) {
      case "DELIVERY":
        return ComputeDriverRouteRequestDtoServiceType.delivery;
      case "TAXI":
        return ComputeDriverRouteRequestDtoServiceType.taxi;
      case "TAXI_MOTO":
        return ComputeDriverRouteRequestDtoServiceType.taxiMoto;
      default:
        return ComputeDriverRouteRequestDtoServiceType.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case ComputeDriverRouteRequestDtoServiceType.delivery:
        return "DELIVERY";
      case ComputeDriverRouteRequestDtoServiceType.taxi:
        return "TAXI";
      case ComputeDriverRouteRequestDtoServiceType.taxiMoto:
        return "TAXI_MOTO";
      case ComputeDriverRouteRequestDtoServiceType.unknown:
        return "DELIVERY";
    }
  }
}

enum ComputeDriverRouteRequestDtoVehicleMode {
  car,
  motorcycle,
  unknown;

  static ComputeDriverRouteRequestDtoVehicleMode fromJson(String value) {
    switch (value) {
      case "CAR":
        return ComputeDriverRouteRequestDtoVehicleMode.car;
      case "MOTORCYCLE":
        return ComputeDriverRouteRequestDtoVehicleMode.motorcycle;
      default:
        return ComputeDriverRouteRequestDtoVehicleMode.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case ComputeDriverRouteRequestDtoVehicleMode.car:
        return "CAR";
      case ComputeDriverRouteRequestDtoVehicleMode.motorcycle:
        return "MOTORCYCLE";
      case ComputeDriverRouteRequestDtoVehicleMode.unknown:
        return "CAR";
    }
  }
}

enum ComputeDriverRouteResponseDtoProfile {
  auto,
  motorcycle,
  unknown;

  static ComputeDriverRouteResponseDtoProfile fromJson(String value) {
    switch (value) {
      case "auto":
        return ComputeDriverRouteResponseDtoProfile.auto;
      case "motorcycle":
        return ComputeDriverRouteResponseDtoProfile.motorcycle;
      default:
        return ComputeDriverRouteResponseDtoProfile.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case ComputeDriverRouteResponseDtoProfile.auto:
        return "auto";
      case ComputeDriverRouteResponseDtoProfile.motorcycle:
        return "motorcycle";
      case ComputeDriverRouteResponseDtoProfile.unknown:
        return "auto";
    }
  }
}

enum ComputeDriverRouteResponseDtoProviderStatus {
  ok,
  noRoute,
  providerUnavailable,
  timeout,
  unknown;

  static ComputeDriverRouteResponseDtoProviderStatus fromJson(String value) {
    switch (value) {
      case "OK":
        return ComputeDriverRouteResponseDtoProviderStatus.ok;
      case "NO_ROUTE":
        return ComputeDriverRouteResponseDtoProviderStatus.noRoute;
      case "PROVIDER_UNAVAILABLE":
        return ComputeDriverRouteResponseDtoProviderStatus.providerUnavailable;
      case "TIMEOUT":
        return ComputeDriverRouteResponseDtoProviderStatus.timeout;
      default:
        return ComputeDriverRouteResponseDtoProviderStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case ComputeDriverRouteResponseDtoProviderStatus.ok:
        return "OK";
      case ComputeDriverRouteResponseDtoProviderStatus.noRoute:
        return "NO_ROUTE";
      case ComputeDriverRouteResponseDtoProviderStatus.providerUnavailable:
        return "PROVIDER_UNAVAILABLE";
      case ComputeDriverRouteResponseDtoProviderStatus.timeout:
        return "TIMEOUT";
      case ComputeDriverRouteResponseDtoProviderStatus.unknown:
        return "OK";
    }
  }
}

enum CreateDeliveryIncidentDtoType {
  delay,
  vehicleIssue,
  safety,
  other,
  unknown;

  static CreateDeliveryIncidentDtoType fromJson(String value) {
    switch (value) {
      case "DELAY":
        return CreateDeliveryIncidentDtoType.delay;
      case "VEHICLE_ISSUE":
        return CreateDeliveryIncidentDtoType.vehicleIssue;
      case "SAFETY":
        return CreateDeliveryIncidentDtoType.safety;
      case "OTHER":
        return CreateDeliveryIncidentDtoType.other;
      default:
        return CreateDeliveryIncidentDtoType.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case CreateDeliveryIncidentDtoType.delay:
        return "DELAY";
      case CreateDeliveryIncidentDtoType.vehicleIssue:
        return "VEHICLE_ISSUE";
      case CreateDeliveryIncidentDtoType.safety:
        return "SAFETY";
      case CreateDeliveryIncidentDtoType.other:
        return "OTHER";
      case CreateDeliveryIncidentDtoType.unknown:
        return "DELAY";
    }
  }
}

enum CreateOwnMobilityIncidentRequestDtoType {
  ride,
  driver,
  vehicle,
  customerComplaint,
  safety,
  other,
  unknown;

  static CreateOwnMobilityIncidentRequestDtoType fromJson(String value) {
    switch (value) {
      case "RIDE":
        return CreateOwnMobilityIncidentRequestDtoType.ride;
      case "DRIVER":
        return CreateOwnMobilityIncidentRequestDtoType.driver;
      case "VEHICLE":
        return CreateOwnMobilityIncidentRequestDtoType.vehicle;
      case "CUSTOMER_COMPLAINT":
        return CreateOwnMobilityIncidentRequestDtoType.customerComplaint;
      case "SAFETY":
        return CreateOwnMobilityIncidentRequestDtoType.safety;
      case "OTHER":
        return CreateOwnMobilityIncidentRequestDtoType.other;
      default:
        return CreateOwnMobilityIncidentRequestDtoType.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case CreateOwnMobilityIncidentRequestDtoType.ride:
        return "RIDE";
      case CreateOwnMobilityIncidentRequestDtoType.driver:
        return "DRIVER";
      case CreateOwnMobilityIncidentRequestDtoType.vehicle:
        return "VEHICLE";
      case CreateOwnMobilityIncidentRequestDtoType.customerComplaint:
        return "CUSTOMER_COMPLAINT";
      case CreateOwnMobilityIncidentRequestDtoType.safety:
        return "SAFETY";
      case CreateOwnMobilityIncidentRequestDtoType.other:
        return "OTHER";
      case CreateOwnMobilityIncidentRequestDtoType.unknown:
        return "RIDE";
    }
  }
}

enum DeliveryHandoffOtpChallengeResponseDtoStatus {
  pending,
  verified,
  expired,
  locked,
  revoked,
  unknown;

  static DeliveryHandoffOtpChallengeResponseDtoStatus fromJson(String value) {
    switch (value) {
      case "PENDING":
        return DeliveryHandoffOtpChallengeResponseDtoStatus.pending;
      case "VERIFIED":
        return DeliveryHandoffOtpChallengeResponseDtoStatus.verified;
      case "EXPIRED":
        return DeliveryHandoffOtpChallengeResponseDtoStatus.expired;
      case "LOCKED":
        return DeliveryHandoffOtpChallengeResponseDtoStatus.locked;
      case "REVOKED":
        return DeliveryHandoffOtpChallengeResponseDtoStatus.revoked;
      default:
        return DeliveryHandoffOtpChallengeResponseDtoStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DeliveryHandoffOtpChallengeResponseDtoStatus.pending:
        return "PENDING";
      case DeliveryHandoffOtpChallengeResponseDtoStatus.verified:
        return "VERIFIED";
      case DeliveryHandoffOtpChallengeResponseDtoStatus.expired:
        return "EXPIRED";
      case DeliveryHandoffOtpChallengeResponseDtoStatus.locked:
        return "LOCKED";
      case DeliveryHandoffOtpChallengeResponseDtoStatus.revoked:
        return "REVOKED";
      case DeliveryHandoffOtpChallengeResponseDtoStatus.unknown:
        return "PENDING";
    }
  }
}

enum DeliveryHandoffOtpVerificationResponseDtoStatus {
  verified,
  unknown;

  static DeliveryHandoffOtpVerificationResponseDtoStatus fromJson(String value) {
    switch (value) {
      case "VERIFIED":
        return DeliveryHandoffOtpVerificationResponseDtoStatus.verified;
      default:
        return DeliveryHandoffOtpVerificationResponseDtoStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DeliveryHandoffOtpVerificationResponseDtoStatus.verified:
        return "VERIFIED";
      case DeliveryHandoffOtpVerificationResponseDtoStatus.unknown:
        return "VERIFIED";
    }
  }
}

enum DeliveryIncidentResponseDtoStatus {
  open,
  resolved,
  unknown;

  static DeliveryIncidentResponseDtoStatus fromJson(String value) {
    switch (value) {
      case "OPEN":
        return DeliveryIncidentResponseDtoStatus.open;
      case "RESOLVED":
        return DeliveryIncidentResponseDtoStatus.resolved;
      default:
        return DeliveryIncidentResponseDtoStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DeliveryIncidentResponseDtoStatus.open:
        return "OPEN";
      case DeliveryIncidentResponseDtoStatus.resolved:
        return "RESOLVED";
      case DeliveryIncidentResponseDtoStatus.unknown:
        return "OPEN";
    }
  }
}

enum DeliveryIncidentResponseDtoType {
  delay,
  vehicleIssue,
  safety,
  other,
  unknown;

  static DeliveryIncidentResponseDtoType fromJson(String value) {
    switch (value) {
      case "DELAY":
        return DeliveryIncidentResponseDtoType.delay;
      case "VEHICLE_ISSUE":
        return DeliveryIncidentResponseDtoType.vehicleIssue;
      case "SAFETY":
        return DeliveryIncidentResponseDtoType.safety;
      case "OTHER":
        return DeliveryIncidentResponseDtoType.other;
      default:
        return DeliveryIncidentResponseDtoType.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DeliveryIncidentResponseDtoType.delay:
        return "DELAY";
      case DeliveryIncidentResponseDtoType.vehicleIssue:
        return "VEHICLE_ISSUE";
      case DeliveryIncidentResponseDtoType.safety:
        return "SAFETY";
      case DeliveryIncidentResponseDtoType.other:
        return "OTHER";
      case DeliveryIncidentResponseDtoType.unknown:
        return "DELAY";
    }
  }
}

enum DriverAvailabilityResponseDtoDeliveryStatus {
  active,
  inactive,
  suspended,
  unknown;

  static DriverAvailabilityResponseDtoDeliveryStatus fromJson(String value) {
    switch (value) {
      case "ACTIVE":
        return DriverAvailabilityResponseDtoDeliveryStatus.active;
      case "INACTIVE":
        return DriverAvailabilityResponseDtoDeliveryStatus.inactive;
      case "SUSPENDED":
        return DriverAvailabilityResponseDtoDeliveryStatus.suspended;
      default:
        return DriverAvailabilityResponseDtoDeliveryStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverAvailabilityResponseDtoDeliveryStatus.active:
        return "ACTIVE";
      case DriverAvailabilityResponseDtoDeliveryStatus.inactive:
        return "INACTIVE";
      case DriverAvailabilityResponseDtoDeliveryStatus.suspended:
        return "SUSPENDED";
      case DriverAvailabilityResponseDtoDeliveryStatus.unknown:
        return "ACTIVE";
    }
  }
}

enum DriverAvailabilityResponseDtoMobilityAvailabilityStatus {
  offline,
  available,
  busy,
  unknown;

  static DriverAvailabilityResponseDtoMobilityAvailabilityStatus fromJson(String value) {
    switch (value) {
      case "OFFLINE":
        return DriverAvailabilityResponseDtoMobilityAvailabilityStatus.offline;
      case "AVAILABLE":
        return DriverAvailabilityResponseDtoMobilityAvailabilityStatus.available;
      case "BUSY":
        return DriverAvailabilityResponseDtoMobilityAvailabilityStatus.busy;
      default:
        return DriverAvailabilityResponseDtoMobilityAvailabilityStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverAvailabilityResponseDtoMobilityAvailabilityStatus.offline:
        return "OFFLINE";
      case DriverAvailabilityResponseDtoMobilityAvailabilityStatus.available:
        return "AVAILABLE";
      case DriverAvailabilityResponseDtoMobilityAvailabilityStatus.busy:
        return "BUSY";
      case DriverAvailabilityResponseDtoMobilityAvailabilityStatus.unknown:
        return "OFFLINE";
    }
  }
}

enum DriverAvailabilityResponseDtoMobilityOnboardingStatus {
  draft,
  submitted,
  underReview,
  approved,
  rejected,
  suspended,
  unknown;

  static DriverAvailabilityResponseDtoMobilityOnboardingStatus fromJson(String value) {
    switch (value) {
      case "DRAFT":
        return DriverAvailabilityResponseDtoMobilityOnboardingStatus.draft;
      case "SUBMITTED":
        return DriverAvailabilityResponseDtoMobilityOnboardingStatus.submitted;
      case "UNDER_REVIEW":
        return DriverAvailabilityResponseDtoMobilityOnboardingStatus.underReview;
      case "APPROVED":
        return DriverAvailabilityResponseDtoMobilityOnboardingStatus.approved;
      case "REJECTED":
        return DriverAvailabilityResponseDtoMobilityOnboardingStatus.rejected;
      case "SUSPENDED":
        return DriverAvailabilityResponseDtoMobilityOnboardingStatus.suspended;
      default:
        return DriverAvailabilityResponseDtoMobilityOnboardingStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverAvailabilityResponseDtoMobilityOnboardingStatus.draft:
        return "DRAFT";
      case DriverAvailabilityResponseDtoMobilityOnboardingStatus.submitted:
        return "SUBMITTED";
      case DriverAvailabilityResponseDtoMobilityOnboardingStatus.underReview:
        return "UNDER_REVIEW";
      case DriverAvailabilityResponseDtoMobilityOnboardingStatus.approved:
        return "APPROVED";
      case DriverAvailabilityResponseDtoMobilityOnboardingStatus.rejected:
        return "REJECTED";
      case DriverAvailabilityResponseDtoMobilityOnboardingStatus.suspended:
        return "SUSPENDED";
      case DriverAvailabilityResponseDtoMobilityOnboardingStatus.unknown:
        return "DRAFT";
    }
  }
}

enum DriverAvailabilityResponseDtoMobilityOperationalStatus {
  active,
  inactive,
  suspended,
  unknown;

  static DriverAvailabilityResponseDtoMobilityOperationalStatus fromJson(String value) {
    switch (value) {
      case "ACTIVE":
        return DriverAvailabilityResponseDtoMobilityOperationalStatus.active;
      case "INACTIVE":
        return DriverAvailabilityResponseDtoMobilityOperationalStatus.inactive;
      case "SUSPENDED":
        return DriverAvailabilityResponseDtoMobilityOperationalStatus.suspended;
      default:
        return DriverAvailabilityResponseDtoMobilityOperationalStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverAvailabilityResponseDtoMobilityOperationalStatus.active:
        return "ACTIVE";
      case DriverAvailabilityResponseDtoMobilityOperationalStatus.inactive:
        return "INACTIVE";
      case DriverAvailabilityResponseDtoMobilityOperationalStatus.suspended:
        return "SUSPENDED";
      case DriverAvailabilityResponseDtoMobilityOperationalStatus.unknown:
        return "ACTIVE";
    }
  }
}

enum DriverContextProfileDtoDeliveryStatus {
  active,
  inactive,
  suspended,
  unknown;

  static DriverContextProfileDtoDeliveryStatus fromJson(String value) {
    switch (value) {
      case "ACTIVE":
        return DriverContextProfileDtoDeliveryStatus.active;
      case "INACTIVE":
        return DriverContextProfileDtoDeliveryStatus.inactive;
      case "SUSPENDED":
        return DriverContextProfileDtoDeliveryStatus.suspended;
      default:
        return DriverContextProfileDtoDeliveryStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverContextProfileDtoDeliveryStatus.active:
        return "ACTIVE";
      case DriverContextProfileDtoDeliveryStatus.inactive:
        return "INACTIVE";
      case DriverContextProfileDtoDeliveryStatus.suspended:
        return "SUSPENDED";
      case DriverContextProfileDtoDeliveryStatus.unknown:
        return "ACTIVE";
    }
  }
}

enum DriverContextProfileDtoMobilityAvailabilityStatus {
  offline,
  available,
  busy,
  unknown;

  static DriverContextProfileDtoMobilityAvailabilityStatus fromJson(String value) {
    switch (value) {
      case "OFFLINE":
        return DriverContextProfileDtoMobilityAvailabilityStatus.offline;
      case "AVAILABLE":
        return DriverContextProfileDtoMobilityAvailabilityStatus.available;
      case "BUSY":
        return DriverContextProfileDtoMobilityAvailabilityStatus.busy;
      default:
        return DriverContextProfileDtoMobilityAvailabilityStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverContextProfileDtoMobilityAvailabilityStatus.offline:
        return "OFFLINE";
      case DriverContextProfileDtoMobilityAvailabilityStatus.available:
        return "AVAILABLE";
      case DriverContextProfileDtoMobilityAvailabilityStatus.busy:
        return "BUSY";
      case DriverContextProfileDtoMobilityAvailabilityStatus.unknown:
        return "OFFLINE";
    }
  }
}

enum DriverContextProfileDtoMobilityOnboardingStatus {
  draft,
  submitted,
  underReview,
  approved,
  rejected,
  suspended,
  unknown;

  static DriverContextProfileDtoMobilityOnboardingStatus fromJson(String value) {
    switch (value) {
      case "DRAFT":
        return DriverContextProfileDtoMobilityOnboardingStatus.draft;
      case "SUBMITTED":
        return DriverContextProfileDtoMobilityOnboardingStatus.submitted;
      case "UNDER_REVIEW":
        return DriverContextProfileDtoMobilityOnboardingStatus.underReview;
      case "APPROVED":
        return DriverContextProfileDtoMobilityOnboardingStatus.approved;
      case "REJECTED":
        return DriverContextProfileDtoMobilityOnboardingStatus.rejected;
      case "SUSPENDED":
        return DriverContextProfileDtoMobilityOnboardingStatus.suspended;
      default:
        return DriverContextProfileDtoMobilityOnboardingStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverContextProfileDtoMobilityOnboardingStatus.draft:
        return "DRAFT";
      case DriverContextProfileDtoMobilityOnboardingStatus.submitted:
        return "SUBMITTED";
      case DriverContextProfileDtoMobilityOnboardingStatus.underReview:
        return "UNDER_REVIEW";
      case DriverContextProfileDtoMobilityOnboardingStatus.approved:
        return "APPROVED";
      case DriverContextProfileDtoMobilityOnboardingStatus.rejected:
        return "REJECTED";
      case DriverContextProfileDtoMobilityOnboardingStatus.suspended:
        return "SUSPENDED";
      case DriverContextProfileDtoMobilityOnboardingStatus.unknown:
        return "DRAFT";
    }
  }
}

enum DriverContextProfileDtoMobilityOperationalStatus {
  active,
  inactive,
  suspended,
  unknown;

  static DriverContextProfileDtoMobilityOperationalStatus fromJson(String value) {
    switch (value) {
      case "ACTIVE":
        return DriverContextProfileDtoMobilityOperationalStatus.active;
      case "INACTIVE":
        return DriverContextProfileDtoMobilityOperationalStatus.inactive;
      case "SUSPENDED":
        return DriverContextProfileDtoMobilityOperationalStatus.suspended;
      default:
        return DriverContextProfileDtoMobilityOperationalStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverContextProfileDtoMobilityOperationalStatus.active:
        return "ACTIVE";
      case DriverContextProfileDtoMobilityOperationalStatus.inactive:
        return "INACTIVE";
      case DriverContextProfileDtoMobilityOperationalStatus.suspended:
        return "SUSPENDED";
      case DriverContextProfileDtoMobilityOperationalStatus.unknown:
        return "ACTIVE";
    }
  }
}

enum DriverContextProfileDtoServiceTypes {
  taxi,
  taxiMoto,
  unknown;

  static DriverContextProfileDtoServiceTypes fromJson(String value) {
    switch (value) {
      case "TAXI":
        return DriverContextProfileDtoServiceTypes.taxi;
      case "TAXI_MOTO":
        return DriverContextProfileDtoServiceTypes.taxiMoto;
      default:
        return DriverContextProfileDtoServiceTypes.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverContextProfileDtoServiceTypes.taxi:
        return "TAXI";
      case DriverContextProfileDtoServiceTypes.taxiMoto:
        return "TAXI_MOTO";
      case DriverContextProfileDtoServiceTypes.unknown:
        return "TAXI";
    }
  }
}

enum DriverContextVehicleSummaryDtoAllowedServiceTypes {
  taxi,
  taxiMoto,
  unknown;

  static DriverContextVehicleSummaryDtoAllowedServiceTypes fromJson(String value) {
    switch (value) {
      case "TAXI":
        return DriverContextVehicleSummaryDtoAllowedServiceTypes.taxi;
      case "TAXI_MOTO":
        return DriverContextVehicleSummaryDtoAllowedServiceTypes.taxiMoto;
      default:
        return DriverContextVehicleSummaryDtoAllowedServiceTypes.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverContextVehicleSummaryDtoAllowedServiceTypes.taxi:
        return "TAXI";
      case DriverContextVehicleSummaryDtoAllowedServiceTypes.taxiMoto:
        return "TAXI_MOTO";
      case DriverContextVehicleSummaryDtoAllowedServiceTypes.unknown:
        return "TAXI";
    }
  }
}

enum DriverContextVehicleSummaryDtoStatus {
  pendingValidation,
  active,
  suspended,
  retired,
  unknown;

  static DriverContextVehicleSummaryDtoStatus fromJson(String value) {
    switch (value) {
      case "PENDING_VALIDATION":
        return DriverContextVehicleSummaryDtoStatus.pendingValidation;
      case "ACTIVE":
        return DriverContextVehicleSummaryDtoStatus.active;
      case "SUSPENDED":
        return DriverContextVehicleSummaryDtoStatus.suspended;
      case "RETIRED":
        return DriverContextVehicleSummaryDtoStatus.retired;
      default:
        return DriverContextVehicleSummaryDtoStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverContextVehicleSummaryDtoStatus.pendingValidation:
        return "PENDING_VALIDATION";
      case DriverContextVehicleSummaryDtoStatus.active:
        return "ACTIVE";
      case DriverContextVehicleSummaryDtoStatus.suspended:
        return "SUSPENDED";
      case DriverContextVehicleSummaryDtoStatus.retired:
        return "RETIRED";
      case DriverContextVehicleSummaryDtoStatus.unknown:
        return "PENDING_VALIDATION";
    }
  }
}

enum DriverContextVehicleSummaryDtoType {
  car,
  motorcycle,
  unknown;

  static DriverContextVehicleSummaryDtoType fromJson(String value) {
    switch (value) {
      case "CAR":
        return DriverContextVehicleSummaryDtoType.car;
      case "MOTORCYCLE":
        return DriverContextVehicleSummaryDtoType.motorcycle;
      default:
        return DriverContextVehicleSummaryDtoType.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverContextVehicleSummaryDtoType.car:
        return "CAR";
      case DriverContextVehicleSummaryDtoType.motorcycle:
        return "MOTORCYCLE";
      case DriverContextVehicleSummaryDtoType.unknown:
        return "CAR";
    }
  }
}

enum DriverMissionCompletionResponseDtoEvidenceType {
  otp,
  unknown;

  static DriverMissionCompletionResponseDtoEvidenceType fromJson(String value) {
    switch (value) {
      case "OTP":
        return DriverMissionCompletionResponseDtoEvidenceType.otp;
      default:
        return DriverMissionCompletionResponseDtoEvidenceType.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverMissionCompletionResponseDtoEvidenceType.otp:
        return "OTP";
      case DriverMissionCompletionResponseDtoEvidenceType.unknown:
        return "OTP";
    }
  }
}

enum DriverMissionCompletionResponseDtoOrderStatus {
  delivered,
  unknown;

  static DriverMissionCompletionResponseDtoOrderStatus fromJson(String value) {
    switch (value) {
      case "DELIVERED":
        return DriverMissionCompletionResponseDtoOrderStatus.delivered;
      default:
        return DriverMissionCompletionResponseDtoOrderStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverMissionCompletionResponseDtoOrderStatus.delivered:
        return "DELIVERED";
      case DriverMissionCompletionResponseDtoOrderStatus.unknown:
        return "DELIVERED";
    }
  }
}

enum DriverMissionCompletionResponseDtoStatus {
  delivered,
  unknown;

  static DriverMissionCompletionResponseDtoStatus fromJson(String value) {
    switch (value) {
      case "DELIVERED":
        return DriverMissionCompletionResponseDtoStatus.delivered;
      default:
        return DriverMissionCompletionResponseDtoStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverMissionCompletionResponseDtoStatus.delivered:
        return "DELIVERED";
      case DriverMissionCompletionResponseDtoStatus.unknown:
        return "DELIVERED";
    }
  }
}

enum DriverMissionResponseDtoStatus {
  readyForDispatch,
  assigned,
  outForDelivery,
  delivered,
  failed,
  cancelled,
  unknown;

  static DriverMissionResponseDtoStatus fromJson(String value) {
    switch (value) {
      case "READY_FOR_DISPATCH":
        return DriverMissionResponseDtoStatus.readyForDispatch;
      case "ASSIGNED":
        return DriverMissionResponseDtoStatus.assigned;
      case "OUT_FOR_DELIVERY":
        return DriverMissionResponseDtoStatus.outForDelivery;
      case "DELIVERED":
        return DriverMissionResponseDtoStatus.delivered;
      case "FAILED":
        return DriverMissionResponseDtoStatus.failed;
      case "CANCELLED":
        return DriverMissionResponseDtoStatus.cancelled;
      default:
        return DriverMissionResponseDtoStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverMissionResponseDtoStatus.readyForDispatch:
        return "READY_FOR_DISPATCH";
      case DriverMissionResponseDtoStatus.assigned:
        return "ASSIGNED";
      case DriverMissionResponseDtoStatus.outForDelivery:
        return "OUT_FOR_DELIVERY";
      case DriverMissionResponseDtoStatus.delivered:
        return "DELIVERED";
      case DriverMissionResponseDtoStatus.failed:
        return "FAILED";
      case DriverMissionResponseDtoStatus.cancelled:
        return "CANCELLED";
      case DriverMissionResponseDtoStatus.unknown:
        return "READY_FOR_DISPATCH";
    }
  }
}

enum DriverMobilityOfferDtoServiceType {
  taxi,
  taxiMoto,
  unknown;

  static DriverMobilityOfferDtoServiceType fromJson(String value) {
    switch (value) {
      case "TAXI":
        return DriverMobilityOfferDtoServiceType.taxi;
      case "TAXI_MOTO":
        return DriverMobilityOfferDtoServiceType.taxiMoto;
      default:
        return DriverMobilityOfferDtoServiceType.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverMobilityOfferDtoServiceType.taxi:
        return "TAXI";
      case DriverMobilityOfferDtoServiceType.taxiMoto:
        return "TAXI_MOTO";
      case DriverMobilityOfferDtoServiceType.unknown:
        return "TAXI";
    }
  }
}

enum DriverVehicleDtoAllowedServiceTypes {
  taxi,
  taxiMoto,
  unknown;

  static DriverVehicleDtoAllowedServiceTypes fromJson(String value) {
    switch (value) {
      case "TAXI":
        return DriverVehicleDtoAllowedServiceTypes.taxi;
      case "TAXI_MOTO":
        return DriverVehicleDtoAllowedServiceTypes.taxiMoto;
      default:
        return DriverVehicleDtoAllowedServiceTypes.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverVehicleDtoAllowedServiceTypes.taxi:
        return "TAXI";
      case DriverVehicleDtoAllowedServiceTypes.taxiMoto:
        return "TAXI_MOTO";
      case DriverVehicleDtoAllowedServiceTypes.unknown:
        return "TAXI";
    }
  }
}

enum DriverVehicleDtoStatus {
  pendingValidation,
  active,
  suspended,
  retired,
  unknown;

  static DriverVehicleDtoStatus fromJson(String value) {
    switch (value) {
      case "PENDING_VALIDATION":
        return DriverVehicleDtoStatus.pendingValidation;
      case "ACTIVE":
        return DriverVehicleDtoStatus.active;
      case "SUSPENDED":
        return DriverVehicleDtoStatus.suspended;
      case "RETIRED":
        return DriverVehicleDtoStatus.retired;
      default:
        return DriverVehicleDtoStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverVehicleDtoStatus.pendingValidation:
        return "PENDING_VALIDATION";
      case DriverVehicleDtoStatus.active:
        return "ACTIVE";
      case DriverVehicleDtoStatus.suspended:
        return "SUSPENDED";
      case DriverVehicleDtoStatus.retired:
        return "RETIRED";
      case DriverVehicleDtoStatus.unknown:
        return "PENDING_VALIDATION";
    }
  }
}

enum DriverVehicleDtoType {
  car,
  motorcycle,
  unknown;

  static DriverVehicleDtoType fromJson(String value) {
    switch (value) {
      case "CAR":
        return DriverVehicleDtoType.car;
      case "MOTORCYCLE":
        return DriverVehicleDtoType.motorcycle;
      default:
        return DriverVehicleDtoType.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverVehicleDtoType.car:
        return "CAR";
      case DriverVehicleDtoType.motorcycle:
        return "MOTORCYCLE";
      case DriverVehicleDtoType.unknown:
        return "CAR";
    }
  }
}

enum DriverWorkFeedItemDtoServiceType {
  delivery,
  taxi,
  taxiMoto,
  unknown;

  static DriverWorkFeedItemDtoServiceType fromJson(String value) {
    switch (value) {
      case "DELIVERY":
        return DriverWorkFeedItemDtoServiceType.delivery;
      case "TAXI":
        return DriverWorkFeedItemDtoServiceType.taxi;
      case "TAXI_MOTO":
        return DriverWorkFeedItemDtoServiceType.taxiMoto;
      default:
        return DriverWorkFeedItemDtoServiceType.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverWorkFeedItemDtoServiceType.delivery:
        return "DELIVERY";
      case DriverWorkFeedItemDtoServiceType.taxi:
        return "TAXI";
      case DriverWorkFeedItemDtoServiceType.taxiMoto:
        return "TAXI_MOTO";
      case DriverWorkFeedItemDtoServiceType.unknown:
        return "DELIVERY";
    }
  }
}

enum DriverWorkFeedItemDtoWorkType {
  delivery,
  ride,
  unknown;

  static DriverWorkFeedItemDtoWorkType fromJson(String value) {
    switch (value) {
      case "DELIVERY":
        return DriverWorkFeedItemDtoWorkType.delivery;
      case "RIDE":
        return DriverWorkFeedItemDtoWorkType.ride;
      default:
        return DriverWorkFeedItemDtoWorkType.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case DriverWorkFeedItemDtoWorkType.delivery:
        return "DELIVERY";
      case DriverWorkFeedItemDtoWorkType.ride:
        return "RIDE";
      case DriverWorkFeedItemDtoWorkType.unknown:
        return "DELIVERY";
    }
  }
}

enum MobilityDriverDtoAllowedServiceTypes {
  taxi,
  taxiMoto,
  unknown;

  static MobilityDriverDtoAllowedServiceTypes fromJson(String value) {
    switch (value) {
      case "TAXI":
        return MobilityDriverDtoAllowedServiceTypes.taxi;
      case "TAXI_MOTO":
        return MobilityDriverDtoAllowedServiceTypes.taxiMoto;
      default:
        return MobilityDriverDtoAllowedServiceTypes.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case MobilityDriverDtoAllowedServiceTypes.taxi:
        return "TAXI";
      case MobilityDriverDtoAllowedServiceTypes.taxiMoto:
        return "TAXI_MOTO";
      case MobilityDriverDtoAllowedServiceTypes.unknown:
        return "TAXI";
    }
  }
}

enum MobilityDriverDtoAvailabilityStatus {
  offline,
  available,
  busy,
  unknown;

  static MobilityDriverDtoAvailabilityStatus fromJson(String value) {
    switch (value) {
      case "OFFLINE":
        return MobilityDriverDtoAvailabilityStatus.offline;
      case "AVAILABLE":
        return MobilityDriverDtoAvailabilityStatus.available;
      case "BUSY":
        return MobilityDriverDtoAvailabilityStatus.busy;
      default:
        return MobilityDriverDtoAvailabilityStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case MobilityDriverDtoAvailabilityStatus.offline:
        return "OFFLINE";
      case MobilityDriverDtoAvailabilityStatus.available:
        return "AVAILABLE";
      case MobilityDriverDtoAvailabilityStatus.busy:
        return "BUSY";
      case MobilityDriverDtoAvailabilityStatus.unknown:
        return "OFFLINE";
    }
  }
}

enum MobilityDriverDtoOnboardingStatus {
  draft,
  submitted,
  underReview,
  approved,
  rejected,
  suspended,
  unknown;

  static MobilityDriverDtoOnboardingStatus fromJson(String value) {
    switch (value) {
      case "DRAFT":
        return MobilityDriverDtoOnboardingStatus.draft;
      case "SUBMITTED":
        return MobilityDriverDtoOnboardingStatus.submitted;
      case "UNDER_REVIEW":
        return MobilityDriverDtoOnboardingStatus.underReview;
      case "APPROVED":
        return MobilityDriverDtoOnboardingStatus.approved;
      case "REJECTED":
        return MobilityDriverDtoOnboardingStatus.rejected;
      case "SUSPENDED":
        return MobilityDriverDtoOnboardingStatus.suspended;
      default:
        return MobilityDriverDtoOnboardingStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case MobilityDriverDtoOnboardingStatus.draft:
        return "DRAFT";
      case MobilityDriverDtoOnboardingStatus.submitted:
        return "SUBMITTED";
      case MobilityDriverDtoOnboardingStatus.underReview:
        return "UNDER_REVIEW";
      case MobilityDriverDtoOnboardingStatus.approved:
        return "APPROVED";
      case MobilityDriverDtoOnboardingStatus.rejected:
        return "REJECTED";
      case MobilityDriverDtoOnboardingStatus.suspended:
        return "SUSPENDED";
      case MobilityDriverDtoOnboardingStatus.unknown:
        return "DRAFT";
    }
  }
}

enum MobilityDriverDtoOperationalStatus {
  active,
  inactive,
  suspended,
  unknown;

  static MobilityDriverDtoOperationalStatus fromJson(String value) {
    switch (value) {
      case "ACTIVE":
        return MobilityDriverDtoOperationalStatus.active;
      case "INACTIVE":
        return MobilityDriverDtoOperationalStatus.inactive;
      case "SUSPENDED":
        return MobilityDriverDtoOperationalStatus.suspended;
      default:
        return MobilityDriverDtoOperationalStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case MobilityDriverDtoOperationalStatus.active:
        return "ACTIVE";
      case MobilityDriverDtoOperationalStatus.inactive:
        return "INACTIVE";
      case MobilityDriverDtoOperationalStatus.suspended:
        return "SUSPENDED";
      case MobilityDriverDtoOperationalStatus.unknown:
        return "ACTIVE";
    }
  }
}

enum MobilityIncidentDtoStatus {
  open,
  inProgress,
  resolved,
  dismissed,
  unknown;

  static MobilityIncidentDtoStatus fromJson(String value) {
    switch (value) {
      case "OPEN":
        return MobilityIncidentDtoStatus.open;
      case "IN_PROGRESS":
        return MobilityIncidentDtoStatus.inProgress;
      case "RESOLVED":
        return MobilityIncidentDtoStatus.resolved;
      case "DISMISSED":
        return MobilityIncidentDtoStatus.dismissed;
      default:
        return MobilityIncidentDtoStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case MobilityIncidentDtoStatus.open:
        return "OPEN";
      case MobilityIncidentDtoStatus.inProgress:
        return "IN_PROGRESS";
      case MobilityIncidentDtoStatus.resolved:
        return "RESOLVED";
      case MobilityIncidentDtoStatus.dismissed:
        return "DISMISSED";
      case MobilityIncidentDtoStatus.unknown:
        return "OPEN";
    }
  }
}

enum MobilityIncidentDtoType {
  ride,
  driver,
  vehicle,
  customerComplaint,
  safety,
  other,
  unknown;

  static MobilityIncidentDtoType fromJson(String value) {
    switch (value) {
      case "RIDE":
        return MobilityIncidentDtoType.ride;
      case "DRIVER":
        return MobilityIncidentDtoType.driver;
      case "VEHICLE":
        return MobilityIncidentDtoType.vehicle;
      case "CUSTOMER_COMPLAINT":
        return MobilityIncidentDtoType.customerComplaint;
      case "SAFETY":
        return MobilityIncidentDtoType.safety;
      case "OTHER":
        return MobilityIncidentDtoType.other;
      default:
        return MobilityIncidentDtoType.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case MobilityIncidentDtoType.ride:
        return "RIDE";
      case MobilityIncidentDtoType.driver:
        return "DRIVER";
      case MobilityIncidentDtoType.vehicle:
        return "VEHICLE";
      case MobilityIncidentDtoType.customerComplaint:
        return "CUSTOMER_COMPLAINT";
      case MobilityIncidentDtoType.safety:
        return "SAFETY";
      case MobilityIncidentDtoType.other:
        return "OTHER";
      case MobilityIncidentDtoType.unknown:
        return "RIDE";
    }
  }
}

enum MobilityRideDetailDtoServiceType {
  taxi,
  taxiMoto,
  unknown;

  static MobilityRideDetailDtoServiceType fromJson(String value) {
    switch (value) {
      case "TAXI":
        return MobilityRideDetailDtoServiceType.taxi;
      case "TAXI_MOTO":
        return MobilityRideDetailDtoServiceType.taxiMoto;
      default:
        return MobilityRideDetailDtoServiceType.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case MobilityRideDetailDtoServiceType.taxi:
        return "TAXI";
      case MobilityRideDetailDtoServiceType.taxiMoto:
        return "TAXI_MOTO";
      case MobilityRideDetailDtoServiceType.unknown:
        return "TAXI";
    }
  }
}

enum MobilityRideDetailDtoStatus {
  driverAssigned,
  driverEnRoute,
  driverArrived,
  inProgress,
  completed,
  cancelled,
  unknown;

  static MobilityRideDetailDtoStatus fromJson(String value) {
    switch (value) {
      case "DRIVER_ASSIGNED":
        return MobilityRideDetailDtoStatus.driverAssigned;
      case "DRIVER_EN_ROUTE":
        return MobilityRideDetailDtoStatus.driverEnRoute;
      case "DRIVER_ARRIVED":
        return MobilityRideDetailDtoStatus.driverArrived;
      case "IN_PROGRESS":
        return MobilityRideDetailDtoStatus.inProgress;
      case "COMPLETED":
        return MobilityRideDetailDtoStatus.completed;
      case "CANCELLED":
        return MobilityRideDetailDtoStatus.cancelled;
      default:
        return MobilityRideDetailDtoStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case MobilityRideDetailDtoStatus.driverAssigned:
        return "DRIVER_ASSIGNED";
      case MobilityRideDetailDtoStatus.driverEnRoute:
        return "DRIVER_EN_ROUTE";
      case MobilityRideDetailDtoStatus.driverArrived:
        return "DRIVER_ARRIVED";
      case MobilityRideDetailDtoStatus.inProgress:
        return "IN_PROGRESS";
      case MobilityRideDetailDtoStatus.completed:
        return "COMPLETED";
      case MobilityRideDetailDtoStatus.cancelled:
        return "CANCELLED";
      case MobilityRideDetailDtoStatus.unknown:
        return "DRIVER_ASSIGNED";
    }
  }
}

enum RouteGeometryDtoType {
  linestring,
  unknown;

  static RouteGeometryDtoType fromJson(String value) {
    switch (value) {
      case "LineString":
        return RouteGeometryDtoType.linestring;
      default:
        return RouteGeometryDtoType.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case RouteGeometryDtoType.linestring:
        return "LineString";
      case RouteGeometryDtoType.unknown:
        return "LineString";
    }
  }
}

enum TransitionMobilityRideDtoStatus {
  driverAssigned,
  driverEnRoute,
  driverArrived,
  inProgress,
  completed,
  cancelled,
  unknown;

  static TransitionMobilityRideDtoStatus fromJson(String value) {
    switch (value) {
      case "DRIVER_ASSIGNED":
        return TransitionMobilityRideDtoStatus.driverAssigned;
      case "DRIVER_EN_ROUTE":
        return TransitionMobilityRideDtoStatus.driverEnRoute;
      case "DRIVER_ARRIVED":
        return TransitionMobilityRideDtoStatus.driverArrived;
      case "IN_PROGRESS":
        return TransitionMobilityRideDtoStatus.inProgress;
      case "COMPLETED":
        return TransitionMobilityRideDtoStatus.completed;
      case "CANCELLED":
        return TransitionMobilityRideDtoStatus.cancelled;
      default:
        return TransitionMobilityRideDtoStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case TransitionMobilityRideDtoStatus.driverAssigned:
        return "DRIVER_ASSIGNED";
      case TransitionMobilityRideDtoStatus.driverEnRoute:
        return "DRIVER_EN_ROUTE";
      case TransitionMobilityRideDtoStatus.driverArrived:
        return "DRIVER_ARRIVED";
      case TransitionMobilityRideDtoStatus.inProgress:
        return "IN_PROGRESS";
      case TransitionMobilityRideDtoStatus.completed:
        return "COMPLETED";
      case TransitionMobilityRideDtoStatus.cancelled:
        return "CANCELLED";
      case TransitionMobilityRideDtoStatus.unknown:
        return "DRIVER_ASSIGNED";
    }
  }
}

enum UpdateDriverAvailabilityDtoAvailabilityStatus {
  offline,
  available,
  busy,
  unknown;

  static UpdateDriverAvailabilityDtoAvailabilityStatus fromJson(String value) {
    switch (value) {
      case "OFFLINE":
        return UpdateDriverAvailabilityDtoAvailabilityStatus.offline;
      case "AVAILABLE":
        return UpdateDriverAvailabilityDtoAvailabilityStatus.available;
      case "BUSY":
        return UpdateDriverAvailabilityDtoAvailabilityStatus.busy;
      default:
        return UpdateDriverAvailabilityDtoAvailabilityStatus.unknown;
    }
  }

  String toJson() {
    switch (this) {
      case UpdateDriverAvailabilityDtoAvailabilityStatus.offline:
        return "OFFLINE";
      case UpdateDriverAvailabilityDtoAvailabilityStatus.available:
        return "AVAILABLE";
      case UpdateDriverAvailabilityDtoAvailabilityStatus.busy:
        return "BUSY";
      case UpdateDriverAvailabilityDtoAvailabilityStatus.unknown:
        return "OFFLINE";
    }
  }
}



class AuthCapabilitiesResponseDto {
  const AuthCapabilitiesResponseDto({
    required this.actorId,
    required this.memberships,
    required this.effectivePermissionCodes,
    required this.capabilities,
  });

  final String actorId;
  final List<AuthCapabilityMembershipResponseDto> memberships;
  final List<String> effectivePermissionCodes;
  final List<String> capabilities;

  factory AuthCapabilitiesResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthCapabilitiesResponseDto(
      actorId: json["actorId"] as String,
      memberships: (json["memberships"] as List<dynamic>).map((e) => AuthCapabilityMembershipResponseDto.fromJson(e as Map<String, dynamic>)).toList(),
      effectivePermissionCodes: (json["effectivePermissionCodes"] as List<dynamic>).map((e) => e as String).toList(),
      capabilities: (json["capabilities"] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "actorId": actorId,
      "memberships": memberships.map((e) => e.toJson()).toList(),
      "effectivePermissionCodes": effectivePermissionCodes.map((e) => e).toList(),
      "capabilities": capabilities.map((e) => e).toList(),
    };
  }
}

class AuthCapabilityCountryScopeResponseDto {
  const AuthCapabilityCountryScopeResponseDto({
    this.organizationCountryId,
    required this.countryCode,
  });

  final String? organizationCountryId;
  final String countryCode;

  factory AuthCapabilityCountryScopeResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthCapabilityCountryScopeResponseDto(
      organizationCountryId: json["organizationCountryId"] as String?,
      countryCode: json["countryCode"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "organizationCountryId": ?organizationCountryId,
      "countryCode": countryCode,
    };
  }
}

class AuthCapabilityMembershipResponseDto {
  const AuthCapabilityMembershipResponseDto({
    required this.membershipId,
    required this.organizationId,
    required this.countryScopes,
    required this.roles,
    required this.permissionCodes,
  });

  final String membershipId;
  final String organizationId;
  final List<AuthCapabilityCountryScopeResponseDto> countryScopes;
  final List<AuthCapabilityRoleResponseDto> roles;
  final List<String> permissionCodes;

  factory AuthCapabilityMembershipResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthCapabilityMembershipResponseDto(
      membershipId: json["membershipId"] as String,
      organizationId: json["organizationId"] as String,
      countryScopes: (json["countryScopes"] as List<dynamic>).map((e) => AuthCapabilityCountryScopeResponseDto.fromJson(e as Map<String, dynamic>)).toList(),
      roles: (json["roles"] as List<dynamic>).map((e) => AuthCapabilityRoleResponseDto.fromJson(e as Map<String, dynamic>)).toList(),
      permissionCodes: (json["permissionCodes"] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "membershipId": membershipId,
      "organizationId": organizationId,
      "countryScopes": countryScopes.map((e) => e.toJson()).toList(),
      "roles": roles.map((e) => e.toJson()).toList(),
      "permissionCodes": permissionCodes.map((e) => e).toList(),
    };
  }
}

class AuthCapabilityRoleResponseDto {
  const AuthCapabilityRoleResponseDto({
    required this.roleId,
    required this.code,
    this.description,
  });

  final String roleId;
  final String code;
  final String? description;

  factory AuthCapabilityRoleResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthCapabilityRoleResponseDto(
      roleId: json["roleId"] as String,
      code: json["code"] as String,
      description: json["description"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "roleId": roleId,
      "code": code,
      "description": ?description,
    };
  }
}

class AuthTokensResponseDto {
  const AuthTokensResponseDto({
    required this.tokenType,
    required this.accessToken,
    required this.accessTokenExpiresIn,
    required this.refreshToken,
    required this.refreshTokenExpiresIn,
  });

  final String tokenType;
  final String accessToken;
  final num accessTokenExpiresIn;
  final String refreshToken;
  final num refreshTokenExpiresIn;

  factory AuthTokensResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthTokensResponseDto(
      tokenType: json["tokenType"] as String,
      accessToken: json["accessToken"] as String,
      accessTokenExpiresIn: (json["accessTokenExpiresIn"] as num?)!,
      refreshToken: json["refreshToken"] as String,
      refreshTokenExpiresIn: (json["refreshTokenExpiresIn"] as num?)!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "tokenType": tokenType,
      "accessToken": accessToken,
      "accessTokenExpiresIn": accessTokenExpiresIn,
      "refreshToken": refreshToken,
      "refreshTokenExpiresIn": refreshTokenExpiresIn,
    };
  }
}

class CompleteDriverMissionDto {
  const CompleteDriverMissionDto({
    required this.otpChallengeId,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
  });

  final String otpChallengeId;
  final num? latitude;
  final num? longitude;
  final num? accuracyMeters;

  factory CompleteDriverMissionDto.fromJson(Map<String, dynamic> json) {
    return CompleteDriverMissionDto(
      otpChallengeId: json["otpChallengeId"] as String,
      latitude: (json["latitude"] as num?),
      longitude: (json["longitude"] as num?),
      accuracyMeters: (json["accuracyMeters"] as num?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "otpChallengeId": otpChallengeId,
      "latitude": ?latitude,
      "longitude": ?longitude,
      "accuracyMeters": ?accuracyMeters,
    };
  }
}

class ComputeDriverRouteRequestDto {
  const ComputeDriverRouteRequestDto({
    required this.origin,
    required this.destination,
    required this.serviceType,
    this.vehicleMode,
  });

  final NavigationGeoPointInputDto origin;
  final NavigationGeoPointInputDto destination;
  final ComputeDriverRouteRequestDtoServiceType serviceType;
  final ComputeDriverRouteRequestDtoVehicleMode? vehicleMode;

  factory ComputeDriverRouteRequestDto.fromJson(Map<String, dynamic> json) {
    return ComputeDriverRouteRequestDto(
      origin: NavigationGeoPointInputDto.fromJson(json["origin"] as Map<String, dynamic>),
      destination: NavigationGeoPointInputDto.fromJson(json["destination"] as Map<String, dynamic>),
      serviceType: ComputeDriverRouteRequestDtoServiceType.fromJson(json["serviceType"] as String),
      vehicleMode: json["vehicleMode"] == null ? null : ComputeDriverRouteRequestDtoVehicleMode.fromJson(json["vehicleMode"] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "origin": origin.toJson(),
      "destination": destination.toJson(),
      "serviceType": serviceType.toJson(),
      "vehicleMode": ?vehicleMode?.toJson(),
    };
  }
}

class ComputeDriverRouteResponseDto {
  const ComputeDriverRouteResponseDto({
    this.geometry,
    this.distanceMeters,
    this.durationSeconds,
    required this.profile,
    required this.maneuvers,
    required this.providerStatus,
  });

  final RouteGeometryDto? geometry;
  final num? distanceMeters;
  final num? durationSeconds;
  final ComputeDriverRouteResponseDtoProfile profile;
  final List<NavigationManeuverDto> maneuvers;
  final ComputeDriverRouteResponseDtoProviderStatus providerStatus;

  factory ComputeDriverRouteResponseDto.fromJson(Map<String, dynamic> json) {
    return ComputeDriverRouteResponseDto(
      geometry: json["geometry"] == null ? null : RouteGeometryDto.fromJson(json["geometry"] as Map<String, dynamic>),
      distanceMeters: (json["distanceMeters"] as num?),
      durationSeconds: (json["durationSeconds"] as num?),
      profile: ComputeDriverRouteResponseDtoProfile.fromJson(json["profile"] as String),
      maneuvers: (json["maneuvers"] as List<dynamic>).map((e) => NavigationManeuverDto.fromJson(e as Map<String, dynamic>)).toList(),
      providerStatus: ComputeDriverRouteResponseDtoProviderStatus.fromJson(json["providerStatus"] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "geometry": ?geometry?.toJson(),
      "distanceMeters": ?distanceMeters,
      "durationSeconds": ?durationSeconds,
      "profile": profile.toJson(),
      "maneuvers": maneuvers.map((e) => e.toJson()).toList(),
      "providerStatus": providerStatus.toJson(),
    };
  }
}

class CountryScopeResponseDto {
  const CountryScopeResponseDto({
    required this.organizationCountryId,
    required this.countryCode,
  });

  final String organizationCountryId;
  final String countryCode;

  factory CountryScopeResponseDto.fromJson(Map<String, dynamic> json) {
    return CountryScopeResponseDto(
      organizationCountryId: json["organizationCountryId"] as String,
      countryCode: json["countryCode"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "organizationCountryId": organizationCountryId,
      "countryCode": countryCode,
    };
  }
}

class CreateDeliveryIncidentDto {
  const CreateDeliveryIncidentDto({
    required this.type,
    this.comment,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
  });

  final CreateDeliveryIncidentDtoType type;
  final String? comment;
  final num? latitude;
  final num? longitude;
  final num? accuracyMeters;

  factory CreateDeliveryIncidentDto.fromJson(Map<String, dynamic> json) {
    return CreateDeliveryIncidentDto(
      type: CreateDeliveryIncidentDtoType.fromJson(json["type"] as String),
      comment: json["comment"] as String?,
      latitude: (json["latitude"] as num?),
      longitude: (json["longitude"] as num?),
      accuracyMeters: (json["accuracyMeters"] as num?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type.toJson(),
      "comment": ?comment,
      "latitude": ?latitude,
      "longitude": ?longitude,
      "accuracyMeters": ?accuracyMeters,
    };
  }
}

class CreateOwnMobilityIncidentRequestDto {
  const CreateOwnMobilityIncidentRequestDto({
    this.rideId,
    required this.type,
    this.comment,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    required this.organizationId,
    required this.countryCode,
  });

  final String? rideId;
  final CreateOwnMobilityIncidentRequestDtoType type;
  final String? comment;
  final num? latitude;
  final num? longitude;
  final num? accuracyMeters;
  final String organizationId;
  final String countryCode;

  factory CreateOwnMobilityIncidentRequestDto.fromJson(Map<String, dynamic> json) {
    return CreateOwnMobilityIncidentRequestDto(
      rideId: json["rideId"] as String?,
      type: CreateOwnMobilityIncidentRequestDtoType.fromJson(json["type"] as String),
      comment: json["comment"] as String?,
      latitude: (json["latitude"] as num?),
      longitude: (json["longitude"] as num?),
      accuracyMeters: (json["accuracyMeters"] as num?),
      organizationId: json["organizationId"] as String,
      countryCode: json["countryCode"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "rideId": ?rideId,
      "type": type.toJson(),
      "comment": ?comment,
      "latitude": ?latitude,
      "longitude": ?longitude,
      "accuracyMeters": ?accuracyMeters,
      "organizationId": organizationId,
      "countryCode": countryCode,
    };
  }
}

class DeliveryHandoffOtpChallengeResponseDto {
  const DeliveryHandoffOtpChallengeResponseDto({
    required this.challengeId,
    required this.shipmentId,
    required this.status,
    required this.expiresAt,
    required this.maxAttempts,
  });

  final String challengeId;
  final String shipmentId;
  final DeliveryHandoffOtpChallengeResponseDtoStatus status;
  final String expiresAt;
  final num maxAttempts;

  factory DeliveryHandoffOtpChallengeResponseDto.fromJson(Map<String, dynamic> json) {
    return DeliveryHandoffOtpChallengeResponseDto(
      challengeId: json["challengeId"] as String,
      shipmentId: json["shipmentId"] as String,
      status: DeliveryHandoffOtpChallengeResponseDtoStatus.fromJson(json["status"] as String),
      expiresAt: json["expiresAt"] as String,
      maxAttempts: (json["maxAttempts"] as num?)!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "challengeId": challengeId,
      "shipmentId": shipmentId,
      "status": status.toJson(),
      "expiresAt": expiresAt,
      "maxAttempts": maxAttempts,
    };
  }
}

class DeliveryHandoffOtpVerificationResponseDto {
  const DeliveryHandoffOtpVerificationResponseDto({
    required this.challengeId,
    required this.shipmentId,
    required this.status,
    required this.verifiedAt,
  });

  final String challengeId;
  final String shipmentId;
  final DeliveryHandoffOtpVerificationResponseDtoStatus status;
  final String verifiedAt;

  factory DeliveryHandoffOtpVerificationResponseDto.fromJson(Map<String, dynamic> json) {
    return DeliveryHandoffOtpVerificationResponseDto(
      challengeId: json["challengeId"] as String,
      shipmentId: json["shipmentId"] as String,
      status: DeliveryHandoffOtpVerificationResponseDtoStatus.fromJson(json["status"] as String),
      verifiedAt: json["verifiedAt"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "challengeId": challengeId,
      "shipmentId": shipmentId,
      "status": status.toJson(),
      "verifiedAt": verifiedAt,
    };
  }
}

class DeliveryIncidentResponseDto {
  const DeliveryIncidentResponseDto({
    required this.id,
    required this.shipmentId,
    required this.type,
    required this.status,
    this.comment,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.resolvedAt,
    this.resolvedByActorId,
    required this.createdAt,
  });

  final String id;
  final String shipmentId;
  final DeliveryIncidentResponseDtoType type;
  final DeliveryIncidentResponseDtoStatus status;
  final String? comment;
  final num? latitude;
  final num? longitude;
  final num? accuracyMeters;
  final String? resolvedAt;
  final String? resolvedByActorId;
  final String createdAt;

  factory DeliveryIncidentResponseDto.fromJson(Map<String, dynamic> json) {
    return DeliveryIncidentResponseDto(
      id: json["id"] as String,
      shipmentId: json["shipmentId"] as String,
      type: DeliveryIncidentResponseDtoType.fromJson(json["type"] as String),
      status: DeliveryIncidentResponseDtoStatus.fromJson(json["status"] as String),
      comment: json["comment"] as String?,
      latitude: (json["latitude"] as num?),
      longitude: (json["longitude"] as num?),
      accuracyMeters: (json["accuracyMeters"] as num?),
      resolvedAt: json["resolvedAt"] as String?,
      resolvedByActorId: json["resolvedByActorId"] as String?,
      createdAt: json["createdAt"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "shipmentId": shipmentId,
      "type": type.toJson(),
      "status": status.toJson(),
      "comment": ?comment,
      "latitude": ?latitude,
      "longitude": ?longitude,
      "accuracyMeters": ?accuracyMeters,
      "resolvedAt": ?resolvedAt,
      "resolvedByActorId": ?resolvedByActorId,
      "createdAt": createdAt,
    };
  }
}

class DeliveryLocationPointInputDto {
  const DeliveryLocationPointInputDto({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    required this.recordedAt,
    this.shipmentId,
  });

  final num latitude;
  final num longitude;
  final num? accuracyMeters;
  final String recordedAt;
  final String? shipmentId;

  factory DeliveryLocationPointInputDto.fromJson(Map<String, dynamic> json) {
    return DeliveryLocationPointInputDto(
      latitude: (json["latitude"] as num?)!,
      longitude: (json["longitude"] as num?)!,
      accuracyMeters: (json["accuracyMeters"] as num?),
      recordedAt: json["recordedAt"] as String,
      shipmentId: json["shipmentId"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "latitude": latitude,
      "longitude": longitude,
      "accuracyMeters": ?accuracyMeters,
      "recordedAt": recordedAt,
      "shipmentId": ?shipmentId,
    };
  }
}

class DriverAvailabilityResponseDto {
  const DriverAvailabilityResponseDto({
    required this.organizationId,
    required this.countryId,
    required this.countryCode,
    this.deliveryProfileId,
    this.deliveryStatus,
    required this.activeDeliveryMissionCount,
    this.mobilityProfileId,
    this.mobilityAvailabilityStatus,
    this.mobilityOnboardingStatus,
    this.mobilityOperationalStatus,
    required this.serviceCapabilities,
    required this.activeMobilityOfferCount,
    required this.activeMobilityRideCount,
  });

  final String organizationId;
  final String countryId;
  final String countryCode;
  final String? deliveryProfileId;
  final DriverAvailabilityResponseDtoDeliveryStatus? deliveryStatus;
  final num activeDeliveryMissionCount;
  final String? mobilityProfileId;
  final DriverAvailabilityResponseDtoMobilityAvailabilityStatus? mobilityAvailabilityStatus;
  final DriverAvailabilityResponseDtoMobilityOnboardingStatus? mobilityOnboardingStatus;
  final DriverAvailabilityResponseDtoMobilityOperationalStatus? mobilityOperationalStatus;
  final List<String> serviceCapabilities;
  final num activeMobilityOfferCount;
  final num activeMobilityRideCount;

  factory DriverAvailabilityResponseDto.fromJson(Map<String, dynamic> json) {
    return DriverAvailabilityResponseDto(
      organizationId: json["organizationId"] as String,
      countryId: json["countryId"] as String,
      countryCode: json["countryCode"] as String,
      deliveryProfileId: json["deliveryProfileId"] as String?,
      deliveryStatus: json["deliveryStatus"] == null ? null : DriverAvailabilityResponseDtoDeliveryStatus.fromJson(json["deliveryStatus"] as String),
      activeDeliveryMissionCount: (json["activeDeliveryMissionCount"] as num?)!,
      mobilityProfileId: json["mobilityProfileId"] as String?,
      mobilityAvailabilityStatus: json["mobilityAvailabilityStatus"] == null ? null : DriverAvailabilityResponseDtoMobilityAvailabilityStatus.fromJson(json["mobilityAvailabilityStatus"] as String),
      mobilityOnboardingStatus: json["mobilityOnboardingStatus"] == null ? null : DriverAvailabilityResponseDtoMobilityOnboardingStatus.fromJson(json["mobilityOnboardingStatus"] as String),
      mobilityOperationalStatus: json["mobilityOperationalStatus"] == null ? null : DriverAvailabilityResponseDtoMobilityOperationalStatus.fromJson(json["mobilityOperationalStatus"] as String),
      serviceCapabilities: (json["serviceCapabilities"] as List<dynamic>).map((e) => e as String).toList(),
      activeMobilityOfferCount: (json["activeMobilityOfferCount"] as num?)!,
      activeMobilityRideCount: (json["activeMobilityRideCount"] as num?)!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "organizationId": organizationId,
      "countryId": countryId,
      "countryCode": countryCode,
      "deliveryProfileId": ?deliveryProfileId,
      "deliveryStatus": ?deliveryStatus?.toJson(),
      "activeDeliveryMissionCount": activeDeliveryMissionCount,
      "mobilityProfileId": ?mobilityProfileId,
      "mobilityAvailabilityStatus": ?mobilityAvailabilityStatus?.toJson(),
      "mobilityOnboardingStatus": ?mobilityOnboardingStatus?.toJson(),
      "mobilityOperationalStatus": ?mobilityOperationalStatus?.toJson(),
      "serviceCapabilities": serviceCapabilities.map((e) => e).toList(),
      "activeMobilityOfferCount": activeMobilityOfferCount,
      "activeMobilityRideCount": activeMobilityRideCount,
    };
  }
}

class DriverContextProfileDto {
  const DriverContextProfileDto({
    required this.organizationId,
    required this.organizationName,
    required this.countryId,
    required this.countryCode,
    this.deliveryProfileId,
    this.deliveryStatus,
    this.mobilityProfileId,
    this.mobilityOnboardingStatus,
    this.mobilityOperationalStatus,
    this.mobilityAvailabilityStatus,
    required this.serviceTypes,
    this.assignedVehicle,
  });

  final String organizationId;
  final String organizationName;
  final String countryId;
  final String countryCode;
  final String? deliveryProfileId;
  final DriverContextProfileDtoDeliveryStatus? deliveryStatus;
  final String? mobilityProfileId;
  final DriverContextProfileDtoMobilityOnboardingStatus? mobilityOnboardingStatus;
  final DriverContextProfileDtoMobilityOperationalStatus? mobilityOperationalStatus;
  final DriverContextProfileDtoMobilityAvailabilityStatus? mobilityAvailabilityStatus;
  final List<DriverContextProfileDtoServiceTypes> serviceTypes;
  final DriverContextVehicleSummaryDto? assignedVehicle;

  factory DriverContextProfileDto.fromJson(Map<String, dynamic> json) {
    return DriverContextProfileDto(
      organizationId: json["organizationId"] as String,
      organizationName: json["organizationName"] as String,
      countryId: json["countryId"] as String,
      countryCode: json["countryCode"] as String,
      deliveryProfileId: json["deliveryProfileId"] as String?,
      deliveryStatus: json["deliveryStatus"] == null ? null : DriverContextProfileDtoDeliveryStatus.fromJson(json["deliveryStatus"] as String),
      mobilityProfileId: json["mobilityProfileId"] as String?,
      mobilityOnboardingStatus: json["mobilityOnboardingStatus"] == null ? null : DriverContextProfileDtoMobilityOnboardingStatus.fromJson(json["mobilityOnboardingStatus"] as String),
      mobilityOperationalStatus: json["mobilityOperationalStatus"] == null ? null : DriverContextProfileDtoMobilityOperationalStatus.fromJson(json["mobilityOperationalStatus"] as String),
      mobilityAvailabilityStatus: json["mobilityAvailabilityStatus"] == null ? null : DriverContextProfileDtoMobilityAvailabilityStatus.fromJson(json["mobilityAvailabilityStatus"] as String),
      serviceTypes: (json["serviceTypes"] as List<dynamic>).map((e) => DriverContextProfileDtoServiceTypes.fromJson(e as String)).toList(),
      assignedVehicle: json["assignedVehicle"] == null ? null : DriverContextVehicleSummaryDto.fromJson(json["assignedVehicle"] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "organizationId": organizationId,
      "organizationName": organizationName,
      "countryId": countryId,
      "countryCode": countryCode,
      "deliveryProfileId": ?deliveryProfileId,
      "deliveryStatus": ?deliveryStatus?.toJson(),
      "mobilityProfileId": ?mobilityProfileId,
      "mobilityOnboardingStatus": ?mobilityOnboardingStatus?.toJson(),
      "mobilityOperationalStatus": ?mobilityOperationalStatus?.toJson(),
      "mobilityAvailabilityStatus": ?mobilityAvailabilityStatus?.toJson(),
      "serviceTypes": serviceTypes.map((e) => e.toJson()).toList(),
      "assignedVehicle": ?assignedVehicle?.toJson(),
    };
  }
}

class DriverContextResponseDto {
  const DriverContextResponseDto({
    required this.actorId,
    required this.displayName,
    this.email,
    required this.effectivePermissionCodes,
    required this.capabilities,
    required this.profiles,
  });

  final String actorId;
  final String displayName;
  final String? email;
  final List<String> effectivePermissionCodes;
  final List<String> capabilities;
  final List<DriverContextProfileDto> profiles;

  factory DriverContextResponseDto.fromJson(Map<String, dynamic> json) {
    return DriverContextResponseDto(
      actorId: json["actorId"] as String,
      displayName: json["displayName"] as String,
      email: json["email"] as String?,
      effectivePermissionCodes: (json["effectivePermissionCodes"] as List<dynamic>).map((e) => e as String).toList(),
      capabilities: (json["capabilities"] as List<dynamic>).map((e) => e as String).toList(),
      profiles: (json["profiles"] as List<dynamic>).map((e) => DriverContextProfileDto.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "actorId": actorId,
      "displayName": displayName,
      "email": ?email,
      "effectivePermissionCodes": effectivePermissionCodes.map((e) => e).toList(),
      "capabilities": capabilities.map((e) => e).toList(),
      "profiles": profiles.map((e) => e.toJson()).toList(),
    };
  }
}

class DriverContextVehicleSummaryDto {
  const DriverContextVehicleSummaryDto({
    required this.id,
    required this.type,
    required this.plate,
    required this.make,
    required this.model,
    required this.status,
    required this.allowedServiceTypes,
  });

  final String id;
  final DriverContextVehicleSummaryDtoType type;
  final String plate;
  final String make;
  final String model;
  final DriverContextVehicleSummaryDtoStatus status;
  final List<DriverContextVehicleSummaryDtoAllowedServiceTypes> allowedServiceTypes;

  factory DriverContextVehicleSummaryDto.fromJson(Map<String, dynamic> json) {
    return DriverContextVehicleSummaryDto(
      id: json["id"] as String,
      type: DriverContextVehicleSummaryDtoType.fromJson(json["type"] as String),
      plate: json["plate"] as String,
      make: json["make"] as String,
      model: json["model"] as String,
      status: DriverContextVehicleSummaryDtoStatus.fromJson(json["status"] as String),
      allowedServiceTypes: (json["allowedServiceTypes"] as List<dynamic>).map((e) => DriverContextVehicleSummaryDtoAllowedServiceTypes.fromJson(e as String)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": type.toJson(),
      "plate": plate,
      "make": make,
      "model": model,
      "status": status.toJson(),
      "allowedServiceTypes": allowedServiceTypes.map((e) => e.toJson()).toList(),
    };
  }
}

class DriverMissionCompletionResponseDto {
  const DriverMissionCompletionResponseDto({
    required this.id,
    required this.shipmentId,
    required this.deliveryAttemptId,
    required this.evidenceId,
    required this.evidenceType,
    required this.status,
    required this.orderStatus,
    required this.completedAt,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
  });

  final String id;
  final String shipmentId;
  final String deliveryAttemptId;
  final String evidenceId;
  final DriverMissionCompletionResponseDtoEvidenceType evidenceType;
  final DriverMissionCompletionResponseDtoStatus status;
  final DriverMissionCompletionResponseDtoOrderStatus orderStatus;
  final String completedAt;
  final num? latitude;
  final num? longitude;
  final num? accuracyMeters;

  factory DriverMissionCompletionResponseDto.fromJson(Map<String, dynamic> json) {
    return DriverMissionCompletionResponseDto(
      id: json["id"] as String,
      shipmentId: json["shipmentId"] as String,
      deliveryAttemptId: json["deliveryAttemptId"] as String,
      evidenceId: json["evidenceId"] as String,
      evidenceType: DriverMissionCompletionResponseDtoEvidenceType.fromJson(json["evidenceType"] as String),
      status: DriverMissionCompletionResponseDtoStatus.fromJson(json["status"] as String),
      orderStatus: DriverMissionCompletionResponseDtoOrderStatus.fromJson(json["orderStatus"] as String),
      completedAt: json["completedAt"] as String,
      latitude: (json["latitude"] as num?),
      longitude: (json["longitude"] as num?),
      accuracyMeters: (json["accuracyMeters"] as num?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "shipmentId": shipmentId,
      "deliveryAttemptId": deliveryAttemptId,
      "evidenceId": evidenceId,
      "evidenceType": evidenceType.toJson(),
      "status": status.toJson(),
      "orderStatus": orderStatus.toJson(),
      "completedAt": completedAt,
      "latitude": ?latitude,
      "longitude": ?longitude,
      "accuracyMeters": ?accuracyMeters,
    };
  }
}

class DriverMissionLineResponseDto {
  const DriverMissionLineResponseDto({
    required this.id,
    required this.orderLineId,
    required this.productId,
    required this.variantId,
    required this.quantity,
  });

  final String id;
  final String orderLineId;
  final String productId;
  final String variantId;
  final num quantity;

  factory DriverMissionLineResponseDto.fromJson(Map<String, dynamic> json) {
    return DriverMissionLineResponseDto(
      id: json["id"] as String,
      orderLineId: json["orderLineId"] as String,
      productId: json["productId"] as String,
      variantId: json["variantId"] as String,
      quantity: (json["quantity"] as num?)!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "orderLineId": orderLineId,
      "productId": productId,
      "variantId": variantId,
      "quantity": quantity,
    };
  }
}

class DriverMissionListResponseDto {
  const DriverMissionListResponseDto({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  final List<DriverMissionResponseDto> items;
  final num page;
  final num pageSize;
  final num total;

  factory DriverMissionListResponseDto.fromJson(Map<String, dynamic> json) {
    return DriverMissionListResponseDto(
      items: (json["items"] as List<dynamic>).map((e) => DriverMissionResponseDto.fromJson(e as Map<String, dynamic>)).toList(),
      page: (json["page"] as num?)!,
      pageSize: (json["pageSize"] as num?)!,
      total: (json["total"] as num?)!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "items": items.map((e) => e.toJson()).toList(),
      "page": page,
      "pageSize": pageSize,
      "total": total,
    };
  }
}

class DriverMissionResponseDto {
  const DriverMissionResponseDto({
    required this.id,
    required this.shipmentId,
    required this.orderId,
    required this.fulfillmentTaskId,
    required this.assignedDriverProfileId,
    required this.status,
    required this.customerFullName,
    this.customerPhone,
    required this.addressLine1,
    this.addressLine2,
    this.instructions,
    this.cityId,
    this.zoneId,
    this.subZoneId,
    required this.codExpectedAmount,
    required this.currencyId,
    this.assignedAt,
    this.outForDeliveryAt,
    this.deliveredAt,
    this.failedAt,
    required this.lines,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String shipmentId;
  final String orderId;
  final String fulfillmentTaskId;
  final String assignedDriverProfileId;
  final DriverMissionResponseDtoStatus status;
  final String customerFullName;
  final String? customerPhone;
  final String addressLine1;
  final String? addressLine2;
  final String? instructions;
  final String? cityId;
  final String? zoneId;
  final String? subZoneId;
  final String codExpectedAmount;
  final String currencyId;
  final String? assignedAt;
  final String? outForDeliveryAt;
  final String? deliveredAt;
  final String? failedAt;
  final List<DriverMissionLineResponseDto> lines;
  final String createdAt;
  final String updatedAt;

  factory DriverMissionResponseDto.fromJson(Map<String, dynamic> json) {
    return DriverMissionResponseDto(
      id: json["id"] as String,
      shipmentId: json["shipmentId"] as String,
      orderId: json["orderId"] as String,
      fulfillmentTaskId: json["fulfillmentTaskId"] as String,
      assignedDriverProfileId: json["assignedDriverProfileId"] as String,
      status: DriverMissionResponseDtoStatus.fromJson(json["status"] as String),
      customerFullName: json["customerFullName"] as String,
      customerPhone: json["customerPhone"] as String?,
      addressLine1: json["addressLine1"] as String,
      addressLine2: json["addressLine2"] as String?,
      instructions: json["instructions"] as String?,
      cityId: json["cityId"] as String?,
      zoneId: json["zoneId"] as String?,
      subZoneId: json["subZoneId"] as String?,
      codExpectedAmount: json["codExpectedAmount"] as String,
      currencyId: json["currencyId"] as String,
      assignedAt: json["assignedAt"] as String?,
      outForDeliveryAt: json["outForDeliveryAt"] as String?,
      deliveredAt: json["deliveredAt"] as String?,
      failedAt: json["failedAt"] as String?,
      lines: (json["lines"] as List<dynamic>).map((e) => DriverMissionLineResponseDto.fromJson(e as Map<String, dynamic>)).toList(),
      createdAt: json["createdAt"] as String,
      updatedAt: json["updatedAt"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "shipmentId": shipmentId,
      "orderId": orderId,
      "fulfillmentTaskId": fulfillmentTaskId,
      "assignedDriverProfileId": assignedDriverProfileId,
      "status": status.toJson(),
      "customerFullName": customerFullName,
      "customerPhone": ?customerPhone,
      "addressLine1": addressLine1,
      "addressLine2": ?addressLine2,
      "instructions": ?instructions,
      "cityId": ?cityId,
      "zoneId": ?zoneId,
      "subZoneId": ?subZoneId,
      "codExpectedAmount": codExpectedAmount,
      "currencyId": currencyId,
      "assignedAt": ?assignedAt,
      "outForDeliveryAt": ?outForDeliveryAt,
      "deliveredAt": ?deliveredAt,
      "failedAt": ?failedAt,
      "lines": lines.map((e) => e.toJson()).toList(),
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}

class DriverMobilityIncidentListResponseDto {
  const DriverMobilityIncidentListResponseDto({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<MobilityIncidentDto> items;
  final num total;
  final num page;
  final num pageSize;

  factory DriverMobilityIncidentListResponseDto.fromJson(Map<String, dynamic> json) {
    return DriverMobilityIncidentListResponseDto(
      items: (json["items"] as List<dynamic>).map((e) => MobilityIncidentDto.fromJson(e as Map<String, dynamic>)).toList(),
      total: (json["total"] as num?)!,
      page: (json["page"] as num?)!,
      pageSize: (json["pageSize"] as num?)!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "items": items.map((e) => e.toJson()).toList(),
      "total": total,
      "page": page,
      "pageSize": pageSize,
    };
  }
}

class DriverMobilityOfferDto {
  const DriverMobilityOfferDto({
    required this.id,
    required this.rideRequestId,
    required this.organizationId,
    required this.countryId,
    required this.countryCode,
    required this.serviceType,
    required this.status,
    required this.pickupAddressSnapshot,
    required this.dropoffAddressSnapshot,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.estimatedFare,
    this.estimatedRoadDistanceKm,
    this.geodesicDistanceKm,
    required this.offeredAt,
    required this.expiresAt,
  });

  final String id;
  final String rideRequestId;
  final String organizationId;
  final String countryId;
  final String countryCode;
  final DriverMobilityOfferDtoServiceType serviceType;
  final String status;
  final String pickupAddressSnapshot;
  final String dropoffAddressSnapshot;
  final num? pickupLatitude;
  final num? pickupLongitude;
  final num? dropoffLatitude;
  final num? dropoffLongitude;
  final DriverWorkMoneySummaryDto? estimatedFare;
  final num? estimatedRoadDistanceKm;
  final num? geodesicDistanceKm;
  final String offeredAt;
  final String expiresAt;

  factory DriverMobilityOfferDto.fromJson(Map<String, dynamic> json) {
    return DriverMobilityOfferDto(
      id: json["id"] as String,
      rideRequestId: json["rideRequestId"] as String,
      organizationId: json["organizationId"] as String,
      countryId: json["countryId"] as String,
      countryCode: json["countryCode"] as String,
      serviceType: DriverMobilityOfferDtoServiceType.fromJson(json["serviceType"] as String),
      status: json["status"] as String,
      pickupAddressSnapshot: json["pickupAddressSnapshot"] as String,
      dropoffAddressSnapshot: json["dropoffAddressSnapshot"] as String,
      pickupLatitude: (json["pickupLatitude"] as num?),
      pickupLongitude: (json["pickupLongitude"] as num?),
      dropoffLatitude: (json["dropoffLatitude"] as num?),
      dropoffLongitude: (json["dropoffLongitude"] as num?),
      estimatedFare: json["estimatedFare"] == null ? null : DriverWorkMoneySummaryDto.fromJson(json["estimatedFare"] as Map<String, dynamic>),
      estimatedRoadDistanceKm: (json["estimatedRoadDistanceKm"] as num?),
      geodesicDistanceKm: (json["geodesicDistanceKm"] as num?),
      offeredAt: json["offeredAt"] as String,
      expiresAt: json["expiresAt"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "rideRequestId": rideRequestId,
      "organizationId": organizationId,
      "countryId": countryId,
      "countryCode": countryCode,
      "serviceType": serviceType.toJson(),
      "status": status,
      "pickupAddressSnapshot": pickupAddressSnapshot,
      "dropoffAddressSnapshot": dropoffAddressSnapshot,
      "pickupLatitude": ?pickupLatitude,
      "pickupLongitude": ?pickupLongitude,
      "dropoffLatitude": ?dropoffLatitude,
      "dropoffLongitude": ?dropoffLongitude,
      "estimatedFare": ?estimatedFare?.toJson(),
      "estimatedRoadDistanceKm": ?estimatedRoadDistanceKm,
      "geodesicDistanceKm": ?geodesicDistanceKm,
      "offeredAt": offeredAt,
      "expiresAt": expiresAt,
    };
  }
}

class DriverMobilityOfferListResponseDto {
  const DriverMobilityOfferListResponseDto({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<DriverMobilityOfferDto> items;
  final num total;
  final num page;
  final num pageSize;

  factory DriverMobilityOfferListResponseDto.fromJson(Map<String, dynamic> json) {
    return DriverMobilityOfferListResponseDto(
      items: (json["items"] as List<dynamic>).map((e) => DriverMobilityOfferDto.fromJson(e as Map<String, dynamic>)).toList(),
      total: (json["total"] as num?)!,
      page: (json["page"] as num?)!,
      pageSize: (json["pageSize"] as num?)!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "items": items.map((e) => e.toJson()).toList(),
      "total": total,
      "page": page,
      "pageSize": pageSize,
    };
  }
}

class DriverUnderlyingResourceDto {
  const DriverUnderlyingResourceDto({
    required this.resourceType,
    required this.resourceId,
  });

  final String resourceType;
  final String resourceId;

  factory DriverUnderlyingResourceDto.fromJson(Map<String, dynamic> json) {
    return DriverUnderlyingResourceDto(
      resourceType: json["resourceType"] as String,
      resourceId: json["resourceId"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "resourceType": resourceType,
      "resourceId": resourceId,
    };
  }
}

class DriverVehicleDto {
  const DriverVehicleDto({
    required this.id,
    required this.type,
    required this.plate,
    required this.make,
    required this.model,
    required this.status,
    required this.allowedServiceTypes,
    required this.organizationId,
    required this.countryId,
    required this.countryCode,
    this.year,
    this.color,
    required this.code,
    this.documentsAvailable,
    required this.updatedAt,
  });

  final String id;
  final DriverVehicleDtoType type;
  final String plate;
  final String make;
  final String model;
  final DriverVehicleDtoStatus status;
  final List<DriverVehicleDtoAllowedServiceTypes> allowedServiceTypes;
  final String organizationId;
  final String countryId;
  final String countryCode;
  final num? year;
  final String? color;
  final String code;
  final String? documentsAvailable;
  final String updatedAt;

  factory DriverVehicleDto.fromJson(Map<String, dynamic> json) {
    return DriverVehicleDto(
      id: json["id"] as String,
      type: DriverVehicleDtoType.fromJson(json["type"] as String),
      plate: json["plate"] as String,
      make: json["make"] as String,
      model: json["model"] as String,
      status: DriverVehicleDtoStatus.fromJson(json["status"] as String),
      allowedServiceTypes: (json["allowedServiceTypes"] as List<dynamic>).map((e) => DriverVehicleDtoAllowedServiceTypes.fromJson(e as String)).toList(),
      organizationId: json["organizationId"] as String,
      countryId: json["countryId"] as String,
      countryCode: json["countryCode"] as String,
      year: (json["year"] as num?),
      color: json["color"] as String?,
      code: json["code"] as String,
      documentsAvailable: json["documentsAvailable"] as String?,
      updatedAt: json["updatedAt"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": type.toJson(),
      "plate": plate,
      "make": make,
      "model": model,
      "status": status.toJson(),
      "allowedServiceTypes": allowedServiceTypes.map((e) => e.toJson()).toList(),
      "organizationId": organizationId,
      "countryId": countryId,
      "countryCode": countryCode,
      "year": ?year,
      "color": ?color,
      "code": code,
      "documentsAvailable": ?documentsAvailable,
      "updatedAt": updatedAt,
    };
  }
}

class DriverVehicleListResponseDto {
  const DriverVehicleListResponseDto({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<DriverVehicleDto> items;
  final num total;
  final num page;
  final num pageSize;

  factory DriverVehicleListResponseDto.fromJson(Map<String, dynamic> json) {
    return DriverVehicleListResponseDto(
      items: (json["items"] as List<dynamic>).map((e) => DriverVehicleDto.fromJson(e as Map<String, dynamic>)).toList(),
      total: (json["total"] as num?)!,
      page: (json["page"] as num?)!,
      pageSize: (json["pageSize"] as num?)!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "items": items.map((e) => e.toJson()).toList(),
      "total": total,
      "page": page,
      "pageSize": pageSize,
    };
  }
}

class DriverWorkFeedItemDto {
  const DriverWorkFeedItemDto({
    required this.workItemId,
    required this.workType,
    required this.serviceType,
    required this.sourceDomain,
    required this.status,
    this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.pickup,
    this.dropoff,
    this.amount,
    required this.actions,
    required this.underlyingResource,
  });

  final String workItemId;
  final DriverWorkFeedItemDtoWorkType workType;
  final DriverWorkFeedItemDtoServiceType serviceType;
  final String sourceDomain;
  final String status;
  final String? priority;
  final String createdAt;
  final String updatedAt;
  final DriverWorkLocationSummaryDto? pickup;
  final DriverWorkLocationSummaryDto? dropoff;
  final DriverWorkMoneySummaryDto? amount;
  final List<String> actions;
  final DriverUnderlyingResourceDto underlyingResource;

  factory DriverWorkFeedItemDto.fromJson(Map<String, dynamic> json) {
    return DriverWorkFeedItemDto(
      workItemId: json["workItemId"] as String,
      workType: DriverWorkFeedItemDtoWorkType.fromJson(json["workType"] as String),
      serviceType: DriverWorkFeedItemDtoServiceType.fromJson(json["serviceType"] as String),
      sourceDomain: json["sourceDomain"] as String,
      status: json["status"] as String,
      priority: json["priority"] as String?,
      createdAt: json["createdAt"] as String,
      updatedAt: json["updatedAt"] as String,
      pickup: json["pickup"] == null ? null : DriverWorkLocationSummaryDto.fromJson(json["pickup"] as Map<String, dynamic>),
      dropoff: json["dropoff"] == null ? null : DriverWorkLocationSummaryDto.fromJson(json["dropoff"] as Map<String, dynamic>),
      amount: json["amount"] == null ? null : DriverWorkMoneySummaryDto.fromJson(json["amount"] as Map<String, dynamic>),
      actions: (json["actions"] as List<dynamic>).map((e) => e as String).toList(),
      underlyingResource: DriverUnderlyingResourceDto.fromJson(json["underlyingResource"] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "workItemId": workItemId,
      "workType": workType.toJson(),
      "serviceType": serviceType.toJson(),
      "sourceDomain": sourceDomain,
      "status": status,
      "priority": ?priority,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "pickup": ?pickup?.toJson(),
      "dropoff": ?dropoff?.toJson(),
      "amount": ?amount?.toJson(),
      "actions": actions.map((e) => e).toList(),
      "underlyingResource": underlyingResource.toJson(),
    };
  }
}

class DriverWorkFeedListResponseDto {
  const DriverWorkFeedListResponseDto({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<DriverWorkFeedItemDto> items;
  final num total;
  final num page;
  final num pageSize;

  factory DriverWorkFeedListResponseDto.fromJson(Map<String, dynamic> json) {
    return DriverWorkFeedListResponseDto(
      items: (json["items"] as List<dynamic>).map((e) => DriverWorkFeedItemDto.fromJson(e as Map<String, dynamic>)).toList(),
      total: (json["total"] as num?)!,
      page: (json["page"] as num?)!,
      pageSize: (json["pageSize"] as num?)!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "items": items.map((e) => e.toJson()).toList(),
      "total": total,
      "page": page,
      "pageSize": pageSize,
    };
  }
}

class DriverWorkLocationSummaryDto {
  const DriverWorkLocationSummaryDto({
    this.label,
    this.addressLine1,
    this.addressLine2,
    this.cityId,
    this.zoneId,
    this.latitude,
    this.longitude,
  });

  final String? label;
  final String? addressLine1;
  final String? addressLine2;
  final String? cityId;
  final String? zoneId;
  final num? latitude;
  final num? longitude;

  factory DriverWorkLocationSummaryDto.fromJson(Map<String, dynamic> json) {
    return DriverWorkLocationSummaryDto(
      label: json["label"] as String?,
      addressLine1: json["addressLine1"] as String?,
      addressLine2: json["addressLine2"] as String?,
      cityId: json["cityId"] as String?,
      zoneId: json["zoneId"] as String?,
      latitude: (json["latitude"] as num?),
      longitude: (json["longitude"] as num?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "label": ?label,
      "addressLine1": ?addressLine1,
      "addressLine2": ?addressLine2,
      "cityId": ?cityId,
      "zoneId": ?zoneId,
      "latitude": ?latitude,
      "longitude": ?longitude,
    };
  }
}

class DriverWorkMoneySummaryDto {
  const DriverWorkMoneySummaryDto({
    required this.amount,
    required this.currencyCode,
  });

  final String amount;
  final String currencyCode;

  factory DriverWorkMoneySummaryDto.fromJson(Map<String, dynamic> json) {
    return DriverWorkMoneySummaryDto(
      amount: json["amount"] as String,
      currencyCode: json["currencyCode"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "currencyCode": currencyCode,
    };
  }
}

class LoginRequestDto {
  const LoginRequestDto({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) {
    return LoginRequestDto(
      email: json["email"] as String,
      password: json["password"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "password": password,
    };
  }
}

class LogoutResponseDto {
  const LogoutResponseDto({
    required this.revoked,
  });

  final bool revoked;

  factory LogoutResponseDto.fromJson(Map<String, dynamic> json) {
    return LogoutResponseDto(
      revoked: json["revoked"] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "revoked": revoked,
    };
  }
}

class MeResponseDto {
  const MeResponseDto({
    required this.actorId,
    required this.displayName,
    this.email,
    required this.memberships,
  });

  final String actorId;
  final String displayName;
  final String? email;
  final List<MembershipResponseDto> memberships;

  factory MeResponseDto.fromJson(Map<String, dynamic> json) {
    return MeResponseDto(
      actorId: json["actorId"] as String,
      displayName: json["displayName"] as String,
      email: json["email"] as String?,
      memberships: (json["memberships"] as List<dynamic>).map((e) => MembershipResponseDto.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "actorId": actorId,
      "displayName": displayName,
      "email": ?email,
      "memberships": memberships.map((e) => e.toJson()).toList(),
    };
  }
}

class MembershipResponseDto {
  const MembershipResponseDto({
    required this.membershipId,
    required this.organizationId,
    required this.countryScopes,
  });

  final String membershipId;
  final String organizationId;
  final List<CountryScopeResponseDto> countryScopes;

  factory MembershipResponseDto.fromJson(Map<String, dynamic> json) {
    return MembershipResponseDto(
      membershipId: json["membershipId"] as String,
      organizationId: json["organizationId"] as String,
      countryScopes: (json["countryScopes"] as List<dynamic>).map((e) => CountryScopeResponseDto.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "membershipId": membershipId,
      "organizationId": organizationId,
      "countryScopes": countryScopes.map((e) => e.toJson()).toList(),
    };
  }
}

class MobilityDriverDto {
  const MobilityDriverDto({
    required this.id,
    required this.code,
    required this.displayName,
    required this.organizationName,
    required this.countryCode,
    this.phoneMasked,
    required this.onboardingStatus,
    required this.operationalStatus,
    required this.availabilityStatus,
    required this.allowedServiceTypes,
    required this.operatingZoneIds,
    this.ratingAverage,
    required this.ratingCount,
    this.lastKnownLocation,
    this.assignedVehicleLabel,
    required this.ridesCount,
    required this.updatedAt,
  });

  final String id;
  final String code;
  final String displayName;
  final String organizationName;
  final String countryCode;
  final String? phoneMasked;
  final MobilityDriverDtoOnboardingStatus onboardingStatus;
  final MobilityDriverDtoOperationalStatus operationalStatus;
  final MobilityDriverDtoAvailabilityStatus availabilityStatus;
  final List<MobilityDriverDtoAllowedServiceTypes> allowedServiceTypes;
  final List<String> operatingZoneIds;
  final num? ratingAverage;
  final num ratingCount;
  final MobilityGeoPointDto? lastKnownLocation;
  final String? assignedVehicleLabel;
  final num ridesCount;
  final String updatedAt;

  factory MobilityDriverDto.fromJson(Map<String, dynamic> json) {
    return MobilityDriverDto(
      id: json["id"] as String,
      code: json["code"] as String,
      displayName: json["displayName"] as String,
      organizationName: json["organizationName"] as String,
      countryCode: json["countryCode"] as String,
      phoneMasked: json["phoneMasked"] as String?,
      onboardingStatus: MobilityDriverDtoOnboardingStatus.fromJson(json["onboardingStatus"] as String),
      operationalStatus: MobilityDriverDtoOperationalStatus.fromJson(json["operationalStatus"] as String),
      availabilityStatus: MobilityDriverDtoAvailabilityStatus.fromJson(json["availabilityStatus"] as String),
      allowedServiceTypes: (json["allowedServiceTypes"] as List<dynamic>).map((e) => MobilityDriverDtoAllowedServiceTypes.fromJson(e as String)).toList(),
      operatingZoneIds: (json["operatingZoneIds"] as List<dynamic>).map((e) => e as String).toList(),
      ratingAverage: (json["ratingAverage"] as num?),
      ratingCount: (json["ratingCount"] as num?)!,
      lastKnownLocation: json["lastKnownLocation"] == null ? null : MobilityGeoPointDto.fromJson(json["lastKnownLocation"] as Map<String, dynamic>),
      assignedVehicleLabel: json["assignedVehicleLabel"] as String?,
      ridesCount: (json["ridesCount"] as num?)!,
      updatedAt: json["updatedAt"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "code": code,
      "displayName": displayName,
      "organizationName": organizationName,
      "countryCode": countryCode,
      "phoneMasked": ?phoneMasked,
      "onboardingStatus": onboardingStatus.toJson(),
      "operationalStatus": operationalStatus.toJson(),
      "availabilityStatus": availabilityStatus.toJson(),
      "allowedServiceTypes": allowedServiceTypes.map((e) => e.toJson()).toList(),
      "operatingZoneIds": operatingZoneIds.map((e) => e).toList(),
      "ratingAverage": ?ratingAverage,
      "ratingCount": ratingCount,
      "lastKnownLocation": ?lastKnownLocation?.toJson(),
      "assignedVehicleLabel": ?assignedVehicleLabel,
      "ridesCount": ridesCount,
      "updatedAt": updatedAt,
    };
  }
}

class MobilityGeoPointDto {
  const MobilityGeoPointDto({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    this.headingDegrees,
    this.speedKph,
    this.recordedAt,
  });

  final num latitude;
  final num longitude;
  final num? accuracyMeters;
  final num? headingDegrees;
  final num? speedKph;
  final String? recordedAt;

  factory MobilityGeoPointDto.fromJson(Map<String, dynamic> json) {
    return MobilityGeoPointDto(
      latitude: (json["latitude"] as num?)!,
      longitude: (json["longitude"] as num?)!,
      accuracyMeters: (json["accuracyMeters"] as num?),
      headingDegrees: (json["headingDegrees"] as num?),
      speedKph: (json["speedKph"] as num?),
      recordedAt: json["recordedAt"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "latitude": latitude,
      "longitude": longitude,
      "accuracyMeters": ?accuracyMeters,
      "headingDegrees": ?headingDegrees,
      "speedKph": ?speedKph,
      "recordedAt": ?recordedAt,
    };
  }
}

class MobilityIncidentDto {
  const MobilityIncidentDto({
    required this.id,
    required this.type,
    required this.status,
    this.rideReference,
    this.driverDisplayName,
    this.vehicleLabel,
    this.comment,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final MobilityIncidentDtoType type;
  final MobilityIncidentDtoStatus status;
  final String? rideReference;
  final String? driverDisplayName;
  final String? vehicleLabel;
  final String? comment;
  final num? latitude;
  final num? longitude;
  final String createdAt;
  final String updatedAt;

  factory MobilityIncidentDto.fromJson(Map<String, dynamic> json) {
    return MobilityIncidentDto(
      id: json["id"] as String,
      type: MobilityIncidentDtoType.fromJson(json["type"] as String),
      status: MobilityIncidentDtoStatus.fromJson(json["status"] as String),
      rideReference: json["rideReference"] as String?,
      driverDisplayName: json["driverDisplayName"] as String?,
      vehicleLabel: json["vehicleLabel"] as String?,
      comment: json["comment"] as String?,
      latitude: (json["latitude"] as num?),
      longitude: (json["longitude"] as num?),
      createdAt: json["createdAt"] as String,
      updatedAt: json["updatedAt"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": type.toJson(),
      "status": status.toJson(),
      "rideReference": ?rideReference,
      "driverDisplayName": ?driverDisplayName,
      "vehicleLabel": ?vehicleLabel,
      "comment": ?comment,
      "latitude": ?latitude,
      "longitude": ?longitude,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}

class MobilityRideDetailDto {
  const MobilityRideDetailDto({
    required this.id,
    required this.reference,
    required this.serviceType,
    required this.status,
    required this.pickupAddressSnapshot,
    required this.dropoffAddressSnapshot,
    required this.driverDisplayName,
    required this.vehicleLabel,
    required this.fareAmount,
    required this.currencyCode,
    this.geodesicDistanceKm,
    this.actualDistanceKm,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.assignedAt,
    this.startedAt,
    this.completedAt,
    required this.updatedAt,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    required this.track,
    required this.timeline,
  });

  final String id;
  final String reference;
  final MobilityRideDetailDtoServiceType serviceType;
  final MobilityRideDetailDtoStatus status;
  final String pickupAddressSnapshot;
  final String dropoffAddressSnapshot;
  final String driverDisplayName;
  final String vehicleLabel;
  final num fareAmount;
  final String currencyCode;
  final num? geodesicDistanceKm;
  final num? actualDistanceKm;
  final String paymentMethod;
  final String paymentStatus;
  final String assignedAt;
  final String? startedAt;
  final String? completedAt;
  final String updatedAt;
  final num pickupLatitude;
  final num pickupLongitude;
  final num dropoffLatitude;
  final num dropoffLongitude;
  final List<MobilityTrackPointDto> track;
  final List<MobilityRideTimelineEntryDto> timeline;

  factory MobilityRideDetailDto.fromJson(Map<String, dynamic> json) {
    return MobilityRideDetailDto(
      id: json["id"] as String,
      reference: json["reference"] as String,
      serviceType: MobilityRideDetailDtoServiceType.fromJson(json["serviceType"] as String),
      status: MobilityRideDetailDtoStatus.fromJson(json["status"] as String),
      pickupAddressSnapshot: json["pickupAddressSnapshot"] as String,
      dropoffAddressSnapshot: json["dropoffAddressSnapshot"] as String,
      driverDisplayName: json["driverDisplayName"] as String,
      vehicleLabel: json["vehicleLabel"] as String,
      fareAmount: (json["fareAmount"] as num?)!,
      currencyCode: json["currencyCode"] as String,
      geodesicDistanceKm: (json["geodesicDistanceKm"] as num?),
      actualDistanceKm: (json["actualDistanceKm"] as num?),
      paymentMethod: json["paymentMethod"] as String,
      paymentStatus: json["paymentStatus"] as String,
      assignedAt: json["assignedAt"] as String,
      startedAt: json["startedAt"] as String?,
      completedAt: json["completedAt"] as String?,
      updatedAt: json["updatedAt"] as String,
      pickupLatitude: (json["pickupLatitude"] as num?)!,
      pickupLongitude: (json["pickupLongitude"] as num?)!,
      dropoffLatitude: (json["dropoffLatitude"] as num?)!,
      dropoffLongitude: (json["dropoffLongitude"] as num?)!,
      track: (json["track"] as List<dynamic>).map((e) => MobilityTrackPointDto.fromJson(e as Map<String, dynamic>)).toList(),
      timeline: (json["timeline"] as List<dynamic>).map((e) => MobilityRideTimelineEntryDto.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "reference": reference,
      "serviceType": serviceType.toJson(),
      "status": status.toJson(),
      "pickupAddressSnapshot": pickupAddressSnapshot,
      "dropoffAddressSnapshot": dropoffAddressSnapshot,
      "driverDisplayName": driverDisplayName,
      "vehicleLabel": vehicleLabel,
      "fareAmount": fareAmount,
      "currencyCode": currencyCode,
      "geodesicDistanceKm": ?geodesicDistanceKm,
      "actualDistanceKm": ?actualDistanceKm,
      "paymentMethod": paymentMethod,
      "paymentStatus": paymentStatus,
      "assignedAt": assignedAt,
      "startedAt": ?startedAt,
      "completedAt": ?completedAt,
      "updatedAt": updatedAt,
      "pickupLatitude": pickupLatitude,
      "pickupLongitude": pickupLongitude,
      "dropoffLatitude": dropoffLatitude,
      "dropoffLongitude": dropoffLongitude,
      "track": track.map((e) => e.toJson()).toList(),
      "timeline": timeline.map((e) => e.toJson()).toList(),
    };
  }
}

class MobilityRideTimelineEntryDto {
  const MobilityRideTimelineEntryDto({
    required this.type,
    this.fromStatus,
    this.toStatus,
    this.message,
    required this.createdAt,
  });

  final String type;
  final String? fromStatus;
  final String? toStatus;
  final String? message;
  final String createdAt;

  factory MobilityRideTimelineEntryDto.fromJson(Map<String, dynamic> json) {
    return MobilityRideTimelineEntryDto(
      type: json["type"] as String,
      fromStatus: json["fromStatus"] as String?,
      toStatus: json["toStatus"] as String?,
      message: json["message"] as String?,
      createdAt: json["createdAt"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "fromStatus": ?fromStatus,
      "toStatus": ?toStatus,
      "message": ?message,
      "createdAt": createdAt,
    };
  }
}

class MobilityTrackPointDto {
  const MobilityTrackPointDto({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    this.headingDegrees,
    this.speedKph,
    this.recordedAt,
    required this.id,
  });

  final num latitude;
  final num longitude;
  final num? accuracyMeters;
  final num? headingDegrees;
  final num? speedKph;
  final String? recordedAt;
  final String id;

  factory MobilityTrackPointDto.fromJson(Map<String, dynamic> json) {
    return MobilityTrackPointDto(
      latitude: (json["latitude"] as num?)!,
      longitude: (json["longitude"] as num?)!,
      accuracyMeters: (json["accuracyMeters"] as num?),
      headingDegrees: (json["headingDegrees"] as num?),
      speedKph: (json["speedKph"] as num?),
      recordedAt: json["recordedAt"] as String?,
      id: json["id"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "latitude": latitude,
      "longitude": longitude,
      "accuracyMeters": ?accuracyMeters,
      "headingDegrees": ?headingDegrees,
      "speedKph": ?speedKph,
      "recordedAt": ?recordedAt,
      "id": id,
    };
  }
}

class NavigationGeoPointInputDto {
  const NavigationGeoPointInputDto({
    required this.latitude,
    required this.longitude,
  });

  final num latitude;
  final num longitude;

  factory NavigationGeoPointInputDto.fromJson(Map<String, dynamic> json) {
    return NavigationGeoPointInputDto(
      latitude: (json["latitude"] as num?)!,
      longitude: (json["longitude"] as num?)!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "latitude": latitude,
      "longitude": longitude,
    };
  }
}

class NavigationManeuverDto {
  const NavigationManeuverDto({
    required this.type,
    this.modifier,
    this.instruction,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.location,
    this.streetName,
  });

  final String type;
  final String? modifier;
  final String? instruction;
  final num distanceMeters;
  final num durationSeconds;
  final NavigationManeuverLocationDto location;
  final String? streetName;

  factory NavigationManeuverDto.fromJson(Map<String, dynamic> json) {
    return NavigationManeuverDto(
      type: json["type"] as String,
      modifier: json["modifier"] as String?,
      instruction: json["instruction"] as String?,
      distanceMeters: (json["distanceMeters"] as num?)!,
      durationSeconds: (json["durationSeconds"] as num?)!,
      location: NavigationManeuverLocationDto.fromJson(json["location"] as Map<String, dynamic>),
      streetName: json["streetName"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "modifier": ?modifier,
      "instruction": ?instruction,
      "distanceMeters": distanceMeters,
      "durationSeconds": durationSeconds,
      "location": location.toJson(),
      "streetName": ?streetName,
    };
  }
}

class NavigationManeuverLocationDto {
  const NavigationManeuverLocationDto({
    required this.latitude,
    required this.longitude,
  });

  final num latitude;
  final num longitude;

  factory NavigationManeuverLocationDto.fromJson(Map<String, dynamic> json) {
    return NavigationManeuverLocationDto(
      latitude: (json["latitude"] as num?)!,
      longitude: (json["longitude"] as num?)!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "latitude": latitude,
      "longitude": longitude,
    };
  }
}

class RefreshRequestDto {
  const RefreshRequestDto({
    required this.refreshToken,
  });

  final String refreshToken;

  factory RefreshRequestDto.fromJson(Map<String, dynamic> json) {
    return RefreshRequestDto(
      refreshToken: json["refreshToken"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "refreshToken": refreshToken,
    };
  }
}

class RouteGeometryDto {
  const RouteGeometryDto({
    required this.type,
    required this.coordinates,
  });

  final RouteGeometryDtoType type;
  final List<List<num>> coordinates;

  factory RouteGeometryDto.fromJson(Map<String, dynamic> json) {
    return RouteGeometryDto(
      type: RouteGeometryDtoType.fromJson(json["type"] as String),
      coordinates: (json["coordinates"] as List<dynamic>).map((e) => (e as List<dynamic>).map((e) => (e as num?)!).toList()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type.toJson(),
      "coordinates": coordinates.map((e) => e.map((e) => e).toList()).toList(),
    };
  }
}

class ScanDeliveryQrDto {
  const ScanDeliveryQrDto({
    required this.token,
  });

  final String token;

  factory ScanDeliveryQrDto.fromJson(Map<String, dynamic> json) {
    return ScanDeliveryQrDto(
      token: json["token"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "token": token,
    };
  }
}

class SubmitDeliveryLocationDto {
  const SubmitDeliveryLocationDto({
    required this.organizationId,
    required this.countryCode,
    required this.points,
  });

  final String organizationId;
  final String countryCode;
  final List<DeliveryLocationPointInputDto> points;

  factory SubmitDeliveryLocationDto.fromJson(Map<String, dynamic> json) {
    return SubmitDeliveryLocationDto(
      organizationId: json["organizationId"] as String,
      countryCode: json["countryCode"] as String,
      points: (json["points"] as List<dynamic>).map((e) => DeliveryLocationPointInputDto.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "organizationId": organizationId,
      "countryCode": countryCode,
      "points": points.map((e) => e.toJson()).toList(),
    };
  }
}

class SubmitDeliveryLocationResponseDto {
  const SubmitDeliveryLocationResponseDto({
    required this.accepted,
    required this.lastLocationAt,
  });

  final num accepted;
  final String lastLocationAt;

  factory SubmitDeliveryLocationResponseDto.fromJson(Map<String, dynamic> json) {
    return SubmitDeliveryLocationResponseDto(
      accepted: (json["accepted"] as num?)!,
      lastLocationAt: json["lastLocationAt"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "accepted": accepted,
      "lastLocationAt": lastLocationAt,
    };
  }
}

class SubmitMobilityLocationDto {
  const SubmitMobilityLocationDto({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    this.headingDegrees,
    this.speedKph,
    this.recordedAt,
    this.rideId,
  });

  final num latitude;
  final num longitude;
  final num? accuracyMeters;
  final num? headingDegrees;
  final num? speedKph;
  final String? recordedAt;
  final String? rideId;

  factory SubmitMobilityLocationDto.fromJson(Map<String, dynamic> json) {
    return SubmitMobilityLocationDto(
      latitude: (json["latitude"] as num?)!,
      longitude: (json["longitude"] as num?)!,
      accuracyMeters: (json["accuracyMeters"] as num?),
      headingDegrees: (json["headingDegrees"] as num?),
      speedKph: (json["speedKph"] as num?),
      recordedAt: json["recordedAt"] as String?,
      rideId: json["rideId"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "latitude": latitude,
      "longitude": longitude,
      "accuracyMeters": ?accuracyMeters,
      "headingDegrees": ?headingDegrees,
      "speedKph": ?speedKph,
      "recordedAt": ?recordedAt,
      "rideId": ?rideId,
    };
  }
}

class TransitionMobilityRideDto {
  const TransitionMobilityRideDto({
    required this.status,
    this.reason,
  });

  final TransitionMobilityRideDtoStatus status;
  final String? reason;

  factory TransitionMobilityRideDto.fromJson(Map<String, dynamic> json) {
    return TransitionMobilityRideDto(
      status: TransitionMobilityRideDtoStatus.fromJson(json["status"] as String),
      reason: json["reason"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status.toJson(),
      "reason": ?reason,
    };
  }
}

class UpdateDriverAvailabilityDto {
  const UpdateDriverAvailabilityDto({
    required this.organizationId,
    required this.countryCode,
    required this.availabilityStatus,
  });

  final String organizationId;
  final String countryCode;
  final UpdateDriverAvailabilityDtoAvailabilityStatus availabilityStatus;

  factory UpdateDriverAvailabilityDto.fromJson(Map<String, dynamic> json) {
    return UpdateDriverAvailabilityDto(
      organizationId: json["organizationId"] as String,
      countryCode: json["countryCode"] as String,
      availabilityStatus: UpdateDriverAvailabilityDtoAvailabilityStatus.fromJson(json["availabilityStatus"] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "organizationId": organizationId,
      "countryCode": countryCode,
      "availabilityStatus": availabilityStatus.toJson(),
    };
  }
}

class VerifyDeliveryHandoffOtpDto {
  const VerifyDeliveryHandoffOtpDto({
    required this.challengeId,
    required this.code,
  });

  final String challengeId;
  final String code;

  factory VerifyDeliveryHandoffOtpDto.fromJson(Map<String, dynamic> json) {
    return VerifyDeliveryHandoffOtpDto(
      challengeId: json["challengeId"] as String,
      code: json["code"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "challengeId": challengeId,
      "code": code,
    };
  }
}
