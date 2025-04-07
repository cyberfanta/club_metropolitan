import 'package:flutter/material.dart';

class ResponsiveLayoutHelper {
  final BoxConstraints constraints;
  final BuildContext context;

  ResponsiveLayoutHelper(this.context, this.constraints);

  /// Check if the device is in landscape orientation
  bool get isLandscape =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// Check if the current device is a mobile phone
  bool get isMobile => constraints.maxWidth < 600;

  /// Check if the current device is a tablet
  bool get isTablet =>
      constraints.maxWidth >= 600 && constraints.maxWidth < 960;

  /// Check if the current device is a desktop
  bool get isDesktop => constraints.maxWidth >= 960;

  /// Check specifically for a horizontal mobile device
  bool get isMobileLandscape => isMobile && isLandscape;

  /// Determine if grid view should be used based on device and orientation
  bool get useGridView => !isMobile || isMobileLandscape;

  /// Get appropriate card width based on device type
  double get cardWidth => isDesktop ? 400 : 350;

  /// Get appropriate card height based on device type and orientation
  double get cardHeight => isDesktop ? 400 : (isMobileLandscape ? 300 : 350);

  /// Calculate the appropriate number of columns for the grid
  int calculateColumnCount() {
    // For portrait mobile - single column
    if (isMobile && !isLandscape) return 1;

    // For landscape mobile - two columns
    if (isMobile && isLandscape) return 2;

    // For tablets - two columns
    if (isTablet) return 2;

    // For desktop, calculate columns based on available width
    // Allowing up to 6 columns on very wide screens
    const int maxColumns = 6;
    final double availableSpace =
        constraints.maxWidth - 32; // 32 = total padding

    // Considering space between columns (16px)
    final int calculatedColumns = (availableSpace / (cardWidth + 16)).floor();

    // Limit between 3 and maxColumns
    return calculatedColumns.clamp(3, maxColumns);
  }
}
