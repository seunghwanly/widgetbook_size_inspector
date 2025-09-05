import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'models/widget_info.dart';

/// Detects widget information using RenderBox constraints.
class WidgetInfoDetector {
  WidgetInfoDetector._();

  /// Finds the widget at the given position and returns size information.
  static WidgetInfo? detectWidgetAtPosition(
    BuildContext context,
    Offset globalPosition,
  ) {
    debugPrint(
      'WidgetInfoDetector: Starting detection at position $globalPosition',
    );

    final RenderBox? rootRenderBox = context.findRenderObject() as RenderBox?;
    if (rootRenderBox == null) {
      debugPrint('WidgetInfoDetector: Root render box is null');
      return null;
    }

    /// Use Flutter's built-in hit testing
    final BoxHitTestResult result = BoxHitTestResult();
    final localPosition = rootRenderBox.globalToLocal(globalPosition);

    debugPrint('WidgetInfoDetector: Local position: $localPosition');

    final bool hitSuccess =
        rootRenderBox.hitTest(result, position: localPosition);

    debugPrint(
      'WidgetInfoDetector: Hit test success: $hitSuccess, Found ${result.path.length} hits',
    );

    if (!hitSuccess || result.path.isEmpty) return null;

    /// Find the smallest RenderBox that was hit
    RenderBox? bestMatch;
    double smallestArea = double.infinity;

    for (final hit in result.path.toList().reversed) {
      if (hit.target is RenderBox) {
        final renderBox = hit.target as RenderBox;
        final area = renderBox.size.width * renderBox.size.height;

        debugPrint(
          'WidgetInfoDetector: Found ${renderBox.runtimeType} with size ${renderBox.size} (area: $area)',
        );

        if (area > 0 && area < smallestArea) {
          bestMatch = renderBox;
          smallestArea = area;
        }
      }
    }

    if (bestMatch == null) {
      debugPrint('WidgetInfoDetector: No suitable render box found');
      return null;
    }

    debugPrint(
      'WidgetInfoDetector: Best match: ${bestMatch.runtimeType} with size ${bestMatch.size}',
    );

    return WidgetInfo(
      actualSize: bestMatch.size,
      constraints: bestMatch.constraints,
      position: bestMatch.localToGlobal(Offset.zero),
      widgetType: bestMatch.runtimeType.toString(),
      intrinsicSize: _getIntrinsicSize(bestMatch),
      padding: _extractPadding(bestMatch),
    );
  }

  static Size? _getIntrinsicSize(RenderBox renderBox) {
    try {
      final intrinsicWidth = renderBox.getMinIntrinsicWidth(double.infinity);
      final intrinsicHeight = renderBox.getMinIntrinsicHeight(double.infinity);

      if (intrinsicWidth.isFinite && intrinsicHeight.isFinite) {
        return Size(intrinsicWidth, intrinsicHeight);
      }
    } catch (e) {
      /// Widget doesn't support intrinsic dimensions
    }
    return null;
  }

  static EdgeInsets? _extractPadding(RenderBox renderBox) {
    if (renderBox is RenderPadding) {
      final EdgeInsetsGeometry padding = renderBox.padding;
      return padding.resolve(TextDirection.ltr);
    }
    return null;
  }
}
