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
  String get homeNoServices => 'No services yet';

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
  String availabilityPendingOffers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pending ride offers',
      one: '1 pending ride offer',
      zero: 'No pending ride offers',
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
  String get workFeedFilterAll => 'All';

  @override
  String get workFeedFilterDelivery => 'Delivery';

  @override
  String get workFeedFilterRides => 'Rides';

  @override
  String get workFeedFilterActive => 'Active';

  @override
  String get workFeedFilterPending => 'Pending';

  @override
  String deliveryCodBadge(String amount) {
    return 'COD: $amount';
  }

  @override
  String get financeAmountToCollectLabel => 'Amount to collect';

  @override
  String get financeAmountToCollectHint =>
      'Collect this amount from the customer before completing the delivery.';

  @override
  String get financeCodSafetyNotice =>
      'This cash belongs to NOKI until it is reconciled. It is not driver earnings.';

  @override
  String get financeEstimatedFareLabel => 'Estimated fare';

  @override
  String get financeEstimatedFareHint =>
      'Shown as operational ride context, not a settled driver payout.';

  @override
  String get missionDetailTitle => 'Mission';

  @override
  String get missionSectionPickup => 'Pickup';

  @override
  String get missionSectionDropoff => 'Drop-off';

  @override
  String get missionSectionFinancial => 'Financial';

  @override
  String get missionSectionMission => 'Mission';

  @override
  String get missionSectionEvidence => 'Handoff verification';

  @override
  String get missionSectionIncidents => 'Incidents';

  @override
  String get missionSectionNotAvailable => 'Not available for this mission';

  @override
  String get missionCallAction => 'Call';

  @override
  String get missionNavigateAction => 'Navigate';

  @override
  String get missionFinancialCodLabel => 'Cash on delivery';

  @override
  String get missionFinancialNoCurrency =>
      'Currency code not available for this amount';

  @override
  String missionLineItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get missionTimestampAssigned => 'Assigned';

  @override
  String get missionTimestampOutForDelivery => 'Out for delivery';

  @override
  String get missionTimestampDelivered => 'Delivered';

  @override
  String get missionTimestampFailed => 'Failed';

  @override
  String get missionStatusReadyForDispatch => 'Ready for dispatch';

  @override
  String get missionStatusAssigned => 'Assigned';

  @override
  String get missionStatusOutForDelivery => 'Out for delivery';

  @override
  String get missionStatusDelivered => 'Delivered';

  @override
  String get missionStatusFailed => 'Failed';

  @override
  String get missionStatusCancelled => 'Cancelled';

  @override
  String get missionOtpRequestCta => 'Request handoff code';

  @override
  String get missionOtpRequestAgainCta => 'Request a new code';

  @override
  String missionOtpChallengeStatus(String status) {
    return 'Code status: $status';
  }

  @override
  String get missionOtpCodeLabel => '6-digit code';

  @override
  String get missionOtpVerifyCta => 'Verify code';

  @override
  String get missionOtpVerifiedLabel => 'Handoff code verified';

  @override
  String get otpStatusPending => 'Pending';

  @override
  String get otpStatusVerified => 'Verified';

  @override
  String get otpStatusExpired => 'Expired';

  @override
  String get otpStatusLocked => 'Locked';

  @override
  String get otpStatusRevoked => 'Revoked';

  @override
  String get missionCompleteCta => 'Complete mission';

  @override
  String get missionCompleteRequiresOtp =>
      'Verify the handoff code before completing';

  @override
  String get missionCompleteRequiresOutForDelivery =>
      'This mission can be completed once it is out for delivery';

  @override
  String get missionAlreadyCompleted =>
      'This mission has already been completed';

  @override
  String get incidentTypeLabel => 'Incident type';

  @override
  String get incidentTypeDelay => 'Delay';

  @override
  String get incidentTypeVehicleIssue => 'Vehicle issue';

  @override
  String get incidentTypeSafety => 'Safety';

  @override
  String get incidentTypeOther => 'Other';

  @override
  String get incidentStatusOpen => 'Open';

  @override
  String get incidentStatusResolved => 'Resolved';

  @override
  String get incidentCommentLabel => 'Comment (optional)';

  @override
  String get incidentSubmitCta => 'Report incident';

  @override
  String get incidentsEmpty => 'No incidents reported';

  @override
  String get qrEntryTitle => 'Enter QR code';

  @override
  String get qrEntryHint => 'Enter the handoff QR token manually.';

  @override
  String get qrEntryTokenLabel => 'QR token';

  @override
  String get qrEntrySubmitCta => 'Submit';

  @override
  String get qrEntryUseCameraCta => 'Scan with camera';

  @override
  String get qrScanTitle => 'Scan QR code';

  @override
  String get qrScanHint => 'Point your camera at the delivery\'s QR code.';

  @override
  String get qrScanManualEntryCta => 'Enter code manually';

  @override
  String get qrScanPermissionDenied =>
      'Camera access was denied. Enter the code manually instead.';

  @override
  String get qrScanCameraUnavailable =>
      'Camera scanning isn\'t available on this device. Enter the code manually instead.';

  @override
  String get serviceTypeTaxi => 'Taxi';

  @override
  String get serviceTypeTaxiMoto => 'Taxi Moto';

  @override
  String get serviceTypeCourier => 'Courier';

  @override
  String get serviceTypeCargo => 'Cargo';

  @override
  String get vehicleClassVan => 'Van';

  @override
  String get vehicleClassTruckSmall => 'Small truck';

  @override
  String get vehicleClassTruckMedium => 'Medium truck';

  @override
  String get vehicleClassTruckLarge => 'Large truck';

  @override
  String get mobilityCargoSectionTitle => 'Cargo';

  @override
  String get mobilityCargoVehicleRequiredLabel => 'Vehicle required';

  @override
  String get mobilityCargoWeightLabel => 'Weight';

  @override
  String get mobilityCargoQuantityLabel => 'Quantity';

  @override
  String get mobilityCargoDimensionsLabel => 'Dimensions';

  @override
  String get mobilityCargoFragileLabel => 'Fragile';

  @override
  String get mobilityCargoDescriptionLabel => 'Description';

  @override
  String get mobilityOfferLabel => 'Offer';

  @override
  String get mobilityRideLabel => 'Active ride';

  @override
  String get mobilityOfferDetailTitle => 'Ride offer';

  @override
  String get mobilityOfferNoLongerAvailable =>
      'This offer is no longer available';

  @override
  String get mobilityEstimatedFareLabel => 'Estimated fare';

  @override
  String get mobilityAcceptOfferCta => 'Accept offer';

  @override
  String get mobilityRideDetailTitle => 'Ride';

  @override
  String get mobilityFareLabel => 'Fare';

  @override
  String get mobilityTimelineTitle => 'Timeline';

  @override
  String get mobilityRideNoActionsAvailable =>
      'No actions available for this ride right now';

  @override
  String get rideStatusDriverAssigned => 'Assigned';

  @override
  String get rideStatusDriverEnRoute => 'Driver en route';

  @override
  String get rideStatusDriverArrived => 'Driver arrived';

  @override
  String get rideStatusInProgress => 'In progress';

  @override
  String get rideStatusCompleted => 'Completed';

  @override
  String get rideStatusCancelled => 'Cancelled';

  @override
  String get rideActionMarkEnRoute => 'Mark en route';

  @override
  String get rideActionMarkArrived => 'Mark arrived';

  @override
  String get rideActionStart => 'Start ride';

  @override
  String get rideActionComplete => 'Complete ride';

  @override
  String get rideActionCancel => 'Cancel ride';

  @override
  String get mobilityIncidentTypeRide => 'Ride';

  @override
  String get mobilityIncidentTypeDriver => 'Driver';

  @override
  String get mobilityIncidentTypeCustomerComplaint => 'Customer complaint';

  @override
  String get mobilityIncidentStatusInProgress => 'In progress';

  @override
  String get mobilityIncidentStatusDismissed => 'Dismissed';

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
  String get profileIdentityEyebrow => 'Driver identity';

  @override
  String get profileNoEmail => 'No contact email available';

  @override
  String get profileOperationalTitle => 'Operational status';

  @override
  String get profileOrganizationTitle => 'Organization';

  @override
  String get profileOrganizationLabel => 'Organization';

  @override
  String get profileVehicleTitle => 'Vehicle and services';

  @override
  String get profileActivationTitle => 'Activation and documents';

  @override
  String get profileDocumentsBackendRequired =>
      'Driver documents and compliance checkpoints require backend support.';

  @override
  String get profileActivityTitle => 'Operational activity';

  @override
  String get profileActivityBody =>
      'Completed deliveries are available today. Mobility trip history still requires backend support.';

  @override
  String get profileNotificationsBackendRequired =>
      'A dedicated notifications center requires backend support.';

  @override
  String get profilePreferencesTitle => 'Preferences';

  @override
  String get profileOpenVehicles => 'Open vehicles';

  @override
  String get profileOpenHistory => 'Open delivery history';

  @override
  String get profileVehicleUnavailable => 'No vehicle assigned yet';

  @override
  String get profileStatusDelivery => 'Delivery';

  @override
  String get profileStatusMobility => 'Mobility';

  @override
  String get profileStatusAvailability => 'Availability';

  @override
  String get profileStatusOnboarding => 'Onboarding';

  @override
  String get profileStatusActive => 'Active';

  @override
  String get profileStatusInactive => 'Inactive';

  @override
  String get profileStatusSuspended => 'Suspended';

  @override
  String get profileStatusOffline => 'Offline';

  @override
  String get profileStatusAvailable => 'Available';

  @override
  String get profileStatusBusy => 'Busy';

  @override
  String get profileStatusDraft => 'Draft';

  @override
  String get profileStatusSubmitted => 'Submitted';

  @override
  String get profileStatusUnderReview => 'Under review';

  @override
  String get profileStatusApproved => 'Approved';

  @override
  String get profileStatusRejected => 'Rejected';

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

  @override
  String get missionMapTitle => 'Map';

  @override
  String get missionMapBackToDetails => 'Details';

  @override
  String get missionMapNextActionOtp =>
      'Request the handoff code to complete this delivery';

  @override
  String get mobilityMapTitle => 'Map';

  @override
  String get homeContinueDelivery => 'Continue active delivery';

  @override
  String get homeContinueRide => 'Continue active ride';

  @override
  String get homeTrackingIdle => 'Not tracking - offline';

  @override
  String get homeTrackingPermissionNeeded =>
      'Location permission needed for tracking';

  @override
  String get deliveryHistoryTitle => 'Delivery history';

  @override
  String get deliveryHistoryEmpty => 'No completed deliveries yet';

  @override
  String get locationPermissionRationale =>
      'NOKI Driver needs your location to show it on the map during an active delivery or ride.';

  @override
  String get locationGrantAction => 'Allow location access';

  @override
  String get locationDeniedForever =>
      'Location access was permanently denied. Enable it in Settings to use the map.';

  @override
  String get locationServiceDisabled =>
      'Location services are turned off on this device. Enable them to use the map.';

  @override
  String get locationOpenSettings => 'Open settings';

  @override
  String get locationErrorGeneric =>
      'Could not read the location permission state.';

  @override
  String get mapGpsLive => 'GPS live';

  @override
  String get mapGpsLocating => 'Locating driver';

  @override
  String get mapGpsUnavailable => 'Location unavailable';

  @override
  String get mapGpsDisabled => 'GPS disabled';

  @override
  String get mapRecenterAction => 'Recenter';

  @override
  String get navigationRouteUnavailable => 'Route unavailable right now.';

  @override
  String get navigationRetryAction => 'Retry';

  @override
  String navigationEtaLabel(String time) {
    return 'Estimated arrival at $time';
  }

  @override
  String navigationDistanceRemainingLabel(String distance) {
    return '$distance remaining';
  }

  @override
  String navigationNextManeuverLabel(String distance, String instruction) {
    return 'In $distance: $instruction';
  }
}
