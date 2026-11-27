# NOKI Driver — Audit Production Congo (P0 & P1)

- **Branche de base** : `claude/modest-cori-m16go8` (`ad2c2c58990cd4c45fcf69ec97588e902c8cee09`, commit MFA présent en tête distante)
- **Branche de travail** : `fix/driver-production-ux`
- **Références API auditées (lecture seule)** :
  - `Agrismartchain/noki-api` branche `main` (`8888eb9dfbb7a7f5269cc31ee87dd157abd21f7e`)
  - `Agrismartchain/noki-api` branche `integration/phase28-post-recette-20261126` (`b563f01453d5b61f5234c4f073ab2e01a9682efb`)
  - `Agrismartchain/noki-finance` (client web Finance)
  - `Agrismartchain/noki-shared-contracts` : non rattaché au jeton GitHub de cet environnement (HTTP 403 `Resource not accessible by integration`) ; verrou de contrat local vérifié dans `contract/lock.json` (`contractsVersion: 0.73.0`, `apiHead: b681b0d62ccf298f021fe9559a8d8be0490dde31`).

---

## 1. Diagnostic des anomalies de recette (P0)

### 1.1 « Livraison : Une erreur est survenue. » sur le Profil
- **Fichier** : `lib/features/settings/settings_screen.dart`
- **Cause racine** : `_OperationalStatusCard` ajoutait inconditionnellement un badge `_StatusPill(label: l10n.profileStatusDelivery, value: _deliveryStatusLabel(l10n, profile.deliveryStatus))`, même pour un chauffeur sans profil Livraison (`deliveryProfileId == null`, `deliveryStatus == null`). `_deliveryStatusLabel` renvoyait `l10n.errorUnknown` (« Une erreur est survenue. ») sur `null` ou `unknown`.
- **Correctif** : `null` affiche désormais `l10n.profileStatusNotEnabled` (« Non activé » / « Not enabled » / « غير مفعّل ») sur badge neutre lisible ; `unknown` affiche `l10n.profileStatusUnavailable` (« Indisponible »).

