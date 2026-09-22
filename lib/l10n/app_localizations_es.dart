// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Sketchit';

  @override
  String get canvasHint => 'Elige una herramienta y empieza a dibujar';

  @override
  String get menuOpen => 'Abrir archivo';

  @override
  String get menuSave => 'Guardar en archivo';

  @override
  String get menuExportPng => 'Exportar PNG';

  @override
  String get menuGrid => 'Cuadrícula';

  @override
  String get menuTheme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get menuLanguage => 'Idioma';

  @override
  String get menuAbout => 'Acerca de';

  @override
  String get menuClearCanvas => 'Vaciar lienzo';

  @override
  String get zoomIn => 'Acercar';

  @override
  String get zoomOut => 'Alejar';

  @override
  String get zoomReset => 'Restablecer zoom';

  @override
  String get zoomFit => 'Ajustar a la vista';

  @override
  String get undo => 'Deshacer';

  @override
  String get redo => 'Rehacer';

  @override
  String get toolSelect => 'Seleccionar';

  @override
  String get toolHand => 'Mover vista';

  @override
  String get toolRectangle => 'Rectángulo';

  @override
  String get toolDiamond => 'Rombo';

  @override
  String get toolEllipse => 'Elipse';

  @override
  String get toolArrow => 'Flecha';

  @override
  String get toolLine => 'Línea';

  @override
  String get toolPencil => 'Dibujar';

  @override
  String get toolText => 'Texto';

  @override
  String get toolEraser => 'Borrador';

  @override
  String get propStroke => 'Trazo';

  @override
  String get propFill => 'Relleno';

  @override
  String get propStrokeWidth => 'Grosor del trazo';

  @override
  String get propStrokeStyle => 'Estilo del trazo';

  @override
  String get propRoughness => 'Estilo manual';

  @override
  String get propOpacity => 'Opacidad';

  @override
  String get propLayers => 'Capas';

  @override
  String get propActions => 'Acciones';

  @override
  String get styleSolid => 'Sólido';

  @override
  String get styleDashed => 'Discontinuo';

  @override
  String get styleDotted => 'Punteado';

  @override
  String get styleCrisp => 'Nítido';

  @override
  String get styleSketch => 'Boceto';

  @override
  String get styleRough => 'Rústico';

  @override
  String get fillNone => 'Ninguno';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionDuplicate => 'Duplicar';

  @override
  String get actionBringForward => 'Avanzar';

  @override
  String get actionSendBackward => 'Retroceder';

  @override
  String get actionBringToFront => 'Traer al frente';

  @override
  String get actionSendToBack => 'Enviar al fondo';

  @override
  String get actionSelectAll => 'Seleccionar todo';

  @override
  String get textPlaceholder => 'Escribe algo';

  @override
  String get dialogClearTitle => 'Vaciar lienzo';

  @override
  String get dialogClearBody =>
      'Esto elimina todos los elementos del lienzo y no se puede deshacer.';

  @override
  String get dialogCancel => 'Cancelar';

  @override
  String get dialogConfirm => 'Vaciar';

  @override
  String get dialogClose => 'Cerrar';

  @override
  String get aboutTitle => 'Acerca de Sketchit';

  @override
  String get aboutBody =>
      'Una pizarra con estilo dibujado a mano. Todo permanece en tu dispositivo.';

  @override
  String get snackSaved => 'Escena guardada';

  @override
  String get snackOpened => 'Escena cargada';

  @override
  String get snackExported => 'Exportación finalizada';

  @override
  String get snackOpenFailed => 'No se pudo abrir ese archivo';

  @override
  String get fileSceneName => 'sketchit-scene';

  @override
  String get fileImageName => 'sketchit';
}
