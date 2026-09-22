import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../models/element.dart';
import '../models/geometry.dart';
import '../state/drawing_controller.dart';
import 'sketch_painter.dart';

enum _Mode { idle, pan, pinch, draw, freedraw, move, resize, rotate, marquee, erase }

/// The interactive canvas. Handles pointer input for every tool,
/// pinch zoom, wheel zoom/pan and the inline text editor.
class CanvasView extends StatefulWidget {
  const CanvasView({super.key, required this.controller});

  final DrawingController controller;

  @override
  State<CanvasView> createState() => CanvasViewState();
}

class CanvasViewState extends State<CanvasView> {
  final Map<int, Offset> _pointers = {};
  _Mode _mode = _Mode.idle;
  Offset _startScene = Offset.zero;
  Offset _lastScene = Offset.zero;
  Offset _lastScreen = Offset.zero;
  GrabHandle _handle = GrabHandle.none;
  String? _resizeId;
  Rect _resizeStart = Rect.zero;
  double _rotateStartPointerAngle = 0;
  double _rotateStartAngle = 0;
  List<Offset> _strokePoints = [];
  double _pinchStartDistance = 0;
  Offset _pinchLastCentroid = Offset.zero;

  // Inline text editor state.
  Offset? _textPos; // scene coords for a brand new element
  String? _editingId;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocus = FocusNode();

  DrawingController get c => widget.controller;

  @override
  void dispose() {
    _textController.dispose();
    _textFocus.dispose();
    super.dispose();
  }

  bool get _isShiftPressed =>
      HardwareKeyboard.instance.logicalKeysPressed
          .contains(LogicalKeyboardKey.shiftLeft) ||
      HardwareKeyboard.instance.logicalKeysPressed
          .contains(LogicalKeyboardKey.shiftRight);

  bool get _isCtrlPressed =>
      HardwareKeyboard.instance.logicalKeysPressed
          .contains(LogicalKeyboardKey.controlLeft) ||
      HardwareKeyboard.instance.logicalKeysPressed
          .contains(LogicalKeyboardKey.controlRight) ||
      HardwareKeyboard.instance.logicalKeysPressed
          .contains(LogicalKeyboardKey.metaLeft) ||
      HardwareKeyboard.instance.logicalKeysPressed
          .contains(LogicalKeyboardKey.metaRight);

  // ---- pointer handling ----

  void _onPointerDown(PointerDownEvent e) {
    if (_textPos != null) {
      _submitText();
      return;
    }
    _pointers[e.pointer] = e.localPosition;
    if (_pointers.length == 2) {
      _finishDraft();
      _endGestureMode();
      _mode = _Mode.pinch;
      final pts = _pointers.values.toList();
      _pinchStartDistance = (pts[0] - pts[1]).distance;
      _pinchLastCentroid = (pts[0] + pts[1]) / 2;
      return;
    }
    if (_pointers.length > 2) return;

    _lastScreen = e.localPosition;
    final scene = c.toScene(e.localPosition);
    _startScene = scene;
    _lastScene = scene;

    if (e.buttons & kMiddleMouseButton != 0) {
      _mode = _Mode.pan;
      return;
    }

    switch (c.tool) {
      case SketchTool.hand:
        _mode = _Mode.pan;
      case SketchTool.select:
        _handleSelectDown(e.localPosition, scene);
      case SketchTool.rectangle ||
            SketchTool.diamond ||
            SketchTool.ellipse:
        _mode = _Mode.draw;
      case SketchTool.line || SketchTool.arrow:
        _mode = _Mode.draw;
      case SketchTool.pencil:
        _mode = _Mode.freedraw;
        _strokePoints = [scene];
      case SketchTool.text:
        _openTextEditor(scene, null);
      case SketchTool.eraser:
        _mode = _Mode.erase;
        c.beginGesture();
        c.eraseAt(scene);
    }
  }

  void _handleSelectDown(Offset screen, Offset scene) {
    final handle = _hitHandle(screen);
    if (handle != GrabHandle.none) {
      c.beginGesture();
      _handle = handle;
      if (handle == GrabHandle.rotate) {
        _mode = _Mode.rotate;
        final e = _singleSelection;
        if (e != null) {
          _rotateStartAngle = e.angle;
          _rotateStartPointerAngle =
              math.atan2(scene.dy - e.center.dy, scene.dx - e.center.dx);
        }
      } else {
        _mode = _Mode.resize;
        final e = _singleSelection;
        _resizeId = e?.id;
        _resizeStart = e?.bounds ?? c.selectionBounds ?? Rect.zero;
      }
      return;
    }
    final hit = c.topMostAt(scene);
    if (hit != null) {
      if (_isShiftPressed) {
        c.toggleSelect(hit.id);
      } else if (!c.selectedIds.contains(hit.id)) {
        c.select(hit.id);
        c.syncStyleFromSelection();
      }
      if (c.selectedIds.contains(hit.id)) {
        _mode = _Mode.move;
        c.beginGesture();
      }
      return;
    }
    _mode = _Mode.marquee;
    if (!_isShiftPressed) c.clearSelection();
  }

