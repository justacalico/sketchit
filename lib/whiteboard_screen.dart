import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'canvas/canvas_view.dart';
import 'io/scene_io.dart';
import 'l10n/app_localizations.dart';
import 'models/scene.dart';
import 'state/drawing_controller.dart';
import 'state/settings_controller.dart';
import 'ui/app_menu.dart';
import 'ui/properties_panel.dart';
import 'ui/toolbar.dart';
import 'ui/zoom_controls.dart';

class WhiteboardScreen extends StatefulWidget {
  const WhiteboardScreen({super.key, required this.settings});

  final SettingsController settings;

  @override
  State<WhiteboardScreen> createState() => _WhiteboardScreenState();
}

class _WhiteboardScreenState extends State<WhiteboardScreen> {
  late final DrawingController _controller;
  Timer? _autosaveTimer;

  @override
  void initState() {
    super.initState();
    _controller = DrawingController();
    _restoreAutosave();
    _controller.addListener(_scheduleAutosave);
  }

  void _restoreAutosave() {
    final saved = widget.settings.loadAutosave();
    if (saved == null) return;
    try {
      _controller.loadScene(SceneData.decode(saved));
    } catch (_) {
      // Corrupt autosave should not crash the app.
    }
  }

  void _scheduleAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(milliseconds: 800), () {
      widget.settings.autosave(_controller.exportScene().encode());
    });
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _controller.removeListener(_scheduleAutosave);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openScene() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final text = await openSceneFile();
      if (text == null) return;
      _controller.loadScene(SceneData.decode(text));
      messenger.showSnackBar(SnackBar(content: Text(l10n.snackOpened)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.snackOpenFailed)));
    }
  }

  Future<void> _saveScene() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await saveSceneFile(l10n.fileSceneName, _controller.exportScene());
      messenger.showSnackBar(SnackBar(content: Text(l10n.snackSaved)));
    } catch (_) {
      // User cancelled or platform denied it; stay quiet.
    }
  }

  Future<void> _exportPng() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    try {
      final bytes = await renderScenePng(
        elements: _controller.elements,
        backgroundColor: dark ? 0xff121212 : 0xffffffff,
      );
      await savePngFile(l10n.fileImageName, bytes);
      messenger.showSnackBar(SnackBar(content: Text(l10n.snackExported)));
    } catch (_) {
      // Cancelled.
    }
  }

  Future<void> _confirmClear() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dialogClearTitle),
        content: Text(l10n.dialogClearBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.dialogConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true) _controller.clearCanvas();
  }

  Map<ShortcutActivator, VoidCallback> get _shortcuts => {
        const SingleActivator(LogicalKeyboardKey.keyV): () =>
            _controller.setTool(SketchTool.select),
        const SingleActivator(LogicalKeyboardKey.digit1): () =>
            _controller.setTool(SketchTool.select),
        const SingleActivator(LogicalKeyboardKey.keyH): () =>
            _controller.setTool(SketchTool.hand),
        const SingleActivator(LogicalKeyboardKey.keyR): () =>
            _controller.setTool(SketchTool.rectangle),
        const SingleActivator(LogicalKeyboardKey.keyD): () =>
            _controller.setTool(SketchTool.diamond),
        const SingleActivator(LogicalKeyboardKey.keyO): () =>
            _controller.setTool(SketchTool.ellipse),
        const SingleActivator(LogicalKeyboardKey.keyA): () =>
            _controller.setTool(SketchTool.arrow),
        const SingleActivator(LogicalKeyboardKey.keyL): () =>
            _controller.setTool(SketchTool.line),
        const SingleActivator(LogicalKeyboardKey.keyP): () =>
            _controller.setTool(SketchTool.pencil),
        const SingleActivator(LogicalKeyboardKey.keyT): () =>
            _controller.setTool(SketchTool.text),
        const SingleActivator(LogicalKeyboardKey.keyE): () =>
            _controller.setTool(SketchTool.eraser),
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
            _controller.undo,
        const SingleActivator(LogicalKeyboardKey.keyZ,
            control: true, shift: true): _controller.redo,
        const SingleActivator(LogicalKeyboardKey.keyY, control: true):
            _controller.redo,
        const SingleActivator(LogicalKeyboardKey.keyA, control: true):
            _controller.selectAll,
        const SingleActivator(LogicalKeyboardKey.keyD, control: true):
            _controller.duplicateSelected,
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
            unawaited(_saveScene()),
        const SingleActivator(LogicalKeyboardKey.keyO, control: true): () =>
            unawaited(_openScene()),
        const SingleActivator(LogicalKeyboardKey.delete):
            _controller.deleteSelected,
        const SingleActivator(LogicalKeyboardKey.backspace):
            _controller.deleteSelected,
        const SingleActivator(LogicalKeyboardKey.escape): () {
          _controller.clearSelection();
          _controller.setTool(SketchTool.select);
        },
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            _nudge(const Offset(-1, 0)),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            _nudge(const Offset(1, 0)),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
            _nudge(const Offset(0, -1)),
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            _nudge(const Offset(0, 1)),
        const SingleActivator(LogicalKeyboardKey.digit0, control: true): () =>
            _controller.resetZoom(MediaQuery.sizeOf(context)),
        const SingleActivator(LogicalKeyboardKey.digit1, shift: true): () =>
            _controller.zoomToFit(MediaQuery.sizeOf(context)),
      };

  void _nudge(Offset delta) {
    if (!_controller.hasSelection) return;
    _controller.beginGesture();
    _controller.moveSelectedBy(delta);
    _controller.endGesture();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canvasColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xff121212)
        : Colors.white;

    return CallbackShortcuts(
      bindings: _shortcuts,
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: canvasColor,
                    child: CanvasView(controller: _controller),
                  ),
                  if (_controller.elements.isEmpty)
                    IgnorePointer(
                      child: Center(
                        child: Text(
                          l10n.canvasHint,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline,
                                  ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: SafeArea(child: PropertiesPanel(controller: _controller)),
                  ),
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.sizeOf(context).width - 260,
                          ),
                          child: ToolBar(controller: _controller),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: SafeArea(
                      child: AppMenu(
                        settings: widget.settings,
                        gridEnabled: _controller.gridEnabled,
                        onToggleGrid: () => _controller
                            .setGridEnabled(!_controller.gridEnabled),
                        onOpen: _openScene,
                        onSave: _saveScene,
                        onExportPng: _exportPng,
                        onClear: _confirmClear,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: SafeArea(
                        child: ZoomControls(controller: _controller)),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
