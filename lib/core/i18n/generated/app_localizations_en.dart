// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NOKI Driver';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginSubmitting => 'Signing in…';

  @override
  String get loginEmailRequired => 'Enter your email address';

  @override
  String get loginEmailInvalid => 'Enter a valid email address';

  @override
  String get loginPasswordRequired => 'Enter your password';

  @override
  String get loginShowPassword => 'Show password';

  @override
  String get loginHidePassword => 'Hide password';

  @override
  String get loginHeadline => 'Sign in to NOKI Driver';

  @override
  String get loginSubheadline =>
      'Use the account provided by your organization.';

  @override
  String get navHome => 'Home';

  @override
  String get navWork => 'Work';

  @override
  String get navActivity => 'Activity';

  @override
  String get navProfile => 'Profile';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get homeNoVehicle => 'No vehicle assigned yet';

  @override
  String get homeVehicleLabel => 'Assigned vehicle';

  @override
  String get homeCountryLabel => 'Country';

  @override
  String get homeCapabilitiesLabel => 'Services';

  @override
  String get homeWorkFeedSummaryTitle => 'Work feed';

  @override
  String homeWorkFeedSummaryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open work items',
      one: '1 open work item',
      zero: 'No open work items',
    );
    return '$_temp0';
  }

  @override
  String get vehiclesTitle => 'Vehicles';

  @override
  String get vehiclesEmpty => 'No vehicles on your profile yet';

  @override
  String get vehiclesEmptyBody =>
      'Vehicles assigned to you by your organization will appear here.';

  @override
  String get vehicleTypeCar => 'Car';

  @override
  String get vehicleTypeMotorcycle => 'Motorcycle';

  @override
  String get vehicleStatusPendingValidation => 'Pending validation';

  @override
  String get vehicleStatusActive => 'Active';

  @override
  String get vehicleStatusSuspended => 'Suspended';

  @override
  String get vehicleStatusRetired => 'Retired';

  @override
  String get vehiclePlateLabel => 'Plate';

  @override
  String get availabilityTitle => 'Availability';

  @override
  String get availabilityStatusOffline => 'Offline';

  @override
  String get availabilityStatusAvailable => 'Available';

  @override
  String get availabilityStatusBusy => 'Busy';

  @override
  String get availabilityUpdating => 'Updating…';

  @override
  String get availabilityUpdateFailed => 'Could not update your availability';

  @override
  String availabilityActiveMissions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active deliveries',
      one: '1 active delivery',
      zero: 'No active deliveries',
    );
    return '$_temp0';
  }

  @override
  String availabilityActiveRides(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active rides',
      one: '1 active ride',
      zero: 'No active rides',
    );
    return '$_temp0';
  }

  @override
  String get workFeedTitle => 'Work feed';

  @override
  String get workFeedEmpty => 'Nothing assigned right now';

  @override
  String get workFeedEmptyBody =>
      'New delivery missions and ride offers will appear here as soon as they are assigned to you.';

  @override
  String get workFeedTypeDelivery => 'Delivery';

  @override
  String get workFeedTypeRide => 'Ride';

  @override
  String get settingsTitle => 'Profile';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Appearance';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLogout => 'Sign out';

  @override
  String get settingsLogoutConfirmTitle => 'Sign out?';

  @override
  String get settingsLogoutConfirmBody =>
      'You will need to sign in again to access your work.';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get accessDeniedTitle => 'This account cannot use NOKI Driver';

  @override
  String get accessDeniedBody =>
      'Your account is not registered as a driver in any organization. Contact your organization if you believe this is an error.';

  @override
  String get accessDeniedSignOut => 'Sign out';

  @override
  String get errorNetwork =>
      'No connection. Check your internet and try again.';

  @override
  String get errorTimeout => 'The server took too long to respond. Try again.';

  @override
  String get errorUnauthenticated => 'Your session has expired. Sign in again.';

  @override
  String get errorForbidden => 'You don\'t have access to this.';

  @override
  String get errorNotFound => 'We couldn\'t find that.';

  @override
  String get errorValidation => 'Some information is not valid.';

  @override
  String get errorConflict =>
      'This couldn\'t be completed because of a conflicting change.';

  @override
  String get errorRateLimited =>
      'Too many attempts. Wait a moment and try again.';

  @override
  String get errorServer =>
      'Something went wrong on our side. Try again shortly.';

  @override
  String get errorUnknown => 'Something went wrong.';

  @override
  String get actionRetry => 'Retry';

  @override
  String get offlineBannerMessage =>
      'You\'re offline. Some information may be out of date.';
}
