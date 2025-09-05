import 'dart:math';

import 'package:flutter/material.dart';

import 'models/widget_info.dart';

/// Visual overlay that displays widget information.
class InfoOverlay extends StatelessWidget {
  const InfoOverlay({
    required this.widgetInfo,
    required this.position,
    super.key,
  });

  final WidgetInfo widgetInfo;
  final Offset position;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      left: max(0, position.dx - 108),
      top: position.dy - 24,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.primaryContainer,
        child: Container(
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxWidth: 250),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Size information - the key fix for SVG issue
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${widgetInfo.actualSize.width.toStringAsFixed(1)} × ${widgetInfo.actualSize.height.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              /// Widget type
              Text(
                _formatWidgetType(widgetInfo.widgetType),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),

              /// Parent type if available
              if (widgetInfo.parentType != null) ...[
                const SizedBox(height: 2),
                Text(
                  '\u2022 Parent: ${_formatWidgetType(widgetInfo.parentType!)}',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 10,
                  ),
                ),
              ],

              /// Key if available
              if (widgetInfo.key != null) ...[
                const SizedBox(height: 2),
                Text(
                  '\u2022 Key: ${widgetInfo.key.toString()}',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 10,
                  ),
                ),
              ],

              /// Show intrinsic vs actual size comparison for debugging
              if (widgetInfo.intrinsicSize != null &&
                  widgetInfo.intrinsicSize != widgetInfo.actualSize) ...[
                const SizedBox(height: 4),
                Text(
                  '\u2022 Intrinsic: ${widgetInfo.intrinsicSize!.width.toStringAsFixed(1)}×${widgetInfo.intrinsicSize!.height.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 10,
                  ),
                ),
              ],

              /// Constraints info
              const SizedBox(height: 4),
              Text(
                _formatConstraints(widgetInfo.constraints),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 10,
                ),
              ),

              /// Padding info if available
              if (widgetInfo.padding != null) ...[
                const SizedBox(height: 4),
                Text(
                  '\u2022 Padding: ${_formatEdgeInsets(widgetInfo.padding!)}',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatWidgetType(String widgetType) {
    /// Clean up widget type names for better readability
    if (widgetType.contains('Render')) {
      return widgetType.replaceFirst('Render', '');
    }
    return widgetType;
  }

  String _formatConstraints(BoxConstraints constraints) {
    if (constraints.isTight) {
      return '\u2022 Fixed: ${constraints.maxWidth.toStringAsFixed(1)} × ${constraints.maxHeight.toStringAsFixed(1)}';
    }

    return '\u2022 Min: ${constraints.minWidth.toStringAsFixed(1)} × ${constraints.minHeight.toStringAsFixed(1)}\n'
        '\u2022 Max: ${constraints.maxWidth.isFinite ? constraints.maxWidth.toStringAsFixed(1) : '∞'}×'
        '${constraints.maxHeight.isFinite ? constraints.maxHeight.toStringAsFixed(1) : '∞'}';
  }

  String _formatEdgeInsets(EdgeInsets padding) {
    if (padding.left == padding.right &&
        padding.top == padding.bottom &&
        padding.left == padding.top) {
      return padding.left.toStringAsFixed(1);
    }

    return '${padding.top.toStringAsFixed(1)}, ${padding.right.toStringAsFixed(1)}, '
        '${padding.bottom.toStringAsFixed(1)}, ${padding.left.toStringAsFixed(1)}';
  }
}
