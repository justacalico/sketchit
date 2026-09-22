import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/element.dart';
import '../state/drawing_controller.dart';
import 'color_swatch.dart';

/// Left-hand panel with stroke/fill/width/style/opacity/layer controls.
/// Visible while a drawing tool is active or a selection exists.
class PropertiesPanel extends StatelessWidget {
  const PropertiesPanel({super.key, required this.controller});

  final DrawingController controller;

  bool get _visible {
    if (controller.hasSelection) return true;
    return switch (controller.tool) {
      SketchTool.rectangle ||
      SketchTool.diamond ||
      SketchTool.ellipse ||
      SketchTool.arrow ||
      SketchTool.line ||
      SketchTool.pencil ||
      SketchTool.text =>
        true,
      _ => false,
    };
  }

  bool get _fillRelevant {
    if (controller.hasSelection) {
      return controller.selectedElements.any((e) => e.supportsFill);
    }
    return switch (controller.tool) {
      SketchTool.rectangle ||
      SketchTool.diamond ||
      SketchTool.ellipse =>
        true,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final c = controller;
    final style = c.style;
    final scheme = Theme.of(context).colorScheme;

    Widget label(String s) => Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Text(s, style: Theme.of(context).textTheme.labelSmall),
        );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 212,
        constraints: const BoxConstraints(maxHeight: 480),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              label(l10n.propStroke),
              ColorSwatchRow(
                colors: strokePalette,
                selected: style.strokeColor,
                onSelected: (v) =>
                    c.setStyle(style.copyWith(strokeColor: v)),
              ),
              if (_fillRelevant) ...[
                label(l10n.propFill),
                ColorSwatchRow(
                  colors: fillPalette,
                  selected: style.fillColor,
                  allowNone: true,
                  noneLabel: l10n.fillNone,
                  onSelected: (v) =>
                      c.setStyle(style.copyWith(fillColor: () => v)),
                ),
              ],
              label(l10n.propStrokeWidth),
              SegmentedButton<double>(
                segments: const [
                  ButtonSegment(value: 1.5, icon: Icon(Icons.line_weight, size: 14)),
                  ButtonSegment(value: 3.0, icon: Icon(Icons.line_weight, size: 18)),
                  ButtonSegment(value: 5.0, icon: Icon(Icons.line_weight, size: 22)),
                ],
                showSelectedIcon: false,
                selected: {_nearestWidth(style.strokeWidth)},
                onSelectionChanged: (v) =>
                    c.setStyle(style.copyWith(strokeWidth: v.first)),
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              label(l10n.propStrokeStyle),
              SegmentedButton<StrokeStyle>(
                segments: [
                  ButtonSegment(
                      value: StrokeStyle.solid,
                      icon: const Icon(Icons.horizontal_rule, size: 16),
                      tooltip: l10n.styleSolid),
                  ButtonSegment(
                      value: StrokeStyle.dashed,
                      icon: const Icon(Icons.more_horiz, size: 16),
                      tooltip: l10n.styleDashed),
                  ButtonSegment(
                      value: StrokeStyle.dotted,
                      icon: const Icon(Icons.scatter_plot_outlined, size: 16),
                      tooltip: l10n.styleDotted),
                ],
                showSelectedIcon: false,
                selected: {style.strokeStyle},
                onSelectionChanged: (v) =>
                    c.setStyle(style.copyWith(strokeStyle: v.first)),
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              label(l10n.propRoughness),
              SegmentedButton<RoughStyle>(
                segments: [
                  ButtonSegment(
                      value: RoughStyle.crisp,
                      icon: const Icon(Icons.architecture, size: 16),
                      tooltip: l10n.styleCrisp),
                  ButtonSegment(
                      value: RoughStyle.sketch,
                      icon: const Icon(Icons.draw_outlined, size: 16),
                      tooltip: l10n.styleSketch),
                  ButtonSegment(
                      value: RoughStyle.rough,
                      icon: const Icon(Icons.gesture, size: 16),
                      tooltip: l10n.styleRough),
                ],
                showSelectedIcon: false,
                selected: {style.roughness},
                onSelectionChanged: (v) =>
                    c.setStyle(style.copyWith(roughness: v.first)),
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              label(l10n.propOpacity),
              Slider(
                value: style.opacity * 100,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${(style.opacity * 100).round()}',
                onChanged: (v) =>
                    c.setStyle(style.copyWith(opacity: v / 100)),
              ),
              if (c.hasSelection) ...[
                label(l10n.propLayers),
                Wrap(
                  spacing: 4,
                  children: [
                    _layerButton(l10n.actionBringToFront, Icons.flip_to_front,
                        c.bringToFront, scheme),
                    _layerButton(l10n.actionBringForward,
                        Icons.arrow_upward, c.bringForward, scheme),
                    _layerButton(l10n.actionSendBackward,
                        Icons.arrow_downward, c.sendBackward, scheme),
                    _layerButton(l10n.actionSendToBack, Icons.flip_to_back,
                        c.sendToBack, scheme),
                  ],
                ),
                label(l10n.propActions),
                Wrap(
                  spacing: 4,
                  children: [
                    _layerButton(l10n.actionDuplicate, Icons.copy_outlined,
                        c.duplicateSelected, scheme),
                    _layerButton(l10n.actionDelete, Icons.delete_outline,
                        c.deleteSelected, scheme),
                  ],
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  static double _nearestWidth(double w) {
    const options = [1.5, 3.0, 5.0];
    return options.reduce(
        (a, b) => (w - a).abs() <= (w - b).abs() ? a : b);
  }

  Widget _layerButton(
      String tooltip, IconData icon, VoidCallback onTap, ColorScheme scheme) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
