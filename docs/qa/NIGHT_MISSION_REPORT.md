# Rapport de mission nocturne — QA + UI/UX — NOKI Driver App

Mission autonome QA + UI/UX exécutée de nuit, sans supervision humaine en direct, en préparation de la bêta Congo. Ce rapport est écrit pour qu'une personne puisse reprendre le travail « à froid » le matin.

## 1. Branche, SHA, commandes exécutées

- **Dépôt** : `agrismartchain/noki-driver-app`
- **Branche** : `claude/modest-cori-m16go8` (poussée sur `origin`, aucune PR créée, aucune fusion, aucun déploiement, conformément au mandat)
- **SHA de départ** : `5c4388c254d8f92462d85feeb07a74a61132654e` (identique à `origin/main` au lancement)
- **SHA final** : `a4058acdc6f7228e99c8b1adb2d439078f93d6c6`
- **5 commits ajoutés cette nuit** (du plus ancien au plus récent) :
  1. `e3041b1` — `fix(ui): harmonize plain Material Card usage onto NokiSurfaceCard`
  2. `c688a33` — `feat(app): animated NOKI splash screen with reduce-motion support`
  3. `8291b11` — `fix(connectivity): surface offline status beyond the Home screen`
  4. `e33b716` — `test(location): cover GpsPublisherController's background/foreground lifecycle`
  5. `a4058ac` — `fix(mobility): localize MobilityHistoryScreen (was hardcoded French)`

### Commandes exécutées et résultats (dans l'ordre, répétées après chaque lot de modifications)

