import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sketchit/models/element.dart';
import 'package:sketchit/models/scene.dart';

SketchElement rect({
  double x = 0,
  double y = 0,
  double w = 100,
  double h = 50,
  int? fill,
}) {
  return SketchElement.shape(
    type: ElementType.rectangle,
    rect: Rect.fromLTWH(x, y, w, h),
    fillColor: fill,
  );
}

void main() {
  group('hitTest', () {
    test('unfilled rect hits border only', () {
      final r = rect();
      expect(r.hitTest(const Offset(50, 0)), isTrue);
      expect(r.hitTest(const Offset(50, 25)), isFalse);
      expect(r.hitTest(const Offset(200, 200)), isFalse);
    });

    test('filled rect hits interior', () {
      final r = rect(fill: 0xffff0000);
      expect(r.hitTest(const Offset(50, 25)), isTrue);
    });

    test('ellipse ring and fill', () {
      final e = SketchElement.shape(
        type: ElementType.ellipse,
        rect: const Rect.fromLTWH(0, 0, 100, 100),
      );
      expect(e.hitTest(const Offset(99, 50)), isTrue);
      expect(e.hitTest(const Offset(50, 50)), isFalse);
      final filled = e.copyWith(fillColor: () => 0xffff0000);
      expect(filled.hitTest(const Offset(50, 50)), isTrue);
    });

    test('diamond vertices', () {
      final d = SketchElement.shape(
        type: ElementType.diamond,
        rect: const Rect.fromLTWH(0, 0, 100, 100),
      );
      expect(d.hitTest(const Offset(50, 2)), isTrue);
      expect(d.hitTest(const Offset(50, 50)), isFalse);
    });

    test('line hits along the segment', () {
      final l = SketchElement.path(
        type: ElementType.line,
        scenePoints: [Offset.zero, const Offset(100, 0)],
      );
      expect(l.hitTest(const Offset(50, 3)), isTrue);
      expect(l.hitTest(const Offset(50, 30)), isFalse);
    });

    test('rotation is respected', () {
      final r = rect(w: 100, h: 20).copyWith(angle: math.pi / 2);
      // Rotated 90 degrees: the long axis is now vertical.
      expect(r.hitTest(const Offset(50, 60)), isTrue);
      expect(r.hitTest(const Offset(50, -35)), isTrue);
      expect(r.hitTest(const Offset(80, 50)), isFalse);
      expect(r.hitTest(const Offset(50, -50)), isFalse);
    });
  });

  group('transforms', () {
    test('movedBy shifts position', () {
      final r = rect().movedBy(const Offset(10, -5));
      expect(r.x, 10);
      expect(r.y, -5);
    });

    test('resizedTo rescales path points', () {
      final l = SketchElement.path(
        type: ElementType.line,
        scenePoints: [Offset.zero, const Offset(100, 50)],
      );
      final scaled = l.resizedTo(const Rect.fromLTWH(0, 0, 200, 100));
      expect(scaled.points.last, const Offset(200, 100));
    });

    test('corners follow rotation', () {
      final r = rect(w: 10, h: 10).copyWith(angle: math.pi / 4);
      for (final c in r.corners) {
        expect((c - r.center).distance, closeTo(math.sqrt(50), 1e-9));
      }
    });
  });

  group('serialization', () {
    test('round trips every field', () {
      final e = SketchElement.path(
        type: ElementType.arrow,
        scenePoints: [Offset.zero, const Offset(30, 40)],
        strokeColor: 0xff00ff00,
        strokeWidth: 4,
        strokeStyle: StrokeStyle.dashed,
        roughness: RoughStyle.rough,
        opacity: 0.5,
      ).copyWith(angle: 0.3, fillColor: () => 0xff0000ff);
      final decoded = SketchElement.fromJson(e.toJson());
      expect(decoded, e);
    });

    test('scene encode/decode', () {
      final scene = SceneData(
        elements: [rect(), SketchElement.text(
          position: Offset.zero,
          text: 'hello',
          width: 40,
          height: 20,
        )],
        gridEnabled: true,
      );
      final decoded = SceneData.decode(scene.encode());
      expect(decoded.elements.length, 2);
      expect(decoded.elements.first, scene.elements.first);
      expect(decoded.gridEnabled, isTrue);
    });

    test('json is valid', () {
      final s = SceneData(elements: [rect()]).encode();
      expect(() => jsonDecode(s), returnsNormally);
    });
  });
}
