import 'package:flutter/material.dart';

/// Widget information extracted from RenderBox.
class WidgetInfo {
  const WidgetInfo({
    required this.actualSize,
    required this.constraints,
    required this.position,
    required this.widgetType,
    this.intrinsicSize,
    this.padding,
    this.key,
    this.parentType,
    this.leftTopLocal,
    this.rightBottomLocal,
  });

  /// The actual rendered size.
  final Size actualSize;

  /// The render box constraints.
  final BoxConstraints constraints;

  /// Global position of the widget.
  final Offset position;

  /// The runtime type of the widget.
  final String widgetType;

  /// The intrinsic size if available.
  final Size? intrinsicSize;

  /// Padding information if available.
  final EdgeInsets? padding;

  /// Widget key if available.
  final Key? key;

  /// Parent widget type if available.
  final String? parentType;

  /// Left-top corner position in Stack local coordinates.
  final Offset? leftTopLocal;

  /// Right-bottom corner position in Stack local coordinates.
  final Offset? rightBottomLocal;

  @override
  String toString() {
    return 'WidgetInfo('
        'type: $widgetType, '
        'size: ${actualSize.width.toStringAsFixed(1)}x${actualSize.height.toStringAsFixed(1)}'
        '${intrinsicSize != null ? ', intrinsic: ${intrinsicSize!.width.toStringAsFixed(1)}x${intrinsicSize!.height.toStringAsFixed(1)}' : ''}'
        ')';
  }
}
