import 'dart:math' as math;
import 'dart:ui';

import '../models/element.dart';

/// Deterministic jittered geometry that gives strokes a hand-drawn feel.
/// Every path is a pure function of its inputs plus [seed], so a shape
/// never wiggles between frames.
class Rough {
  Rough._();

  static double amplitude(RoughStyle style, double strokeWidth) {
    return switch (style) {
      RoughStyle.crisp => 0,
      RoughStyle.sketch => 0.9 + strokeWidth * 0.15,
      RoughStyle.rough => 1.8 + strokeWidth * 0.3,
    };
  }

  /// How many offset passes to draw. Extra passes are what make strokes
  /// look sketched rather than drawn with a ruler.
  static int passes(RoughStyle style) => switch (style) {
        RoughStyle.crisp => 1,
        RoughStyle.sketch => 2,
        RoughStyle.rough => 2,
      };

  static Offset _jitter(math.Random r, double amp) =>
      Offset((r.nextDouble() - 0.5) * 2 * amp, (r.nextDouble() - 0.5) * 2 * amp);

  /// A line subdivided and nudged sideways so it wobbles slightly.
  static Path line(Offset a, Offset b, int seed, double amp) {
    final path = Path()..moveTo(a.dx, a.dy);
    if (amp == 0) {
      path.lineTo(b.dx, b.dy);
      return path;
    }
    final r = math.Random(seed);
    final len = (b - a).distance;
    final steps = math.max(2, (len / 60).round());
    for (var i = 1; i < steps; i++) {
      final t = i / steps;
      path.lineTo(
        a.dx + (b.dx - a.dx) * t + _jitter(r, amp).dx,
        a.dy + (b.dy - a.dy) * t + _jitter(r, amp).dy,
      );
    }
    path.lineTo(b.dx, b.dy);
    return path;
  }

  static Path rect(Rect bounds, int seed, double amp) {
    if (amp == 0) return Path()..addRect(bounds);
    final path = Path();
    final corners = [
      bounds.topLeft,
      bounds.topRight,
      bounds.bottomRight,
      bounds.bottomLeft,
    ];
    for (var i = 0; i < 4; i++) {
      path.addPath(
          line(corners[i], corners[(i + 1) % 4], seed + i * 31, amp),
          Offset.zero);
    }
    return path;
  }

  static Path polygon(List<Offset> vertices, int seed, double amp,
      {bool close = true}) {
    final path = Path();
    for (var i = 0; i + 1 < vertices.length; i++) {
      path.addPath(
          line(vertices[i], vertices[i + 1], seed + i * 31, amp), Offset.zero);
    }
    if (close && vertices.length > 1) {
      path.addPath(
          line(vertices.last, vertices.first, seed + 999, amp), Offset.zero);
    }
    return path;
  }

  static Path ellipse(Rect bounds, int seed, double amp) {
    final r = math.Random(seed);
    const n = 28;
    final cx = bounds.center.dx;
    final cy = bounds.center.dy;
    final rx = bounds.width / 2;
    final ry = bounds.height / 2;
    final pts = <Offset>[];
    for (var i = 0; i < n; i++) {
      final t = i / n * 2 * math.pi;
      final wobble = amp == 0 ? 0 : (r.nextDouble() - 0.5) * 2 * amp;
      pts.add(Offset(
        cx + (rx + wobble) * math.cos(t),
        cy + (ry + wobble) * math.sin(t),
      ));
    }
    return smoothClosed(pts);
  }

  /// Catmull-Rom spline through [pts], used for pencil strokes.
  static Path smooth(List<Offset> pts) {
    final path = Path();
    if (pts.isEmpty) return path;
    path.moveTo(pts.first.dx, pts.first.dy);
    if (pts.length == 1) {
      path.lineTo(pts.first.dx + 0.01, pts.first.dy);
      return path;
    }
    if (pts.length == 2) {
      path.lineTo(pts[1].dx, pts[1].dy);
      return path;
    }
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = i == 0 ? pts[i] : pts[i - 1];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 >= pts.length ? p2 : pts[i + 2];
      final c1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final c2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  /// Smooth closed loop, used by the ellipse approximation.
  static Path smoothClosed(List<Offset> pts) {
    final path = Path();
    if (pts.length < 3) return path;
    path.moveTo(pts.first.dx, pts.first.dy);
    final n = pts.length;
    for (var i = 0; i < n; i++) {
      final p0 = pts[(i - 1 + n) % n];
      final p1 = pts[i];
      final p2 = pts[(i + 1) % n];
      final p3 = pts[(i + 2) % n];
      path.cubicTo(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
        p2.dx,
        p2.dy,
      );
    }
    path.close();
    return path;
  }

  /// Path for a whole element in its local frame (origin at bounds top-left).
  static Path elementPath(SketchElement e, {int seedOffset = 0}) {
    final amp = amplitude(e.roughness, e.strokeWidth);
    final seed = e.seed + seedOffset;
    final b = Offset.zero & Size(e.width, e.height);
    return switch (e.type) {
      ElementType.rectangle => rect(b, seed, amp),
      ElementType.diamond => polygon([
          Offset(b.center.dx, b.top),
          Offset(b.right, b.center.dy),
          Offset(b.center.dx, b.bottom),
          Offset(b.left, b.center.dy),
        ], seed, amp),
      ElementType.ellipse => ellipse(b, seed, amp),
      ElementType.line ||
      ElementType.arrow =>
        polygon(e.points, seed, amp, close: false),
      ElementType.freedraw => smooth(e.points),
      ElementType.text => Path(),
    };
  }

  /// Converts [path] into a dashed or dotted version.
  static Path styled(Path path, StrokeStyle style, double strokeWidth) {
    if (style == StrokeStyle.solid) return path;
    final (dash, gap) = switch (style) {
      StrokeStyle.dashed => (strokeWidth * 4, strokeWidth * 3),
      StrokeStyle.dotted => (0.1, strokeWidth * 2.5),
      StrokeStyle.solid => (0.0, 0.0),
    };
    final out = Path();
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final next = math.min(dist + dash, metric.length);
        out.addPath(metric.extractPath(dist, next), Offset.zero);
        dist = next + gap;
      }
    }
    if (style == StrokeStyle.dotted) {
      // Round caps make the zero-length dashes render as dots.
      return out;
    }
    return out;
  }
}
