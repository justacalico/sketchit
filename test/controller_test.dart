import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sketchit/models/element.dart';
import 'package:sketchit/models/scene.dart';
import 'package:sketchit/state/drawing_controller.dart';

SketchElement box({double x = 0, double y = 0, double w = 100, double h = 100}) {
  return SketchElement.shape(
    type: ElementType.rectangle,
    rect: Rect.fromLTWH(x, y, w, h),
    fillColor: 0xffff0000,
  );
}

void main() {
  group('viewport', () {
    test('scene/screen round trip', () {
      final c = DrawingController();
      c.zoomAt(const Offset(100, 100), 2);
      const scene = Offset(40, 60);
      expect(c.toScene(c.toScreen(scene)).dx, closeTo(scene.dx, 1e-9));
      expect(c.toScene(c.toScreen(scene)).dy, closeTo(scene.dy, 1e-9));
    });

    test('zoom clamps', () {
      final c = DrawingController();
      for (var i = 0; i < 20; i++) {
        c.zoomAt(Offset.zero, 2);
      }
      expect(c.zoom, DrawingController.maxZoom);
      for (var i = 0; i < 40; i++) {
        c.zoomAt(Offset.zero, 0.5);
      }
      expect(c.zoom, DrawingController.minZoom);
    });

    test('zoomAt keeps focal point stable', () {
      final c = DrawingController();
      const focal = Offset(200, 150);
      final before = c.toScene(focal);
      c.zoomAt(focal, 1.5);
      final after = c.toScene(focal);
      expect(after.dx, closeTo(before.dx, 1e-9));
      expect(after.dy, closeTo(before.dy, 1e-9));
    });

    test('zoomToFit centers content', () {
      final c = DrawingController(elements: [box(w: 100, h: 100)]);
      c.zoomToFit(const Size(1000, 1000));
      final center = c.toScreen(const Offset(50, 50));
      expect(center.dx, closeTo(500, 1e-6));
      expect(center.dy, closeTo(500, 1e-6));
    });

    test('zoomToFit on empty scene resets', () {
      final c = DrawingController();
      c.panBy(const Offset(500, 500));
      c.zoomToFit(const Size(800, 600));
      expect(c.zoom, 1);
      expect(c.pan, Offset.zero);
    });
  });

  group('elements and undo', () {
    test('commitDraft adds element and selects it', () {
      final c = DrawingController();
      c.setDraft(box());
      c.commitDraft();
      expect(c.elements.length, 1);
      expect(c.selectedIds.length, 1);
      expect(c.canUndo, isTrue);
    });

    test('undo restores previous state', () {
      final c = DrawingController();
      c.setDraft(box());
      c.commitDraft();
      c.undo();
      expect(c.elements, isEmpty);
      c.redo();
      expect(c.elements.length, 1);
    });

    test('gesture counts as a single undo step', () {
      final c = DrawingController(elements: [box()]);
      c.select(c.elements.first.id);
      c.beginGesture();
      c.moveSelectedBy(const Offset(10, 0));
      c.moveSelectedBy(const Offset(10, 0));
      c.endGesture();
      expect(c.elements.first.x, 20);
      c.undo();
      expect(c.elements.first.x, 0);
    });

    test('unchanged gesture does not pollute undo stack', () {
      final c = DrawingController(elements: [box()]);
      c.beginGesture();
      c.endGesture();
      expect(c.canUndo, isFalse);
    });

    test('redo cleared by new edit', () {
      final c = DrawingController();
      c.setDraft(box());
      c.commitDraft();
      c.undo();
      c.setDraft(box(x: 50));
      c.commitDraft();
      expect(c.canRedo, isFalse);
    });
  });

  group('selection', () {
    test('topMostAt returns last drawn hit', () {
      final c = DrawingController(elements: [box(), box(w: 50, h: 50)]);
      final hit = c.topMostAt(const Offset(25, 25));
      expect(hit, c.elements[1]);
    });

    test('marquee selects overlapping elements', () {
      final c =
          DrawingController(elements: [box(), box(x: 500, y: 500, w: 50, h: 50)]);
      c.setMarquee(const Rect.fromLTWH(-10, -10, 200, 200));
      expect(c.selectedIds, {c.elements[0].id});
    });

    test('toggleSelect adds and removes', () {
      final c = DrawingController(elements: [box()]);
      final id = c.elements.first.id;
      c.toggleSelect(id);
      c.toggleSelect(id);
      expect(c.selectedIds, isEmpty);
    });

    test('deleteSelected removes and is undoable', () {
      final c = DrawingController(elements: [box(), box(x: 300)]);
      c.selectAll();
      c.deleteSelected();
      expect(c.elements, isEmpty);
      c.undo();
      expect(c.elements.length, 2);
    });
  });

  group('ordering and duplication', () {
    test('bringToFront moves element to end', () {
      final c = DrawingController(elements: [box(), box(x: 200)]);
      final first = c.elements[0];
      c.select(first.id);
      c.bringToFront();
      expect(c.elements.last, first);
    });

    test('forward swaps with next unselected', () {
      final c = DrawingController(elements: [box(), box(x: 200)]);
      final first = c.elements[0];
      c.select(first.id);
      c.bringForward();
      expect(c.elements[1], first);
    });

    test('duplicate creates offset copy with new id', () {
      final c = DrawingController(elements: [box()]);
      c.select(c.elements.first.id);
      c.duplicateSelected();
      expect(c.elements.length, 2);
      expect(c.elements[1].id, isNot(c.elements[0].id));
      expect(c.elements[1].x, c.elements[0].x + 16);
      expect(c.selectedIds, {c.elements[1].id});
    });
  });

  group('style and misc', () {
    test('setStyle applies to selection', () {
      final c = DrawingController(elements: [box()]);
      c.select(c.elements.first.id);
      c.setStyle(const ElementStyle(strokeColor: 0xff00ff00));
      expect(c.elements.first.strokeColor, 0xff00ff00);
    });

    test('syncStyleFromSelection updates defaults', () {
      final c = DrawingController(elements: [
        box().copyWith(strokeWidth: 7, strokeStyle: StrokeStyle.dotted),
      ]);
      c.select(c.elements.first.id);
      c.syncStyleFromSelection();
      expect(c.style.strokeWidth, 7);
      expect(c.style.strokeStyle, StrokeStyle.dotted);
    });

    test('eraseAt removes hit element', () {
      final c = DrawingController(elements: [box()]);
      c.eraseAt(const Offset(50, 50));
      expect(c.elements, isEmpty);
    });

    test('resizeElement fits new bounds', () {
      final c = DrawingController(elements: [box()]);
      c.resizeElement(
          c.elements.first.id, const Rect.fromLTWH(10, 10, 40, 40));
      expect(c.elements.first.bounds, const Rect.fromLTWH(10, 10, 40, 40));
    });

    test('scene round trip through controller', () {
      final c = DrawingController(elements: [box()]);
      final other = DrawingController();
      other.loadScene(c.exportScene());
      expect(other.elements.length, 1);
      expect(other.elements.first, c.elements.first);
    });

    test('clipboard round trip creates new ids', () {
      final c = DrawingController(elements: [box()]);
      c.selectAll();
      final json = c.copySelectedJson();
      expect(json, isNotNull);
      expect(c.pasteJson(json!), isTrue);
      expect(c.elements.length, 2);
      expect(c.elements[1].id, isNot(c.elements[0].id));
    });

    test('pasteJson rejects garbage', () {
      final c = DrawingController();
      expect(c.pasteJson('not json'), isFalse);
      expect(c.elements, isEmpty);
    });

    test('cutSelectedJson removes the selection', () {
      final c = DrawingController(elements: [box()]);
      c.selectAll();
      expect(c.cutSelectedJson(), isNotNull);
      expect(c.elements, isEmpty);
    });

    test('loadScene preserves grid flag', () {
      final c = DrawingController();
      c.loadScene(const SceneData(elements: [], gridEnabled: true));
      expect(c.gridEnabled, isTrue);
    });
  });
}
