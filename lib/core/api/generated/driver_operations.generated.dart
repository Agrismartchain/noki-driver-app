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
  GeneratedApiOperation(operationId: "DriverController_availability", method: "GET", path: "/v1/driver/availability"),
  GeneratedApiOperation(operationId: "DriverController_context", method: "GET", path: "/v1/driver/context"),
  GeneratedApiOperation(operationId: "DriverController_updateAvailability", method: "PATCH", path: "/v1/driver/availability"),
  GeneratedApiOperation(operationId: "DriverController_vehicles", method: "GET", path: "/v1/driver/vehicles"),
  GeneratedApiOperation(operationId: "DriverController_workFeed", method: "GET", path: "/v1/driver/work-feed"),
];
