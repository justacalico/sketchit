import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_saver/file_saver.dart';
import 'package:flutter/rendering.dart';

import '../canvas/sketch_painter.dart';
import '../models/element.dart';
import '../models/scene.dart';
import 'pick_scene_stub.dart'
    if (dart.library.js_interop) 'pick_scene_web.dart';

/// Picks a scene file and returns its JSON text, or null when cancelled.
Future<String?> openSceneFile() => pickSceneText();

/// Saves scene JSON through the platform save flow.
Future<void> saveSceneFile(String baseName, SceneData scene) {
  return FileSaver.instance.saveFile(
    name: baseName,
    bytes: Uint8List.fromList(utf8.encode(scene.encode())),
    fileExtension: 'sketchit.json',
    mimeType: MimeType.json,
  );
}

/// Renders the scene to PNG bytes with a transparent-friendly white/dark
/// background at [scale] device pixels per scene unit.
Future<Uint8List> renderScenePng({
  required List<SketchElement> elements,
  required int backgroundColor,
  double scale = 2,
}) async {
  Rect? bounds;
  for (final e in elements) {
    final b = e.sceneBounds;
    bounds = bounds == null ? b : bounds.expandToInclude(b);
  }
  bounds = (bounds ?? const Rect.fromLTWH(0, 0, 800, 600)).inflate(24);

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.scale(scale);
  canvas.drawRect(bounds, Paint()..color = ui.Color(backgroundColor));
  canvas.translate(-bounds.left, -bounds.top);
  SketchPainter(
    elements: elements,
    selectedIds: const {},
    zoom: scale,
  ).paint(canvas, bounds.size);
  final picture = recorder.endRecording();
  final image = await picture.toImage(
    (bounds.width * scale).ceil(),
    (bounds.height * scale).ceil(),
  );
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

Future<void> savePngFile(String baseName, Uint8List bytes) {
  return FileSaver.instance.saveFile(
    name: baseName,
    bytes: bytes,
    fileExtension: 'png',
    mimeType: MimeType.png,
  );
}

/// Kept for callers that only need the visible bounds of a scene.
Rect contentBounds(List<SketchElement> elements) {
  Rect? bounds;
  for (final e in elements) {
    final b = e.sceneBounds;
    bounds = bounds == null ? b : bounds.expandToInclude(b);
  }
  return bounds ?? Rect.zero;
}
