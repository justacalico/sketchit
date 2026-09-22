import 'dart:math' as math;
import 'dart:ui';

double distToSegment(Offset p, Offset a, Offset b) {
  final dx = b.dx - a.dx;
  final dy = b.dy - a.dy;
  final lenSq = dx * dx + dy * dy;
  if (lenSq == 0) return (p - a).distance;
  var t = ((p.dx - a.dx) * dx + (p.dy - a.dy) * dy) / lenSq;
  t = t.clamp(0.0, 1.0);
  return (p - Offset(a.dx + t * dx, a.dy + t * dy)).distance;
}

Offset rotatePoint(Offset p, Offset center, double angle) {
  if (angle == 0) return p;
  final s = math.sin(angle);
  final c = math.cos(angle);
  final dx = p.dx - center.dx;
  final dy = p.dy - center.dy;
  return Offset(center.dx + dx * c - dy * s, center.dy + dx * s + dy * c);
}

bool pointInPolygon(Offset p, List<Offset> vertices) {
  var inside = false;
  for (var i = 0, j = vertices.length - 1; i < vertices.length; j = i++) {
    final a = vertices[i];
    final b = vertices[j];
    if ((a.dy > p.dy) != (b.dy > p.dy) &&
        p.dx < (b.dx - a.dx) * (p.dy - a.dy) / (b.dy - a.dy) + a.dx) {
      inside = !inside;
    }
  }
  return inside;
}

Rect rectFromPoints(Iterable<Offset> points) {
  var minX = double.infinity;
  var minY = double.infinity;
  var maxX = double.negativeInfinity;
  var maxY = double.negativeInfinity;
  for (final p in points) {
    if (p.dx < minX) minX = p.dx;
    if (p.dy < minY) minY = p.dy;
    if (p.dx > maxX) maxX = p.dx;
    if (p.dy > maxY) maxY = p.dy;
  }
  if (minX > maxX) return Rect.zero;
  return Rect.fromLTRB(minX, minY, maxX, maxY);
}

/// Smallest rect that contains a rotated rect in scene space.
Rect rotatedBounds(Rect rect, double angle) {
  if (angle == 0) return rect;
  final c = rect.center;
  return rectFromPoints([
    rotatePoint(rect.topLeft, c, angle),
    rotatePoint(rect.topRight, c, angle),
    rotatePoint(rect.bottomLeft, c, angle),
    rotatePoint(rect.bottomRight, c, angle),
  ]);
}
