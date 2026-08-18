# NOKI Driver App

Flutter/Dart client for authenticated NOKI drivers. Talks only to the
`/v1/auth/*` and `/v1/driver/*` boundary of `noki-api`, via the typed Dart
models generated from the canonical OpenAPI document. The backend remains
the sole source of truth: this app creates no parallel Delivery or Mobility
engine, and never merges `DeliveryShipment` and `Ride` into a single
"UniversalOrder" shape.

This is **DRIVER-APP-01**: Flutter bootstrap, secure auth, session
management, the Driver role guard, and read/write access to Driver context,
vehicles, availability and a work-feed foundation. It is not a finished
operational app - see [Limitations](#limitations-of-driver-app-01) below.

## Architecture

```text
lib/
  app/            Root widget, splash, auth-gated shell, bottom navigation
  core/
    api/          Dio client, generated models/operations, contract lock, HTTP client
    auth/         AuthSessionGateway interface (consumed by core/api, implemented by features/auth)
    config/       Build-time environment/config (--dart-define, no secrets)
    connectivity/ Network status stream + offline banner
    errors/       AppFailure model, error->message mapping, ErrorView/EmptyView/LoadingView
    i18n/         ARB sources, generated AppLocalizations, locale controller
    logging/      Redacted central logger
    routing/      go_router + auth-state-driven redirects
    storage/      SecureSessionStorage abstraction (Keystore/Keychain-backed)
    theme/        NOKI color/type/spacing tokens, ThemeData, theme controller
  features/
    auth/         Login, access-denied, session/role-guard controller
    driver_context/  Home screen, Driver context repository, DriverScope
    vehicles/     Vehicle list screen
    availability/ Availability card (read + update)
    work_feed/    Work feed screen (foundation only, see Limitations)
    settings/     Language/theme/logout
```

Deliberately **not** used: `lib/services.dart`-style catch-all files. Every
feature owns its repository/screen; `core/` holds only cross-cutting
concerns.

### State management: Riverpod (no code generation)

One paradigm across the whole app: `Provider`/`FutureProvider`/`Notifier`
from `flutter_riverpod`, used directly (no `riverpod_generator`/build_runner
step). This was chosen over Bloc/Provider/GetX because it removes
`BuildContext`-coupled global singletons and is fully testable through
`ProviderContainer` overrides (see every test under `test/`). Code
generation was deliberately left out to keep the build graph small and the
"why does this exist" answerable by reading the file, not a generated one.

### Routing: go_router

Declarative, Flutter-team-maintained. `core/routing/app_router.dart` derives
redirects from `AuthController`'s status (`bootstrapping` /
`unauthenticated` / `authenticating` / `authenticated` / `accessDenied`) so
no screen ever manually calls `Navigator.push` to enforce auth/role state.

### HTTP: Dio

`core/api/dio_client_factory.dart` centralizes: base URL + timeouts from
`AppConfig`, bearer injection, a single-flight 401-refresh-and-retry
interceptor, and redacted debug logging. `core/errors/app_failure.dart`
maps every Dio outcome to one closed `AppFailureType` enum consumed by the
UI - no screen inspects a status code directly.

### Secure storage

`flutter_secure_storage` (Android Keystore / iOS Keychain) behind the
`SecureSessionStorage` interface - access token, refresh token, and access
token expiry only. Never `SharedPreferences`, never logged. `shared_preferences`
is used exclusively for two non-sensitive settings: theme mode and locale.

## Contract strategy

`@agrismartchain/noki-shared-contracts` is a TypeScript/npm package and is
**not** consumed from Flutter. Instead:

```text
noki-api HEAD
   -> canonical OpenAPI export (docs/openapi/noki-api.openapi.json)
   -> synced into noki-shared-contracts (spec/openapi/noki-api.openapi.json, checksum-locked)
   -> read directly by tool/generate_api_models.mjs (this repo)
   -> lib/core/api/generated/*.generated.dart
```

`tool/generate_api_models.mjs` is a small, in-repo, deterministic generator
(Node, no external OpenAPI-generator dependency): it reads
`../noki-shared-contracts/spec/openapi/noki-api.openapi.json`, **refuses to
run if that file's SHA-256 does not match `contract/lock.json`**, and emits
plain Dart classes (`fromJson`/`toJson`, no reflection) only for the
operations explicitly whitelisted in `contract/lock.json ->
includedOperationIds`. No endpoint is ever guessed - every path is copied
from the real OpenAPI document.

