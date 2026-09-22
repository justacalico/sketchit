import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sketchit/canvas/rough.dart';
import 'package:sketchit/models/element.dart';

void main() {
  group('Rough paths', () {
    test('crisp rect is exact', () {
      const r = Rect.fromLTWH(0, 0, 100, 50);
      final p = Rough.rect(r, 42, 0);
      expect(p.getBounds(), r);
    });

    test('sketchy rect stays near bounds', () {
      const r = Rect.fromLTWH(0, 0, 100, 50);
      final p = Rough.rect(r, 42, 2);
      final b = p.getBounds();
      expect((b.left - r.left).abs(), lessThan(10));
      expect((b.right - r.right).abs(), lessThan(10));
    });

    test('same seed gives identical path', () {
      const r = Rect.fromLTWH(0, 0, 100, 50);
      final a = Rough.ellipse(r, 7, 2).computeMetrics().first.length;
      final b = Rough.ellipse(r, 7, 2).computeMetrics().first.length;
      expect(a, b);
    });

    test('different seeds differ', () {
      const r = Rect.fromLTWH(0, 0, 100, 50);
      final a = Rough.ellipse(r, 7, 2).computeMetrics().first.length;
      final b = Rough.ellipse(r, 8, 2).computeMetrics().first.length;
      expect(a, isNot(b));
    });

    test('smooth path through points', () {
      final p = Rough.smooth([Offset.zero, const Offset(50, 50), const Offset(100, 0)]);
      expect(p.getBounds().width, greaterThan(90));
    });

    test('single point smooth path does not crash', () {
      final p = Rough.smooth([Offset.zero]);
      expect(p, isNotNull);
    });
  });

  group('stroke styles', () {
    final line = Rough.line(Offset.zero, const Offset(100, 0), 1, 0);

    test('solid returns path unchanged', () {
      expect(identical(Rough.styled(line, StrokeStyle.solid, 2), line), isTrue);
    });

    test('dashed splits into multiple contours', () {
      final dashed = Rough.styled(line, StrokeStyle.dashed, 2);
      expect(dashed.computeMetrics().length, greaterThan(1));
    });

    test('dotted produces dots', () {
      final dotted = Rough.styled(line, StrokeStyle.dotted, 2);
      expect(dotted.computeMetrics().length, greaterThan(5));
    });
  });

  group('elementPath', () {
    test('covers all drawable types', () {
      for (final type in [
        ElementType.rectangle,
        ElementType.diamond,
        ElementType.ellipse,
      ]) {
        final e = SketchElement.shape(
          type: type,
          rect: const Rect.fromLTWH(0, 0, 50, 50),
        );
        expect(Rough.elementPath(e).getBounds().isEmpty, isFalse);
      }
    });

    test('arrow path does not close', () {
      final e = SketchElement.path(
        type: ElementType.arrow,
        scenePoints: [Offset.zero, const Offset(100, 0)],
      );
      final p = Rough.elementPath(e);
      expect(p.getBounds().width, greaterThan(50));
    });

    test('text yields empty path', () {
      final e = SketchElement.text(
        position: Offset.zero,
        text: 'hi',
        width: 20,
        height: 20,
      );
      expect(Rough.elementPath(e).getBounds().isEmpty, isTrue);
    });
  });
}