### 1.2 Historiques « Introuvable. » (HTTP 404)
1. **Historique des livraisons (`GET /v1/delivery/missions?status=DELIVERED`)** :
   - Dans `noki-api/src/modules/delivery/delivery-shipment.service.ts` (`listOwnMissions`), le backend lève `NotFoundException('Driver mission profile not found')` (**HTTP 404**) dès que le chauffeur n'a pas de `DeliveryDriverProfile` au statut `ACTIVE` dans le couple `(organizationId, countryCode)`.
   - **Correctif** : `DeliveryHistoryScreen` distingue désormais **liste vide** (`200 OK`, `items: []`), **accès/service indisponible** (`404`/`403` -> « Historique des livraisons indisponible » expliquant que le service Livraison n'est pas activé sur le profil), et **erreur technique** (`5xx`/réseau -> `ErrorView` avec bouton Réessayer).
2. **Historique Mobility (`GET /v1/driver/mobility/rides/history`)** :
   - Sur `noki-api@main` (`8888eb9`), cette route **n'existe pas** dans `DriverController` (`driver.controller.ts` ne déclare que `@Get('mobility/rides/current')` et `@Get('mobility/rides/:id')`). Fastify/NestJS associe donc `/v1/driver/mobility/rides/history` à `:id = "history"` et répond **HTTP 404** (« Introuvable. »).
   - Sur `integration/phase28-post-recette-20261126` (`b563f01`), `@Get('mobility/rides/history')` a été ajouté avant `:id` (note : filtre `serviceType: { in: ['TAXI', 'TAXI_MOTO', 'CARGO'] }`, sans `COURIER`).
   - **Correctif** : `MobilityHistoryScreen` distingue désormais **liste vide** (`200 OK`, `[]`), **historique indisponible** (`404`/`403` -> « Historique Mobility indisponible »), et **erreur technique** (`ErrorView` + Réessayer).
3. **HTTP 400 non mappé** : `AppFailure._fromStatusCode` ne traitait pas `400`, qui tombait dans `unknown` (« Une erreur est survenue. »). Mappé vers `AppFailureType.validation`.

### 1.3 Blocage du scroll, chevauchement de la barre du bas et contrastes sombres
- `HomeShell` définissait `extendBody: true`, étendant le contenu des 3 onglets **derrière** la barre de navigation du bas (~90 dp + zone système) alors que le padding bas des écrans était de 16–48 dp. Sur un téléphone standard, la dernière carte de l'Accueil restait masquée/inaccessible et le scroll semblait bloqué.
- `NokiColors.dark` associait `chromeSurface: #0A0A0A` à `textInverse: #121212` (noir sur noir !), rendant illisibles en thème sombre : `NokiBadgeTone.offline`, `AvailabilityCard`, `_DriverIdentityCard`, `MfaEnrollScreen` (clé secrète), `MfaVerifyScreen`, `MfaRecoveryCodesScreen` (codes de récupération), et `OfflineBanner`.
- `NokiScreenBackground` dessinait des orbes lumineux et une grille `_GridPainter`.
- **Correctifs** :
  - Suppression de `extendBody: true` sur `HomeShell`, barre de navigation sobre à fort contraste + `SafeArea` sur les écrans poussés et cartes.
  - Suppression du quadrillage/orbes dans `NokiScreenBackground` -> surfaces sobres et opaques.
  - Ajout de `chromeInk` (`#FFFFFF`), correction de `offline` / `offlineSurface` (contraste >= 4.5:1 en clair et sombre), passage des cartes Profil / Disponibilité / Connexion / MFA sur surfaces opaques `defaultTone` avec `textPrimary`.
  - Écrans MFA (`MfaEnrollScreen`, `MfaVerifyScreen`, `MfaRecoveryCodesScreen`) : surface opaque lisible, encadré dédié pour la clé et les codes de récupération, `LayoutBuilder` + `SingleChildScrollView` + `resizeToAvoidBottomInset: true` pour garder champs et boutons accessibles clavier ouvert.
  - Accueil (`HomeScreen`) : logo NOKI (`assets/brand/noki_logo.png`) à côté du salut, carte intégrée visible dès l'ouverture (`interactive: false` / `IgnorePointer` sur le canvas `FlutterMap` pour que tout geste de défilement fasse défiler la page), centrage sur la zone de service connue (`CG` Brazzaville, `CD`, `MA`, `CM`, `CI`, `SN`, `GA`) puis position GPS réelle dès disponibilité.
  - GPS : bandeau actionnable sur l'Accueil selon l'état réel (`deniedOnce` -> demander permission, `serviceDisabled` -> `Geolocator.openLocationSettings()`, `deniedForever` -> `Geolocator.openAppSettings()`), ré-interrogation automatique de l'autorisation et du flux GPS au retour dans l'app (`AppLifecycleState.resumed`) dans `HomeShell`, `HomeScreen` et `LocationPermissionGate`.
  - Travail (`WorkFeedScreen`) : filtres accessibles pour **Tout**, **Livraison**, **Taxi**, **Taxi Moto**, **Colis**, **Cargo**, **En cours**, **En attente** + distinction liste vide / filtre vide avec réinitialisation / accès indisponible (`403`) / erreur.

---

## 2. Cartographie métier complète (P1)

Permissions attribuées au rôle `SYSTEM_ROLE_CODES.DRIVER` dans `noki-api/src/modules/authorization/authorization.constants.ts` (20 permissions atomiques) :
`auth.me.read`, `driver.profile.read_own`, `driver.vehicle.read_own`, `driver.availability.read_own`, `driver.work.read_own`, `delivery.mission.read_own`, `delivery.mission.complete_own`, `delivery.incident.read_own`, `delivery.incident.create_own`, `delivery.qr.scan_own`, `delivery.otp.request_own`, `delivery.otp.verify_own`, `delivery.location.submit_own`, `mobility.location.submit_own`, `mobility.offer.read_own`, `mobility.offer.respond_own`, `mobility.ride.read_own`, `mobility.ride.transition_own`, `mobility.incident.read_own`, `mobility.incident.create_own`.

| Fonction métier | Écran `noki-driver-app` | Route API | Permission `DRIVER` | État réel | Dépôt responsable |
|---|---|---|---|---|---|
| Contexte chauffeur & profil | `HomeScreen`, `SettingsScreen` | `GET /v1/driver/context` | `driver.profile.read_own` (OK) | **Supporté** (nb: `operatingZoneIds` absent du DTO contexte) | `noki-api` (si ajout zones), `noki-driver-app` |
| Disponibilité chauffeur | `AvailabilityCard` (Accueil) | `GET/PATCH /v1/driver/availability` | `driver.availability.read_own`, `mobility.offer.read_own` (OK) | **Supporté** (Livraison & Mobilité séparées) | `noki-driver-app` (OK) |
| Fil de travail unifié | `WorkFeedScreen` | `GET /v1/driver/work-feed` | `driver.work.read_own` (OK) | **Supporté** (`DELIVERY`, `TAXI`, `TAXI_MOTO`, `COURIER`, `CARGO` selon branche déployée) | `noki-api` (aligner `main` avec `integration`), `noki-driver-app` |
| Missions Livraison (détail, QR, OTP, clôture, incidents) | `DeliveryMissionDetailScreen`, `DeliveryMissionMapScreen`, `DeliveryQrScanScreen` | `GET /v1/delivery/missions`, `GET /v1/delivery/missions/:id`, `POST /v1/delivery/missions/scan-qr`, `POST .../handoff-otp/{request,verify}`, `POST .../complete`, `POST .../incidents`, `GET /v1/driver/delivery/missions/:id/incidents` | `delivery.mission.read_own`, `delivery.qr.scan_own`, `delivery.otp.*_own`, `delivery.mission.complete_own`, `delivery.incident.*_own` (OK) | **Supporté** si `DeliveryDriverProfile.status == ACTIVE` ; sinon `listOwnMissions` renvoie **404** | `noki-api` (retourner `[]` au lieu de 404 si pas de profil Delivery), `noki-driver-app` (géré proprement) |
| Offres Mobility (liste, acceptation) | `WorkFeedScreen`, `MobilityOfferDetailScreen`, `MobilityOfferPollerController` | `GET /v1/driver/mobility/offers`, `GET /v1/mobility/driver/offers`, `POST /v1/mobility/driver/offers/:id/accept` | `mobility.offer.read_own`, `mobility.offer.respond_own` (OK) | **Partiel** : acceptation OK ; pas d'endpoint `decline` ; `GET /v1/mobility/driver/offers` absent de `main` `8888eb9` ; `expiresAt` absent de `DriverWorkFeedItemDto` | `noki-api`, `noki-shared-contracts`, `noki-driver-app` |
| Courses Mobility (course en cours, transitions, incidents) | `MobilityRideScreen`, `MobilityRideMapScreen` | `GET /v1/driver/mobility/rides/current`, `GET /v1/driver/mobility/rides/:id`, `POST /v1/mobility/driver/rides/:id/transition`, `GET/POST /v1/driver/mobility/incidents` | `mobility.ride.read_own`, `mobility.ride.transition_own`, `mobility.incident.*_own` (OK) | **Supporté** | `noki-driver-app` (OK) |
| GPS / Télémétrie | `GpsPublisherController`, `HomeScreen`, écrans Carte | `POST /v1/delivery/location`, `POST /v1/mobility/driver/location` | `delivery.location.submit_own`, `mobility.location.submit_own` (OK) | **Attention** : sur `noki-api@main` `8888eb9`, `DeliveryLocationPointInputDto` rejette `headingDegrees`/`speedKph` (400) | `noki-api` (aligner `main` / DTO) |
| Routage in-app | `NavigationRouteController` | `POST /v1/driver/navigation/route` | Non présent sur `main` `8888eb9` | **Dépend du déploiement** (dégradation gracieuse déjà en place) | `noki-api`, `noki-shared-contracts` |
| **Retours / Échecs de livraison** | Aucun écran dédié | Aucune route `DRIVER` (`POST /v1/delivery/shipments/:id/attempts` exige `delivery.attempt.create`, réservé Ops) | **Manquante** | **Non supporté par l'API** : aucun statut `RETURNED`/`RETURNING` ni endpoint retour chauffeur | `noki-api`, `noki-shared-contracts`, `noki-driver-app` |
| **Historique Livraisons** | `DeliveryHistoryScreen` | `GET /v1/delivery/missions?status=DELIVERED` | `delivery.mission.read_own` (OK) | **Supporté** si profil Delivery actif ; **404** si chauffeur Mobilité seul (géré côté app) | `noki-api` (retourner `[]`), `noki-driver-app` |
| **Historique Mobility** | `MobilityHistoryScreen` | `GET /v1/driver/mobility/rides/history` | `mobility.ride.read_own` (OK) | **Manquant sur `main` `8888eb9` (404)** ; présent sur `integration/phase28-post-recette-20261126` (filtre `TAXI`, `TAXI_MOTO`, `CARGO` sans `COURIER`) | `noki-api` (merger/déployer la route + inclure `COURIER`), `noki-shared-contracts` |
| **Véhicules** | `VehiclesScreen`, `SettingsScreen` | `GET /v1/driver/vehicles` | `driver.vehicle.read_own` (OK) | **Lecture seule supportée** (pas d'ajout/édition/changement de véhicule actif côté chauffeur) | `noki-api` (si self-service souhaité) |
| **Documents chauffeur & véhicule** | `SettingsScreen` (bandeau d'état) | Aucune route (`documentsAvailable: boolean` uniquement sur véhicule) | **Manquante** | **Non supporté par l'API** (aucun modèle `DriverDocument`/`VehicleDocument` dans Prisma) | `noki-api`, `noki-shared-contracts`, `noki-driver-app` |
| **Notifications** | `SettingsScreen` (bandeau d'état) | Aucune route (pas d'inbox ni d'enregistrement de jeton FCM/APNs) | **Manquante** | **Non supporté par l'API** | `noki-api`, `noki-shared-contracts`, `noki-driver-app` |
| **Support / Tickets** | Aucun écran dédié | Aucune route `DRIVER` (`/v1/seller/support/tickets` réservé `SELLER`, `/v1/support/tickets` réservé Contact Center) | **Manquante** | **Non supporté par l'API** | `noki-api`, `noki-shared-contracts`, `noki-driver-app` |
| **Portefeuille chauffeur, Gains, COD & Demandes de paiement** | Montants COD (`À encaisser` en XAF) et tarifs estimés sur cartes/détails ; aucun écran portefeuille | **Aucune route `/v1/driver/finance/*` ou `/v1/driver/wallet/*`** | **0 permission finance sur `DRIVER`** | **Contrat manquant côté `noki-api`** (voir §3 ci-dessous) | `noki-api`, `noki-shared-contracts`, `noki-finance`, `noki-driver-app` |

---

## 3. Audit prioritaire : Portefeuille chauffeur, Gains, COD & Paiements (XAF)

### 3.1 Ce qui existe déjà côté moteur Finance (`noki-api` & `noki-finance`)
- Le schéma Prisma (`noki-api/prisma/schema.prisma`) et les services Finance Phase 2 (`FinancePhase2Controller`, `FinanceCashController`, `FinanceConsumerController`) **modélisent déjà `DRIVER` comme contrepartie de premier rang** :
  - `FinanceLedgerCounterpartyType.DRIVER`, `PayoutRecipientType.DRIVER`.
  - `FinancialObligation` (`PAYABLE`/`RECEIVABLE`, statuts `OPEN`, `PARTIALLY_ALLOCATED`, `ALLOCATED`, `ON_HOLD`, `PARTIALLY_SETTLED`, `SETTLED`, `CANCELLED`, `REVERSED`).
  - `Payout` + `PayoutLine` + `PayoutHold` + `PayoutApproval` + `FinancePaymentMethod` (`BANK_ACCOUNT`, `MOBILE_MONEY`).
  - `CodCollection` (`DECLARED`, `VOIDED`, `REMITTED`, `RECONCILED`) et `CashHandover` / `CashSession` / `CashVariance`.
- `noki-finance` consomme déjà ces endpoints back-office avec `counterpartyType: "DRIVER"`, et `noki-api` dispose déjà d'un modèle self-service complet pour les vendeurs dans `SellerFinanceController` (`/v1/seller/finance/*`).

### 3.2 Ce qui manque pour intégrer le portefeuille dans `noki-driver-app` (dépendances à livrer avant intégration mobile)
1. **Permissions atomiques `DRIVER` (`noki-api`)** : créer et attribuer au rôle `DRIVER` des permissions propres (`driver.finance.read_own`, `driver.cod.read_own`, `driver.payout.read_own`, `driver.payout.request_own`, `driver.payment_method.manage_own`).
2. **Comptabilisation automatique des gains (`noki-api`)** : aujourd'hui, `DeliveryEvidenceService.completeOwnMission` et `MobilityService.transitionRide(COMPLETED)` **ne créent aucune `FinancialObligation` ni écriture de gain chauffeur**, et la clôture de livraison ne crée pas automatiquement de `CodCollection`.
3. **Endpoints self-service `/v1/driver/finance/*` (`noki-api` + publication `@agrismartchain/noki-shared-contracts`)** :
   - `GET /v1/driver/finance/summary?organizationId=&countryCode=` -> soldes réels en `XAF` : `availableForPayout` (disponible), `onHold` (bloqué), `pendingPayout` (en attente), `paid` (payé), plus synthèse COD séparée (`codToRemit`, `codRemitted`, `codReconciled`) afin de ne **jamais** confondre les espèces COD encaissées pour NOKI avec les gains du chauffeur.
   - `GET /v1/driver/finance/earnings` (gains par mission/course, liés à `sourceReferenceId` et `sourceDomain`).
   - `GET /v1/driver/finance/cod` & `POST /v1/driver/finance/cod/handovers` (suivi des encaissements COD et remises espèces).
   - `GET /v1/driver/finance/payouts` & `POST /v1/driver/finance/payouts` (demande de paiement idempotente avec `Idempotency-Key` + vérification d'éligibilité & méthode Mobile Money / compte bancaire actif).
4. **Règle d'intégrité respectée dans cette livraison** : aucune donnée de portefeuille ni demande de paiement n'a été simulée dans `noki-driver-app`. Les montants réels en **XAF** sont préservés tels quels (`formatNokiMoney` normalise `XAF` sans altération) et les encaissements COD restent explicitement distingués des gains (`À encaisser` + avertissement COD NOKI).
