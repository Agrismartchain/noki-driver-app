/// Literal JSON fixtures mirroring real `/v1/driver/*` and `/v1/auth/*`
/// response shapes (field names/enum values copied from the canonical
/// OpenAPI document, not invented). Used to exercise the generated models'
/// `fromJson` and the repositories/widgets that consume them.
library;

Map<String, dynamic> sampleAuthTokens({String access = 'access-token-1', String refresh = 'refresh-token-1'}) => {
      'tokenType': 'Bearer',
      'accessToken': access,
      'accessTokenExpiresIn': 900,
      'refreshToken': refresh,
      'refreshTokenExpiresIn': 2592000,
    };

Map<String, dynamic> sampleDriverContext({bool withProfile = true, bool withVehicle = true}) => {
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
                        'type': 'CAR',
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

Map<String, dynamic> sampleAvailability({String mobilityStatus = 'OFFLINE'}) => {
      'organizationId': 'org-1',
      'countryId': 'country-1',
      'countryCode': 'MA',
      'deliveryProfileId': 'delivery-profile-1',
      'deliveryStatus': 'ACTIVE',
      'activeDeliveryMissionCount': 2,
      'mobilityProfileId': 'mobility-profile-1',
      'mobilityAvailabilityStatus': mobilityStatus,
      'mobilityOnboardingStatus': 'APPROVED',
      'mobilityOperationalStatus': 'ACTIVE',
      'serviceCapabilities': ['TAXI'],
      'activeMobilityOfferCount': 0,
      'activeMobilityRideCount': 1,
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
      'pickup': {'label': 'Warehouse', 'addressLine1': '12 Rue Atlas', 'latitude': 33.57, 'longitude': -7.58},
      'dropoff': {'label': 'Customer', 'addressLine1': '4 Rue Zerktouni', 'latitude': 33.58, 'longitude': -7.6},
      'amount': {'amount': '120.00', 'currencyCode': 'MAD'},
      'actions': ['view'],
      'underlyingResource': {'resourceType': 'DeliveryShipment', 'resourceId': 'shipment-1'},
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
      'underlyingResource': {'resourceType': 'MobilityRide', 'resourceId': 'ride-1'},
    };

Map<String, dynamic> sampleWorkFeedList() => {
      'items': [sampleWorkFeedDeliveryItem(), sampleWorkFeedRideItem()],
      'total': 2,
      'page': 1,
      'pageSize': 25,
    };
