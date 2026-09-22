import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Browser file picker: synthesizes an <input type=file> and reads the
/// chosen file as text.
Future<String?> pickSceneText() {
  final completer = Completer<String?>();
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = '.json,.sketchit,application/json';
  input.onchange = (web.Event _) {
    final file = input.files?.item(0);
    if (file == null) {
      completer.complete(null);
      return;
    }
    final reader = web.FileReader();
    reader.onload = (web.Event _) {
      completer.complete((reader.result as JSString?)?.toDart);
    }.toJS;
    reader.onerror = (web.Event _) {
      completer.complete(null);
    }.toJS;
    reader.readAsText(file);
  }.toJS;
  input.click();
  return completer.future;
}
