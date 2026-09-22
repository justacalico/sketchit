import 'dart:math' as math;
import 'dart:ui';

import 'geometry.dart';

enum ElementType { rectangle, diamond, ellipse, line, arrow, freedraw, text }

enum StrokeStyle { solid, dashed, dotted }

/// How hand-drawn an element looks.
enum RoughStyle { crisp, sketch, rough }

int _idCounter = 0;

String nextElementId() {
  _idCounter++;
  return '${DateTime.now().microsecondsSinceEpoch}_$_idCounter';
}

int _seedCounter = 0;

int nextSeed() {
  _seedCounter++;
  return (_seedCounter * 2654435761) & 0x7fffffff;
}

class SketchElement {
  SketchElement({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.angle = 0,
    this.strokeColor = 0xff1e1e1e,
    this.fillColor,
    this.strokeWidth = 2,
    this.strokeStyle = StrokeStyle.solid,
    this.roughness = RoughStyle.sketch,
    this.opacity = 1,
    int? seed,
    List<Offset>? points,
    this.text = '',
    this.fontSize = 20,
  })  : seed = seed ?? nextSeed(),
        points = points ?? const [];

  factory SketchElement.shape({
    required ElementType type,
    required Rect rect,
    int strokeColor = 0xff1e1e1e,
    int? fillColor,
    double strokeWidth = 2,
    StrokeStyle strokeStyle = StrokeStyle.solid,
    RoughStyle roughness = RoughStyle.sketch,
    double opacity = 1,
  }) {
    return SketchElement(
      id: nextElementId(),
      type: type,
      x: rect.left,
      y: rect.top,
      width: rect.width,
      height: rect.height,
      strokeColor: strokeColor,
      fillColor: fillColor,
      strokeWidth: strokeWidth,
      strokeStyle: strokeStyle,
      roughness: roughness,
      opacity: opacity,
    );
  }

  /// Line, arrow and freedraw elements store [points] relative to x/y.
  factory SketchElement.path({
    required ElementType type,
    required List<Offset> scenePoints,
    int strokeColor = 0xff1e1e1e,
    double strokeWidth = 2,
    StrokeStyle strokeStyle = StrokeStyle.solid,
    RoughStyle roughness = RoughStyle.sketch,
    double opacity = 1,
  }) {
    final bounds = rectFromPoints(scenePoints);
    final rel = scenePoints
        .map((p) => Offset(p.dx - bounds.left, p.dy - bounds.top))
        .toList();
    return SketchElement(
      id: nextElementId(),
      type: type,
      x: bounds.left,
      y: bounds.top,
      width: bounds.width,
      height: bounds.height,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      strokeStyle: strokeStyle,
      roughness: roughness,
      opacity: opacity,
      points: rel,
    );
  }

  factory SketchElement.text({
    required Offset position,
    required String text,
    required double width,
    required double height,
    int strokeColor = 0xff1e1e1e,
    double fontSize = 20,
    double opacity = 1,
  }) {
    return SketchElement(
      id: nextElementId(),
      type: ElementType.text,
      x: position.dx,
      y: position.dy,
      width: width,
      height: height,
      strokeColor: strokeColor,
      opacity: opacity,
      text: text,
      fontSize: fontSize,
      roughness: RoughStyle.crisp,
    );
  }

  factory SketchElement.fromJson(Map<String, dynamic> json) {
    final pts = (json['points'] as List?)
            ?.map((p) => Offset(
                  (p[0] as num).toDouble(),
                  (p[1] as num).toDouble(),
                ))
            .toList() ??
        const <Offset>[];
    return SketchElement(
      id: json['id'] as String,
      type: ElementType.values.byName(json['type'] as String),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      angle: (json['angle'] as num?)?.toDouble() ?? 0,
      strokeColor: (json['strokeColor'] as num?)?.toInt() ?? 0xff1e1e1e,
      fillColor: (json['fillColor'] as num?)?.toInt(),
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 2,
      strokeStyle: StrokeStyle.values
          .byName(json['strokeStyle'] as String? ?? 'solid'),
      roughness:
          RoughStyle.values.byName(json['roughness'] as String? ?? 'sketch'),
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
      seed: (json['seed'] as num?)?.toInt(),
      points: pts,
      text: json['text'] as String? ?? '',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 20,
    );
  }