  SketchElement? get _singleSelection {
    if (c.selectedIds.length != 1) return null;
    final id = c.selectedIds.first;
    for (final e in c.elements) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// Hit test the 8 resize handles plus the rotation handle in screen space.
  GrabHandle _hitHandle(Offset screen) {
    const radius = 12.0;
    final single = _singleSelection;
    if (single == null) {
      final b = c.selectionBounds;
      if (b == null) return GrabHandle.none;
      final pts = {
        GrabHandle.nw: b.topLeft,
        GrabHandle.ne: b.topRight,
        GrabHandle.se: b.bottomRight,
        GrabHandle.sw: b.bottomLeft,
        GrabHandle.n: Offset(b.center.dx, b.top),
        GrabHandle.e: Offset(b.right, b.center.dy),
        GrabHandle.s: Offset(b.center.dx, b.bottom),
        GrabHandle.w: Offset(b.left, b.center.dy),
      };
      for (final entry in pts.entries) {
        if ((c.toScreen(entry.value) - screen).distance <= radius) {
          return entry.key;
        }
      }
      return GrabHandle.none;
    }
    final b = single.bounds;
    final center = single.center;
    final corners = single.corners;
    final mid = [
      rotatePoint(Offset(b.center.dx, b.top), center, single.angle),
      rotatePoint(Offset(b.right, b.center.dy), center, single.angle),
      rotatePoint(Offset(b.center.dx, b.bottom), center, single.angle),
      rotatePoint(Offset(b.left, b.center.dy), center, single.angle),
    ];
    final up = rotatePoint(Offset(0, -24 / c.zoom), Offset.zero, single.angle);
    final pts = <GrabHandle, Offset>{
      GrabHandle.nw: corners[0],
      GrabHandle.ne: corners[1],
      GrabHandle.se: corners[2],
      GrabHandle.sw: corners[3],
      GrabHandle.n: mid[0],
      GrabHandle.e: mid[1],
      GrabHandle.s: mid[2],
      GrabHandle.w: mid[3],
      GrabHandle.rotate: mid[0] + up,
    };
    for (final entry in pts.entries) {
      if ((c.toScreen(entry.value) - screen).distance <= radius) {
        return entry.key;
      }
    }
    return GrabHandle.none;
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (_pointers.containsKey(e.pointer)) {
      _pointers[e.pointer] = e.localPosition;
    }
    if (_mode == _Mode.pinch && _pointers.length >= 2) {
      final pts = _pointers.values.toList();
      final centroid = (pts[0] + pts[1]) / 2;
      final dist = (pts[0] - pts[1]).distance;
      if (_pinchStartDistance > 0) {
        c.zoomAt(centroid, dist / _pinchStartDistance);
        _pinchStartDistance = dist;
      }
      c.panBy(centroid - _pinchLastCentroid);
      _pinchLastCentroid = centroid;
      return;
    }
    if (_pointers.length > 1) return;

    final scene = c.toScene(e.localPosition);
    final delta = scene - _lastScene;

    switch (_mode) {
      case _Mode.pan:
        c.panBy(e.localPosition - _lastScreen);
      case _Mode.draw:
        if (c.tool == SketchTool.line || c.tool == SketchTool.arrow) {
          c.setDraft(c.makePath(_startScene, scene));
        } else {
          c.setDraft(c.makeShape(_startScene, scene));
        }
      case _Mode.freedraw:
        if (_strokePoints.isEmpty || (scene - _strokePoints.last).distance > 0.5 / c.zoom) {
          _strokePoints.add(scene);
          c.setDraft(c.makeFreedraw(_strokePoints));
        }
      case _Mode.move:
        c.moveSelectedBy(delta);
      case _Mode.resize:
        _applyResize(scene);
      case _Mode.rotate:
        _applyRotate(scene);
      case _Mode.marquee:
        c.setMarquee(Rect.fromPoints(_startScene, scene));
      case _Mode.erase:
        c.eraseAt(scene);
      case _Mode.idle || _Mode.pinch:
        break;
    }
    _lastScene = scene;
    _lastScreen = e.localPosition;
  }

  void _applyResize(Offset scene) {
    final single = _resizeId == null ? null : _singleSelection;
    if (single != null) {
      // Work in the element's unrotated frame so rotated shapes resize
      // along their own axes.
      final local = rotatePoint(scene, single.center, -single.angle);
      var b = _resizeStart;
      final minSize = 4.0;
      switch (_handle) {
        case GrabHandle.e:
          b = Rect.fromLTRB(b.left, b.top, math.max(b.left + minSize, local.dx), b.bottom);
        case GrabHandle.w:
          b = Rect.fromLTRB(math.min(b.right - minSize, local.dx), b.top, b.right, b.bottom);
        case GrabHandle.s:
          b = Rect.fromLTRB(b.left, b.top, b.right, math.max(b.top + minSize, local.dy));
        case GrabHandle.n:
          b = Rect.fromLTRB(b.left, math.min(b.bottom - minSize, local.dy), b.right, b.bottom);
        case GrabHandle.se:
          b = Rect.fromLTRB(b.left, b.top, math.max(b.left + minSize, local.dx), math.max(b.top + minSize, local.dy));
        case GrabHandle.sw:
          b = Rect.fromLTRB(math.min(b.right - minSize, local.dx), b.top, b.right, math.max(b.top + minSize, local.dy));
        case GrabHandle.ne:
          b = Rect.fromLTRB(b.left, math.min(b.bottom - minSize, local.dy), math.max(b.left + minSize, local.dx), b.bottom);
        case GrabHandle.nw:
          b = Rect.fromLTRB(math.min(b.right - minSize, local.dx), math.min(b.bottom - minSize, local.dy), b.right, b.bottom);
        case GrabHandle.none || GrabHandle.rotate:
          return;
      }
      c.resizeElement(single.id, b);
      return;
    }
    // Multi-selection: proportional resize of the bounding box.
    final old = _resizeStart;
    if (old.width == 0 || old.height == 0) return;
    var nb = old;
    switch (_handle) {
      case GrabHandle.e:
        nb = Rect.fromLTRB(old.left, old.top, math.max(old.left + 4, scene.dx), old.bottom);
      case GrabHandle.w:
        nb = Rect.fromLTRB(math.min(old.right - 4, scene.dx), old.top, old.right, old.bottom);
      case GrabHandle.s:
        nb = Rect.fromLTRB(old.left, old.top, old.right, math.max(old.top + 4, scene.dy));
      case GrabHandle.n:
        nb = Rect.fromLTRB(old.left, math.min(old.bottom - 4, scene.dy), old.right, old.bottom);
      case GrabHandle.se:
        nb = Rect.fromLTRB(old.left, old.top, math.max(old.left + 4, scene.dx), math.max(old.top + 4, scene.dy));
      case GrabHandle.sw:
        nb = Rect.fromLTRB(math.min(old.right - 4, scene.dx), old.top, old.right, math.max(old.top + 4, scene.dy));
      case GrabHandle.ne:
        nb = Rect.fromLTRB(old.left, math.min(old.bottom - 4, scene.dy), math.max(old.left + 4, scene.dx), old.bottom);
      case GrabHandle.nw:
        nb = Rect.fromLTRB(math.min(old.right - 4, scene.dx), math.min(old.bottom - 4, scene.dy), old.right, old.bottom);
      case GrabHandle.none || GrabHandle.rotate:
        return;
    }
    c.resizeSelection(nb);
  }

  void _applyRotate(Offset scene) {
    final e = _singleSelection;
    if (e == null) return;
    var angle = _rotateStartAngle +
        math.atan2(scene.dy - e.center.dy, scene.dx - e.center.dx) -
        _rotateStartPointerAngle;
    if (_isShiftPressed) {
      const step = math.pi / 12;
      angle = (angle / step).round() * step;
    }
    c.rotateElement(e.id, angle);
  }

  void _onPointerUp(PointerUpEvent e) {
    _pointers.remove(e.pointer);
    if (_mode == _Mode.pinch) {
      if (_pointers.isEmpty) _mode = _Mode.idle;
      return;
    }
    _finishDraft();
    _endGestureMode();
  }

  void _onPointerCancel(PointerCancelEvent e) {
    _pointers.remove(e.pointer);
    _finishDraft();
    _endGestureMode();
  }

  void _finishDraft() {
    if (_mode == _Mode.draw ||
        _mode == _Mode.freedraw ||
        _mode == _Mode.marquee) {
      if (_mode == _Mode.marquee) {
        c.setMarquee(null);
      } else {
        c.commitDraft();
      }
    }
  }

  void _endGestureMode() {
    if (_mode == _Mode.move ||
        _mode == _Mode.resize ||
        _mode == _Mode.rotate ||
        _mode == _Mode.erase) {
      c.endGesture();
    }
    _mode = _Mode.idle;
    _handle = GrabHandle.none;
  }

  void _onScroll(PointerScrollEvent e) {
    if (_isCtrlPressed) {
      final factor = math.exp(-e.scrollDelta.dy * 0.002);
      c.zoomAt(e.localPosition, factor);
    } else {
      c.panBy(-e.scrollDelta);
    }
  }

  void _onDoubleTap(TapDownDetails d) {
    final scene = c.toScene(d.localPosition);
    final hit = c.topMostAt(scene);
    if (hit != null && hit.type == ElementType.text) {
      c.select(hit.id);
      _openTextEditor(scene, hit);
    }
  }

  // ---- text editing ----

  void _openTextEditor(Offset scenePos, SketchElement? existing) {
    setState(() {
      _textPos = scenePos;
      _editingId = existing?.id;
      _textController.text = existing?.text ?? '';
    });
    if (existing != null) c.startEditingText(existing.id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textFocus.requestFocus();
    });
  }

