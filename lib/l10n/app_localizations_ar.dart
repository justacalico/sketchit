// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Sketchit';

  @override
  String get canvasHint => 'اختر أداة وابدأ الرسم';

  @override
  String get menuOpen => 'فتح ملف';

  @override
  String get menuSave => 'حفظ في ملف';

  @override
  String get menuExportPng => 'تصدير PNG';

  @override
  String get menuGrid => 'الشبكة';

  @override
  String get menuTheme => 'المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get menuLanguage => 'اللغة';

  @override
  String get menuAbout => 'حول';

  @override
  String get menuClearCanvas => 'مسح اللوحة';

  @override
  String get zoomIn => 'تكبير';

  @override
  String get zoomOut => 'تصغير';

  @override
  String get zoomReset => 'إعادة ضبط التكبير';

  @override
  String get zoomFit => 'ملاءمة العرض';

  @override
  String get undo => 'تراجع';

  @override
  String get redo => 'إعادة';

  @override
  String get toolSelect => 'تحديد';

  @override
  String get toolHand => 'تحريك';

  @override
  String get toolRectangle => 'مستطيل';

  @override
  String get toolDiamond => 'معين';

  @override
  String get toolEllipse => 'بيضاوي';

  @override
  String get toolArrow => 'سهم';

  @override
  String get toolLine => 'خط';

  @override
  String get toolPencil => 'رسم حر';

  @override
  String get toolText => 'نص';

  @override
  String get toolEraser => 'ممحاة';

  @override
  String get propStroke => 'الحد';

  @override
  String get propFill => 'التعبئة';

  @override
  String get propStrokeWidth => 'سماكة الخط';

  @override
  String get propStrokeStyle => 'نمط الخط';

  @override
  String get propRoughness => 'الأسلوب اليدوي';

  @override
  String get propOpacity => 'الشفافية';

  @override
  String get propLayers => 'الطبقات';

  @override
  String get propActions => 'إجراءات';

  @override
  String get styleSolid => 'متصل';

  @override
  String get styleDashed => 'متقطع';

  @override
  String get styleDotted => 'منقط';

  @override
  String get styleCrisp => 'نظيف';

  @override
  String get styleSketch => 'رسمي';

  @override
  String get styleRough => 'خشن';

  @override
  String get fillNone => 'بدون';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionDuplicate => 'تكرار';

  @override
  String get actionBringForward => 'للأمام';

  @override
  String get actionSendBackward => 'للخلف';

  @override
  String get actionBringToFront => 'إلى المقدمة';

  @override
  String get actionSendToBack => 'إلى الخلفية';

  @override
  String get actionSelectAll => 'تحديد الكل';

  @override
  String get textPlaceholder => 'اكتب شيئاً';

  @override
  String get dialogClearTitle => 'مسح اللوحة';

  @override
  String get dialogClearBody =>
      'سيؤدي هذا إلى إزالة كل العناصر على اللوحة ولا يمكن التراجع عنه.';

  @override
  String get dialogCancel => 'إلغاء';

  @override
  String get dialogConfirm => 'مسح';

  @override
  String get dialogClose => 'إغلاق';

  @override
  String get aboutTitle => 'حول Sketchit';

  @override
  String get aboutBody =>
      'لوحة بيضاء بأسلوب مرسوم يدوياً. كل شيء يبقى على جهازك.';

  @override
  String get snackSaved => 'تم حفظ المشهد';

  @override
  String get snackOpened => 'تم تحميل المشهد';

  @override
  String get snackExported => 'اكتمل التصدير';

  @override
  String get snackOpenFailed => 'تعذر فتح الملف';

  @override
  String get fileSceneName => 'sketchit-scene';

  @override
  String get fileImageName => 'sketchit';
}
