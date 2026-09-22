// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Sketchit';

  @override
  String get canvasHint => 'Choisis un outil et commence à dessiner';

  @override
  String get menuOpen => 'Ouvrir un fichier';

  @override
  String get menuSave => 'Enregistrer dans un fichier';

  @override
  String get menuExportPng => 'Exporter en PNG';

  @override
  String get menuGrid => 'Grille';

  @override
  String get menuTheme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get menuLanguage => 'Langue';

  @override
  String get menuAbout => 'À propos';

  @override
  String get menuClearCanvas => 'Vider le canvas';

  @override
  String get zoomIn => 'Zoomer';

  @override
  String get zoomOut => 'Dézoomer';

  @override
  String get zoomReset => 'Réinitialiser le zoom';

  @override
  String get zoomFit => 'Ajuster à la vue';

  @override
  String get undo => 'Annuler';

  @override
  String get redo => 'Rétablir';

  @override
  String get toolSelect => 'Sélection';

  @override
  String get toolHand => 'Déplacer la vue';

  @override
  String get toolRectangle => 'Rectangle';

  @override
  String get toolDiamond => 'Losange';

  @override
  String get toolEllipse => 'Ellipse';

  @override
  String get toolArrow => 'Flèche';

  @override
  String get toolLine => 'Ligne';

  @override
  String get toolPencil => 'Dessiner';

  @override
  String get toolText => 'Texte';

  @override
  String get toolEraser => 'Gomme';

  @override
  String get propStroke => 'Contour';

  @override
  String get propFill => 'Remplissage';

  @override
  String get propStrokeWidth => 'Épaisseur du trait';

  @override
  String get propStrokeStyle => 'Style du trait';

  @override
  String get propRoughness => 'Style manuel';

  @override
  String get propOpacity => 'Opacité';

  @override
  String get propLayers => 'Calques';

  @override
  String get propActions => 'Actions';

  @override
  String get styleSolid => 'Plein';

  @override
  String get styleDashed => 'Tirets';

  @override
  String get styleDotted => 'Pointillés';

  @override
  String get styleCrisp => 'Net';

  @override
  String get styleSketch => 'Croquis';

  @override
  String get styleRough => 'Rugueux';

  @override
  String get fillNone => 'Aucun';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionDuplicate => 'Dupliquer';

  @override
  String get actionBringForward => 'Avancer';

  @override
  String get actionSendBackward => 'Reculer';

  @override
  String get actionBringToFront => 'Mettre au premier plan';

  @override
  String get actionSendToBack => 'Mettre en arrière-plan';

  @override
  String get actionSelectAll => 'Tout sélectionner';

  @override
  String get actionCopy => 'Copier';

  @override
  String get actionPaste => 'Coller';

  @override
  String get actionCut => 'Couper';

  @override
  String get textPlaceholder => 'Écris quelque chose';

  @override
  String get dialogClearTitle => 'Vider le canvas';

  @override
  String get dialogClearBody =>
      'Cela supprime tous les éléments du canvas et ne peut pas être annulé.';

  @override
  String get dialogCancel => 'Annuler';

  @override
  String get dialogConfirm => 'Vider';

  @override
  String get dialogClose => 'Fermer';

  @override
  String get aboutTitle => 'À propos de Sketchit';

  @override
  String get aboutBody =>
      'Un tableau blanc au style dessiné à la main. Tout reste sur ton appareil.';

  @override
  String get snackSaved => 'Scène enregistrée';

  @override
  String get snackOpened => 'Scène chargée';

  @override
  String get snackExported => 'Export terminé';

  @override
  String get snackOpenFailed => 'Impossible d\'ouvrir ce fichier';

  @override
  String get fileSceneName => 'sketchit-scene';

  @override
  String get fileImageName => 'sketchit';
}
