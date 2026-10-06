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

  /// No description provided for @homeNoServices.
  ///
  /// In en, this message translates to:
  /// **'No services yet'**
  String get homeNoServices;

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

  /// No description provided for @availabilityPendingOffers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No pending ride offers} =1{1 pending ride offer} other{{count} pending ride offers}}'**
  String availabilityPendingOffers(int count);

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

  /// No description provided for @workFeedFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get workFeedFilterAll;

  /// No description provided for @workFeedFilterDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get workFeedFilterDelivery;

  /// No description provided for @workFeedFilterRides.
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get workFeedFilterRides;

  /// No description provided for @workFeedFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get workFeedFilterActive;

  /// No description provided for @workFeedFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get workFeedFilterPending;

  /// No description provided for @deliveryCodBadge.
  ///
  /// In en, this message translates to:
  /// **'COD: {amount}'**
  String deliveryCodBadge(String amount);

  /// No description provided for @financeAmountToCollectLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount to collect'**
  String get financeAmountToCollectLabel;

  /// No description provided for @financeAmountToCollectHint.
  ///
  /// In en, this message translates to:
  /// **'Collect this amount from the customer before completing the delivery.'**
  String get financeAmountToCollectHint;

  /// No description provided for @financeCodSafetyNotice.
  ///
  /// In en, this message translates to:
  /// **'This cash belongs to NOKI until it is reconciled. It is not driver earnings.'**
  String get financeCodSafetyNotice;

  /// No description provided for @financeEstimatedFareLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated fare'**
  String get financeEstimatedFareLabel;

  /// No description provided for @financeEstimatedFareHint.
  ///
  /// In en, this message translates to:
  /// **'Shown as operational ride context, not a settled driver payout.'**
  String get financeEstimatedFareHint;

  /// No description provided for @missionDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get missionDetailTitle;

  /// No description provided for @missionSectionPickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get missionSectionPickup;

  /// No description provided for @missionSectionDropoff.
  ///
  /// In en, this message translates to:
  /// **'Drop-off'**
  String get missionSectionDropoff;

  /// No description provided for @missionSectionFinancial.
  ///
  /// In en, this message translates to:
  /// **'Financial'**
  String get missionSectionFinancial;

  /// No description provided for @missionSectionMission.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get missionSectionMission;

  /// No description provided for @missionSectionEvidence.
  ///
  /// In en, this message translates to:
  /// **'Handoff verification'**
  String get missionSectionEvidence;

  /// No description provided for @missionSectionIncidents.
  ///
  /// In en, this message translates to:
  /// **'Incidents'**
  String get missionSectionIncidents;

  /// No description provided for @missionSectionNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available for this mission'**
  String get missionSectionNotAvailable;

  /// No description provided for @missionCallAction.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get missionCallAction;

  /// No description provided for @missionNavigateAction.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get missionNavigateAction;

  /// No description provided for @missionFinancialCodLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get missionFinancialCodLabel;

  /// No description provided for @missionFinancialNoCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency code not available for this amount'**
  String get missionFinancialNoCurrency;

  /// No description provided for @missionLineItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String missionLineItemsCount(int count);

  /// No description provided for @missionTimestampAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get missionTimestampAssigned;

  /// No description provided for @missionTimestampOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for delivery'**
  String get missionTimestampOutForDelivery;

  /// No description provided for @missionTimestampDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get missionTimestampDelivered;

  /// No description provided for @missionTimestampFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get missionTimestampFailed;

  /// No description provided for @missionStatusReadyForDispatch.
  ///
  /// In en, this message translates to:
  /// **'Ready for dispatch'**
  String get missionStatusReadyForDispatch;

  /// No description provided for @missionStatusAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get missionStatusAssigned;

  /// No description provided for @missionStatusOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for delivery'**
  String get missionStatusOutForDelivery;

  /// No description provided for @missionStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get missionStatusDelivered;

  /// No description provided for @missionStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get missionStatusFailed;

  /// No description provided for @missionStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get missionStatusCancelled;

  /// No description provided for @missionOtpRequestCta.
  ///
  /// In en, this message translates to:
  /// **'Request handoff code'**
  String get missionOtpRequestCta;

  /// No description provided for @missionOtpRequestAgainCta.
  ///
  /// In en, this message translates to:
  /// **'Request a new code'**
  String get missionOtpRequestAgainCta;

  /// No description provided for @missionOtpChallengeStatus.
  ///
  /// In en, this message translates to:
  /// **'Code status: {status}'**
  String missionOtpChallengeStatus(String status);

  /// No description provided for @missionOtpCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get missionOtpCodeLabel;

  /// No description provided for @missionOtpVerifyCta.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get missionOtpVerifyCta;

  /// No description provided for @missionOtpVerifiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Handoff code verified'**
  String get missionOtpVerifiedLabel;

  /// No description provided for @otpStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get otpStatusPending;

  /// No description provided for @otpStatusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get otpStatusVerified;

  /// No description provided for @otpStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get otpStatusExpired;

  /// No description provided for @otpStatusLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get otpStatusLocked;

  /// No description provided for @otpStatusRevoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get otpStatusRevoked;

  /// No description provided for @missionCompleteCta.
  ///
  /// In en, this message translates to:
  /// **'Complete mission'**
  String get missionCompleteCta;

  /// No description provided for @missionCompleteRequiresOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify the handoff code before completing'**
  String get missionCompleteRequiresOtp;

  /// No description provided for @missionCompleteRequiresOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'This mission can be completed once it is out for delivery'**
  String get missionCompleteRequiresOutForDelivery;

  /// No description provided for @missionAlreadyCompleted.
  ///
  /// In en, this message translates to:
  /// **'This mission has already been completed'**
  String get missionAlreadyCompleted;

  /// No description provided for @incidentTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Incident type'**
  String get incidentTypeLabel;

  /// No description provided for @incidentTypeDelay.
  ///
  /// In en, this message translates to:
  /// **'Delay'**
  String get incidentTypeDelay;

  /// No description provided for @incidentTypeVehicleIssue.
  ///
  /// In en, this message translates to:
  /// **'Vehicle issue'**
  String get incidentTypeVehicleIssue;

  /// No description provided for @incidentTypeSafety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get incidentTypeSafety;

  /// No description provided for @incidentTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get incidentTypeOther;

  /// No description provided for @incidentStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get incidentStatusOpen;

  /// No description provided for @incidentStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get incidentStatusResolved;

  /// No description provided for @incidentCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get incidentCommentLabel;

  /// No description provided for @incidentSubmitCta.
  ///
  /// In en, this message translates to:
  /// **'Report incident'**
  String get incidentSubmitCta;

  /// No description provided for @incidentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No incidents reported'**
  String get incidentsEmpty;

  /// No description provided for @qrEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter QR code'**
  String get qrEntryTitle;

  /// No description provided for @qrEntryHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the handoff QR token manually.'**
  String get qrEntryHint;

  /// No description provided for @qrEntryTokenLabel.
  ///
  /// In en, this message translates to:
  /// **'QR token'**
  String get qrEntryTokenLabel;

  /// No description provided for @qrEntrySubmitCta.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get qrEntrySubmitCta;

  /// No description provided for @qrEntryUseCameraCta.
  ///
  /// In en, this message translates to:
  /// **'Scan with camera'**
  String get qrEntryUseCameraCta;

  /// No description provided for @qrScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get qrScanTitle;

  /// No description provided for @qrScanHint.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at the delivery\'s QR code.'**
  String get qrScanHint;

  /// No description provided for @qrScanManualEntryCta.
  ///
  /// In en, this message translates to:
  /// **'Enter code manually'**
  String get qrScanManualEntryCta;

  /// No description provided for @qrScanPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera access was denied. Enter the code manually instead.'**
  String get qrScanPermissionDenied;

  /// No description provided for @qrScanCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera scanning isn\'t available on this device. Enter the code manually instead.'**
  String get qrScanCameraUnavailable;

  /// No description provided for @serviceTypeTaxi.
  ///
  /// In en, this message translates to:
  /// **'Taxi'**
  String get serviceTypeTaxi;

  /// No description provided for @serviceTypeTaxiMoto.
  ///
  /// In en, this message translates to:
  /// **'Taxi Moto'**
  String get serviceTypeTaxiMoto;

  /// No description provided for @serviceTypeCourier.
  ///
  /// In en, this message translates to:
  /// **'Courier'**
  String get serviceTypeCourier;

  /// No description provided for @serviceTypeCargo.
  ///
  /// In en, this message translates to:
  /// **'Cargo'**
  String get serviceTypeCargo;

  /// No description provided for @vehicleClassVan.
  ///
  /// In en, this message translates to:
  /// **'Van'**
  String get vehicleClassVan;

  /// No description provided for @vehicleClassTruckSmall.
  ///
  /// In en, this message translates to:
  /// **'Small truck'**
  String get vehicleClassTruckSmall;

  /// No description provided for @vehicleClassTruckMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium truck'**
  String get vehicleClassTruckMedium;

  /// No description provided for @vehicleClassTruckLarge.
  ///
  /// In en, this message translates to:
  /// **'Large truck'**
  String get vehicleClassTruckLarge;

  /// No description provided for @mobilityCargoSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Cargo'**
  String get mobilityCargoSectionTitle;

  /// No description provided for @mobilityCargoVehicleRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle required'**
  String get mobilityCargoVehicleRequiredLabel;

  /// No description provided for @mobilityCargoWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get mobilityCargoWeightLabel;

  /// No description provided for @mobilityCargoQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get mobilityCargoQuantityLabel;

  /// No description provided for @mobilityCargoDimensionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get mobilityCargoDimensionsLabel;

  /// No description provided for @mobilityCargoFragileLabel.
  ///
  /// In en, this message translates to:
  /// **'Fragile'**
  String get mobilityCargoFragileLabel;

  /// No description provided for @mobilityCargoDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get mobilityCargoDescriptionLabel;

  /// No description provided for @mobilityOfferLabel.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get mobilityOfferLabel;

  /// No description provided for @mobilityRideLabel.
  ///
  /// In en, this message translates to:
  /// **'Active ride'**
  String get mobilityRideLabel;

  /// No description provided for @mobilityOfferDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Ride offer'**
  String get mobilityOfferDetailTitle;

  /// No description provided for @mobilityOfferNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'This offer is no longer available'**
  String get mobilityOfferNoLongerAvailable;

  /// No description provided for @mobilityEstimatedFareLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated fare'**
  String get mobilityEstimatedFareLabel;

  /// No description provided for @mobilityAcceptOfferCta.
  ///
  /// In en, this message translates to:
  /// **'Accept offer'**
  String get mobilityAcceptOfferCta;

  /// No description provided for @mobilityDeclineOfferCta.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get mobilityDeclineOfferCta;

  /// No description provided for @mobilityRideDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get mobilityRideDetailTitle;

  /// No description provided for @mobilityFareLabel.
  ///
  /// In en, this message translates to:
  /// **'Fare'**
  String get mobilityFareLabel;

  /// No description provided for @mobilityTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get mobilityTimelineTitle;

  /// No description provided for @mobilityRideNoActionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No actions available for this ride right now'**
  String get mobilityRideNoActionsAvailable;

  /// No description provided for @rideStatusDriverAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get rideStatusDriverAssigned;

  /// No description provided for @rideStatusDriverEnRoute.
  ///
  /// In en, this message translates to:
  /// **'Driver en route'**
  String get rideStatusDriverEnRoute;

  /// No description provided for @rideStatusDriverArrived.
  ///
  /// In en, this message translates to:
  /// **'Driver arrived'**
  String get rideStatusDriverArrived;

  /// No description provided for @rideStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get rideStatusInProgress;

  /// No description provided for @rideStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get rideStatusCompleted;

  /// No description provided for @rideStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get rideStatusCancelled;

  /// No description provided for @rideActionMarkEnRoute.
  ///
  /// In en, this message translates to:
  /// **'Mark en route'**
  String get rideActionMarkEnRoute;

  /// No description provided for @rideActionMarkArrived.
  ///
  /// In en, this message translates to:
  /// **'Mark arrived'**
  String get rideActionMarkArrived;

  /// No description provided for @rideActionStart.
  ///
  /// In en, this message translates to:
  /// **'Start ride'**
  String get rideActionStart;

  /// No description provided for @rideActionComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete ride'**
  String get rideActionComplete;

  /// No description provided for @rideActionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel ride'**
  String get rideActionCancel;

  /// No description provided for @mobilityIncidentTypeRide.
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get mobilityIncidentTypeRide;

  /// No description provided for @mobilityIncidentTypeDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get mobilityIncidentTypeDriver;

  /// No description provided for @mobilityIncidentTypeCustomerComplaint.
  ///
  /// In en, this message translates to:
  /// **'Customer complaint'**
  String get mobilityIncidentTypeCustomerComplaint;

  /// No description provided for @mobilityIncidentStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get mobilityIncidentStatusInProgress;

  /// No description provided for @mobilityIncidentStatusDismissed.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get mobilityIncidentStatusDismissed;

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

  /// No description provided for @profileIdentityEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Driver identity'**
  String get profileIdentityEyebrow;

  /// No description provided for @profileNoEmail.
  ///
  /// In en, this message translates to:
  /// **'No contact email available'**
  String get profileNoEmail;

  /// No description provided for @profileOperationalTitle.
  ///
  /// In en, this message translates to:
  /// **'Operational status'**
  String get profileOperationalTitle;

  /// No description provided for @profileOrganizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get profileOrganizationTitle;

  /// No description provided for @profileOrganizationLabel.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get profileOrganizationLabel;

  /// No description provided for @profileVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle and services'**
  String get profileVehicleTitle;

  /// No description provided for @profileActivationTitle.
  ///
  /// In en, this message translates to:
  /// **'Activation and documents'**
  String get profileActivationTitle;

  /// No description provided for @profileDocumentsBackendRequired.
  ///
  /// In en, this message translates to:
  /// **'Driver documents and compliance checkpoints require backend support.'**
  String get profileDocumentsBackendRequired;

  /// No description provided for @profileActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Operational activity'**
  String get profileActivityTitle;

  /// No description provided for @profileActivityBody.
  ///
  /// In en, this message translates to:
  /// **'Completed deliveries are available today. Mobility trip history still requires backend support.'**
  String get profileActivityBody;

  /// No description provided for @profileNotificationsBackendRequired.
  ///
  /// In en, this message translates to:
  /// **'A dedicated notifications center requires backend support.'**
  String get profileNotificationsBackendRequired;

  /// No description provided for @profilePreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profilePreferencesTitle;

  /// No description provided for @profileOpenVehicles.
  ///
  /// In en, this message translates to:
  /// **'Open vehicles'**
  String get profileOpenVehicles;

  /// No description provided for @profileOpenHistory.
  ///
  /// In en, this message translates to:
  /// **'Open delivery history'**
  String get profileOpenHistory;

  /// No description provided for @profileVehicleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No vehicle assigned yet'**
  String get profileVehicleUnavailable;

  /// No description provided for @profileStatusDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get profileStatusDelivery;

  /// No description provided for @profileStatusMobility.
  ///
  /// In en, this message translates to:
  /// **'Mobility'**
  String get profileStatusMobility;

  /// No description provided for @profileStatusAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get profileStatusAvailability;

  /// No description provided for @profileStatusOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Onboarding'**
  String get profileStatusOnboarding;

  /// No description provided for @profileStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get profileStatusActive;

  /// No description provided for @profileStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get profileStatusInactive;

  /// No description provided for @profileStatusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get profileStatusSuspended;

  /// No description provided for @profileStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get profileStatusOffline;

  /// No description provided for @profileStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get profileStatusAvailable;

  /// No description provided for @profileStatusBusy.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get profileStatusBusy;

  /// No description provided for @profileStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get profileStatusDraft;

  /// No description provided for @profileStatusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get profileStatusSubmitted;

  /// No description provided for @profileStatusUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get profileStatusUnderReview;

  /// No description provided for @profileStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get profileStatusApproved;

  /// No description provided for @profileStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get profileStatusRejected;

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

  /// No description provided for @missionMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get missionMapTitle;

  /// No description provided for @missionMapBackToDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get missionMapBackToDetails;

  /// No description provided for @missionMapNextActionOtp.
  ///
  /// In en, this message translates to:
  /// **'Request the handoff code to complete this delivery'**
  String get missionMapNextActionOtp;

  /// No description provided for @mobilityMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mobilityMapTitle;

  /// No description provided for @homeContinueDelivery.
  ///
  /// In en, this message translates to:
  /// **'Continue active delivery'**
  String get homeContinueDelivery;

  /// No description provided for @homeContinueRide.
  ///
  /// In en, this message translates to:
  /// **'Continue active ride'**
  String get homeContinueRide;

  /// No description provided for @homeTrackingIdle.
  ///
  /// In en, this message translates to:
  /// **'Not tracking - offline'**
  String get homeTrackingIdle;

  /// No description provided for @homeTrackingPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Location permission needed for tracking'**
  String get homeTrackingPermissionNeeded;

  /// No description provided for @deliveryHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery history'**
  String get deliveryHistoryTitle;

  /// No description provided for @deliveryHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No completed deliveries yet'**
  String get deliveryHistoryEmpty;

  /// No description provided for @locationPermissionRationale.
  ///
  /// In en, this message translates to:
  /// **'NOKI Driver needs your location to show it on the map during an active delivery or ride.'**
  String get locationPermissionRationale;

  /// No description provided for @locationGrantAction.
  ///
  /// In en, this message translates to:
  /// **'Allow location access'**
  String get locationGrantAction;

  /// No description provided for @locationDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location access was permanently denied. Enable it in Settings to use the map.'**
  String get locationDeniedForever;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off on this device. Enable them to use the map.'**
  String get locationServiceDisabled;

  /// No description provided for @locationOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get locationOpenSettings;

  /// No description provided for @locationErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not read the location permission state.'**
  String get locationErrorGeneric;

  /// No description provided for @mapGpsLive.
  ///
  /// In en, this message translates to:
  /// **'GPS live'**
  String get mapGpsLive;

  /// No description provided for @mapGpsLocating.
  ///
  /// In en, this message translates to:
  /// **'Locating driver'**
  String get mapGpsLocating;

  /// No description provided for @mapGpsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get mapGpsUnavailable;

  /// No description provided for @mapGpsDisabled.
  ///
  /// In en, this message translates to:
  /// **'GPS disabled'**
  String get mapGpsDisabled;

  /// No description provided for @mapRecenterAction.
  ///
  /// In en, this message translates to:
  /// **'Recenter'**
  String get mapRecenterAction;

  /// No description provided for @navigationRouteUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Route unavailable right now.'**
  String get navigationRouteUnavailable;

  /// No description provided for @navigationRetryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get navigationRetryAction;

  /// No description provided for @navigationEtaLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated arrival at {time}'**
  String navigationEtaLabel(String time);

  /// No description provided for @navigationDistanceRemainingLabel.
  ///
  /// In en, this message translates to:
  /// **'{distance} remaining'**
  String navigationDistanceRemainingLabel(String distance);

  /// No description provided for @navigationNextManeuverLabel.
  ///
  /// In en, this message translates to:
  /// **'In {distance}: {instruction}'**
  String navigationNextManeuverLabel(String distance, String instruction);
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
