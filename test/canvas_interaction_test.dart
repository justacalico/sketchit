import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sketchit/app.dart';
import 'package:sketchit/canvas/canvas_view.dart';
import 'package:sketchit/models/element.dart';
import 'package:sketchit/state/drawing_controller.dart';
import 'package:sketchit/state/settings_controller.dart';

Future<SettingsController> testSettings([Map<String, Object> prefs = const {}]) async {
  SharedPreferences.setMockInitialValues(prefs);
  return SettingsController.load();
}

DrawingController controllerOf(WidgetTester tester) =>
    tester.widget<CanvasView>(find.byType(CanvasView)).controller;

Future<void> pumpApp(WidgetTester tester,
    [Map<String, Object> prefs = const {}]) async {
  final settings = await testSettings(prefs);
  await tester.pumpWidget(SketchitApp(settings: settings));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('dragging with rectangle tool creates an element',
      (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.rectangle_outlined));
    await tester.pumpAndSettle();

    await tester.dragFrom(const Offset(300, 300), const Offset(120, 80));
    await tester.pumpAndSettle();

    final c = controllerOf(tester);
    expect(c.elements.length, 1);
    expect(c.elements.first.type, ElementType.rectangle);
    expect(c.selectedIds, {c.elements.first.id});
  });

  testWidgets('freedraw collects points', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.gesture));
    await tester.pumpAndSettle();

    final g = await tester.startGesture(const Offset(300, 300));
    await g.moveBy(const Offset(40, 20));
    await g.moveBy(const Offset(40, 40));
    await g.up();
    await tester.pumpAndSettle();

    final c = controllerOf(tester);
    expect(c.elements.single.type, ElementType.freedraw);
    expect(c.elements.single.points.length, greaterThan(1));
  });

  testWidgets('eraser removes a drawn element', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.rectangle_outlined));
    await tester.pumpAndSettle();
    await tester.dragFrom(const Offset(300, 300), const Offset(120, 80));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.cleaning_services_outlined));
    await tester.pumpAndSettle();
    // Tap on the border of the unfilled rect.
    await tester.tapAt(const Offset(302, 340));
    await tester.pumpAndSettle();

    expect(controllerOf(tester).elements, isEmpty);
  });

  testWidgets('select tool picks an element', (tester) async {
    await pumpApp(tester);
    final c = controllerOf(tester);
    c.setDraft(SketchElement.shape(
      type: ElementType.rectangle,
      rect: const Rect.fromLTWH(200, 200, 100, 100),
      fillColor: 0xffff0000,
    ));
    c.commitDraft();
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(250, 250));
    await tester.pumpAndSettle();
    expect(c.hasSelection, isTrue);
  });

  testWidgets('dragging a selected element moves it', (tester) async {
    await pumpApp(tester);
    final c = controllerOf(tester);
    c.setDraft(SketchElement.shape(
      type: ElementType.rectangle,
      rect: const Rect.fromLTWH(200, 200, 100, 100),
      fillColor: 0xffff0000,
    ));
    c.commitDraft();
    await tester.pumpAndSettle();

    await tester.dragFrom(const Offset(250, 250), const Offset(50, 30));
    await tester.pumpAndSettle();
    expect(c.elements.first.x, closeTo(250, 1));
    expect(c.elements.first.y, closeTo(230, 1));
  });

  testWidgets('undo button restores deleted element', (tester) async {
    await pumpApp(tester);
    final c = controllerOf(tester);
    c.setDraft(SketchElement.shape(
      type: ElementType.rectangle,
      rect: const Rect.fromLTWH(100, 100, 50, 50),
    ));
    c.commitDraft();
    await tester.pumpAndSettle();

    c.selectAll();
    c.deleteSelected();
    await tester.pumpAndSettle();
    expect(c.elements, isEmpty);

    await tester.tap(find.byIcon(Icons.undo));
    await tester.pumpAndSettle();
    expect(c.elements.length, 1);
  });

  testWidgets('zoom buttons update the zoom label', (tester) async {
    await pumpApp(tester);
    expect(find.text('100%'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('120%'), findsOneWidget);
  });

  testWidgets('text tool opens an editor and commits text',
      (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.text_fields));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(400, 300));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'hello canvas');
    await tester.pumpAndSettle();
    // Tapping the canvas commits the text.
    await tester.tapAt(const Offset(600, 500));
    await tester.pumpAndSettle();

    final c = controllerOf(tester);
    expect(c.elements.single.type, ElementType.text);
    expect(c.elements.single.text, 'hello canvas');
  });

  testWidgets('clear canvas asks for confirmation', (tester) async {
    await pumpApp(tester);
    final c = controllerOf(tester);
    c.setDraft(SketchElement.shape(
      type: ElementType.rectangle,
      rect: const Rect.fromLTWH(0, 0, 50, 50),
    ));
    c.commitDraft();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear canvas'));
    await tester.pumpAndSettle();
    expect(find.text('Clear'), findsOneWidget);

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(c.elements, isEmpty);
  });

  testWidgets('autosave restores the last scene', (tester) async {
    final c = DrawingController();
    c.setDraft(SketchElement.shape(
      type: ElementType.rectangle,
      rect: const Rect.fromLTWH(10, 10, 60, 40),
    ));
    c.commitDraft();
    final saved = c.exportScene().encode();

    await pumpApp(tester, {'scene.autosave': saved});
    expect(controllerOf(tester).elements.length, 1);
  });

  testWidgets('locale change re-renders strings', (tester) async {
    final settings = await testSettings();
    await tester.pumpWidget(SketchitApp(settings: settings));
    await tester.pumpAndSettle();
    expect(find.text('Pick a tool and start sketching'), findsOneWidget);

    settings.setLocale(const Locale('zh'));
    await tester.pumpAndSettle();
    expect(find.text('选择一个工具开始画图'), findsOneWidget);
  });

  testWidgets('arabic locale renders RTL', (tester) async {
    final settings = await testSettings({'settings.locale': 'ar'});
    await tester.pumpWidget(SketchitApp(settings: settings));
    await tester.pumpAndSettle();
    final direction =
        tester.widget<Directionality>(find.byType(Directionality).first);
    expect(direction.textDirection, TextDirection.rtl);
  });
}
