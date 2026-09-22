import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../state/drawing_controller.dart';

/// Floating tool island, modeled on the Excalidraw top bar.
class ToolBar extends StatelessWidget {
  const ToolBar({super.key, required this.controller});

  final DrawingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tools = <(SketchTool, IconData, String)>[
      (SketchTool.select, Icons.north_west, l10n.toolSelect),
      (SketchTool.hand, Icons.pan_tool_outlined, l10n.toolHand),
      (SketchTool.rectangle, Icons.rectangle_outlined, l10n.toolRectangle),
      (SketchTool.diamond, Icons.diamond_outlined, l10n.toolDiamond),
      (SketchTool.ellipse, Icons.circle_outlined, l10n.toolEllipse),
      (SketchTool.arrow, Icons.arrow_outward, l10n.toolArrow),
      (SketchTool.line, Icons.remove, l10n.toolLine),
      (SketchTool.pencil, Icons.gesture, l10n.toolPencil),
      (SketchTool.text, Icons.text_fields, l10n.toolText),
      (SketchTool.eraser, Icons.cleaning_services_outlined, l10n.toolEraser),
    ];
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (tool, icon, label) in tools)
                Tooltip(
                  message: label,
                  child: _ToolButton(
                    icon: icon,
                    selected: controller.tool == tool,
                    scheme: scheme,
                    onTap: () => controller.setTool(tool),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.selected,
    required this.scheme,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
