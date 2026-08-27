/// Literal JSON fixtures mirroring real `/v1/driver/*` and `/v1/auth/*`
/// response shapes (field names/enum values copied from the canonical
/// OpenAPI document, not invented). Used to exercise the generated models'
/// `fromJson` and the repositories/widgets that consume them.
library;

Map<String, dynamic> sampleAuthTokens({
  String access = 'access-token-1',
  String refresh = 'refresh-token-1',
}) => {
  'tokenType': 'Bearer',
  'accessToken': access,
  'accessTokenExpiresIn': 900,
  'refreshToken': refresh,
  'refreshTokenExpiresIn': 2592000,
};

Map<String, dynamic> sampleDriverContext({
  bool withProfile = true,
  bool withVehicle = true,
  String vehicleType = 'CAR',
}) => {
  'actorId': 'actor-1',
  'displayName': 'Amine Tazi',
  'email': 'amine@example.test',
  'effectivePermissionCodes': ['driver.profile.read.own'],
  'capabilities': ['driver.profile.read.own'],
  'profiles': withProfile
      ? [
          {
            'organizationId': 'org-1',
            'organizationName': 'NOKI Casablanca',
            'countryId': 'country-1',
            'countryCode': 'MA',
            'deliveryProfileId': 'delivery-profile-1',
            'deliveryStatus': 'ACTIVE',
            'mobilityProfileId': 'mobility-profile-1',
            'mobilityOnboardingStatus': 'APPROVED',
            'mobilityOperationalStatus': 'ACTIVE',
            'mobilityAvailabilityStatus': 'OFFLINE',
            'serviceTypes': ['TAXI'],
            'assignedVehicle': withVehicle
                ? {
                    'id': 'vehicle-1',
                    'type': vehicleType,
                    'plate': '12345-A-6',
                    'make': 'Dacia',
                    'model': 'Logan',
                    'status': 'ACTIVE',
                    'allowedServiceTypes': ['TAXI'],
                  }
                : null,
          },
        ]
      : [],
};

Map<String, dynamic> sampleVehicleList() => {
  'items': [
    {
      'id': 'vehicle-1',
      'type': 'CAR',
      'plate': '12345-A-6',
      'make': 'Dacia',
      'model': 'Logan',
      'status': 'ACTIVE',
      'allowedServiceTypes': ['TAXI'],
      'organizationId': 'org-1',
      'countryId': 'country-1',
      'countryCode': 'MA',
      'year': 2021,
      'color': 'white',
      'code': 'VEH-001',
      'updatedAt': '2026-08-01T10:00:00.000Z',
    },
  ],
  'total': 1,
  'page': 1,
  'pageSize': 25,
};

Map<String, dynamic> sampleAvailability({
  String mobilityStatus = 'OFFLINE',
  int activeDeliveryMissionCount = 2,
  int activeMobilityRideCount = 1,
}) => {
  'organizationId': 'org-1',
  'countryId': 'country-1',
  'countryCode': 'MA',
  'deliveryProfileId': 'delivery-profile-1',
  'deliveryStatus': 'ACTIVE',
  'activeDeliveryMissionCount': activeDeliveryMissionCount,
  'mobilityProfileId': 'mobility-profile-1',
  'mobilityAvailabilityStatus': mobilityStatus,
  'mobilityOnboardingStatus': 'APPROVED',
  'mobilityOperationalStatus': 'ACTIVE',
  'serviceCapabilities': ['TAXI'],
  'activeMobilityOfferCount': 0,
  'activeMobilityRideCount': activeMobilityRideCount,
};