  final String id;
  final ElementType type;
  final double x;
  final double y;
  final double width;
  final double height;
  final double angle;
  final int strokeColor;
  final int? fillColor;
  final double strokeWidth;
  final StrokeStyle strokeStyle;
  final RoughStyle roughness;
  final double opacity;
  final int seed;
  final List<Offset> points;
  final String text;
  final double fontSize;

  bool get isLinear =>
      type == ElementType.line ||
      type == ElementType.arrow ||
      type == ElementType.freedraw;

  bool get supportsFill =>
      type == ElementType.rectangle ||
      type == ElementType.diamond ||
      type == ElementType.ellipse;

  Rect get bounds => Rect.fromLTWH(x, y, width, height);

  Offset get center => bounds.center;

  /// Axis-aligned bounds after rotation, in scene space.
  Rect get sceneBounds => rotatedBounds(bounds, angle);

  List<Offset> get scenePoints =>
      points.map((p) => Offset(x + p.dx, y + p.dy)).toList();

  /// Corners of the (possibly rotated) bounds, clockwise from top-left.
  List<Offset> get corners {
    final b = bounds;
    final c = b.center;
    return [
      rotatePoint(b.topLeft, c, angle),
      rotatePoint(b.topRight, c, angle),
      rotatePoint(b.bottomRight, c, angle),
      rotatePoint(b.bottomLeft, c, angle),
    ];
  }

