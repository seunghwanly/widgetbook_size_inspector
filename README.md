# widgetbook_size_inspector

A Widgetbook addon that provides accurate widget size inspection using RenderBox constraints. This library solves the common issue where SVG widgets and other constrained widgets report incorrect sizes in traditional inspectors.

## About the Package

This package is inspired by the [inspector package](https://pub.dev/packages/inspector) but specifically designed for Widgetbook environments. It provides accurate sizing information by using RenderBox constraints instead of intrinsic dimensions, making it particularly useful for debugging SVG widgets and other constrained widgets.

### Key Features

- **Accurate SVG sizing**: Shows actual rendered size (e.g., 16x16) instead of intrinsic dimensions (24x24) for constrained SVG widgets
- **Real constraints**: Displays actual RenderBox constraints, not intrinsic dimensions
- **InteractiveViewer support**: Works correctly with zoom and pan transformations
- **Enhanced widget info**: Shows widget type, parent type, key, padding, and constraints
- **Visual overlay**: Clear information display with size, constraints, and widget type
- **Designer/QA friendly**: Perfect for providing accurate measurements to design teams

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  widgetbook_size_inspector: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Setup

Add the `SizeInspectorAddon` to your Widgetbook configuration:

```dart
import 'package:widgetbook_size_inspector/widgetbook_size_inspector.dart';

Widgetbook.material(
  addons: [
    SizeInspectorAddon(),
    // ... other addons
  ],
)
```

### Example

Here's a complete example of how to set up Widgetbook with the size inspector:

```dart
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_size_inspector/widgetbook_size_inspector.dart';

import 'main.directories.g.dart';

void main() {
  runApp(
    WidgetbookApp(
        directories: directories,
        addons: [
            SizeInspectorAddon(),
        ],
    )
  );
}
```

### How to Use

1. **Enable the Inspector**: In your Widgetbook interface, find the "Size Inspector" addon in the addons panel and toggle it on.

2. **Inspect Widgets**: Click on any widget in your story to see detailed size information including:
   - Actual rendered size
   - Widget constraints (min/max width and height)
   - Widget type and parent type
   - Padding information (if available)
   - Widget key (if available)

3. **Visual Feedback**: The selected widget will be highlighted with a blue rectangle, and an information overlay will appear showing all relevant sizing data.

## API Reference

### SizeInspectorAddon

The main addon class that provides widget size inspection functionality.

```dart
class SizeInspectorAddon extends WidgetbookAddon<bool>
```

**Fields:**
- `enabled`: Boolean field to enable/disable the inspector

### WidgetInfo

Data class containing information about a widget:

```dart
class WidgetInfo {
  final Size actualSize;           // The actual rendered size
  final BoxConstraints constraints; // The render box constraints
  final Offset position;           // Global position of the widget
  final String widgetType;         // The runtime type of the widget
  final Size? intrinsicSize;       // The intrinsic size if available
  final EdgeInsets? padding;       // Padding information if available
  final Key? key;                  // Widget key if available
  final String? parentType;        // Parent widget type if available
}
```

## Contributing

Contributions are welcome! 

Please feel free to submit a Pull Request :)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by the [inspector package](https://pub.dev/packages/inspector) by kekland.com
- Built for the Widgetbook community