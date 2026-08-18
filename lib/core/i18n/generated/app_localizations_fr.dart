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
}
