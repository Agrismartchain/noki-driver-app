// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'NOKI Chauffeur';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginSubmit => 'Se connecter';

  @override
  String get loginSubmitting => 'Connexion…';

  @override
  String get loginEmailRequired => 'Saisissez votre adresse e-mail';

  @override
  String get loginEmailInvalid => 'Saisissez une adresse e-mail valide';

  @override
  String get loginPasswordRequired => 'Saisissez votre mot de passe';

  @override
  String get loginShowPassword => 'Afficher le mot de passe';

  @override
  String get loginHidePassword => 'Masquer le mot de passe';

  @override
  String get loginHeadline => 'Connexion à NOKI Chauffeur';

  @override
  String get loginSubheadline =>
      'Utilisez le compte fourni par votre organisation.';

  @override
  String get navHome => 'Accueil';

  @override
  String get navWork => 'Travail';

  @override
  String get navActivity => 'Activité';

  @override
  String get navProfile => 'Profil';

  @override
  String homeGreeting(String name) {
    return 'Bonjour, $name';
  }

  @override
  String get homeNoVehicle => 'Aucun véhicule assigné pour le moment';

  @override
  String get homeVehicleLabel => 'Véhicule assigné';

  @override
  String get homeCountryLabel => 'Pays';

  @override
  String get homeCapabilitiesLabel => 'Services';

  @override
  String get homeNoServices => 'Aucun service pour le moment';

  @override
  String get homeWorkFeedSummaryTitle => 'Fil de travail';

  @override
  String homeWorkFeedSummaryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches en cours',
      one: '1 tâche en cours',
      zero: 'Aucune tâche en cours',
    );
    return '$_temp0';
  }

  @override
  String get vehiclesTitle => 'Véhicules';

  @override
  String get vehiclesEmpty => 'Aucun véhicule sur votre profil';

  @override
  String get vehiclesEmptyBody =>
      'Les véhicules assignés par votre organisation apparaîtront ici.';

  @override
  String get vehicleTypeCar => 'Voiture';

  @override
  String get vehicleTypeMotorcycle => 'Moto';

  @override
  String get vehicleStatusPendingValidation => 'En attente de validation';

  @override
  String get vehicleStatusActive => 'Actif';

  @override
  String get vehicleStatusSuspended => 'Suspendu';

  @override
  String get vehicleStatusRetired => 'Retiré';

  @override
  String get vehiclePlateLabel => 'Immatriculation';

  @override
  String get availabilityTitle => 'Disponibilité';

  @override
  String get availabilityStatusOffline => 'Hors ligne';

  @override
  String get availabilityStatusAvailable => 'Disponible';

  @override
  String get availabilityStatusBusy => 'Occupé';

  @override
  String get availabilityUpdating => 'Mise à jour…';

  @override
  String get availabilityUpdateFailed =>
      'Impossible de mettre à jour votre disponibilité';

  @override
  String availabilityActiveMissions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livraisons en cours',
      one: '1 livraison en cours',
      zero: 'Aucune livraison en cours',
    );
    return '$_temp0';
  }

  @override
  String availabilityActiveRides(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count courses en cours',
      one: '1 course en cours',
      zero: 'Aucune course en cours',
    );
    return '$_temp0';
  }

  @override
  String availabilityPendingOffers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offres de course en attente',
      one: '1 offre de course en attente',
      zero: 'Aucune offre de course en attente',
    );
    return '$_temp0';
  }

  @override
  String get workFeedTitle => 'Fil de travail';

  @override
  String get workFeedEmpty => 'Rien d\'assigné pour le moment';

  @override
  String get workFeedEmptyBody =>
      'Les nouvelles missions de livraison et courses assignées apparaîtront ici.';

  @override
  String get workFeedTypeDelivery => 'Livraison';

  @override
  String get workFeedTypeRide => 'Course';

  @override
  String get workFeedFilterAll => 'Tout';

  @override
  String get workFeedFilterDelivery => 'Livraison';

  @override
  String get workFeedFilterRides => 'Courses';

  @override
  String get workFeedFilterActive => 'En cours';

  @override
  String get workFeedFilterPending => 'En attente';

  @override
  String deliveryCodBadge(String amount) {
    return 'Encaissement : $amount';
  }

  @override
  String get financeAmountToCollectLabel => 'À encaisser';

  @override
  String get financeAmountToCollectHint =>
      'Encaissez ce montant auprès du client avant de terminer la livraison.';

  @override
  String get financeCodSafetyNotice =>
      'Cette somme appartient à NOKI jusqu\'à sa réconciliation. Elle ne correspond pas à vos gains.';

  @override
  String get financeEstimatedFareLabel => 'Tarif estimé';

  @override
  String get financeEstimatedFareHint =>
      'Affiché comme contexte opérationnel de course, pas comme gain chauffeur validé.';

  @override
  String get missionDetailTitle => 'Mission';

  @override
  String get missionSectionPickup => 'Enlèvement';

  @override
  String get missionSectionDropoff => 'Livraison';

  @override
  String get missionSectionFinancial => 'Finances';

  @override
  String get missionSectionMission => 'Mission';

  @override
  String get missionSectionEvidence => 'Vérification de remise';

  @override
  String get missionSectionIncidents => 'Incidents';

  @override
  String get missionSectionNotAvailable => 'Non disponible pour cette mission';

  @override
  String get missionCallAction => 'Appeler';

  @override
  String get missionNavigateAction => 'Itinéraire';

  @override
  String get missionFinancialCodLabel => 'Paiement à la livraison';

  @override
  String get missionFinancialNoCurrency =>
      'Devise non disponible pour ce montant';

  @override
  String missionLineItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
      zero: 'Aucun article',
    );
    return '$_temp0';
  }

  @override
  String get missionTimestampAssigned => 'Assignée';

  @override
  String get missionTimestampOutForDelivery => 'En cours de livraison';

  @override
  String get missionTimestampDelivered => 'Livrée';

  @override
  String get missionTimestampFailed => 'Échouée';

  @override
  String get missionStatusReadyForDispatch => 'Prête à expédier';

  @override
  String get missionStatusAssigned => 'Assignée';

  @override
  String get missionStatusOutForDelivery => 'En cours de livraison';

  @override
  String get missionStatusDelivered => 'Livrée';

  @override
  String get missionStatusFailed => 'Échouée';

  @override
  String get missionStatusCancelled => 'Annulée';

  @override
  String get missionOtpRequestCta => 'Demander le code de remise';

  @override
  String get missionOtpRequestAgainCta => 'Demander un nouveau code';

  @override
  String missionOtpChallengeStatus(String status) {
    return 'Statut du code : $status';
  }

  @override
  String get missionOtpCodeLabel => 'Code à 6 chiffres';

  @override
  String get missionOtpVerifyCta => 'Vérifier le code';

  @override
  String get missionOtpVerifiedLabel => 'Code de remise vérifié';

  @override
  String get otpStatusPending => 'En attente';

  @override
  String get otpStatusVerified => 'Vérifié';

  @override
  String get otpStatusExpired => 'Expiré';

  @override
  String get otpStatusLocked => 'Bloqué';

  @override
  String get otpStatusRevoked => 'Révoqué';

  @override
  String get missionCompleteCta => 'Terminer la mission';

  @override
  String get missionCompleteRequiresOtp =>
      'Vérifiez le code de remise avant de terminer';

  @override
  String get missionCompleteRequiresOutForDelivery =>
      'Cette mission peut être terminée une fois en cours de livraison';

  @override
  String get missionAlreadyCompleted => 'Cette mission a déjà été terminée';

  @override
  String get incidentTypeLabel => 'Type d\'incident';

  @override
  String get incidentTypeDelay => 'Retard';

  @override
  String get incidentTypeVehicleIssue => 'Problème véhicule';

  @override
  String get incidentTypeSafety => 'Sécurité';

  @override
  String get incidentTypeOther => 'Autre';

  @override
  String get incidentStatusOpen => 'Ouvert';

  @override
  String get incidentStatusResolved => 'Résolu';

  @override
  String get incidentCommentLabel => 'Commentaire (facultatif)';

  @override
  String get incidentSubmitCta => 'Signaler un incident';

  @override
  String get incidentsEmpty => 'Aucun incident signalé';

  @override
  String get qrEntryTitle => 'Saisir le QR code';

  @override
  String get qrEntryHint =>
      'Saisissez le jeton du QR code de remise manuellement.';

  @override
  String get qrEntryTokenLabel => 'Jeton QR';

  @override
  String get qrEntrySubmitCta => 'Valider';

  @override
  String get qrEntryUseCameraCta => 'Scanner avec la caméra';

  @override
  String get qrScanTitle => 'Scanner le QR code';

  @override
  String get qrScanHint =>
      'Pointez votre caméra vers le QR code de la livraison.';

  @override
  String get qrScanManualEntryCta => 'Saisir le code manuellement';

  @override
  String get qrScanPermissionDenied =>
      'L\'accès à la caméra a été refusé. Saisissez le code manuellement.';

  @override
  String get qrScanCameraUnavailable =>
      'La lecture par caméra n\'est pas disponible sur cet appareil. Saisissez le code manuellement.';

  @override
  String get serviceTypeTaxi => 'Taxi';

  @override
  String get serviceTypeTaxiMoto => 'Taxi Moto';

  @override
  String get mobilityOfferLabel => 'Offre';

  @override
  String get mobilityRideLabel => 'Course en cours';

  @override
  String get mobilityOfferDetailTitle => 'Offre de course';

  @override
  String get mobilityOfferNoLongerAvailable =>
      'Cette offre n\'est plus disponible';

  @override
  String get mobilityEstimatedFareLabel => 'Tarif estimé';

  @override
  String get mobilityAcceptOfferCta => 'Accepter l\'offre';

  @override
  String get mobilityRideDetailTitle => 'Course';

  @override
  String get mobilityFareLabel => 'Tarif';

  @override
  String get mobilityTimelineTitle => 'Chronologie';

  @override
  String get mobilityRideNoActionsAvailable =>
      'Aucune action disponible pour cette course pour le moment';

  @override
  String get rideStatusDriverAssigned => 'Assignée';

  @override
  String get rideStatusDriverEnRoute => 'Chauffeur en route';

  @override
  String get rideStatusDriverArrived => 'Chauffeur arrivé';

  @override
  String get rideStatusInProgress => 'En cours';

  @override
  String get rideStatusCompleted => 'Terminée';

  @override
  String get rideStatusCancelled => 'Annulée';

  @override
  String get rideActionMarkEnRoute => 'Se mettre en route';

  @override
  String get rideActionMarkArrived => 'Signaler l\'arrivée';

  @override
  String get rideActionStart => 'Démarrer la course';

  @override
  String get rideActionComplete => 'Terminer la course';

  @override
  String get rideActionCancel => 'Annuler la course';

  @override
  String get mobilityIncidentTypeRide => 'Course';

  @override
  String get mobilityIncidentTypeDriver => 'Chauffeur';

  @override
  String get mobilityIncidentTypeCustomerComplaint => 'Réclamation client';

  @override
  String get mobilityIncidentStatusInProgress => 'En cours';

  @override
  String get mobilityIncidentStatusDismissed => 'Rejeté';

  @override
  String get settingsTitle => 'Profil';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsTheme => 'Apparence';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsLogout => 'Se déconnecter';

  @override
  String get settingsLogoutConfirmTitle => 'Se déconnecter ?';

  @override
  String get settingsLogoutConfirmBody =>
      'Vous devrez vous reconnecter pour accéder à votre travail.';

  @override
  String get settingsCancel => 'Annuler';

  @override
  String get accessDeniedTitle =>
      'Ce compte ne peut pas utiliser NOKI Chauffeur';

  @override
  String get accessDeniedBody =>
      'Votre compte n\'est enregistré comme chauffeur dans aucune organisation. Contactez votre organisation si vous pensez qu\'il s\'agit d\'une erreur.';

  @override
  String get accessDeniedSignOut => 'Se déconnecter';

  @override
  String get errorNetwork =>
      'Pas de connexion. Vérifiez votre connexion internet et réessayez.';

  @override
  String get errorTimeout =>
      'Le serveur a mis trop de temps à répondre. Réessayez.';

  @override
  String get errorUnauthenticated =>
      'Votre session a expiré. Reconnectez-vous.';

  @override
  String get errorForbidden => 'Vous n\'avez pas accès à cette ressource.';

  @override
  String get errorNotFound => 'Introuvable.';

  @override
  String get errorValidation => 'Certaines informations ne sont pas valides.';

  @override
  String get errorConflict =>
      'Cette action n\'a pas pu être effectuée en raison d\'un conflit.';

  @override
  String get errorRateLimited =>
      'Trop de tentatives. Patientez un instant puis réessayez.';

  @override
  String get errorServer =>
      'Une erreur est survenue de notre côté. Réessayez sous peu.';

  @override
  String get errorUnknown => 'Une erreur est survenue.';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get offlineBannerMessage =>
      'Vous êtes hors ligne. Certaines informations peuvent ne pas être à jour.';

  @override
  String get missionMapTitle => 'Carte';

  @override
  String get missionMapBackToDetails => 'Détails';

  @override
  String get missionMapNextActionOtp =>
      'Demandez le code de remise pour terminer cette livraison';

  @override
  String get mobilityMapTitle => 'Carte';

  @override
  String get homeContinueDelivery => 'Continuer la livraison en cours';

  @override
  String get homeContinueRide => 'Continuer la course en cours';

  @override
  String get homeTrackingIdle => 'Pas de suivi - hors ligne';

  @override
  String get homeTrackingPermissionNeeded =>
      'Autorisation de localisation requise pour le suivi';

  @override
  String get deliveryHistoryTitle => 'Historique des livraisons';

  @override
  String get deliveryHistoryEmpty => 'Aucune livraison terminée pour le moment';

  @override
  String get locationPermissionRationale =>
      'NOKI Chauffeur a besoin de votre position pour l\'afficher sur la carte pendant une livraison ou une course en cours.';

  @override
  String get locationGrantAction => 'Autoriser la localisation';

  @override
  String get locationDeniedForever =>
      'L\'accès à la position a été définitivement refusé. Activez-le dans les Réglages pour utiliser la carte.';

  @override
  String get locationServiceDisabled =>
      'Les services de localisation sont désactivés sur cet appareil. Activez-les pour utiliser la carte.';

  @override
  String get locationOpenSettings => 'Ouvrir les réglages';

  @override
  String get locationErrorGeneric =>
      'Impossible de lire l\'état de l\'autorisation de localisation.';

  @override
  String get mapGpsLive => 'GPS actif';

  @override
  String get mapGpsLocating => 'Localisation en cours';

  @override
  String get mapGpsUnavailable => 'Position indisponible';

  @override
  String get mapGpsDisabled => 'GPS désactivé';
}
