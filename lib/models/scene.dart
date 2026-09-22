import 'dart:convert';

import 'element.dart';

/// A serialized drawing plus view preferences.
class SceneData {
  const SceneData({
    required this.elements,
    this.gridEnabled = false,
    this.backgroundColor = 0xffffffff,
  });

  factory SceneData.fromJson(Map<String, dynamic> json) {
    final elements = (json['elements'] as List?)
            ?.map((e) => SketchElement.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const <SketchElement>[];
    return SceneData(
      elements: elements,
      gridEnabled: json['gridEnabled'] as bool? ?? false,
      backgroundColor:
          (json['backgroundColor'] as num?)?.toInt() ?? 0xffffffff,
    );
  }

  factory SceneData.decode(String source) =>
      SceneData.fromJson(jsonDecode(source) as Map<String, dynamic>);

  static const int currentVersion = 1;

  final List<SketchElement> elements;
  final bool gridEnabled;
  final int backgroundColor;

  Map<String, dynamic> toJson() => {
        'type': 'sketchit',
        'version': currentVersion,
        'gridEnabled': gridEnabled,
        'backgroundColor': backgroundColor,
        'elements': elements.map((e) => e.toJson()).toList(),
      };

  String encode() => jsonEncode(toJson());
}
