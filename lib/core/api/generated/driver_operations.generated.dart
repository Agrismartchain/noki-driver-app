// GENERATED CODE - DO NOT EDIT BY HAND.
//
// Produced by tool/generate_api_models.mjs from the canonical OpenAPI document
// locked in contract/lock.json. Run:
//   node tool/generate_api_models.mjs
// to regenerate, or:
//   node tool/generate_api_models.mjs --check
// to detect drift in CI.

// Machine-readable description of every generated operation, consumed by
// lib/core/api/driver_api_client.dart. Kept separate from the client itself
// so the client stays hand-written and reviewable.

class GeneratedApiOperation {
  const GeneratedApiOperation({
    required this.operationId,
    required this.method,
    required this.path,
  });

  final String operationId;
  final String method;
  final String path;
}

const List<GeneratedApiOperation> generatedApiOperations = [
  GeneratedApiOperation(operationId: "AuthController_capabilities", method: "GET", path: "/v1/auth/capabilities"),
  GeneratedApiOperation(operationId: "AuthController_login", method: "POST", path: "/v1/auth/login"),
  GeneratedApiOperation(operationId: "AuthController_logout", method: "POST", path: "/v1/auth/logout"),
  GeneratedApiOperation(operationId: "AuthController_me", method: "GET", path: "/v1/auth/me"),
  GeneratedApiOperation(operationId: "AuthController_refresh", method: "POST", path: "/v1/auth/refresh"),
  GeneratedApiOperation(operationId: "DeliveryController_completeOwnMission", method: "POST", path: "/v1/delivery/missions/{id}/complete"),
  GeneratedApiOperation(operationId: "DeliveryController_createOwnMissionIncident", method: "POST", path: "/v1/delivery/missions/{id}/incidents"),
  GeneratedApiOperation(operationId: "DeliveryController_getOwnMission", method: "GET", path: "/v1/delivery/missions/{id}"),
  GeneratedApiOperation(operationId: "DeliveryController_listOwnMissions", method: "GET", path: "/v1/delivery/missions"),
  GeneratedApiOperation(operationId: "DeliveryController_requestHandoffOtp", method: "POST", path: "/v1/delivery/missions/{id}/handoff-otp/request"),
  GeneratedApiOperation(operationId: "DeliveryController_scanOwnMissionQr", method: "POST", path: "/v1/delivery/missions/scan-qr"),
  GeneratedApiOperation(operationId: "DeliveryController_submitOwnLocation", method: "POST", path: "/v1/delivery/location"),
  GeneratedApiOperation(operationId: "DeliveryController_verifyHandoffOtp", method: "POST", path: "/v1/delivery/missions/{id}/handoff-otp/verify"),
  GeneratedApiOperation(operationId: "DriverController_availability", method: "GET", path: "/v1/driver/availability"),
  GeneratedApiOperation(operationId: "DriverController_context", method: "GET", path: "/v1/driver/context"),
  GeneratedApiOperation(operationId: "DriverController_createMobilityIncident", method: "POST", path: "/v1/driver/mobility/incidents"),
  GeneratedApiOperation(operationId: "DriverController_currentMobilityRide", method: "GET", path: "/v1/driver/mobility/rides/current"),
  GeneratedApiOperation(operationId: "DriverController_deliveryMissionIncidents", method: "GET", path: "/v1/driver/delivery/missions/{id}/incidents"),
  GeneratedApiOperation(operationId: "DriverController_mobilityIncidents", method: "GET", path: "/v1/driver/mobility/incidents"),
  GeneratedApiOperation(operationId: "DriverController_mobilityOffers", method: "GET", path: "/v1/driver/mobility/offers"),
  GeneratedApiOperation(operationId: "DriverController_mobilityRideById", method: "GET", path: "/v1/driver/mobility/rides/{id}"),
  GeneratedApiOperation(operationId: "DriverController_updateAvailability", method: "PATCH", path: "/v1/driver/availability"),
  GeneratedApiOperation(operationId: "DriverController_vehicles", method: "GET", path: "/v1/driver/vehicles"),
  GeneratedApiOperation(operationId: "DriverController_workFeed", method: "GET", path: "/v1/driver/work-feed"),
  GeneratedApiOperation(operationId: "MobilityDriverController_acceptOffer", method: "POST", path: "/v1/mobility/driver/offers/{id}/accept"),
  GeneratedApiOperation(operationId: "MobilityDriverController_listOffers", method: "GET", path: "/v1/mobility/driver/offers"),
  GeneratedApiOperation(operationId: "MobilityDriverController_submitLocation", method: "POST", path: "/v1/mobility/driver/location"),
  GeneratedApiOperation(operationId: "MobilityDriverController_transitionRide", method: "POST", path: "/v1/mobility/driver/rides/{id}/transition"),
  GeneratedApiOperation(operationId: "NavigationController_computeRoute", method: "POST", path: "/v1/driver/navigation/route"),
];
