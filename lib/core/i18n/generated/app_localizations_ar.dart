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
}