  Size _measureText(String text, double fontSize) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize, height: 1.25)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 4000);
    return tp.size;
  }

  void _submitText() {
    final text = _textController.text.trimRight();
    final editingId = _editingId;
    final pos = _textPos;
    setState(() {
      _textPos = null;
      _editingId = null;
    });
    if (editingId != null) {
      c.stopEditingText();
      if (text.isEmpty) {
        c.removeElement(editingId);
      } else {
        final size = _measureText(text, c.style.fontSize);
        c.updateText(editingId, text, size.width, size.height);
      }
      return;
    }
    if (pos == null || text.isEmpty) return;
    final size = _measureText(text, c.style.fontSize);
    c.addText(pos, text, size.width, size.height);
  }

  void _cancelText() {
    final editingId = _editingId;
    setState(() {
      _textPos = null;
      _editingId = null;
    });
    if (editingId != null) c.stopEditingText();
  }

  // ---- build ----

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: c,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Listener(
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerUp,
              onPointerCancel: _onPointerCancel,
              onPointerSignal: (s) {
                if (s is PointerScrollEvent) _onScroll(s);
              },
              child: GestureDetector(
                onDoubleTapDown: _onDoubleTap,
                behavior: HitTestBehavior.opaque,
                child: CustomPaint(
                  painter: _ScenePainter(
                    controller: c,
                    accentColor: Theme.of(context).colorScheme.primary,
                    handleColor: Theme.of(context).colorScheme.surface,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            if (_textPos != null) _buildTextEditor(l10n),
          ],
        );
      },
    );
  }

  Widget _buildTextEditor(AppLocalizations l10n) {
    final pos = _textPos!;
    final existing = _editingId == null
        ? null
        : c.elements.where((e) => e.id == _editingId).firstOrNull;
    final fontSize = existing?.fontSize ?? c.style.fontSize;
    final screen = c.toScreen(existing?.bounds.topLeft ?? pos);
    return Positioned(
      left: screen.dx,
      top: screen.dy,
      child: IntrinsicWidth(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 80, maxWidth: 480),
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.escape): _cancelText,
            },
            child: TextField(
              controller: _textController,
              focusNode: _textFocus,
              maxLines: null,
              style: TextStyle(
                fontSize: fontSize * c.zoom,
                height: 1.25,
                color: Color(existing?.strokeColor ?? c.style.strokeColor),
              ),
              decoration: InputDecoration(
                hintText: l10n.textPlaceholder,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _submitText(),
              onEditingComplete: _submitText,
            ),
          ),
        ),
      ),
    );
  }
}

/// CustomPainter wrapper reading everything off the controller.
class _ScenePainter extends CustomPainter {
  _ScenePainter({required this.controller, this.accentColor = const Color(0xff6965db), this.handleColor = const Color(0xffffffff)})
      : super(repaint: controller);

  final DrawingController controller;
  final Color accentColor;
  final Color handleColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(controller.pan.dx, controller.pan.dy);
    canvas.scale(controller.zoom);
    SketchPainter(
      elements: controller.elements,
      selectedIds: controller.selectedIds,
      zoom: controller.zoom,
      draft: controller.draft,
      marquee: controller.marquee,
      editingId: controller.editingTextId,
      gridEnabled: controller.gridEnabled,
      accentColor: accentColor,
      handleColor: handleColor,
    ).paint(canvas, size);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScenePainter old) => true;
}
