// GENERATED CODE - DO NOT EDIT BY HAND.
//
// Produced by tool/generate_api_models.mjs from the canonical OpenAPI document
// locked in contract/lock.json. Run:
//   node tool/generate_api_models.mjs
// to regenerate, or:
//   node tool/generate_api_models.mjs --check
// to detect drift in CI.


// ignore_for_file: type=lint



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
      "organizationCountryId": organizationCountryId,
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
      "description": description,
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
      "deliveryProfileId": deliveryProfileId,
      "deliveryStatus": deliveryStatus?.toJson(),
      "activeDeliveryMissionCount": activeDeliveryMissionCount,
      "mobilityProfileId": mobilityProfileId,
      "mobilityAvailabilityStatus": mobilityAvailabilityStatus?.toJson(),
      "mobilityOnboardingStatus": mobilityOnboardingStatus?.toJson(),
      "mobilityOperationalStatus": mobilityOperationalStatus?.toJson(),
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
      "deliveryProfileId": deliveryProfileId,
      "deliveryStatus": deliveryStatus?.toJson(),
      "mobilityProfileId": mobilityProfileId,
      "mobilityOnboardingStatus": mobilityOnboardingStatus?.toJson(),
      "mobilityOperationalStatus": mobilityOperationalStatus?.toJson(),
      "mobilityAvailabilityStatus": mobilityAvailabilityStatus?.toJson(),
      "serviceTypes": serviceTypes.map((e) => e.toJson()).toList(),
      "assignedVehicle": assignedVehicle?.toJson(),
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
      "email": email,
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
      "year": year,
      "color": color,
      "code": code,
      "documentsAvailable": documentsAvailable,
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
      "priority": priority,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "pickup": pickup?.toJson(),
      "dropoff": dropoff?.toJson(),
      "amount": amount?.toJson(),
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
      "label": label,
      "addressLine1": addressLine1,
      "addressLine2": addressLine2,
      "cityId": cityId,
      "zoneId": zoneId,
      "latitude": latitude,
      "longitude": longitude,
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
      "email": email,
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
