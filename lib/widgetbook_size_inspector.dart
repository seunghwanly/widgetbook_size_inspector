/// A Widgetbook addon that provides accurate widget size inspection using RenderBox constraints
///
/// This library solves the common issue where SVG widgets and other constrained widgets
/// report incorrect sizes in traditional inspectors by using RenderBox constraints
/// instead of intrinsic dimensions. It also provides proper support for InteractiveViewer
/// zoom and pan transformations.
///
/// ## Usage
///
/// Add the addon to your Widgetbook configuration:
///
/// ```dart
/// Widgetbook.material(
///   directories: directories,
///   addons: [
///     SizeInspectorAddon(),
///     /// ... other addons
///   ],
/// )
/// ```
///
/// ## Features
///
/// - **Accurate SVG sizing**: Shows 16x16 instead of 24x24 for constrained SVG widgets
/// - **Real constraints**: Displays actual RenderBox constraints, not intrinsic dimensions
/// - **InteractiveViewer support**: Works correctly with zoom and pan transformations
/// - **Hover & Tap support**: Both hover and tap events for better UX
/// - **Enhanced widget info**: Shows widget type, parent type, key, padding, and constraints
/// - **Visual overlay**: Clear information display with size, constraints, and widget type
/// - **Designer/QA friendly**: Perfect for providing accurate measurements to design teams
library;

export 'src/models/widget_info.dart';
export 'src/size_inspector_addon.dart';