| Commande | Résultat au départ (baseline, inchangé) | Résultat final |
|---|---|---|
| `flutter pub get` | OK (bump cosmétique de `pubspec.lock` dû au SDK plus récent — annulé à chaque fois avec `git checkout -- pubspec.lock`, jamais commité) | idem |
| `flutter analyze` | 79 problèmes, tous `info` / `deprecated_member_use` (dépréciation `package:flutter/material.dart` → `material_ui`/`cupertino_ui`, propre au SDK plus récent, hors périmètre), **0 erreur, 0 avertissement** | **82 problèmes** (79 pré-existants + 3 du même type `deprecated_member_use`, un par nouveau fichier de test ajouté cette nuit), **0 erreur, 0 avertissement** — aucune nouvelle catégorie de problème introduite |
| `flutter test` | **238/238 tests réussis** | **247/247 tests réussis** (9 nouveaux tests ajoutés cette nuit, 0 test cassé) |
| `flutter build web --release` | Non testé avant (le plugin Web n'était pas initialisé dans ce dépôt) | **Build réussi** après `flutter create . --platforms web` (fichiers `web/` ajoutés et re-brandés NOKI). Capture d'écran réelle du rendu (écran de connexion, locale FR par défaut) : `docs/qa/screenshots/web_login_render.png`, produite via Chromium headless (Playwright) servant `build/web`. |
| `flutter build apk --debug` (tentative, priorité basse) | — | **Réussi** après mise en place manuelle du SDK Android — voir §5. APK produit : `build/app/outputs/flutter-apk/app-debug.apk` (174 Mo, non commité — répertoire déjà ignoré par `.gitignore`). Non installé/exécuté (aucun émulateur/device dans ce conteneur) |

Chaque commit a été suivi d'un nouveau `flutter analyze` + `flutter test` complet avant d'être poussé — voir le détail dans chaque message de commit (`git log`).

## 2. Matrice des scénarios

Légende preuve : **Test auto** = `flutter test` ; **Web** = rendu réel observé via build web + Chromium headless (preuve visuelle/layout uniquement — jamais une validation GPS/navigation réelle) ; **Revue de code** = lecture du code + logique métier, sans exécution sur device réel ; **Device** = nécessiterait un téléphone/émulateur physique, absent de cet environnement.

| # | Scénario | Résultat | Preuve | Détail |
|---|---|---|---|---|
| 1 | Connexion (login) | **PASS** | Test auto + Web | `login_screen_test.dart`, `auth_controller_test.dart`, `auth_controller_real_provider_graph_test.dart`, `noki_driver_app_bootstrap_test.dart` (couvre aussi le bootstrap complet sans crash) ; rendu réel capturé en web (écran de connexion, FR) |
| 2 | Bascule disponible / indisponible | **PASS** | Test auto | `availability_card_test.dart` ; convention couleur imposée (vert=AVAILABLE, rouge=BUSY, gris=OFFLINE) vérifiée dans le code et par les tests |
| 3 | Réception + acceptation d'une offre de mission (Mobility) | **PASS** | Test auto | `mobility_offer_detail_screen_test.dart`, `work_feed_mobility_offer_navigation_test.dart`, `mobility_offer_poller_test.dart` (découverte auto des offres, 7s de cadence) |
| 4 | Navigation guidée en app (turn-by-turn) | **PARTIEL** | Test auto (logique) + Revue de code | `navigation_route_controller_test.dart`, `navigation_status_chips_test.dart` couvrent le calcul d'itinéraire, le throttling (150 m / 30 s), les chips ETA/distance/manœuvre. **Aucune validation sur device réel avec GPS en mouvement** — un test mocké ne prouve jamais qu'un virage s'affiche au bon moment dans une vraie voiture |
| 5 | Arrivée / clôture de mission (Delivery OTP, Mobility transitions) | **PASS** | Test auto | `delivery_mission_detail_screen_test.dart` (flux OTP complet), `delivery_completion_refresh_test.dart`, `mobility_completion_refresh_test.dart`, `mobility_ride_screen_test.dart` |
| 6 | Étapes métier intermédiaires (machine à états) | **PASS** | Test auto | `delivery_status_presentation_test.dart`, `mobility_status_presentation_test.dart` — transitions légales testées unitairement |
| 7 | Permission GPS (accordée / refusée une fois / refusée définitivement / service désactivé) | **PASS** | Test auto | `location_permission_gate_test.dart` couvre les 4 états + le flux de re-demande |
| 8 | Reprise après perte réseau | **PASS (corrigé cette nuit)** | Test auto | Avant : bannière hors-ligne visible **uniquement sur Home**. Corrigé — voir §3. Le retry par action (OTP, transition, acceptation) existait déjà et est testé partout. Perte réseau réelle sur device non testée |
| 9 | Reprise après mise en arrière-plan de l'app | **PASS** | Test auto (nouveau) | `GpsPublisherController.pauseForBackground/resumeForForeground` n'avait **aucun test direct** avant cette nuit (seul le polling d'offres l'avait) — ajouté (`gps_publisher_test.dart`). Le câblage réel dans `HomeShell.didChangeAppLifecycleState` (qui appelle les deux contrôleurs) n'a lui-même aucun test d'intégration widget — signalé en dette de test, pas un bug |
| 10a | App tuée en pleine mission | **PASS** | Revue de code | Conception sans état local fragile : au relancement, Home re-dérive systématiquement « mission active » depuis l'état serveur (`availability.activeDeliveryMissionCount`/`activeMobilityRideCount`), jamais depuis un cache local. Rien à perdre si l'app est tuée |
| 10b | Offre qui expire | **FAIL (gap identifié, non corrigé)** | Revue de code | Voir défaut D1 en §3 — aucune indication d'expiration visible pour le conducteur sur le seul écran réellement atteignable |
| 10c | Double-acceptation (race) | **PASS (logique) / BLOQUÉ (réel)** | Revue de code | Garde locale anti-double-tap + `AppFailureType.conflict` (409) géré génériquement. La vraie course à 2 conducteurs nécessite 2 comptes + backend réel — non testable ici |
| 11 | Écrans de mission sur petit écran | **PASS** | Test auto | `delivery_mission_map_screen_responsive_test.dart`, `mobility_ride_map_screen_responsive_test.dart`, `mobility_ride_screen_responsive_test.dart`, `work_feed_responsive_test.dart`, `vehicles_responsive_test.dart` |
| 12 | Mode sombre / contraste | **PASS** | Test auto | `dark_mode_test.dart` |
| 13 | RTL (arabe) | **PASS** | Test auto | `rtl_test.dart` ; un gap d'i18n trouvé et corrigé cette nuit (§3, `MobilityHistoryScreen`) |
| 14 | Respect du réglage OS « réduire les animations » | **PASS (ajouté cette nuit)** | Test auto | N'existait nulle part avant. `NokiMotion` + tests dans `splash_screen_test.dart`. Propagé au splash, à l'indicateur d'onglet actif et à `NokiSurfaceCard` ; pas encore propagé à 100 % du code (voir backlog E2) |
| 15 | Zones tactiles larges / usage à une main | **PASS** | Revue de code | `ElevatedButton`/`OutlinedButton` ont une hauteur minimale de 56 dp pleine largeur par thème global (`Size.fromHeight(AppControlSize.primaryButtonHeight)`), `IconButton` ≥ 48 dp. Pas de test automatisé dédié à la mesure des cibles tactiles |
| 16 | Agrandissement du texte système (accessibilité) | **NON TESTÉ** | — | Aucun test `textScaleFactor` trouvé dans la suite ; à ajouter |
| 17 | Build web (bêta stand-in) | **PASS** | Web | Capture réelle jointe (`docs/qa/screenshots/web_login_render.png`) |
| 18 | Build APK debug | **PASS (compilation uniquement)** | Build | Voir §5 — compile et produit un APK installable ; jamais exécuté faute de device |

## 3. Défauts corrigés cette nuit

| # | Défaut | Priorité | Fichiers | Statut |
|---|---|---|---|---|
| C1 | Incohérence visuelle : plusieurs écrans utilisaient le `Card` Material générique au lieu du composant de design system `NokiSurfaceCard` (carte OTP/incidents de livraison, carte de scan QR, cartes Work Feed livraison/mobilité, détail d'offre mobilité, section incidents mobilité) | Visuel / cohérence | `delivery_mission_detail_screen.dart`, `delivery_qr_scan_screen.dart`, `delivery_work_card.dart`, `mobility_incidents_section.dart`, `mobility_offer_detail_screen.dart`, `mobility_work_card.dart` | **Corrigé** (commit `e3041b1`) |
| C2 | Splash screen statique, sans animation, sans respect du réglage « réduire les animations », icône générique au lieu de la vraie identité NOKI | Majeur (UX demandé explicitement) | `lib/app/splash_screen.dart`, `lib/app/root_gate.dart`, `lib/core/theme/motion.dart`, `assets/brand/noki_logo.png` (vrai logo NOKI, copié de l'icône de lancement Android) | **Corrigé** (commit `c688a33`) |
| C3 | Aucun indicateur de perte réseau en dehors de Home (Work Feed, détail mission/course, carte de navigation active) | Fonctionnel (scénario explicitement demandé) | `offline_banner.dart` (+ nouveau `NetworkStatusChip`), `work_feed_screen.dart`, `delivery_mission_detail_screen.dart`, `mobility_ride_screen.dart`, `delivery_mission_map_screen.dart`, `mobility_ride_map_screen.dart` | **Corrigé** (commit `8291b11`) |
| C4 | `GpsPublisherController.pauseForBackground`/`resumeForForeground` — la moitié « GPS » du contrat de cycle de vie arrière-plan (mandatée §10/§35) n'avait aucun test direct, contrairement à la moitié « polling d'offres » | Dette de test (sécurité du suivi GPS) | `gps_publisher.dart` (ajout d'un seuil d'horloge testable `nowFn`), `gps_publisher_test.dart` | **Corrigé** (commit `e33b716`) — aucun bug de comportement trouvé, juste absence de preuve |
| C5 | `MobilityHistoryScreen` : titre et message d'état vide codés en dur en français (« Historique Mobility », « Aucune course Mobility terminee » — accent manquant en plus), ignorant la locale choisie par le conducteur. Bouton identique codé en dur dans `SettingsScreen`. Texte obsolète juste à côté affirmant que l'historique Mobility « nécessite encore le backend » alors que l'écran fonctionne déjà avec de vraies données | Fonctionnel i18n + contenu obsolète | `mobility_history_screen.dart`, `settings_screen.dart`, 3 fichiers `.arb` + générés | **Corrigé** (commit `a4058ac`) |

Pour chaque correctif : scénario concerné ré-exécuté (`flutter test` ciblé puis suite complète), `flutter analyze` et `flutter test` complets relancés avant commit — voir §1.

## 4. Défauts restants (non corrigés, priorisés)

### D1 — Aucune indication d'expiration d'offre visible pour le conducteur (Priorité : Moyenne)

**Repro** : Travail → taper sur une carte d'offre de course en attente → `MobilityOfferDetailScreen` s'ouvre. Rien n'indique au conducteur que l'offre expire bientôt, alors que le scénario « offre qui expire » est explicitement demandé dans la mission.

**Cause racine** (trouvée par lecture du code, pas une supposition) : `DriverMobilityOfferDto` (le DTO complet, retourné par `GET /v1/mobility/driver/offers`) porte bien `offeredAt`/`expiresAt`. Mais le **seul chemin de navigation réellement utilisé** dans l'app (`WorkFeedScreen._open` → `MobilityOfferDetailScreen.fromWorkFeedItem`) construit l'écran à partir du `DriverWorkFeedItemDto`, plus léger, qui **ne porte pas** `expiresAt`. Un deuxième écran plus complet existe déjà dans le même fichier (`MobilityOfferLookupScreen`, qui résout l'id contre la vraie liste d'offres et porte bien `expiresAt`) mais **n'est appelé depuis nulle part dans l'app** — code mort/orphelin, probablement prévu pour une entrée par lien profond (notification push) qui n'existe pas encore.

**Pourquoi non corrigé cette nuit** : un test (`work_feed_mobility_offer_navigation_test.dart`) verrouille délibérément le choix actuel — `.fromWorkFeedItem` fonctionne même quand la liste d'offres est vide/périmée, ce qui est une robustesse voulue, pas un bug. Rebrancher vers `MobilityOfferLookupScreen` réintroduirait exactement la fragilité que ce test empêche. La vraie correction nécessite soit un ajout de `expiresAt` au DTO `DriverWorkFeedItemDto` (changement de contrat API, explicitement hors périmètre de cette mission UI/UX), soit un nouveau point d'entrée dédié — à trancher par l'équipe produit/backend.

**Fix proposé** : ajouter `expiresAt` à `DriverWorkFeedItemDto` côté `noki-api` (ticket backend), puis afficher un compte à rebours/badge d'urgence dans `MobilityOfferDetailScreen` (composant à ajouter dans `core/ui/noki_ui.dart`, cohérent avec `NokiBadge`), désactiver le bouton « Accepter » une fois expiré avec message dédié.

### D2 — `mobility_ride_screen.dart` : 2 `Card` restants, non harmonisés (Priorité : Basse)

**Repro** : ouvrir un détail de course Mobility (pas la carte, l'écran liste) → la carte « Pickup/Dropoff/Tarif » et la carte « Historique » utilisent encore `Card` Material générique.

**Cause de la non-correction** : remplacer par `NokiSurfaceCard` modifie légèrement la hauteur du contenu (la `Card` Material a une marge par défaut de 4dp que `NokiSurfaceCard` n'a pas), ce qui suffit à faire entrer `MobilityIncidentsSection` — normalement hors-vue dans ce `ListView` non paginé — dans la zone de construction lazy de Flutter. Son `DropdownButtonFormField` construit alors un item caché supplémentaire portant le texte « Ride » (le même texte que le titre de l'AppBar), et un test (`mobility_offer_detail_screen_test.dart`) qui cherche `find.text('Ride'), findsOneWidget)` échoue — pas une régression fonctionnelle, mais une fragilité de test pré-existante révélée par un changement par ailleurs correct.

**Fix proposé** : rendre le test plus spécifique (chercher le texte dans l'AppBar précisément, ex. `find.descendant(of: find.byType(AppBar), matching: find.text('Ride'))`) **avant** de refaire la tentative d'harmonisation.

### D3 — Pas de test d'agrandissement du texte système (accessibilité) (Priorité : Basse)

Aucun test `textScaleFactor` trouvé. À ajouter, en particulier sur les écrans de mission/navigation où le texte doit rester lisible en plein soleil avec une taille système augmentée.

### D4 — Pas de test d'intégration widget pour `HomeShell.didChangeAppLifecycleState` (Priorité : Basse)

Les deux contrôleurs qu'il pilote (`GpsPublisherController`, `MobilityOfferPollerController`) sont désormais testés individuellement, mais le câblage réel (`HomeShell` reçoit bien `AppLifecycleState.paused`/`resumed` et appelle les deux) n'a pas de test widget dédié.

### D5 — `livePositionProvider` continue de s'abonner au GPS local même app en arrière-plan sur un écran de carte (Priorité : Basse / observation)

Contrairement à `GpsPublisherController` (explicitement coupé par `HomeShell` en arrière-plan), le flux de position *locale* affichée sur la carte (`core/location/live_position_provider.dart`) n'est jamais coupé lui-même. Aucune donnée n'est envoyée au réseau (impact batterie uniquement, probablement déjà limité par l'OS qui throttle les abonnements de localisation d'une app en arrière-plan). Signalé, non corrigé — nécessiterait de faire écouter `HomeShell` ce provider aussi, à évaluer avec l'équipe.

### D6 — Scénarios nécessitant un vrai device/backend (Priorité : à valider demain, voir checklist §5)

Course concurrente à 2 conducteurs, navigation GPS en mouvement réel, permission GPS sur device réel (Android/iOS), reprise après tuage OS réel (pas juste un redémarrage de process de test), latence réseau réelle.

## 5. Résultat des builds + mini-checklist pour demain sur téléphone physique

### Build web
**Réussi.** `flutter create . --platforms web` a été nécessaire (le support Web n'était pas initialisé dans ce dépôt) — fichiers `web/` ajoutés et re-brandés NOKI (titre, manifest, description) au lieu des placeholders « A new Flutter project » générés par défaut. `flutter build web --release` compile sans erreur. Capture d'écran réelle (Chromium headless via Playwright, servant `build/web`) : `docs/qa/screenshots/web_login_render.png` — montre l'écran de connexion réel, locale française par défaut, rendu propre, aucun chevauchement.

**Rappel du mandat** : ce build web est une preuve de *mise en page/rendu* uniquement. L'app dépend fortement de cartes/GPS/navigation en direct qui se comportent très différemment (ou pas du tout) en web — ceci ne valide jamais un vrai trajet de conduite.

### Build APK debug (tentative, priorité basse)
**Réussi**, après plusieurs obstacles d'infrastructure (pas de code de l'app) :

1. Android SDK absent du conteneur → installé manuellement (`cmdline-tools`, `platform-tools`, `platforms;android-36`, `build-tools;36.0.0`, NDK r28c, CMake 3.22.1) via `sdkmanager`, licences acceptées.
2. Version d'Android Gradle Plugin figée dans le projet (9.1.0) inférieure au minimum requis par ce SDK Flutter plus récent (9.1.1) → contourné localement avec `--android-skip-build-dependency-validation` (lecture seule, sans toucher au projet).
3. Le build release-signing est, à raison, bloqué par défaut (`chore(android): harden driver release branding and signing`) → contourné pour compilation seule via `NOKI_ALLOW_DEBUG_RELEASE_SIGNING=true` (prévu explicitement par le projet pour cet usage, jamais pour une vraie distribution).
4. Le proxy réseau de cet environnement a d'abord répondu `429 Too Many Requests` de façon répétée sur `repo.maven.apache.org` (dépendances Kotlin/AndroidX) — en réduisant le parallélisme Gradle (`org.gradle.workers.max=1`, `org.gradle.parallel=false`, temporaire) et en relançant, les téléchargements ont fini par passer et la compilation native (mobile_scanner, ~3 min) a abouti.

**Résultat** : `build/app/outputs/flutter-apk/app-debug.apk` (174 Mo) produit avec succès. **Non installé ni exécuté** — aucun émulateur/device dans ce conteneur ; ceci prouve seulement que le projet compile avec ce SDK Flutter plus récent, pas qu'il fonctionne sur un vrai téléphone.

**Aucun fichier de configuration du projet n'a été modifié de façon permanente pour cette tentative** : `android/local.properties` est gitignored (ligne `sdk.dir` ajoutée, locale à ce conteneur) ; `android/gradle.properties` a été modifié temporairement (3 lignes de réglages Gradle) puis restauré à l'identique avant le commit final — `git diff` est vide sur ce fichier. L'APK produit n'est pas commité (déjà couvert par `/build/` dans `.gitignore`).

**Point d'attention pour une vraie CI/release** : le mismatch de version AGP (9.1.0 commité vs 9.1.1+ requis par ce SDK Flutter) n'est contourné ici que par un flag de validation désactivée — une vraie CI qui installera ce même SDK Flutter plus récent sans ce flag échouera à la même étape. À planifier : bump du AGP committé dans `android/settings.gradle.kts` lors d'une prochaine mise à jour du SDK Flutter du projet (hors périmètre de cette mission QA/UI).

### Mini-checklist à exécuter demain sur téléphone physique (Android et/ou iOS)

1. Connexion avec un vrai compte conducteur (Delivery + Mobility si double-profil) — vérifier qu'aucun écran de connexion ne boucle.
2. Bascule disponible/indisponible — vérifier la couleur (vert/rouge/gris) et la latence de confirmation serveur.
3. Recevoir une vraie offre Mobility (ou mission Delivery) poussée par le backend réel — vérifier l'apparition automatique (polling 7s) sans pull-to-refresh.
4. Accepter l'offre, ouvrir la carte, suivre un vrai trajet en voiture/moto — vérifier que l'itinéraire se recalcule après un vrai écart de ~150m, pas à chaque frame GPS.
5. Mettre l'app en arrière-plan 30+ secondes en pleine mission, revenir au premier plan — vérifier que la position reprend sans état bloqué/périmé.
6. Couper les données mobiles en pleine mission — vérifier que la bannière/puce hors-ligne apparaît sur l'écran actif (pas seulement sur Home), et qu'elle disparaît au retour du réseau.
7. Refuser puis accorder la permission GPS — vérifier qu'aucune boucle de re-demande n'apparaît en cas de refus définitif (« Ouvrir les réglages » uniquement).
8. Scanner un vrai QR de colis (pas la saisie manuelle) — vérifier la bascule caméra/clavier.
9. Clôturer une mission (OTP livraison / transition course) — vérifier qu'aucun double-tap ne déclenche deux appels serveur.
10. Tuer l'app depuis le gestionnaire de tâches OS en pleine mission, relancer — vérifier que « Continuer la mission » réapparaît correctement sur Home.
11. Activer « Réduire les animations » dans les réglages d'accessibilité OS — vérifier que le splash apparaît instantanément (sans animation) au démarrage.
12. Agrandir la taille de texte système au maximum — vérifier qu'aucun texte n'est tronqué/superposé sur les écrans de mission.
13. Tester en arabe (RTL) un vrai parcours mission de bout en bout, pas seulement les captures d'écran statiques.

## 6. Verdict

**Corrections requises avant la bêta — pas bloquée, mais pas prête pour recette sur device sans action humaine.**

Ce qui est solide : la base de code est déjà mature (de nombreuses itérations QA antérieures visibles dans l'historique git, mandats « DRIVER-APP-0x » documentés dans les commentaires), 247 tests automatisés passent, 0 erreur/avertissement `flutter analyze`, les 5 correctifs de cette nuit ont chacun été re-testés avant commit, le build web fonctionne et produit un rendu propre, et un APK debug compile désormais avec succès avec ce SDK Flutter plus récent.

**Ce qui manque précisément pour le GO bêta :**
1. **Un vrai device Android/iOS** pour exécuter la checklist §5 et installer l'APK produit cette nuit — rien dans cet environnement ne permet de valider un vrai trajet GPS, une vraie perte réseau, ou un vrai tuage d'app par l'OS. L'APK compile mais n'a jamais tourné sur un appareil réel.
2. **Une décision produit/backend sur D1** (expiration d'offre) — nécessite un changement de contrat API, donc une validation côté équipe backend `noki-api`.
3. **Un bump du AGP committé** (`android/settings.gradle.kts`, actuellement 9.1.0) avant qu'une vraie CI puisse builder avec ce même SDK Flutter plus récent sans le flag de contournement utilisé cette nuit (voir §5).
4. Les points D2–D5 (dette de test mineure, pas des bugs) peuvent attendre une prochaine itération.

Tout le travail de cette nuit est commité et poussé sur `claude/modest-cori-m16go8` (SHA final `a4058acdc6f7228e99c8b1adb2d439078f93d6c6`). Aucune pull request n'a été créée, conformément au mandat.
