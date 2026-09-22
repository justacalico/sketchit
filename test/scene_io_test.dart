import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sketchit/io/scene_io.dart';
import 'package:sketchit/models/element.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('contentBounds unions element bounds', () {
    final elements = [
      SketchElement.shape(
        type: ElementType.rectangle,
        rect: const Rect.fromLTWH(0, 0, 10, 10),
      ),
      SketchElement.shape(
        type: ElementType.rectangle,
        rect: const Rect.fromLTWH(100, 100, 10, 10),
      ),
    ];
    expect(contentBounds(elements), const Rect.fromLTRB(0, 0, 110, 110));
  });

  test('contentBounds empty', () {
    expect(contentBounds(const []), Rect.zero);
  });

  test('renderScenePng produces png bytes', () async {
    final bytes = await renderScenePng(
      elements: [
        SketchElement.shape(
          type: ElementType.rectangle,
          rect: const Rect.fromLTWH(0, 0, 100, 80),
          fillColor: 0xffff0000,
        ),
      ],
      backgroundColor: 0xffffffff,
      scale: 1,
    );
    // PNG magic number.
    expect(bytes.sublist(0, 4), [0x89, 0x50, 0x4e, 0x47]);
  });
}