Map<String, dynamic> sampleWorkFeedDeliveryItem() => {
  'workItemId': 'work-1',
  'workType': 'DELIVERY',
  'serviceType': 'DELIVERY',
  'sourceDomain': 'delivery',
  'status': 'ASSIGNED',
  'priority': 'NORMAL',
  'createdAt': '2026-08-01T09:00:00.000Z',
  'updatedAt': '2026-08-01T09:05:00.000Z',
  'pickup': {
    'label': 'Warehouse',
    'addressLine1': '12 Rue Atlas',
    'latitude': 33.57,
    'longitude': -7.58,
  },
  'dropoff': {
    'label': 'Customer',
    'addressLine1': '4 Rue Zerktouni',
    'latitude': 33.58,
    'longitude': -7.6,
  },
  'amount': {'amount': '120.00', 'currencyCode': 'MAD'},
  'actions': ['view'],
  'underlyingResource': {
    'resourceType': 'DeliveryShipment',
    'resourceId': 'shipment-1',
  },
};

Map<String, dynamic> sampleWorkFeedRideItem() => {
  'workItemId': 'work-2',
  'workType': 'RIDE',
  'serviceType': 'TAXI',
  'sourceDomain': 'mobility',
  'status': 'IN_PROGRESS',
  'createdAt': '2026-08-01T09:10:00.000Z',
  'updatedAt': '2026-08-01T09:12:00.000Z',
  'pickup': {'label': 'Airport', 'addressLine1': 'Aéroport Mohammed V'},
  'dropoff': null,
  'amount': null,
  'actions': ['view'],
  'underlyingResource': {
    'resourceType': 'MobilityRide',
    'resourceId': 'ride-1',
  },
};

Map<String, dynamic> sampleWorkFeedOfferItem() => {
  'workItemId': 'work-3',
  'workType': 'RIDE',
  'serviceType': 'TAXI',
  'sourceDomain': 'MOBILITY_OFFER',
  'status': 'OFFERED',
  'createdAt': '2026-08-01T09:00:00.000Z',
  'updatedAt': '2026-08-01T09:00:00.000Z',
  'pickup': {
    'label': 'Gare',
    'addressLine1': 'Gare Casa-Voyageurs',
    'latitude': 33.59,
    'longitude': -7.61,
  },
  'dropoff': {
    'label': 'Aéroport',
    'addressLine1': 'Aéroport Mohammed V',
    'latitude': 33.37,
    'longitude': -7.59,
  },
  'amount': {'amount': '85.00', 'currencyCode': 'MAD'},
  'actions': ['ACCEPT_OFFER'],
  'underlyingResource': {
    'resourceType': 'MobilityRideOffer',
    'resourceId': 'offer-1',
  },
};

Map<String, dynamic> sampleWorkFeedCargoOfferItem() => {
  'workItemId': 'work-4',
  'workType': 'RIDE',
  'serviceType': 'CARGO',
  'sourceDomain': 'MOBILITY_OFFER',
  'status': 'OFFERED',
  'createdAt': '2026-08-01T09:20:00.000Z',
  'updatedAt': '2026-08-01T09:20:00.000Z',
  'pickup': {
    'label': 'Entrepôt',
    'addressLine1': 'Zone Industrielle Ain Sebaa',
    'latitude': 33.6,
    'longitude': -7.55,
  },
  'dropoff': {
    'label': 'Chantier',
    'addressLine1': 'Route de Rabat',
    'latitude': 33.65,
    'longitude': -7.5,
  },
  'amount': {'amount': '350.00', 'currencyCode': 'MAD'},
  'actions': ['ACCEPT_OFFER'],
  'underlyingResource': {
    'resourceType': 'MobilityRideOffer',
    'resourceId': 'offer-cargo-1',
  },
};

