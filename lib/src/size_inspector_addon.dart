import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:widgetbook/widgetbook.dart';

import 'info_overlay.dart';
import 'models/widget_info.dart';

/// A Widgetbook addon for accurate widget size inspection.
///
/// Uses RenderBox constraints instead of intrinsic dimensions to provide
/// accurate sizing information for SVG widgets and other constrained widgets.
class SizeInspectorAddon extends WidgetbookAddon<bool> {
  SizeInspectorAddon() : super(name: 'Size Inspector');

  @override
  List<Field> get fields => [
        BooleanField(name: 'enabled', initialValue: false),
      ];

  @override
  bool valueFromQueryGroup(Map<String, String> group) =>
      group['enabled']?.toLowerCase() == 'true';

  @override
  Widget buildUseCase(
    BuildContext context,
    Widget child,
    bool setting,
  ) {
    if (!setting) return child;

    return _SizeInspectorWrapper(child: child);
  }
}

/// Internal wrapper that handles widget inspection.
class _SizeInspectorWrapper extends StatefulWidget {
  const _SizeInspectorWrapper({
    required this.child,
  });

  final Widget child;

  @override
  State<_SizeInspectorWrapper> createState() => _SizeInspectorWrapperState();
}

class _SizeInspectorWrapperState extends State<_SizeInspectorWrapper> {
  WidgetInfo? _selectedWidgetInfo;
  Offset? _tapPosition;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) => _handleTap(event.position),
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          widget.child,

          /// Visual highlight for selected widget
          if (_selectedWidgetInfo != null) _buildHighlight(),

          /// Overlay showing selected widget info
          if (_selectedWidgetInfo != null && _tapPosition != null)
            InfoOverlay(
              widgetInfo: _selectedWidgetInfo!,
              position: _tapPosition!,
            ),
        ],
      ),
    );
  }

  void _handleTap(Offset globalPosition) {
    _handlePointerEvent(globalPosition);
  }

  void _handlePointerEvent(Offset globalPosition) {
    debugPrint(
      'AccurateInspector: Tap detected at $globalPosition',
    );

    /// Use Flutter's global hit testing for InteractiveViewer support
    final hitTestResult = HitTestResult();
    final renderView =
        WidgetsBinding.instance.rootElement!.renderObject! as RenderView;
    renderView.hitTest(hitTestResult, position: globalPosition);

    if (hitTestResult.path.isEmpty) {
      debugPrint('AccurateInspector: No widgets found at position');
      setState(() {
        _selectedWidgetInfo = null;
        _tapPosition = null;
      });
      return;
    }

    /// Find the smallest suitable widget from hit test results
    RenderBox? bestRenderBox;
    double smallestArea = double.infinity;

    for (final hit in hitTestResult.path.toList().reversed) {
      if (hit.target is RenderBox) {
        final renderBox = hit.target as RenderBox;
        final area = renderBox.size.width * renderBox.size.height;

        /// Skip very large containers and very small widgets
        if (area > 100000 || area < 100) {
          continue;
        }
        if (area < smallestArea) {
          bestRenderBox = renderBox;
          smallestArea = area;
        }
      }
    }

    if (bestRenderBox == null) {
      debugPrint('AccurateInspector: No suitable RenderBox found');
      setState(() {
        _selectedWidgetInfo = null;
        _tapPosition = null;
      });
      return;
    }

    debugPrint(
      'AccurateInspector: Found ${bestRenderBox.runtimeType} with size ${bestRenderBox.size}',
    );

    /// Get widget boundaries in global coordinates
    final leftTopLocal = bestRenderBox.localToGlobal(Offset.zero);
    final rightBottomGlobal = bestRenderBox.localToGlobal(
      Offset(
        bestRenderBox.size.width,
        bestRenderBox.size.height,
      ),
    );

    /// Convert to Stack local coordinates
    final stackRenderBox = context.findRenderObject() as RenderBox?;
    final stackOffset =
        stackRenderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    final leftTopStackLocal = Offset(
      leftTopLocal.dx - stackOffset.dx,
      leftTopLocal.dy - stackOffset.dy,
    );

    final rightBottomStackLocal = Offset(
      rightBottomGlobal.dx - stackOffset.dx,
      rightBottomGlobal.dy - stackOffset.dy,
    );

    debugPrint('AccurateInspector: Widget left-top global: $leftTopLocal');
    debugPrint(
      'AccurateInspector: Widget right-bottom global: $rightBottomGlobal',
    );
    debugPrint('AccurateInspector: Stack offset: $stackOffset');
    debugPrint('AccurateInspector: Left-top stack local: $leftTopStackLocal');
    debugPrint(
      'AccurateInspector: Right-bottom stack local: $rightBottomStackLocal',
    );
    debugPrint('AccurateInspector: Widget type: ${bestRenderBox.runtimeType}');

    final widgetInfo = WidgetInfo(
      actualSize: bestRenderBox.size,
      constraints: bestRenderBox.constraints,
      position: leftTopStackLocal,
      widgetType: bestRenderBox.runtimeType.toString(),
      intrinsicSize: _getIntrinsicSize(bestRenderBox),
      padding: _extractPadding(bestRenderBox),
      key: _extractKey(bestRenderBox),
      parentType: _extractParentType(bestRenderBox),
      leftTopLocal: leftTopStackLocal,
      rightBottomLocal: rightBottomStackLocal,
    );

    debugPrint('AccurateInspector: Widget info: $widgetInfo');

    setState(() {
      _selectedWidgetInfo = widgetInfo;
      _tapPosition = globalPosition;
    });

    /// Auto-hide after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _selectedWidgetInfo = null;
          _tapPosition = null;
        });
      }
    });
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

  static Key? _extractKey(RenderBox renderBox) {
    try {
      final debugCreator = renderBox.debugCreator;
      if (debugCreator != null) {
        final element = (debugCreator as dynamic).element;
        if (element != null) {
          return element.widget.key;
        }
      }
    } catch (e) {
      /// Ignore errors in debug mode
    }
    return null;
  }

  static String? _extractParentType(RenderBox renderBox) {
    try {
      final debugCreator = renderBox.debugCreator;
      if (debugCreator != null) {
        final element = (debugCreator as dynamic).element;
        if (element != null) {
          final parent = element.findAncestorElementOfExactType<Element>();
          if (parent != null) {
            return parent.widget.runtimeType.toString();
          }
        }
      }
    } catch (e) {
      /// Ignore errors in debug mode
    }
    return null;
  }

  Widget _buildHighlight() {
    final info = _selectedWidgetInfo!;

    final RenderBox? stackRenderBox = context.findRenderObject() as RenderBox?;
    if (stackRenderBox == null) {
      return const SizedBox.shrink();
    }

    final Offset stackOffset = stackRenderBox.localToGlobal(Offset.zero);
    final Offset localPosition = Offset(
      info.position.dx - stackOffset.dx,
      info.position.dy - stackOffset.dy,
    );

    debugPrint(
      'AccurateInspector: Highlight - global position: ${info.position}, size: ${info.actualSize}',
    );
    debugPrint('AccurateInspector: Stack offset: $stackOffset');
    debugPrint('AccurateInspector: Local position: $localPosition');

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _WidgetRectanglePainter(
                leftTop: info.leftTopLocal ?? localPosition,
                rightBottom: info.rightBottomLocal ??
                    Offset(
                      localPosition.dx + info.actualSize.width,
                      localPosition.dy + info.actualSize.height,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for widget rectangle overlay.
class _WidgetRectanglePainter extends CustomPainter {
  const _WidgetRectanglePainter({
    required this.leftTop,
    required this.rightBottom,
  });

  final Offset leftTop;
  final Offset rightBottom;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1976D2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = const Color(0xFF1976D2).withAlpha(40)
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTRB(
      leftTop.dx,
      leftTop.dy,
      rightBottom.dx,
      rightBottom.dy,
    );

    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
