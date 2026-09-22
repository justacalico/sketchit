// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Sketchit';

  @override
  String get canvasHint => 'ツールを選んでスケッチを始めよう';

  @override
  String get menuOpen => 'ファイルを開く';

  @override
  String get menuSave => 'ファイルに保存';

  @override
  String get menuExportPng => 'PNGをエクスポート';

  @override
  String get menuGrid => 'グリッド';

  @override
  String get menuTheme => 'テーマ';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get menuLanguage => '言語';

  @override
  String get menuAbout => '情報';

  @override
  String get menuClearCanvas => 'キャンバスをクリア';

  @override
  String get zoomIn => '拡大';

  @override
  String get zoomOut => '縮小';

  @override
  String get zoomReset => 'ズームをリセット';

  @override
  String get zoomFit => '全体を表示';

  @override
  String get undo => '元に戻す';

  @override
  String get redo => 'やり直し';

  @override
  String get toolSelect => '選択';

  @override
  String get toolHand => 'パン';

  @override
  String get toolRectangle => '矩形';

  @override
  String get toolDiamond => 'ひし形';

  @override
  String get toolEllipse => '楕円';

  @override
  String get toolArrow => '矢印';

  @override
  String get toolLine => '直線';

  @override
  String get toolPencil => 'フリーハンド';

  @override
  String get toolText => 'テキスト';

  @override
  String get toolEraser => '消しゴム';

  @override
  String get propStroke => '線';

  @override
  String get propFill => '塗りつぶし';

  @override
  String get propStrokeWidth => '線の太さ';

  @override
  String get propStrokeStyle => '線のスタイル';

  @override
  String get propRoughness => '手描き感';

  @override
  String get propOpacity => '不透明度';

  @override
  String get propLayers => 'レイヤー';

  @override
  String get propActions => '操作';

  @override
  String get styleSolid => '実線';

  @override
  String get styleDashed => '破線';

  @override
  String get styleDotted => '点線';

  @override
  String get styleCrisp => 'きれい';

  @override
  String get styleSketch => 'スケッチ';

  @override
  String get styleRough => 'ラフ';

  @override
  String get fillNone => 'なし';

  @override
  String get actionDelete => '削除';

  @override
  String get actionDuplicate => '複製';

  @override
  String get actionBringForward => '前面へ';

  @override
  String get actionSendBackward => '背面へ';

  @override
  String get actionBringToFront => '最前面へ';

  @override
  String get actionSendToBack => '最背面へ';

  @override
  String get actionSelectAll => 'すべて選択';

  @override
  String get actionCopy => 'コピー';

  @override
  String get actionPaste => '貼り付け';

  @override
  String get actionCut => '切り取り';

  @override
  String get textPlaceholder => 'テキストを入力';

  @override
  String get dialogClearTitle => 'キャンバスをクリア';

  @override
  String get dialogClearBody => 'キャンバス上のすべての要素が削除されます。この操作は元に戻せません。';

  @override
  String get dialogCancel => 'キャンセル';

  @override
  String get dialogConfirm => 'クリア';

  @override
  String get dialogClose => '閉じる';

  @override
  String get aboutTitle => 'Sketchitについて';

  @override
  String get aboutBody => '手描き風のホワイトボード。データはすべてこのデバイスに保存されます。';

  @override
  String get snackSaved => 'シーンを保存しました';

  @override
  String get snackOpened => 'シーンを読み込みました';

  @override
  String get snackExported => 'エクスポートが完了しました';

  @override
  String get snackOpenFailed => 'ファイルを開けませんでした';

  @override
  String get fileSceneName => 'sketchit-scene';

  @override
  String get fileImageName => 'sketchit';
}