Map<String, dynamic> sampleMobilityCargoOffer() => {
  'id': 'offer-cargo-1',
  'rideRequestId': 'req-cargo-1',
  'organizationId': 'org-1',
  'countryId': 'country-1',
  'countryCode': 'MA',
  'serviceType': 'CARGO',
  'status': 'OFFERED',
  'pickupAddressSnapshot': 'Zone Industrielle Ain Sebaa',
  'dropoffAddressSnapshot': 'Route de Rabat',
  'pickupLatitude': 33.6,
  'pickupLongitude': -7.55,
  'dropoffLatitude': 33.65,
  'dropoffLongitude': -7.5,
  'estimatedFare': {'amount': '350.00', 'currencyCode': 'MAD'},
  'estimatedRoadDistanceKm': 12.4,
  'geodesicDistanceKm': 10.1,
  'offeredAt': '2026-08-01T09:20:00.000Z',
  'expiresAt': '2026-08-01T09:25:00.000Z',
};

Map<String, dynamic> sampleWorkFeedList() => {
  'items': [sampleWorkFeedDeliveryItem(), sampleWorkFeedRideItem()],
  'total': 2,
  'page': 1,
  'pageSize': 25,
};

Map<String, dynamic> sampleMissionLine() => {
  'id': 'line-1',
  'orderLineId': 'order-line-1',
  'productId': 'product-1',
  'variantId': 'variant-1',
  'quantity': 2,
};

Map<String, dynamic> sampleMission({String status = 'OUT_FOR_DELIVERY'}) => {
  'id': 'shipment-1',
  'shipmentId': 'shipment-1',
  'orderId': 'order-1',
  'fulfillmentTaskId': 'task-1',
  'assignedDriverProfileId': 'delivery-profile-1',
  'status': status,
  'customerFullName': 'Nadia Idrissi',
  'customerPhone': '+212600000000',
  'addressLine1': '4 Rue Zerktouni',
  'addressLine2': 'Étage 2',
  'instructions': 'Sonner à l\'interphone',
  'cityId': 'city-1',
  'zoneId': 'zone-1',
  'subZoneId': null,
  'codExpectedAmount': '120.00',
  'currencyId': 'currency-1',
  'assignedAt': '2026-08-01T09:00:00.000Z',
  'outForDeliveryAt': '2026-08-01T09:30:00.000Z',
  'deliveredAt': null,
  'failedAt': null,
  'lines': [sampleMissionLine()],
  'createdAt': '2026-08-01T08:55:00.000Z',
  'updatedAt': '2026-08-01T09:30:00.000Z',
};

Map<String, dynamic> sampleMissionList() => {
  'items': [sampleMission()],
  'page': 1,
  'pageSize': 25,
  'total': 1,
};

Map<String, dynamic> sampleOtpChallenge({String status = 'PENDING'}) => {
  'challengeId': 'challenge-1',
  'shipmentId': 'shipment-1',
  'status': status,
  'expiresAt': '2026-08-01T09:40:00.000Z',
  'maxAttempts': 3,
};

Map<String, dynamic> sampleOtpVerification() => {
  'challengeId': 'challenge-1',
  'shipmentId': 'shipment-1',
  'status': 'VERIFIED',
  'verifiedAt': '2026-08-01T09:31:00.000Z',
};

Map<String, dynamic> sampleMissionCompletion() => {
  'id': 'completion-1',
  'shipmentId': 'shipment-1',
  'deliveryAttemptId': 'attempt-1',
  'evidenceId': 'evidence-1',
  'evidenceType': 'OTP',
  'status': 'DELIVERED',
  'orderStatus': 'DELIVERED',
  'completedAt': '2026-08-01T09:45:00.000Z',
  'latitude': null,
  'longitude': null,
  'accuracyMeters': null,
};

Map<String, dynamic> sampleDeliveryIncident({String status = 'OPEN'}) => {
  'id': 'incident-1',
  'shipmentId': 'shipment-1',
  'type': 'DELAY',
  'status': status,
  'comment': 'Traffic on the ring road',
  'latitude': null,
  'longitude': null,
  'accuracyMeters': null,
  'resolvedAt': null,
  'resolvedByActorId': null,
  'createdAt': '2026-08-01T09:20:00.000Z',
};