An external generator (`openapi-generator-cli`, `dart-dio` target) was
considered and rejected for this phase: run unfiltered it would generate a
client for all 582 backend paths for 9 consumed ones, and there was no
existing Dart-generator convention in this monorepo to follow. This
decision can be revisited once the Driver mobile surface grows.

Regenerate after any backend change:

```bash
node tool/generate_api_models.mjs          # regenerate
node tool/generate_api_models.mjs --check  # fail if generated output is stale (used in CI when the contracts repo is checked out alongside this one)
```

### Contract lock

`contract/lock.json`:

```json
{
  "apiHead": "8888eb9dfbb7a7f5269cc31ee87dd157abd21f7e",
  "contractsVersion": "0.44.0",
  "openapiChecksum": "45429a359e1d2dd78c06810a1b20f595e4d87a75ffdd0b93a819b8b037dee0ba",
  "includedOperationIds": ["AuthController_login", "...", "DriverController_workFeed"]
}
```

No token, credential or credentialed URL is ever stored here or anywhere
else in this repo. `generatorVersion` is a manual semver for the generator
script itself, not a timestamp - the lock file is fully deterministic.

## Environments

Selected at build time, never hardcoded:

```bash
flutter run \
  --dart-define=NOKI_ENV=development \
  --dart-define=NOKI_API_BASE_URL=http://10.0.2.2:3000   # Android emulator loopback to host
```

`NOKI_ENV` is one of `development` / `staging` / `production` (see
`lib/core/config/app_environment.dart`). No environment's URL, token or
credential is checked into this repository.

## Authentication

Real endpoints only, verified against the canonical OpenAPI document before
implementation - no MFA, no dedicated "driver login" endpoint exists on the
backend today, so this app uses the same actor login the rest of NOKI uses:

- `POST /v1/auth/login` - email + password -> access/refresh tokens
- `POST /v1/auth/refresh` - refresh token -> new access/refresh tokens
- `POST /v1/auth/logout` - revokes the current session (best-effort; local
  session is always cleared even if this call fails)
- `GET /v1/driver/context` - used both to render Home *and* as the role
  guard: an authenticated actor with zero Driver profiles never reaches the
  authenticated shell (see `AuthController._resolveRoleGuard`)

**Gap reported, not invented:** the backend does not expose a `/v1/auth/me`
- or `/v1/auth/capabilities`-driven Driver role check; the closest and most
reliable signal is `DriverController_context` returning an empty
`profiles` array, which is what the role guard uses. If a dedicated
capability check is added to the backend, this guard should switch to it.

## Session bootstrap

```text
App launch -> read secure storage
  no tokens              -> /login
  tokens present         -> GET /v1/driver/context
    profiles non-empty   -> authenticated shell
    profiles empty       -> /access-denied
    401 (token rejected) -> storage cleared -> /login
    network/timeout/5xx  -> /login, with the failure surfaced (session kept
                             on disk - not discarded on a transient error)
```

No operational screen is ever built before this resolves - `SplashScreen`
is the only thing rendered during `AuthStatus.bootstrapping`.

## Testing

```bash
flutter analyze
flutter test
```

60 tests, all real (no `expect(true, true)` placeholders):

- **Unit** (`test/core/**`, `test/features/**/*_controller_test.dart`,
  `test/core/api/generated/driver_models_test.dart`): config parsing, error
  mapping for every HTTP status this app handles, secure-storage contract,
  Driver-context/vehicle/availability/work-feed JSON parsing (including one
  DELIVERY and one RIDE work-feed item, proving both parse under the same
  boundary without merging), locale/theme persistence, and the full
  `AuthController` state machine (bootstrap, login, role guard, refresh,
  session expiry, logout) against a controllable `FakeDriverApiClient`.
- **Widget** (`test/features/**/*_screen_test.dart`,
  `test/widget/*_test.dart`): login validation/loading/error, Driver home
  with real and empty vehicle data, vehicle list empty vs populated state,
  availability toggle sending the exact backend enum value, RTL layout
  under Arabic, and dark-theme token resolution.

