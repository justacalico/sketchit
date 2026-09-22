import 'package:file_selector/file_selector.dart';

/// Native file picker for opening a saved scene.
Future<String?> pickSceneText() async {
  const group = XTypeGroup(
    label: 'Sketchit scene',
    extensions: ['json', 'sketchit'],
  );
  final file = await openFile(acceptedTypeGroups: [group]);
  return file?.readAsString();
}
