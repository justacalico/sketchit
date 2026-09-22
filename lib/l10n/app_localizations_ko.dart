// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Sketchit';

  @override
  String get canvasHint => '도구를 선택하고 스케치를 시작하세요';

  @override
  String get menuOpen => '파일 열기';

  @override
  String get menuSave => '파일로 저장';

  @override
  String get menuExportPng => 'PNG보내기';

  @override
  String get menuGrid => '격자';

  @override
  String get menuTheme => '테마';

  @override
  String get themeSystem => '시스템';

  @override
  String get themeLight => '라이트';

  @override
  String get themeDark => '다크';

  @override
  String get menuLanguage => '언어';

  @override
  String get menuAbout => '정보';

  @override
  String get menuClearCanvas => '캔버스 지우기';

  @override
  String get zoomIn => '확대';

  @override
  String get zoomOut => '축소';

  @override
  String get zoomReset => '확대/축소 초기화';

  @override
  String get zoomFit => '화면에 맞추기';

  @override
  String get undo => '실행 취소';

  @override
  String get redo => '다시 실행';

  @override
  String get toolSelect => '선택';

  @override
  String get toolHand => '이동';

  @override
  String get toolRectangle => '사각형';

  @override
  String get toolDiamond => '마름모';

  @override
  String get toolEllipse => '타원';

  @override
  String get toolArrow => '화살표';

  @override
  String get toolLine => '직선';

  @override
  String get toolPencil => '그리기';

  @override
  String get toolText => '텍스트';

  @override
  String get toolEraser => '지우개';

  @override
  String get propStroke => '윤곽선';

  @override
  String get propFill => '채우기';

  @override
  String get propStrokeWidth => '선 굵기';

  @override
  String get propStrokeStyle => '선 스타일';

  @override
  String get propRoughness => '손그림 정도';

  @override
  String get propOpacity => '불투명도';

  @override
  String get propLayers => '레이어';

  @override
  String get propActions => '작업';

  @override
  String get styleSolid => '실선';

  @override
  String get styleDashed => '파선';

  @override
  String get styleDotted => '점선';

  @override
  String get styleCrisp => '깔끔';

  @override
  String get styleSketch => '스케치';

  @override
  String get styleRough => '거침';

  @override
  String get fillNone => '없음';

  @override
  String get actionDelete => '삭제';

  @override
  String get actionDuplicate => '복제';

  @override
  String get actionBringForward => '앞으로';

  @override
  String get actionSendBackward => '뒤로';

  @override
  String get actionBringToFront => '맨 앞으로';

  @override
  String get actionSendToBack => '맨 뒤로';

  @override
  String get actionSelectAll => '모두 선택';

  @override
  String get actionCopy => '복사';

  @override
  String get actionPaste => '붙여넣기';

  @override
  String get actionCut => '잘라내기';

  @override
  String get textPlaceholder => '내용을 입력하세요';

  @override
  String get dialogClearTitle => '캔버스 지우기';

  @override
  String get dialogClearBody => '캔버스의 모든 요소가 삭제되며 되돌릴 수 없습니다.';

  @override
  String get dialogCancel => '취소';

  @override
  String get dialogConfirm => '지우기';

  @override
  String get dialogClose => '닫기';

  @override
  String get aboutTitle => 'Sketchit 정보';

  @override
  String get aboutBody => '손그림 스타일 화이트보드입니다. 모든 데이터는 기기에만 저장됩니다.';

  @override
  String get snackSaved => '장면이 저장됨';

  @override
  String get snackOpened => '장면을 불러옴';

  @override
  String get snackExported => '보내기 완료';

  @override
  String get snackOpenFailed => '파일을 열 수 없습니다';

  @override
  String get fileSceneName => 'sketchit-scene';

  @override
  String get fileImageName => 'sketchit';
}
