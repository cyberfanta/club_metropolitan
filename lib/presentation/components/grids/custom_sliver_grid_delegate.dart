import 'package:flutter/rendering.dart';

class CustomSliverGridDelegate extends SliverGridDelegate {
  final int crossAxisCount;
  final double spacing;
  final double childHeight;

  const CustomSliverGridDelegate({
    required this.crossAxisCount,
    required this.spacing,
    required this.childHeight,
  });

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    // Calculate total available width
    final double availableWidth = constraints.crossAxisExtent;

    // Calculate width of each item considering spacing
    final double usableWidth = availableWidth - spacing * (crossAxisCount - 1);
    final double cellWidth = usableWidth / crossAxisCount;

    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childHeight + spacing,
      crossAxisStride: cellWidth + spacing,
      childMainAxisExtent: childHeight,
      childCrossAxisExtent: cellWidth,
      reverseCrossAxis: false,
    );
  }

  @override
  bool shouldRelayout(CustomSliverGridDelegate oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount ||
        oldDelegate.spacing != spacing ||
        oldDelegate.childHeight != childHeight;
  }
}
