import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/element.dart';
import '../models/geometry.dart';
import 'rough.dart';

/// Paints the whole scene: grid, elements, in-progress draft, selection
/// chrome and the marquee rect. Drawn in scene coordinates; the parent
/// transform handles zoom/pan.
class SketchPainter extends CustomPainter {
  SketchPainter({
    required this.elements,
    required this.selectedIds,
    required this.zoom,
    this.draft,
    this.marquee,
    this.editingId,
    this.gridEnabled = false,
    this.accentColor = const Color(0xff6965db),
    this.handleColor = const Color(0xffffffff),
  });

  final List<SketchElement> elements;
  final Set<String> selectedIds;
  final double zoom;
  final SketchElement? draft;
  final Rect? marquee;

  /// Element currently edited inline; hidden so the overlay replaces it.
  final String? editingId;
  final bool gridEnabled;
  final Color accentColor;
  final Color handleColor;

  @override
  void paint(Canvas canvas, Size size) {
    final visible = _visibleSceneRect(canvas, size);
    if (gridEnabled) _paintGrid(canvas, visible);
    for (final e in elements) {
      if (e.id == editingId) continue;
      _paintElement(canvas, e);
    }
    if (draft != null) _paintElement(canvas, draft!);
    _paintSelection(canvas);
    _paintMarquee(canvas);
  }

  Rect _visibleSceneRect(Canvas canvas, Size size) {
    final transform = Matrix4.fromFloat64List(canvas.getTransform());
    final inv = Matrix4.tryInvert(transform);
    if (inv == null) return Rect.largest;
    final tl = MatrixUtils.transformPoint(inv, Offset.zero);
    final br = MatrixUtils.transformPoint(
        inv, Offset(size.width, size.height));
    return Rect.fromPoints(tl, br).inflate(50);
  }

  void _paintGrid(Canvas canvas, Rect visible) {
    var spacing = 32.0;
    while (spacing * zoom < 12) {
      spacing *= 4;
    }
    if (visible.width / spacing > 4000) return;
    final paint = Paint()
      ..color = const Color(0x33000000)
      ..strokeWidth = 1 / zoom;
    final points = <Offset>[];
    final startX = (visible.left / spacing).floor() * spacing;
    final startY = (visible.top / spacing).floor() * spacing;
    for (var x = startX; x <= visible.right; x += spacing) {
      for (var y = startY; y <= visible.bottom; y += spacing) {
        points.add(Offset(x, y));
      }
    }
    canvas.drawPoints(ui.PointMode.points, points, paint..strokeWidth = 2 / zoom);
  }

  void _paintElement(Canvas canvas, SketchElement e) {
    final strokeColor =
        Color(e.strokeColor).withValues(alpha: e.opacity.clamp(0, 1));
    canvas.save();
    final c = e.center;
    canvas.translate(c.dx, c.dy);
    canvas.rotate(e.angle);
    canvas.translate(-c.dx, -c.dy);

    if (e.type == ElementType.text) {
      _paintText(canvas, e, strokeColor);
      canvas.restore();
      return;
    }

    final localOrigin = Offset(e.x, e.y);
    canvas.save();
    canvas.translate(localOrigin.dx, localOrigin.dy);

    final passes = Rough.passes(e.roughness);
    final fill = e.fillColor;
    if (fill != null && e.supportsFill) {
      final fillPath = Rough.elementPath(e);
      canvas.drawPath(
        fillPath,
        Paint()
          ..color = Color(fill).withValues(alpha: e.opacity.clamp(0, 1))
          ..style = PaintingStyle.fill,
      );
    }

    final stroke = Paint()
      ..color = strokeColor
      ..strokeWidth = e.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = e.strokeStyle == StrokeStyle.dotted
          ? StrokeCap.round
          : StrokeCap.butt
      ..strokeJoin = StrokeJoin.round;

    for (var i = 0; i < passes; i++) {
      final path = Rough.styled(
        Rough.elementPath(e, seedOffset: i * 7919),
        e.strokeStyle,
        e.strokeWidth,
      );
      // Later passes get lighter so the sketch reads as one stroke.
      if (i > 0) {
        stroke.color = strokeColor.withValues(alpha: 0.45 * strokeColor.a);
      }
      canvas.drawPath(path, stroke);
    }

    if (e.type == ElementType.arrow && e.points.length >= 2) {
      _paintArrowHead(canvas, e, strokeColor);
    }
    canvas.restore();
    canvas.restore();
  }