Map<String, dynamic> sampleMobilityOffer() => {
  'id': 'offer-1',
  'rideRequestId': 'request-1',
  'organizationId': 'org-1',
  'countryId': 'country-1',
  'countryCode': 'MA',
  'serviceType': 'TAXI',
  'status': 'OFFERED',
  'pickupAddressSnapshot': 'Gare Casa-Voyageurs',
  'dropoffAddressSnapshot': 'Aéroport Mohammed V',
  'pickupLatitude': 33.59,
  'pickupLongitude': -7.61,
  'dropoffLatitude': 33.37,
  'dropoffLongitude': -7.59,
  'estimatedFare': {'amount': '85.00', 'currencyCode': 'MAD'},
  'estimatedRoadDistanceKm': 28.4,
  'geodesicDistanceKm': 24.1,
  'offeredAt': '2026-08-01T09:00:00.000Z',
  'expiresAt': '2026-08-01T09:05:00.000Z',
};

Map<String, dynamic> sampleMobilityOfferList() => {
  'items': [sampleMobilityOffer()],
  'total': 1,
  'page': 1,
  'pageSize': 25,
};

Map<String, dynamic> sampleMobilityRide({
  String status = 'DRIVER_ASSIGNED',
  String serviceType = 'TAXI',
}) => {
  'id': 'ride-1',
  'reference': 'RIDE-0001',
  'serviceType': serviceType,
  'status': status,
  'pickupAddressSnapshot': 'Gare Casa-Voyageurs',
  'dropoffAddressSnapshot': 'Aéroport Mohammed V',
  'driverDisplayName': 'Amine Tazi',
  'vehicleLabel': 'Dacia Logan · 12345-A-6',
  'fareAmount': 85.0,
  'currencyCode': 'MAD',
  'geodesicDistanceKm': 24.1,
  'actualDistanceKm': null,
  'paymentMethod': 'CASH',
  'paymentStatus': 'PENDING',
  'assignedAt': '2026-08-01T09:05:00.000Z',
  'startedAt': null,
  'completedAt': null,
  'updatedAt': '2026-08-01T09:05:00.000Z',
  'pickupLatitude': 33.59,
  'pickupLongitude': -7.61,
  'dropoffLatitude': 33.37,
  'dropoffLongitude': -7.59,
  'track': [],
  'timeline': [
    {
      'type': 'STATUS_CHANGE',
      'fromStatus': null,
      'toStatus': 'DRIVER_ASSIGNED',
      'message': null,
      'createdAt': '2026-08-01T09:05:00.000Z',
    },
  ],
};

Map<String, dynamic> sampleComputeRouteResponse({
  String providerStatus = 'OK',
  bool withGeometry = true,
}) => {
  'geometry': withGeometry
      ? {
          'type': 'LineString',
          'coordinates': [
            [-7.61, 33.59],
            [-7.60, 33.58],
            [-7.59, 33.37],
          ],
        }
      : null,
  'distanceMeters': 24100,
  'durationSeconds': 1800,
  'profile': 'auto',
  'maneuvers': [
    {
      'type': 'turn',
      'modifier': 'right',
      'instruction': 'Turn right onto Boulevard Zerktouni',
      'distanceMeters': 350,
      'durationSeconds': 60,
      'location': {'latitude': 33.585, 'longitude': -7.605},
      'streetName': 'Boulevard Zerktouni',
    },
  ],
  'providerStatus': providerStatus,
};

Map<String, dynamic> sampleMobilityIncident({String status = 'OPEN'}) => {
  'id': 'mobility-incident-1',
  'type': 'SAFETY',
  'status': status,
  'rideReference': 'RIDE-0001',
  'driverDisplayName': 'Amine Tazi',
  'vehicleLabel': 'Dacia Logan · 12345-A-6',
  'comment': 'Passenger felt unsafe',
  'latitude': null,
  'longitude': null,
  'createdAt': '2026-08-01T09:20:00.000Z',
  'updatedAt': '2026-08-01T09:20:00.000Z',
};
