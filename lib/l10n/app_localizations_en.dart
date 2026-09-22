// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sketchit';

  @override
  String get canvasHint => 'Pick a tool and start sketching';

  @override
  String get menuOpen => 'Open file';

  @override
  String get menuSave => 'Save to file';

  @override
  String get menuExportPng => 'Export PNG';

  @override
  String get menuGrid => 'Grid';

  @override
  String get menuTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get menuLanguage => 'Language';

  @override
  String get menuAbout => 'About';

  @override
  String get menuClearCanvas => 'Clear canvas';

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String get zoomReset => 'Reset zoom';

  @override
  String get zoomFit => 'Zoom to fit';

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get toolSelect => 'Select';

  @override
  String get toolHand => 'Pan';

  @override
  String get toolRectangle => 'Rectangle';

  @override
  String get toolDiamond => 'Diamond';

  @override
  String get toolEllipse => 'Ellipse';

  @override
  String get toolArrow => 'Arrow';

  @override
  String get toolLine => 'Line';

  @override
  String get toolPencil => 'Draw';

  @override
  String get toolText => 'Text';

  @override
  String get toolEraser => 'Eraser';

  @override
  String get propStroke => 'Stroke';

  @override
  String get propFill => 'Fill';

  @override
  String get propStrokeWidth => 'Stroke width';

  @override
  String get propStrokeStyle => 'Stroke style';

  @override
  String get propRoughness => 'Sloppiness';

  @override
  String get propOpacity => 'Opacity';

  @override
  String get propLayers => 'Layers';

  @override
  String get propActions => 'Actions';

  @override
  String get styleSolid => 'Solid';

  @override
  String get styleDashed => 'Dashed';

  @override
  String get styleDotted => 'Dotted';

  @override
  String get styleCrisp => 'Crisp';

  @override
  String get styleSketch => 'Sketch';

  @override
  String get styleRough => 'Rough';

  @override
  String get fillNone => 'None';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionDuplicate => 'Duplicate';

  @override
  String get actionBringForward => 'Bring forward';

  @override
  String get actionSendBackward => 'Send backward';

  @override
  String get actionBringToFront => 'Bring to front';

  @override
  String get actionSendToBack => 'Send to back';

  @override
  String get actionSelectAll => 'Select all';

  @override
  String get textPlaceholder => 'Type something';

  @override
  String get dialogClearTitle => 'Clear canvas';

  @override
  String get dialogClearBody =>
      'This removes every element on the canvas and cannot be undone.';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogConfirm => 'Clear';

  @override
  String get dialogClose => 'Close';

  @override
  String get aboutTitle => 'About Sketchit';

  @override
  String get aboutBody =>
      'A hand-drawn style whiteboard. Everything stays on your device.';

  @override
  String get snackSaved => 'Scene saved';

  @override
  String get snackOpened => 'Scene loaded';

  @override
  String get snackExported => 'Export finished';

  @override
  String get snackOpenFailed => 'Could not open that file';

  @override
  String get fileSceneName => 'sketchit-scene';

  @override
  String get fileImageName => 'sketchit';
}
