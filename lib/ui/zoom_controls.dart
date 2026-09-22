import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../state/drawing_controller.dart';

/// Bottom-left cluster: undo/redo, zoom out, zoom label, zoom in, fit.
class ZoomControls extends StatelessWidget {
  const ZoomControls({super.key, required this.controller});

  final DrawingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = controller;
    final scheme = Theme.of(context).colorScheme;

    Widget btn(IconData icon, String tooltip, VoidCallback? onTap) {
      return Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Icon(
              icon,
              size: 17,
              color: onTap == null
                  ? scheme.outlineVariant
                  : scheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            btn(Icons.undo, l10n.undo, c.canUndo ? c.undo : null),
            btn(Icons.redo, l10n.redo, c.canRedo ? c.redo : null),
            _divider(scheme),
            btn(Icons.remove, l10n.zoomOut,
                () => c.zoomAt(_center(context), 1 / 1.2)),
            Tooltip(
              message: l10n.zoomReset,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => c.resetZoom(_viewSize(context)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  child: Text(
                    '${(c.zoom * 100).round()}%',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
            ),
            btn(Icons.add, l10n.zoomIn,
                () => c.zoomAt(_center(context), 1.2)),
            _divider(scheme),
            btn(Icons.fit_screen, l10n.zoomFit,
                () => c.zoomToFit(_viewSize(context))),
          ],
        ),
      ),
    );
  }

  Widget _divider(ColorScheme scheme) => Container(
        width: 1,
        height: 20,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: scheme.outlineVariant,
      );

  Size _viewSize(BuildContext context) => MediaQuery.sizeOf(context);

  Offset _center(BuildContext context) =>
      _viewSize(context).center(Offset.zero);
}
