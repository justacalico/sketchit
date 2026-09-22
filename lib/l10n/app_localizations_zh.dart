// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Sketchit';

  @override
  String get canvasHint => '选择一个工具开始画图';

  @override
  String get menuOpen => '打开文件';

  @override
  String get menuSave => '保存到文件';

  @override
  String get menuExportPng => '导出 PNG';

  @override
  String get menuGrid => '网格';

  @override
  String get menuTheme => '主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get menuLanguage => '语言';

  @override
  String get menuAbout => '关于';

  @override
  String get menuClearCanvas => '清空画布';

  @override
  String get zoomIn => '放大';

  @override
  String get zoomOut => '缩小';

  @override
  String get zoomReset => '重置缩放';

  @override
  String get zoomFit => '缩放至适合';

  @override
  String get undo => '撤销';

  @override
  String get redo => '重做';

  @override
  String get toolSelect => '选择';

  @override
  String get toolHand => '平移';

  @override
  String get toolRectangle => '矩形';

  @override
  String get toolDiamond => '菱形';

  @override
  String get toolEllipse => '椭圆';

  @override
  String get toolArrow => '箭头';

  @override
  String get toolLine => '直线';

  @override
  String get toolPencil => '画笔';

  @override
  String get toolText => '文本';

  @override
  String get toolEraser => '橡皮擦';

  @override
  String get propStroke => '描边';

  @override
  String get propFill => '填充';

  @override
  String get propStrokeWidth => '线条粗细';

  @override
  String get propStrokeStyle => '线条样式';

  @override
  String get propRoughness => '手绘程度';

  @override
  String get propOpacity => '不透明度';

  @override
  String get propLayers => '图层';

  @override
  String get propActions => '操作';

  @override
  String get styleSolid => '实线';

  @override
  String get styleDashed => '虚线';

  @override
  String get styleDotted => '点线';

  @override
  String get styleCrisp => '工整';

  @override
  String get styleSketch => '手绘';

  @override
  String get styleRough => '潦草';

  @override
  String get fillNone => '无';

  @override
  String get actionDelete => '删除';

  @override
  String get actionDuplicate => '创建副本';

  @override
  String get actionBringForward => '上移一层';

  @override
  String get actionSendBackward => '下移一层';

  @override
  String get actionBringToFront => '置于顶层';

  @override
  String get actionSendToBack => '置于底层';

  @override
  String get actionSelectAll => '全选';

  @override
  String get textPlaceholder => '输入文本';

  @override
  String get dialogClearTitle => '清空画布';

  @override
  String get dialogClearBody => '这会删除画布上的所有元素，且无法撤销。';

  @override
  String get dialogCancel => '取消';

  @override
  String get dialogConfirm => '清空';

  @override
  String get dialogClose => '关闭';

  @override
  String get aboutTitle => '关于 Sketchit';

  @override
  String get aboutBody => '手绘风格白板，所有内容只保存在你的设备上。';

  @override
  String get snackSaved => '场景已保存';

  @override
  String get snackOpened => '场景已加载';

  @override
  String get snackExported => '导出完成';

  @override
  String get snackOpenFailed => '无法打开该文件';

  @override
  String get fileSceneName => 'sketchit-scene';

  @override
  String get fileImageName => 'sketchit';
}
