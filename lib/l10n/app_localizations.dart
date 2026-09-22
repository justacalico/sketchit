import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sketchit'**
  String get appTitle;

  /// No description provided for @canvasHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a tool and start sketching'**
  String get canvasHint;

  /// No description provided for @menuOpen.
  ///
  /// In en, this message translates to:
  /// **'Open file'**
  String get menuOpen;

  /// No description provided for @menuSave.
  ///
  /// In en, this message translates to:
  /// **'Save to file'**
  String get menuSave;

  /// No description provided for @menuExportPng.
  ///
  /// In en, this message translates to:
  /// **'Export PNG'**
  String get menuExportPng;

  /// No description provided for @menuGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get menuGrid;

  /// No description provided for @menuTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get menuTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @menuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get menuLanguage;

  /// No description provided for @menuAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get menuAbout;

  /// No description provided for @menuClearCanvas.
  ///
  /// In en, this message translates to:
  /// **'Clear canvas'**
  String get menuClearCanvas;

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get zoomOut;

  /// No description provided for @zoomReset.
  ///
  /// In en, this message translates to:
  /// **'Reset zoom'**
  String get zoomReset;

  /// No description provided for @zoomFit.
  ///
  /// In en, this message translates to:
  /// **'Zoom to fit'**
  String get zoomFit;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @toolSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get toolSelect;

  /// No description provided for @toolHand.
  ///
  /// In en, this message translates to:
  /// **'Pan'**
  String get toolHand;

  /// No description provided for @toolRectangle.
  ///
  /// In en, this message translates to:
  /// **'Rectangle'**
  String get toolRectangle;

  /// No description provided for @toolDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get toolDiamond;

  /// No description provided for @toolEllipse.
  ///
  /// In en, this message translates to:
  /// **'Ellipse'**
  String get toolEllipse;

  /// No description provided for @toolArrow.
  ///
  /// In en, this message translates to:
  /// **'Arrow'**
  String get toolArrow;

  /// No description provided for @toolLine.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get toolLine;

  /// No description provided for @toolPencil.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get toolPencil;

  /// No description provided for @toolText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get toolText;

  /// No description provided for @toolEraser.
  ///
  /// In en, this message translates to:
  /// **'Eraser'**
  String get toolEraser;

  /// No description provided for @propStroke.
  ///
  /// In en, this message translates to:
  /// **'Stroke'**
  String get propStroke;

  /// No description provided for @propFill.
  ///
  /// In en, this message translates to:
  /// **'Fill'**
  String get propFill;

  /// No description provided for @propStrokeWidth.
  ///
  /// In en, this message translates to:
  /// **'Stroke width'**
  String get propStrokeWidth;

  /// No description provided for @propStrokeStyle.
  ///
  /// In en, this message translates to:
  /// **'Stroke style'**
  String get propStrokeStyle;

  /// No description provided for @propRoughness.
  ///
  /// In en, this message translates to:
  /// **'Sloppiness'**
  String get propRoughness;

  /// No description provided for @propOpacity.
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get propOpacity;

  /// No description provided for @propLayers.
  ///
  /// In en, this message translates to:
  /// **'Layers'**
  String get propLayers;

  /// No description provided for @propActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get propActions;

  /// No description provided for @styleSolid.
  ///
  /// In en, this message translates to:
  /// **'Solid'**
  String get styleSolid;

  /// No description provided for @styleDashed.
  ///
  /// In en, this message translates to:
  /// **'Dashed'**
  String get styleDashed;

  /// No description provided for @styleDotted.
  ///
  /// In en, this message translates to:
  /// **'Dotted'**
  String get styleDotted;

  /// No description provided for @styleCrisp.
  ///
  /// In en, this message translates to:
  /// **'Crisp'**
  String get styleCrisp;

  /// No description provided for @styleSketch.
  ///
  /// In en, this message translates to:
  /// **'Sketch'**
  String get styleSketch;

  /// No description provided for @styleRough.
  ///
  /// In en, this message translates to:
  /// **'Rough'**
  String get styleRough;

  /// No description provided for @fillNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get fillNone;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get actionDuplicate;

  /// No description provided for @actionBringForward.
  ///
  /// In en, this message translates to:
  /// **'Bring forward'**
  String get actionBringForward;

  /// No description provided for @actionSendBackward.
  ///
  /// In en, this message translates to:
  /// **'Send backward'**
  String get actionSendBackward;

  /// No description provided for @actionBringToFront.
  ///
  /// In en, this message translates to:
  /// **'Bring to front'**
  String get actionBringToFront;

  /// No description provided for @actionSendToBack.
  ///
  /// In en, this message translates to:
  /// **'Send to back'**
  String get actionSendToBack;

  /// No description provided for @actionSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get actionSelectAll;

  /// No description provided for @actionCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// No description provided for @actionPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get actionPaste;

  /// No description provided for @actionCut.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get actionCut;

  /// No description provided for @textPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type something'**
  String get textPlaceholder;

  /// No description provided for @dialogClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear canvas'**
  String get dialogClearTitle;

  /// No description provided for @dialogClearBody.
  ///
  /// In en, this message translates to:
  /// **'This removes every element on the canvas and cannot be undone.'**
  String get dialogClearBody;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @dialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get dialogConfirm;

  /// No description provided for @dialogClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dialogClose;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Sketchit'**
  String get aboutTitle;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'A hand-drawn style whiteboard. Everything stays on your device.'**
  String get aboutBody;

  /// No description provided for @snackSaved.
  ///
  /// In en, this message translates to:
  /// **'Scene saved'**
  String get snackSaved;

  /// No description provided for @snackOpened.
  ///
  /// In en, this message translates to:
  /// **'Scene loaded'**
  String get snackOpened;

  /// No description provided for @snackExported.
  ///
  /// In en, this message translates to:
  /// **'Export finished'**
  String get snackExported;

  /// No description provided for @snackOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open that file'**
  String get snackOpenFailed;

  /// No description provided for @fileSceneName.
  ///
  /// In en, this message translates to:
  /// **'sketchit-scene'**
  String get fileSceneName;

  /// No description provided for @fileImageName.
  ///
  /// In en, this message translates to:
  /// **'sketchit'**
  String get fileImageName;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'ko',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
