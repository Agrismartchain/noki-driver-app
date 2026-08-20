// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'نوكي للسائقين';

  @override
  String get loginEmailLabel => 'البريد الإلكتروني';

  @override
  String get loginPasswordLabel => 'كلمة المرور';

  @override
  String get loginSubmit => 'تسجيل الدخول';

  @override
  String get loginSubmitting => 'جارٍ تسجيل الدخول…';

  @override
  String get loginEmailRequired => 'أدخل بريدك الإلكتروني';

  @override
  String get loginEmailInvalid => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get loginPasswordRequired => 'أدخل كلمة المرور';

  @override
  String get loginShowPassword => 'إظهار كلمة المرور';

  @override
  String get loginHidePassword => 'إخفاء كلمة المرور';

  @override
  String get loginHeadline => 'تسجيل الدخول إلى نوكي للسائقين';

  @override
  String get loginSubheadline => 'استخدم الحساب الذي زوّدتك به منظمتك.';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navWork => 'العمل';

  @override
  String get navActivity => 'النشاط';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String homeGreeting(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String get homeNoVehicle => 'لا توجد مركبة مخصصة بعد';

  @override
  String get homeVehicleLabel => 'المركبة المخصصة';

  @override
  String get homeCountryLabel => 'الدولة';

  @override
  String get homeCapabilitiesLabel => 'الخدمات';

  @override
  String get homeNoServices => 'لا توجد خدمات بعد';

  @override
  String get homeWorkFeedSummaryTitle => 'قائمة المهام';

  @override
  String homeWorkFeedSummaryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهام مفتوحة',
      one: 'مهمة واحدة مفتوحة',
      zero: 'لا توجد مهام مفتوحة',
    );
    return '$_temp0';
  }

  @override
  String get vehiclesTitle => 'المركبات';

  @override
  String get vehiclesEmpty => 'لا توجد مركبات في ملفك الشخصي';

  @override
  String get vehiclesEmptyBody => 'ستظهر هنا المركبات التي تخصصها لك منظمتك.';

  @override
  String get vehicleTypeCar => 'سيارة';

  @override
  String get vehicleTypeMotorcycle => 'دراجة نارية';

  @override
  String get vehicleStatusPendingValidation => 'بانتظار التحقق';

  @override
  String get vehicleStatusActive => 'نشطة';

  @override
  String get vehicleStatusSuspended => 'موقوفة';

  @override
  String get vehicleStatusRetired => 'خارج الخدمة';

  @override
  String get vehiclePlateLabel => 'رقم اللوحة';

  @override
  String get availabilityTitle => 'التوفر';

  @override
  String get availabilityStatusOffline => 'غير متصل';

  @override
  String get availabilityStatusAvailable => 'متاح';

  @override
  String get availabilityStatusBusy => 'مشغول';

  @override
  String get availabilityUpdating => 'جارٍ التحديث…';

  @override
  String get availabilityUpdateFailed => 'تعذّر تحديث حالة توفرك';

  @override
  String availabilityActiveMissions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count توصيلات نشطة',
      one: 'توصيلة نشطة واحدة',
      zero: 'لا توجد توصيلات نشطة',
    );
    return '$_temp0';
  }

  @override
  String availabilityActiveRides(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رحلات نشطة',
      one: 'رحلة نشطة واحدة',
      zero: 'لا توجد رحلات نشطة',
    );
    return '$_temp0';
  }

  @override
  String availabilityPendingOffers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عروض رحلات معلّقة',
      one: 'عرض رحلة معلّق واحد',
      zero: 'لا توجد عروض رحلات معلّقة',
    );
    return '$_temp0';
  }

  @override
  String get workFeedTitle => 'قائمة المهام';

  @override
  String get workFeedEmpty => 'لا توجد مهام مسندة الآن';

  @override
  String get workFeedEmptyBody =>
      'ستظهر هنا مهام التوصيل والرحلات الجديدة المسندة إليك.';

  @override
  String get workFeedTypeDelivery => 'توصيل';

  @override
  String get workFeedTypeRide => 'رحلة';

  @override
  String get workFeedFilterAll => 'الكل';

  @override
  String get workFeedFilterDelivery => 'توصيل';

  @override
  String get workFeedFilterRides => 'رحلات';

  @override
  String get workFeedFilterActive => 'نشطة';

  @override
  String get workFeedFilterPending => 'معلّقة';

  @override
  String deliveryCodBadge(String amount) {
    return 'الدفع عند الاستلام: $amount';
  }

  @override
  String get financeAmountToCollectLabel => 'المبلغ المطلوب تحصيله';

  @override
  String get financeAmountToCollectHint =>
      'قم بتحصيل هذا المبلغ من العميل قبل إنهاء التوصيلة.';

  @override
  String get financeCodSafetyNotice =>
      'هذا المبلغ يعود إلى نوكي حتى تتم تسويته. لا يُعد من أرباح السائق.';

  @override
  String get financeEstimatedFareLabel => 'الأجرة التقديرية';

  @override
  String get financeEstimatedFareHint =>
      'يُعرض كسياق تشغيلي للرحلة وليس كدفعة نهائية للسائق.';

  @override
  String get missionDetailTitle => 'المهمة';

  @override
  String get missionSectionPickup => 'الاستلام';

  @override
  String get missionSectionDropoff => 'التسليم';

  @override
  String get missionSectionFinancial => 'المعلومات المالية';

  @override
  String get missionSectionMission => 'المهمة';

  @override
  String get missionSectionEvidence => 'التحقق من التسليم';

  @override
  String get missionSectionIncidents => 'الحوادث';

  @override
  String get missionSectionNotAvailable => 'غير متاح لهذه المهمة';

  @override
  String get missionCallAction => 'اتصال';

  @override
  String get missionNavigateAction => 'التوجيه';

  @override
  String get missionFinancialCodLabel => 'الدفع عند الاستلام';

  @override
  String get missionFinancialNoCurrency => 'رمز العملة غير متاح لهذا المبلغ';

  @override
  String missionLineItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عناصر',
      one: 'عنصر واحد',
      zero: 'لا توجد عناصر',
    );
    return '$_temp0';
  }

  @override
  String get missionTimestampAssigned => 'تم الإسناد';

  @override
  String get missionTimestampOutForDelivery => 'قيد التوصيل';

  @override
  String get missionTimestampDelivered => 'تم التسليم';

  @override
  String get missionTimestampFailed => 'فشل التسليم';

  @override
  String get missionStatusReadyForDispatch => 'جاهزة للإرسال';

  @override
  String get missionStatusAssigned => 'مسندة';

  @override
  String get missionStatusOutForDelivery => 'قيد التوصيل';

  @override
  String get missionStatusDelivered => 'تم التسليم';

  @override
  String get missionStatusFailed => 'فشلت';

  @override
  String get missionStatusCancelled => 'ملغاة';

  @override
  String get missionOtpRequestCta => 'طلب رمز التسليم';

  @override
  String get missionOtpRequestAgainCta => 'طلب رمز جديد';

  @override
  String missionOtpChallengeStatus(String status) {
    return 'حالة الرمز: $status';
  }

  @override
  String get missionOtpCodeLabel => 'رمز مكوّن من 6 أرقام';

  @override
  String get missionOtpVerifyCta => 'تحقق من الرمز';

  @override
  String get missionOtpVerifiedLabel => 'تم التحقق من رمز التسليم';

  @override
  String get otpStatusPending => 'قيد الانتظار';

  @override
  String get otpStatusVerified => 'تم التحقق';

  @override
  String get otpStatusExpired => 'منتهي الصلاحية';

  @override
  String get otpStatusLocked => 'مقفل';

  @override
  String get otpStatusRevoked => 'ملغى';

  @override
  String get missionCompleteCta => 'إنهاء المهمة';

  @override
  String get missionCompleteRequiresOtp => 'تحقق من رمز التسليم قبل الإنهاء';

  @override
  String get missionCompleteRequiresOutForDelivery =>
      'يمكن إنهاء هذه المهمة بمجرد أن تصبح قيد التوصيل';

  @override
  String get missionAlreadyCompleted => 'تم إنهاء هذه المهمة بالفعل';

  @override
  String get incidentTypeLabel => 'نوع الحادثة';

  @override
  String get incidentTypeDelay => 'تأخير';

  @override
  String get incidentTypeVehicleIssue => 'عطل في المركبة';

  @override
  String get incidentTypeSafety => 'سلامة';

  @override
  String get incidentTypeOther => 'أخرى';

  @override
  String get incidentStatusOpen => 'مفتوحة';

  @override
  String get incidentStatusResolved => 'تم الحل';

  @override
  String get incidentCommentLabel => 'ملاحظة (اختياري)';

  @override
  String get incidentSubmitCta => 'الإبلاغ عن حادثة';

  @override
  String get incidentsEmpty => 'لا توجد حوادث مُبلّغ عنها';

  @override
  String get qrEntryTitle => 'إدخال رمز QR';

  @override
  String get qrEntryHint => 'أدخل رمز QR الخاص بالتسليم يدويًا.';

  @override
  String get qrEntryTokenLabel => 'رمز QR';

  @override
  String get qrEntrySubmitCta => 'إرسال';

  @override
  String get qrEntryUseCameraCta => 'المسح بالكاميرا';

  @override
  String get qrScanTitle => 'مسح رمز QR';

  @override
  String get qrScanHint => 'وجّه الكاميرا نحو رمز QR الخاص بالتوصيلة.';

  @override
  String get qrScanManualEntryCta => 'إدخال الرمز يدويًا';

  @override
  String get qrScanPermissionDenied =>
      'تم رفض الوصول إلى الكاميرا. أدخل الرمز يدويًا بدلاً من ذلك.';

  @override
  String get qrScanCameraUnavailable =>
      'المسح بالكاميرا غير متاح على هذا الجهاز. أدخل الرمز يدويًا بدلاً من ذلك.';

  @override
  String get serviceTypeTaxi => 'تاكسي';

  @override
  String get serviceTypeTaxiMoto => 'تاكسي دراجة';

  @override
  String get mobilityOfferLabel => 'عرض';

  @override
  String get mobilityRideLabel => 'رحلة نشطة';

  @override
  String get mobilityOfferDetailTitle => 'عرض رحلة';

  @override
  String get mobilityOfferNoLongerAvailable => 'هذا العرض لم يعد متاحًا';

  @override
  String get mobilityEstimatedFareLabel => 'الأجرة المقدّرة';

  @override
  String get mobilityAcceptOfferCta => 'قبول العرض';

  @override
  String get mobilityRideDetailTitle => 'الرحلة';

  @override
  String get mobilityFareLabel => 'الأجرة';

  @override
  String get mobilityTimelineTitle => 'السجل الزمني';

  @override
  String get mobilityRideNoActionsAvailable =>
      'لا توجد إجراءات متاحة لهذه الرحلة حاليًا';

  @override
  String get rideStatusDriverAssigned => 'مسندة';

  @override
  String get rideStatusDriverEnRoute => 'السائق في الطريق';

  @override
  String get rideStatusDriverArrived => 'وصل السائق';

  @override
  String get rideStatusInProgress => 'قيد التنفيذ';

  @override
  String get rideStatusCompleted => 'مكتملة';

  @override
  String get rideStatusCancelled => 'ملغاة';

  @override
  String get rideActionMarkEnRoute => 'التوجه الآن';

  @override
  String get rideActionMarkArrived => 'تسجيل الوصول';

  @override
  String get rideActionStart => 'بدء الرحلة';

  @override
  String get rideActionComplete => 'إنهاء الرحلة';

  @override
  String get rideActionCancel => 'إلغاء الرحلة';

  @override
  String get mobilityIncidentTypeRide => 'رحلة';

  @override
  String get mobilityIncidentTypeDriver => 'سائق';

  @override
  String get mobilityIncidentTypeCustomerComplaint => 'شكوى عميل';

  @override
  String get mobilityIncidentStatusInProgress => 'قيد المعالجة';

  @override
  String get mobilityIncidentStatusDismissed => 'مرفوضة';

  @override
  String get settingsTitle => 'الملف الشخصي';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get settingsThemeSystem => 'النظام';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsLogout => 'تسجيل الخروج';

  @override
  String get settingsLogoutConfirmTitle => 'تسجيل الخروج؟';

  @override
  String get settingsLogoutConfirmBody =>
      'ستحتاج إلى تسجيل الدخول مرة أخرى للوصول إلى عملك.';

  @override
  String get settingsCancel => 'إلغاء';

  @override
  String get accessDeniedTitle => 'لا يمكن لهذا الحساب استخدام نوكي للسائقين';

  @override
  String get accessDeniedBody =>
      'حسابك غير مسجل كسائق في أي منظمة. تواصل مع منظمتك إذا كنت تعتقد أن هذا خطأ.';

  @override
  String get accessDeniedSignOut => 'تسجيل الخروج';

  @override
  String get errorNetwork =>
      'لا يوجد اتصال. تحقق من اتصالك بالإنترنت وحاول مرة أخرى.';

  @override
  String get errorTimeout =>
      'استغرق الخادم وقتًا طويلاً للاستجابة. حاول مرة أخرى.';

  @override
  String get errorUnauthenticated => 'انتهت صلاحية جلستك. سجّل الدخول من جديد.';

  @override
  String get errorForbidden => 'ليس لديك صلاحية الوصول إلى هذا.';

  @override
  String get errorNotFound => 'لم نتمكن من العثور على ذلك.';

  @override
  String get errorValidation => 'بعض المعلومات غير صالحة.';

  @override
  String get errorConflict => 'تعذّر إتمام هذا الإجراء بسبب تعارض في البيانات.';

  @override
  String get errorRateLimited =>
      'محاولات كثيرة جدًا. انتظر لحظة ثم حاول مرة أخرى.';

  @override
  String get errorServer => 'حدث خطأ من جانبنا. حاول مرة أخرى بعد قليل.';

  @override
  String get errorUnknown => 'حدث خطأ ما.';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get offlineBannerMessage =>
      'أنت غير متصل بالإنترنت. قد تكون بعض المعلومات غير محدثة.';

  @override
  String get missionMapTitle => 'الخريطة';

  @override
  String get missionMapBackToDetails => 'التفاصيل';

  @override
  String get missionMapNextActionOtp => 'اطلب رمز التسليم لإنهاء هذه التوصيلة';

  @override
  String get mobilityMapTitle => 'الخريطة';

  @override
  String get homeContinueDelivery => 'متابعة التوصيلة النشطة';

  @override
  String get homeContinueRide => 'متابعة الرحلة النشطة';

  @override
  String get homeTrackingIdle => 'لا يوجد تتبع - غير متصل';

  @override
  String get homeTrackingPermissionNeeded => 'إذن الموقع مطلوب للتتبع';

  @override
  String get deliveryHistoryTitle => 'سجل التوصيلات';

  @override
  String get deliveryHistoryEmpty => 'لا توجد توصيلات مكتملة بعد';

  @override
  String get locationPermissionRationale =>
      'يحتاج نوكي للسائقين إلى موقعك لعرضه على الخريطة أثناء توصيلة أو رحلة نشطة.';

  @override
  String get locationGrantAction => 'السماح بالوصول إلى الموقع';

  @override
  String get locationDeniedForever =>
      'تم رفض الوصول إلى الموقع نهائيًا. فعّله من الإعدادات لاستخدام الخريطة.';

  @override
  String get locationServiceDisabled =>
      'خدمات الموقع معطّلة على هذا الجهاز. فعّلها لاستخدام الخريطة.';

  @override
  String get locationOpenSettings => 'فتح الإعدادات';

  @override
  String get locationErrorGeneric => 'تعذّرت قراءة حالة إذن الموقع.';

  @override
  String get mapGpsLive => 'نظام GPS نشط';

  @override
  String get mapGpsLocating => 'جارٍ تحديد موقع السائق';

  @override
  String get mapGpsUnavailable => 'الموقع غير متاح';

  @override
  String get mapGpsDisabled => 'تم تعطيل GPS';
}
