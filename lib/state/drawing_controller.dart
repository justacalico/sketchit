import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../models/element.dart';
import '../models/geometry.dart';
import '../models/scene.dart';

enum SketchTool {
  select,
  hand,
  rectangle,
  diamond,
  ellipse,
  arrow,
  line,
  pencil,
  text,
  eraser,
}

/// Which grab point of the selection box a pointer is on.
enum GrabHandle { none, nw, n, ne, e, se, s, sw, w, rotate }

/// Style applied to newly drawn elements and editable on a selection.
class ElementStyle {
  const ElementStyle({
    this.strokeColor = 0xff1e1e1e,
    this.fillColor,
    this.strokeWidth = 2,
    this.strokeStyle = StrokeStyle.solid,
    this.roughness = RoughStyle.sketch,
    this.opacity = 1,
    this.fontSize = 20,
  });

  final int strokeColor;
  final int? fillColor;
  final double strokeWidth;
  final StrokeStyle strokeStyle;
  final RoughStyle roughness;
  final double opacity;
  final double fontSize;

  ElementStyle copyWith({
    int? strokeColor,
    int? Function()? fillColor,
    double? strokeWidth,
    StrokeStyle? strokeStyle,
    RoughStyle? roughness,
    double? opacity,
    double? fontSize,
  }) {
    return ElementStyle(
      strokeColor: strokeColor ?? this.strokeColor,
      fillColor: fillColor != null ? fillColor() : this.fillColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeStyle: strokeStyle ?? this.strokeStyle,
      roughness: roughness ?? this.roughness,
      opacity: opacity ?? this.opacity,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

class DrawingController extends ChangeNotifier {
  DrawingController({List<SketchElement>? elements})
      : _elements = List.of(elements ?? const []);

  List<SketchElement> _elements;
  final Set<String> _selectedIds = {};
  final List<List<SketchElement>> _undoStack = [];
  final List<List<SketchElement>> _redoStack = [];
  List<SketchElement>? _gestureSnapshot;

  SketchTool _tool = SketchTool.select;
  ElementStyle _style = const ElementStyle();
  SketchElement? _draft;
  Rect? _marquee;
  String? _editingTextId;

  double _zoom = 1;
  Offset _pan = Offset.zero;
  bool _gridEnabled = false;

  static const double minZoom = 0.1;
  static const double maxZoom = 8;
  static const int maxUndoDepth = 200;

  List<SketchElement> get elements => List.unmodifiable(_elements);
  Set<String> get selectedIds => Set.unmodifiable(_selectedIds);
  SketchTool get tool => _tool;
  ElementStyle get style => _style;
  SketchElement? get draft => _draft;
  Rect? get marquee => _marquee;
  String? get editingTextId => _editingTextId;
  double get zoom => _zoom;
  Offset get pan => _pan;
  bool get gridEnabled => _gridEnabled;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  bool get hasSelection => _selectedIds.isNotEmpty;

  List<SketchElement> get selectedElements =>
      _elements.where((e) => _selectedIds.contains(e.id)).toList();

  Rect? get selectionBounds {
    if (_selectedIds.isEmpty) return null;
    Rect? result;
    for (final e in selectedElements) {
      final b = e.sceneBounds;
      result = result == null ? b : result.expandToInclude(b);
    }
    return result;
  }

  // ---- viewport ----

  Offset toScene(Offset screen) => (screen - _pan) / _zoom;
  Offset toScreen(Offset scene) => scene * _zoom + _pan;

  void panBy(Offset screenDelta) {
    _pan += screenDelta;
    notifyListeners();
  }

  void zoomAt(Offset screenFocal, double factor) {
    final next = (_zoom * factor).clamp(minZoom, maxZoom);
    final sceneFocal = toScene(screenFocal);
    _zoom = next;
    _pan = screenFocal - sceneFocal * _zoom;
    notifyListeners();
  }

  void resetZoom(Size viewSize) {
    _zoom = 1;
    final b = selectionBounds ?? _contentBounds();
    _pan = b == null
        ? Offset.zero
        : viewSize.center(Offset.zero) - b.center * _zoom;
    notifyListeners();
  }

  void zoomToFit(Size viewSize, {double padding = 60}) {
    final b = _contentBounds();
    if (b == null) {
      _zoom = 1;
      _pan = Offset.zero;
      notifyListeners();
      return;
    }
    final w = math.max(b.width, 1);
    final h = math.max(b.height, 1);
    final zx = (viewSize.width - padding * 2) / w;
    final zy = (viewSize.height - padding * 2) / h;
    _zoom = math.min(zx, zy).clamp(minZoom, maxZoom);
    _pan = viewSize.center(Offset.zero) - b.center * _zoom;
    notifyListeners();
  }

  Rect? _contentBounds() {
    if (_elements.isEmpty) return null;
    Rect? result;
    for (final e in _elements) {
      final b = e.sceneBounds;
      result = result == null ? b : result.expandToInclude(b);
    }
    return result;
  }

  // ---- tools and style ----

  void setTool(SketchTool tool) {
    if (_tool == tool) return;
    _tool = tool;
    _draft = null;
    _marquee = null;
    _editingTextId = null;
    notifyListeners();
  }

  void setStyle(ElementStyle style, {bool applyToSelection = true}) {
    _style = style;
    if (applyToSelection && _selectedIds.isNotEmpty) {
      _commit();
      _mutateSelected((e) => e.copyWith(
            strokeColor: style.strokeColor,
            fillColor: () => style.fillColor,
            strokeWidth: style.strokeWidth,
            strokeStyle: style.strokeStyle,
            roughness: style.roughness,
            opacity: style.opacity,
          ));
    }
    notifyListeners();
  }

  /// Reads the style off the current selection into [style] so the panel
  /// reflects what is selected.
  void syncStyleFromSelection() {
    final sel = selectedElements;
    if (sel.isEmpty) return;
    final e = sel.first;
    _style = ElementStyle(
      strokeColor: e.strokeColor,
      fillColor: e.fillColor,
      strokeWidth: e.strokeWidth,
      strokeStyle: e.strokeStyle,
      roughness: e.roughness,
      opacity: e.opacity,
      fontSize: e.fontSize,
    );
    notifyListeners();
  }

  // ---- element mutation ----

  void _commit() {
    _undoStack.add(List.of(_elements));
    if (_undoStack.length > maxUndoDepth) _undoStack.removeAt(0);
    _redoStack.clear();
  }

  void _mutateSelected(SketchElement Function(SketchElement) fn) {
    _elements = [
      for (final e in _elements) _selectedIds.contains(e.id) ? fn(e) : e,
    ];
  }

  /// Call at the start of a drag so the whole gesture counts as one undo step.
  void beginGesture() {
    _gestureSnapshot = List.of(_elements);
  }

  void endGesture() {
    final snapshot = _gestureSnapshot;
    _gestureSnapshot = null;
    if (snapshot == null) return;
    if (!_sameElements(snapshot, _elements)) {
      _undoStack.add(snapshot);
      if (_undoStack.length > maxUndoDepth) _undoStack.removeAt(0);
      _redoStack.clear();
      notifyListeners();
    }
  }

  static bool _sameElements(List<SketchElement> a, List<SketchElement> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(List.of(_elements));
    _elements = _undoStack.removeLast();
    _selectedIds.removeWhere(
        (id) => !_elements.any((e) => e.id == id));
    _draft = null;
    notifyListeners();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(List.of(_elements));
    _elements = _redoStack.removeLast();
    _selectedIds.removeWhere(
        (id) => !_elements.any((e) => e.id == id));
    _draft = null;
    notifyListeners();
  }

  // ---- drawing ----

  void setDraft(SketchElement? element) {
    _draft = element;
    notifyListeners();
  }

  void commitDraft() {
    final d = _draft;
    _draft = null;
    if (d == null) return;
    _commit();
    _elements = [..._elements, d];
    _selectedIds
      ..clear()
      ..add(d.id);
    notifyListeners();
  }

  SketchElement makeShape(Offset start, Offset current) {
    final rect = Rect.fromPoints(start, current);
    final type = switch (_tool) {
      SketchTool.rectangle => ElementType.rectangle,
      SketchTool.diamond => ElementType.diamond,
      SketchTool.ellipse => ElementType.ellipse,
      _ => ElementType.rectangle,
    };
    return SketchElement.shape(
      type: type,
      rect: rect,
      strokeColor: _style.strokeColor,
      fillColor: _style.fillColor,
      strokeWidth: _style.strokeWidth,
      strokeStyle: _style.strokeStyle,
      roughness: _style.roughness,
      opacity: _style.opacity,
    );
  }

  SketchElement makePath(Offset start, Offset current) {
    final type =
        _tool == SketchTool.arrow ? ElementType.arrow : ElementType.line;
    return SketchElement.path(
      type: type,
      scenePoints: [start, current],
      strokeColor: _style.strokeColor,
      strokeWidth: _style.strokeWidth,
      strokeStyle: _style.strokeStyle,
      roughness: _style.roughness,
      opacity: _style.opacity,
    );
  }

  SketchElement makeFreedraw(List<Offset> scenePoints) {
    return SketchElement.path(
      type: ElementType.freedraw,
      scenePoints: scenePoints,
      strokeColor: _style.strokeColor,
      strokeWidth: _style.strokeWidth,
      strokeStyle: _style.strokeStyle,
      roughness: _style.roughness,
      opacity: _style.opacity,
    );
  }

  SketchElement addText(Offset position, String text, double width,
      [double? height]) {
    final el = SketchElement.text(
      position: position,
      text: text,
      width: width,
      height: height ?? _style.fontSize * 1.4,
      strokeColor: _style.strokeColor,
      fontSize: _style.fontSize,
      opacity: _style.opacity,
    );
    _commit();
    _elements = [..._elements, el];
    _selectedIds
      ..clear()
      ..add(el.id);
    notifyListeners();
    return el;
  }

  // ---- selection ----

  SketchElement? topMostAt(Offset scenePoint) {
    for (var i = _elements.length - 1; i >= 0; i--) {
      if (_elements[i].hitTest(scenePoint, tolerance: 6 / _zoom)) {
        return _elements[i];
      }
    }
    return null;
  }

  void select(String id, {bool additive = false}) {
    if (!additive) _selectedIds.clear();
    _selectedIds.add(id);
    notifyListeners();
  }

  void toggleSelect(String id) {
    if (!_selectedIds.remove(id)) _selectedIds.add(id);
    notifyListeners();
  }

  void clearSelection() {
    if (_selectedIds.isEmpty) return;
    _selectedIds.clear();
    notifyListeners();
  }

  void selectAll() {
    _selectedIds
      ..clear()
      ..addAll(_elements.map((e) => e.id));
    notifyListeners();
  }

  void setMarquee(Rect? rect) {
    _marquee = rect;
    if (rect != null) {
      _selectedIds
        ..clear()
        ..addAll(_elements
            .where((e) => rect.overlaps(e.sceneBounds))
            .map((e) => e.id));
    }
    notifyListeners();
  }

  // ---- transforms ----

  void moveSelectedBy(Offset sceneDelta) {
    _mutateSelected((e) => e.movedBy(sceneDelta));
    notifyListeners();
  }

  /// Resizes the whole selection to [newBounds] proportionally.
  void resizeSelection(Rect newBounds) {
    final old = selectionBounds;
    if (old == null || old.width == 0 || old.height == 0) return;
    final sx = newBounds.width / old.width;
    final sy = newBounds.height / old.height;
    _mutateSelected((e) {
      final b = e.bounds;
      final nb = Rect.fromLTWH(
        newBounds.left + (b.left - old.left) * sx,
        newBounds.top + (b.top - old.top) * sy,
        b.width * sx,
        b.height * sy,
      );
      return e.resizedTo(nb);
    });
    notifyListeners();
  }

  void resizeElement(String id, Rect newBounds) {
    _elements = [
      for (final e in _elements) e.id == id ? e.resizedTo(newBounds) : e,
    ];
    notifyListeners();
  }

  void rotateElement(String id, double angle) {
    _elements = [
      for (final e in _elements) e.id == id ? e.copyWith(angle: angle) : e,
    ];
    notifyListeners();
  }

  void rotateSelection(double deltaAngle, Offset pivot) {
    _mutateSelected((e) {
      final c = rotatePoint(e.center, pivot, deltaAngle);
      return e.copyWith(
        x: c.dx - e.width / 2,
        y: c.dy - e.height / 2,
        angle: e.angle + deltaAngle,
      );
    });
    notifyListeners();
  }

  // ---- clipboard-ish ops ----

  void deleteSelected() {
    if (_selectedIds.isEmpty) return;
    _commit();
    _elements =
        _elements.where((e) => !_selectedIds.contains(e.id)).toList();
    _selectedIds.clear();
    notifyListeners();
  }

  void duplicateSelected() {
    if (_selectedIds.isEmpty) return;
    _commit();
    final copies = <SketchElement>[];
    for (final e in selectedElements) {
      final json = e.toJson()
        ..['id'] = nextElementId()
        ..['seed'] = nextSeed();
      copies.add(SketchElement.fromJson(json).movedBy(const Offset(16, 16)));
    }
    _elements = [..._elements, ...copies];
    _selectedIds
      ..clear()
      ..addAll(copies.map((e) => e.id));
    notifyListeners();
  }

  /// Serializes the selection for the clipboard. Returns null when empty.
  String? copySelectedJson() {
    final sel = selectedElements;
    if (sel.isEmpty) return null;
    return SceneData(elements: sel).encode();
  }

  String? cutSelectedJson() {
    final json = copySelectedJson();
    if (json != null) deleteSelected();
    return json;
  }

  /// Pastes clipboard JSON. Returns false when [json] is not a scene.
  bool pasteJson(String json) {
    try {
      final scene = SceneData.decode(json);
      if (scene.elements.isEmpty) return false;
      _commit();
      final pasted = <SketchElement>[];
      for (final e in scene.elements) {
        final j = e.toJson()
          ..['id'] = nextElementId()
          ..['seed'] = nextSeed();
        pasted.add(
            SketchElement.fromJson(j).movedBy(const Offset(24, 24)));
      }
      _elements = [..._elements, ...pasted];
      _selectedIds
        ..clear()
        ..addAll(pasted.map((e) => e.id));
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void reorderSelected(LayerOp op) {
    if (_selectedIds.isEmpty) return;
    _commit();
    final sel = selectedElements;
    final rest =
        _elements.where((e) => !_selectedIds.contains(e.id)).toList();
    switch (op) {
      case LayerOp.toFront:
        _elements = [...rest, ...sel];
      case LayerOp.toBack:
        _elements = [...sel, ...rest];
      case LayerOp.forward:
        final list = List.of(_elements);
        for (var i = list.length - 2; i >= 0; i--) {
          if (_selectedIds.contains(list[i].id) &&
              !_selectedIds.contains(list[i + 1].id)) {
            final t = list[i];
            list[i] = list[i + 1];
            list[i + 1] = t;
          }
        }
        _elements = list;
      case LayerOp.backward:
        final list = List.of(_elements);
        for (var i = 1; i < list.length; i++) {
          if (_selectedIds.contains(list[i].id) &&
              !_selectedIds.contains(list[i - 1].id)) {
            final t = list[i];
            list[i] = list[i - 1];
            list[i - 1] = t;
          }
        }
        _elements = list;
    }
    notifyListeners();
  }

  void bringForward() => reorderSelected(LayerOp.forward);
  void sendBackward() => reorderSelected(LayerOp.backward);
  void bringToFront() => reorderSelected(LayerOp.toFront);
  void sendToBack() => reorderSelected(LayerOp.toBack);

  void eraseAt(Offset scenePoint) {
    final hit = topMostAt(scenePoint);
    if (hit == null) return;
    _elements = _elements.where((e) => e.id != hit.id).toList();
    _selectedIds.remove(hit.id);
    notifyListeners();
  }

  void clearCanvas() {
    if (_elements.isEmpty) return;
    _commit();
    _elements = [];
    _selectedIds.clear();
    notifyListeners();
  }

  // ---- text editing ----

  void startEditingText(String id) {
    _editingTextId = id;
    notifyListeners();
  }

  void stopEditingText() {
    _editingTextId = null;
    notifyListeners();
  }

  void updateText(String id, String text, double width, double height) {
    _commit();
    _elements = [
      for (final e in _elements)
        e.id == id ? e.copyWith(text: text, width: width, height: height) : e,
    ];
    notifyListeners();
  }

  void removeElement(String id) {
    _commit();
    _elements = _elements.where((e) => e.id != id).toList();
    _selectedIds.remove(id);
    notifyListeners();
  }

  // ---- scene io ----

  void setGridEnabled(bool value) {
    _gridEnabled = value;
    notifyListeners();
  }

  SceneData exportScene() =>
      SceneData(elements: _elements, gridEnabled: _gridEnabled);

  void loadScene(SceneData scene) {
    _commit();
    _elements = List.of(scene.elements);
    _gridEnabled = scene.gridEnabled;
    _selectedIds.clear();
    _draft = null;
    notifyListeners();
  }
}

enum LayerOp { forward, backward, toFront, toBack }
