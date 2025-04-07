import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/lang/ui_texts.dart';
import '../../../core/theme/ui_colors.dart';

class ActivitySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDesktop;
  final bool isMobileLandscape;
  final BoxConstraints constraints;
  final Function(String) onSearchChanged;

  const ActivitySearchBar({
    super.key,
    required this.controller,
    required this.isDesktop,
    required this.isMobileLandscape,
    required this.constraints,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final UiTexts uiTexts = Provider.of<UiTexts>(context);

    return Container(
      width:
          isDesktop
              ? 400
              : isMobileLandscape
              ? constraints.maxWidth * 0.6
              : MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: cWhite,
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: adjustOpacity(cBlack, 0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: uiTexts.searchActivities,
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
