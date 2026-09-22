import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sketchit/models/geometry.dart';

void main() {
  group('distToSegment', () {
    test('perpendicular distance', () {
      expect(
        distToSegment(const Offset(5, 5), Offset.zero, const Offset(10, 0)),
        5,
      );
    });

    test('clamps to segment ends', () {
      expect(
        distToSegment(const Offset(-3, 4), Offset.zero, const Offset(10, 0)),
        5,
      );
    });

    test('zero-length segment', () {
      expect(
        distToSegment(const Offset(3, 4), Offset.zero, Offset.zero),
        5,
      );
    });
  });

  group('rotatePoint', () {
    test('zero angle is identity', () {
      const p = Offset(3, 4);
      expect(rotatePoint(p, Offset.zero, 0), p);
    });

    test('quarter turn around origin', () {
      final r = rotatePoint(const Offset(1, 0), Offset.zero, math.pi / 2);
      expect(r.dx, closeTo(0, 1e-9));
      expect(r.dy, closeTo(1, 1e-9));
    });

    test('rotation about a center', () {
      final r =
          rotatePoint(const Offset(2, 1), const Offset(1, 1), math.pi);
      expect(r.dx, closeTo(0, 1e-9));
      expect(r.dy, closeTo(1, 1e-9));
    });
  });

  group('pointInPolygon', () {
    final square = [
      Offset.zero,
      const Offset(10, 0),
      const Offset(10, 10),
      const Offset(0, 10),
    ];

    test('inside', () {
      expect(pointInPolygon(const Offset(5, 5), square), isTrue);
    });

    test('outside', () {
      expect(pointInPolygon(const Offset(15, 5), square), isFalse);
    });
  });

  group('rectFromPoints', () {
    test('bounding box', () {
      final r = rectFromPoints([
        const Offset(3, 7),
        const Offset(-2, 1),
        const Offset(8, -4),
      ]);
      expect(r, const Rect.fromLTRB(-2, -4, 8, 7));
    });

    test('empty list', () {
      expect(rectFromPoints(const []), Rect.zero);
    });
  });

  group('rotatedBounds', () {
    test('unrotated rect unchanged', () {
      const r = Rect.fromLTWH(0, 0, 10, 4);
      expect(rotatedBounds(r, 0), r);
    });

    test('square rotated 45 degrees grows bounds', () {
      const r = Rect.fromLTWH(-5, -5, 10, 10);
      final b = rotatedBounds(r, math.pi / 4);
      expect(b.width, closeTo(10 * math.sqrt2, 1e-9));
    });
  });
}