Testability is structural, not incidental: `DriverApiClient` and
`SecureSessionStorage` are interfaces; tests substitute
`FakeDriverApiClient` / `FakeSecureSessionStorage` (`test/fixtures/`)
through Riverpod provider overrides - no HTTP call and no platform channel
is ever touched in a test.

## i18n / RTL / themes

- French (default), English, Arabic - `lib/core/i18n/arb/app_{fr,en,ar}.arb`,
  compiled by `flutter gen-l10n` (standard Flutter tooling, no third-party
  i18n package). Switchable from Profile; persisted via `shared_preferences`.
- Arabic drives `Directionality.rtl` automatically through
  `MaterialApp.supportedLocales` - verified in `test/widget/rtl_test.dart`,
  not just declared.
- Light/dark/system - `lib/core/theme/`. Every color is a named token
  (`NokiColors.light` / `NokiColors.dark`, mirrored from
  `noki-design-system/src/tokens/source/{color,theme-dark}.json`); no widget
  reads a raw `Color` literal.
- **Typography**: the design system's source-of-truth font family is
  `Helvetica, "Helvetica Neue", Arial, sans-serif`. Helvetica has no
  licensed `.ttf`/`.otf` in this monorepo and must not be downloaded from
  the internet (see `lib/core/theme/app_typography.dart`). This app
  therefore sets no `fontFamily` override, which makes Flutter fall back to
  each platform's native system font (Roboto on Android, San Francisco on
  iOS) - the documented, legally-safe fallback for this phase.

## Security notes

- Access/refresh tokens: `flutter_secure_storage` only (Android Keystore /
  iOS Keychain), never `SharedPreferences`, files, or logs. Full wipe on
  logout and on a rejected refresh.
- `AppLogger` (`core/logging/app_logger.dart`) redacts any key that looks
  like `accessToken`/`refreshToken`/`password`/`otp`/`authorization`/`token`
  before it reaches a log line, in both debug and release builds.
- 404s are treated as non-enumerating: the same generic "not found" message
  is shown whether a resource does not exist or is not the driver's own -
  see `AppFailureType.notFound` / `errorNotFound`.
- No optimistic UI updates for mutations: `AvailabilityCard` only reflects a
  new status after the server confirms it.
- Android manifest requests only `INTERNET` - no GPS/camera/background
  permission is requested until the feature that needs it ships.

## Android / iOS foundation

- Android: `applicationId com.agrismartchain.noki.noki_driver_app`,
  `minSdk 24` / `compileSdk 36` (Flutter defaults, already high enough for
  the GPS/camera work planned in later lots), `INTERNET` permission only.
- iOS: bundle id `com.agrismartchain.noki.nokiDriverApp`,
  `IPHONEOS_DEPLOYMENT_TARGET 15.0`, no usage-description keys added yet
  (no camera/location feature exists in this phase to justify one).

## CI

`.github/workflows/ci.yml`: `flutter pub get`, `flutter analyze`,
`flutter test --coverage`, `flutter build apk --debug`. Flutter version
pinned (`3.47.0`) via `subosito/flutter-action`, itself pinned by commit
SHA (as is `actions/checkout`), matching this monorepo's existing
pinned-action convention. No app is signed and no artifact is published by
this workflow.

## Limitations of DRIVER-APP-01

This phase is a foundation, not a finished app. Explicitly **not** built
yet (see the gate document for the full list): full Delivery/Ride mission
UI, map, background GPS, QR scanning, OTP workflow, proof-of-delivery,
signature, COD collection, earnings/settlements, push notifications,
realtime/websocket updates, an offline command queue or sync engine, and
the "Activity" navigation tab (no backend endpoint backs it yet, so it is
not shown - shipping a "coming soon" tab was judged worse than not having
one). The Driver scope is currently the actor's *first* Driver profile only
- multi-organization/multi-country selection is deferred.

## Next lot

**DRIVER-APP-02** (not started by this phase): full Work Feed interaction
(accept/decline offers, mission lifecycle), map integration, and the first
GPS-driven screens. Recommended, but not begun here per the gate document's
explicit instruction.