  SketchElement copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? angle,
    int? strokeColor,
    int? Function()? fillColor,
    double? strokeWidth,
    StrokeStyle? strokeStyle,
    RoughStyle? roughness,
    double? opacity,
    int? seed,
    List<Offset>? points,
    String? text,
    double? fontSize,
  }) {
    return SketchElement(
      id: id,
      type: type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      angle: angle ?? this.angle,
      strokeColor: strokeColor ?? this.strokeColor,
      fillColor: fillColor != null ? fillColor() : this.fillColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeStyle: strokeStyle ?? this.strokeStyle,
      roughness: roughness ?? this.roughness,
      opacity: opacity ?? this.opacity,
      seed: seed ?? this.seed,
      points: points ?? this.points,
      text: text ?? this.text,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  SketchElement movedBy(Offset delta) =>
      copyWith(x: x + delta.dx, y: y + delta.dy);

  /// Returns a copy fitted into [newBounds]. Path points are rescaled.
  SketchElement resizedTo(Rect newBounds) {
    if (isLinear && points.isNotEmpty && width > 0 && height > 0) {
      final sx = width == 0 ? 1.0 : newBounds.width / width;
      final sy = height == 0 ? 1.0 : newBounds.height / height;
      final scaled = points
          .map((p) => Offset(p.dx * sx, p.dy * sy))
          .toList();
      return copyWith(
        x: newBounds.left,
        y: newBounds.top,
        width: newBounds.width,
        height: newBounds.height,
        points: scaled,
      );
    }
    if (isLinear && points.isNotEmpty) {
      // Degenerate zero-area bounds: keep the line usable by translating only.
      final scaled = points
          .map((p) => Offset(
                p.dx * (width == 0 ? 1.0 : newBounds.width / width),
                p.dy * (height == 0 ? 1.0 : newBounds.height / height),
              ))
          .toList();
      return copyWith(
        x: newBounds.left,
        y: newBounds.top,
        width: newBounds.width,
        height: newBounds.height,
        points: scaled,
      );
    }
    return copyWith(
      x: newBounds.left,
      y: newBounds.top,
      width: newBounds.width,
      height: newBounds.height,
    );
  }

  /// Whether [scenePoint] lands on this element. [tolerance] is in scene units.
  bool hitTest(Offset scenePoint, {double tolerance = 6}) {
    final local = rotatePoint(scenePoint, center, -angle);
    switch (type) {
      case ElementType.text:
        return bounds.inflate(tolerance).contains(local);
      case ElementType.rectangle:
        return _hitShape(bounds, local, tolerance, (r, p) => r.contains(p));
      case ElementType.diamond:
        final b = bounds;
        final poly = [
          Offset(b.center.dx, b.top),
          Offset(b.right, b.center.dy),
          Offset(b.center.dx, b.bottom),
          Offset(b.left, b.center.dy),
        ];
        if (fillColor != null && pointInPolygon(local, poly)) return true;
        for (var i = 0; i < 4; i++) {
          if (distToSegment(local, poly[i], poly[(i + 1) % 4]) <=
              tolerance + strokeWidth / 2) {
            return true;
          }
        }
        return false;
      case ElementType.ellipse:
        final b = bounds;
        if (b.width == 0 || b.height == 0) return false;
        final nx = (local.dx - b.center.dx) / (b.width / 2);
        final ny = (local.dy - b.center.dy) / (b.height / 2);
        final d = math.sqrt(nx * nx + ny * ny);
        if (fillColor != null && d <= 1) return true;
        // Ring hit: compare against a normalized stroke threshold.
        final ringTol = (tolerance + strokeWidth / 2) /
            math.max(1, math.min(b.width, b.height) / 2);
        return (d - 1).abs() <= ringTol;
      case ElementType.line:
      case ElementType.arrow:
      case ElementType.freedraw:
        final sp = scenePoints
            .map((p) => rotatePoint(p, center, -angle))
            .toList();
        for (var i = 0; i + 1 < sp.length; i++) {
          if (distToSegment(local, sp[i], sp[i + 1]) <=
              tolerance + strokeWidth / 2) {
            return true;
          }
        }
        return sp.length == 1 &&
            (local - sp.first).distance <= tolerance + strokeWidth / 2;
    }
  }

  bool _hitShape(
    Rect b,
    Offset p,
    double tolerance,
    bool Function(Rect, Offset) contains,
  ) {
    if (fillColor != null && contains(b, p)) return true;
    final t = tolerance + strokeWidth / 2;
    final nearEdge = (p.dx - b.left).abs() <= t ||
        (p.dx - b.right).abs() <= t ||
        (p.dy - b.top).abs() <= t ||
        (p.dy - b.bottom).abs() <= t;
    return nearEdge && b.inflate(t).contains(p);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'angle': angle,
      'strokeColor': strokeColor,
      'fillColor': fillColor,
      'strokeWidth': strokeWidth,
      'strokeStyle': strokeStyle.name,
      'roughness': roughness.name,
      'opacity': opacity,
      'seed': seed,
      'points': points.map((p) => [p.dx, p.dy]).toList(),
      'text': text,
      'fontSize': fontSize,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is SketchElement &&
      other.id == id &&
      other.type == type &&
      other.x == x &&
      other.y == y &&
      other.width == width &&
      other.height == height &&
      other.angle == angle &&
      other.strokeColor == strokeColor &&
      other.fillColor == fillColor &&
      other.strokeWidth == strokeWidth &&
      other.strokeStyle == strokeStyle &&
      other.roughness == roughness &&
      other.opacity == opacity &&
      other.seed == seed &&
      other.text == text &&
      other.fontSize == fontSize &&
      _pointsEqual(other.points, points);

  static bool _pointsEqual(List<Offset> a, List<Offset> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        id, type, x, y, width, height, angle, strokeColor, fillColor,
        strokeWidth, strokeStyle, roughness, opacity, seed, text, fontSize,
        Object.hashAll(points),
      );
}
