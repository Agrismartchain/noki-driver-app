import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// Application title shown on the login screen and app switcher
  ///
  /// In en, this message translates to:
  /// **'NOKI Driver'**
  String get appTitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSubmit;

  /// No description provided for @loginSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get loginSubmitting;

  /// No description provided for @loginEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get loginEmailRequired;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordRequired;

  /// No description provided for @loginShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get loginShowPassword;

  /// No description provided for @loginHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get loginHidePassword;

  /// No description provided for @loginHeadline.
  ///
  /// In en, this message translates to:
  /// **'Sign in to NOKI Driver'**
  String get loginHeadline;

  /// No description provided for @loginSubheadline.
  ///
  /// In en, this message translates to:
  /// **'Use the account provided by your organization.'**
  String get loginSubheadline;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get navWork;

  /// No description provided for @navActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get navActivity;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeNoVehicle.
  ///
  /// In en, this message translates to:
  /// **'No vehicle assigned yet'**
  String get homeNoVehicle;

  /// No description provided for @homeVehicleLabel.
  ///
  /// In en, this message translates to:
  /// **'Assigned vehicle'**
  String get homeVehicleLabel;

  /// No description provided for @homeCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get homeCountryLabel;

  /// No description provided for @homeCapabilitiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get homeCapabilitiesLabel;

  /// No description provided for @homeWorkFeedSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Work feed'**
  String get homeWorkFeedSummaryTitle;

  /// No description provided for @homeWorkFeedSummaryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No open work items} =1{1 open work item} other{{count} open work items}}'**
  String homeWorkFeedSummaryCount(int count);

  /// No description provided for @vehiclesTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehiclesTitle;

  /// No description provided for @vehiclesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No vehicles on your profile yet'**
  String get vehiclesEmpty;

  /// No description provided for @vehiclesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Vehicles assigned to you by your organization will appear here.'**
  String get vehiclesEmptyBody;

  /// No description provided for @vehicleTypeCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get vehicleTypeCar;

  /// No description provided for @vehicleTypeMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get vehicleTypeMotorcycle;

  /// No description provided for @vehicleStatusPendingValidation.
  ///
  /// In en, this message translates to:
  /// **'Pending validation'**
  String get vehicleStatusPendingValidation;

  /// No description provided for @vehicleStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get vehicleStatusActive;

  /// No description provided for @vehicleStatusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get vehicleStatusSuspended;

  /// No description provided for @vehicleStatusRetired.
  ///
  /// In en, this message translates to:
  /// **'Retired'**
  String get vehicleStatusRetired;

  /// No description provided for @vehiclePlateLabel.
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get vehiclePlateLabel;

  /// No description provided for @availabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availabilityTitle;

  /// No description provided for @availabilityStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get availabilityStatusOffline;

  /// No description provided for @availabilityStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availabilityStatusAvailable;

  /// No description provided for @availabilityStatusBusy.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get availabilityStatusBusy;

  /// No description provided for @availabilityUpdating.
  ///
  /// In en, this message translates to:
  /// **'Updating…'**
  String get availabilityUpdating;

  /// No description provided for @availabilityUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update your availability'**
  String get availabilityUpdateFailed;

  /// No description provided for @availabilityActiveMissions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No active deliveries} =1{1 active delivery} other{{count} active deliveries}}'**
  String availabilityActiveMissions(int count);

  /// No description provided for @availabilityActiveRides.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No active rides} =1{1 active ride} other{{count} active rides}}'**
  String availabilityActiveRides(int count);

  /// No description provided for @workFeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Work feed'**
  String get workFeedTitle;

  /// No description provided for @workFeedEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing assigned right now'**
  String get workFeedEmpty;

  /// No description provided for @workFeedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'New delivery missions and ride offers will appear here as soon as they are assigned to you.'**
  String get workFeedEmptyBody;

  /// No description provided for @workFeedTypeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get workFeedTypeDelivery;

  /// No description provided for @workFeedTypeRide.
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get workFeedTypeRide;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get settingsLogoutConfirmTitle;

  /// No description provided for @settingsLogoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to access your work.'**
  String get settingsLogoutConfirmBody;

  /// No description provided for @settingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// No description provided for @accessDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'This account cannot use NOKI Driver'**
  String get accessDeniedTitle;

  /// No description provided for @accessDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Your account is not registered as a driver in any organization. Contact your organization if you believe this is an error.'**
  String get accessDeniedBody;

  /// No description provided for @accessDeniedSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accessDeniedSignOut;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server took too long to respond. Try again.'**
  String get errorTimeout;

  /// No description provided for @errorUnauthenticated.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Sign in again.'**
  String get errorUnauthenticated;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have access to this.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that.'**
  String get errorNotFound;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Some information is not valid.'**
  String get errorValidation;

  /// No description provided for @errorConflict.
  ///
  /// In en, this message translates to:
  /// **'This couldn\'t be completed because of a conflicting change.'**
  String get errorConflict;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a moment and try again.'**
  String get errorRateLimited;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Try again shortly.'**
  String get errorServer;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorUnknown;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @offlineBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Some information may be out of date.'**
  String get offlineBannerMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
