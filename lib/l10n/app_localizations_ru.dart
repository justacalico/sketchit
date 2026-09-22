// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Sketchit';

  @override
  String get canvasHint => 'Выберите инструмент и начните рисовать';

  @override
  String get menuOpen => 'Открыть файл';

  @override
  String get menuSave => 'Сохранить в файл';

  @override
  String get menuExportPng => 'Экспорт PNG';

  @override
  String get menuGrid => 'Сетка';

  @override
  String get menuTheme => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get menuLanguage => 'Язык';

  @override
  String get menuAbout => 'О приложении';

  @override
  String get menuClearCanvas => 'Очистить холст';

  @override
  String get zoomIn => 'Увеличить';

  @override
  String get zoomOut => 'Уменьшить';

  @override
  String get zoomReset => 'Сбросить масштаб';

  @override
  String get zoomFit => 'По размеру экрана';

  @override
  String get undo => 'Отменить';

  @override
  String get redo => 'Повторить';

  @override
  String get toolSelect => 'Выбор';

  @override
  String get toolHand => 'Панорама';

  @override
  String get toolRectangle => 'Прямоугольник';

  @override
  String get toolDiamond => 'Ромб';

  @override
  String get toolEllipse => 'Эллипс';

  @override
  String get toolArrow => 'Стрелка';

  @override
  String get toolLine => 'Линия';

  @override
  String get toolPencil => 'Рисование';

  @override
  String get toolText => 'Текст';

  @override
  String get toolEraser => 'Ластик';

  @override
  String get propStroke => 'Контур';

  @override
  String get propFill => 'Заливка';

  @override
  String get propStrokeWidth => 'Толщина линии';

  @override
  String get propStrokeStyle => 'Стиль линии';

  @override
  String get propRoughness => 'Ручной стиль';

  @override
  String get propOpacity => 'Непрозрачность';

  @override
  String get propLayers => 'Слои';

  @override
  String get propActions => 'Действия';

  @override
  String get styleSolid => 'Сплошная';

  @override
  String get styleDashed => 'Пунктир';

  @override
  String get styleDotted => 'Точки';

  @override
  String get styleCrisp => 'Чёткий';

  @override
  String get styleSketch => 'Эскиз';

  @override
  String get styleRough => 'Грубый';

  @override
  String get fillNone => 'Нет';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionDuplicate => 'Дублировать';

  @override
  String get actionBringForward => 'Выше';

  @override
  String get actionSendBackward => 'Ниже';

  @override
  String get actionBringToFront => 'На передний план';

  @override
  String get actionSendToBack => 'На задний план';

  @override
  String get actionSelectAll => 'Выбрать всё';

  @override
  String get textPlaceholder => 'Введите текст';

  @override
  String get dialogClearTitle => 'Очистить холст';

  @override
  String get dialogClearBody =>
      'Все элементы на холсте будут удалены. Это действие нельзя отменить.';

  @override
  String get dialogCancel => 'Отмена';

  @override
  String get dialogConfirm => 'Очистить';

  @override
  String get dialogClose => 'Закрыть';

  @override
  String get aboutTitle => 'О Sketchit';

  @override
  String get aboutBody =>
      'Доска для рисования от руки. Всё остаётся на вашем устройстве.';

  @override
  String get snackSaved => 'Сцена сохранена';

  @override
  String get snackOpened => 'Сцена загружена';

  @override
  String get snackExported => 'Экспорт завершён';

  @override
  String get snackOpenFailed => 'Не удалось открыть файл';

  @override
  String get fileSceneName => 'sketchit-scene';

  @override
  String get fileImageName => 'sketchit';
}
