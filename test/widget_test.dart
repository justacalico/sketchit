import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sketchit/app.dart';
import 'package:sketchit/state/settings_controller.dart';

Future<SettingsController> testSettings() async {
  SharedPreferences.setMockInitialValues({});
  return SettingsController.load();
}

void main() {
  testWidgets('app renders toolbar, menu and canvas hint', (tester) async {
    final settings = await testSettings();
    await tester.pumpWidget(SketchitApp(settings: settings));
    await tester.pumpAndSettle();

    expect(find.text('Sketchit'), findsNothing); // no app bar, hint instead
    expect(find.byIcon(Icons.rectangle_outlined), findsOneWidget);
    expect(find.byIcon(Icons.gesture), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.text('Pick a tool and start sketching'), findsOneWidget);
  });

  testWidgets('menu opens with file actions', (tester) async {
    final settings = await testSettings();
    await tester.pumpWidget(SketchitApp(settings: settings));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text('Open file'), findsOneWidget);
    expect(find.text('Export PNG'), findsOneWidget);
    expect(find.text('Clear canvas'), findsOneWidget);
  });

  testWidgets('tool buttons switch the active tool', (tester) async {
    final settings = await testSettings();
    await tester.pumpWidget(SketchitApp(settings: settings));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.rectangle_outlined));
    await tester.pumpAndSettle();
    // Properties panel appears once a drawing tool is active.
    expect(find.text('Stroke'), findsOneWidget);
    expect(find.text('Fill'), findsOneWidget);
  });
}
