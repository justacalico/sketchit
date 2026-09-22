import 'package:flutter/material.dart';

/// Stroke palette, roughly the Excalidraw defaults.
const strokePalette = [
  0xff1e1e1e,
  0xffe03131,
  0xff2f9e44,
  0xff1971c2,
  0xfff08c00,
  0xff9c36b5,
  0xff0c8599,
  0xffffffff,
];

/// Fill palette: pastels that read well under sketchy strokes.
const fillPalette = [
  0xffffc9c9,
  0xffb2f2bb,
  0xffa5d8ff,
  0xffffec99,
  0xffe9ecef,
  0xffd0bfff,
];

/// A row of round color swatches. [allowNone] prepends a transparent option.
class ColorSwatchRow extends StatelessWidget {
  const ColorSwatchRow({
    super.key,
    required this.colors,
    required this.selected,
    required this.onSelected,
    this.allowNone = false,
    this.noneLabel = '',
  });

  final List<int> colors;
  final int? selected;
  final ValueChanged<int?> onSelected;
  final bool allowNone;
  final String noneLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (allowNone)
          _Swatch(
            tooltip: noneLabel,
            selected: selected == null,
            scheme: scheme,
            onTap: () => onSelected(null),
            child: Icon(Icons.format_color_reset,
                size: 14, color: scheme.onSurfaceVariant),
          ),
        for (final c in colors)
          _Swatch(
            color: Color(c),
            selected: selected == c,
            scheme: scheme,
            onTap: () => onSelected(c),
          ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    this.color,
    this.child,
    this.tooltip,
    required this.selected,
    required this.scheme,
    required this.onTap,
  });

  final Color? color;
  final Widget? child;
  final String? tooltip;
  final bool selected;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final swatch = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: child,
      ),
    );
    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(message: tooltip!, child: swatch);
    }
    return swatch;
  }
}