  void _paintArrowHead(Canvas canvas, SketchElement e, Color color) {
    final pts = e.points;
    final tip = pts.last;
    // Direction from the previous segment.
    var dir = pts[pts.length - 1] - pts[pts.length - 2];
    if (dir.distance == 0) return;
    dir = dir / dir.distance;
    final len = math.max(12.0, e.strokeWidth * 5);
    const spread = 0.42;
    final base = tip - dir * len;
    final perp = Offset(-dir.dy, dir.dx);
    final left = base + perp * len * spread;
    final right = base - perp * len * spread;
    final amp = Rough.amplitude(e.roughness, e.strokeWidth);
    final paint = Paint()
      ..color = color
      ..strokeWidth = e.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final head = Path()
      ..addPath(Rough.line(left, tip, e.seed + 11, amp), Offset.zero)
      ..addPath(Rough.line(right, tip, e.seed + 23, amp), Offset.zero);
    canvas.drawPath(head, paint);
  }

  void _paintText(Canvas canvas, SketchElement e, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: e.text,
        style: TextStyle(
          color: color,
          fontSize: e.fontSize,
          height: 1.25,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: math.max(e.width, 1));
    tp.paint(canvas, Offset(e.x, e.y));
  }

  void _paintSelection(Canvas canvas) {
    if (selectedIds.isEmpty) return;
    final sel = elements.where((e) => selectedIds.contains(e.id));
    final outline = Paint()
      ..color = accentColor
      ..strokeWidth = 1.5 / zoom
      ..style = PaintingStyle.stroke;
    for (final e in sel) {
      final path = Path()..addPolygon(e.corners, true);
      canvas.drawPath(path, outline);
      if (sel.length == 1) _paintHandles(canvas, e);
    }
    if (sel.length > 1) {
      // Group bounding box.
      Rect? all;
      for (final e in sel) {
        all = all == null ? e.sceneBounds : all.expandToInclude(e.sceneBounds);
      }
      if (all != null) {
        canvas.drawRect(all, outline..strokeWidth = 1.5 / zoom);
      }
    }
  }

  void _paintHandles(Canvas canvas, SketchElement e) {
    final r = 4.0 / zoom;
    final fill = Paint()..color = handleColor;
    final edge = Paint()
      ..color = accentColor
      ..strokeWidth = 1.5 / zoom
      ..style = PaintingStyle.stroke;
    for (final c in e.corners) {
      canvas.drawCircle(c, r, fill);
      canvas.drawCircle(c, r, edge);
    }
    final b = e.bounds;
    final mid = [
      rotatePoint(Offset(b.center.dx, b.top), e.center, e.angle),
      rotatePoint(Offset(b.right, b.center.dy), e.center, e.angle),
      rotatePoint(Offset(b.center.dx, b.bottom), e.center, e.angle),
      rotatePoint(Offset(b.left, b.center.dy), e.center, e.angle),
    ];
    for (final c in mid) {
      canvas.drawCircle(c, r, fill);
      canvas.drawCircle(c, r, edge);
    }
    // Rotation handle floating above the top edge midpoint.
    final topMid = mid[0];
    final up = rotatePoint(
        Offset(0, -24 / zoom), Offset.zero, e.angle);
    final rotHandle = topMid + up;
    canvas.drawLine(topMid, rotHandle, edge);
    canvas.drawCircle(rotHandle, r, fill);
    canvas.drawCircle(rotHandle, r, edge);
  }

  void _paintMarquee(Canvas canvas) {
    final m = marquee;
    if (m == null) return;
    canvas.drawRect(
      m,
      Paint()
        ..color = accentColor.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      m,
      Paint()
        ..color = accentColor
        ..strokeWidth = 1 / zoom
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(SketchPainter old) => true;
}
