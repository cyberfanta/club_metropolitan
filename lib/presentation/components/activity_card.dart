import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/lang/ui_texts.dart';
import '../../core/theme/ui_colors.dart';
import '../../core/theme/ui_text_styles.dart';
import '../../domain/models/activity.dart';
import '../../domain/use_cases/components/activity_card_use_cases.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback onTap;
  final bool isDesktop;
  final bool isTablet;
  final bool? isUserEnrolled;
  final bool? hasConflict;
  final ActivityCardUseCases _useCases = ActivityCardUseCases();

  ActivityCard({
    super.key,
    required this.activity,
    required this.onTap,
    this.isDesktop = false,
    this.isTablet = false,
    this.isUserEnrolled,
    this.hasConflict,
  });

  @override
  Widget build(BuildContext context) {
    // Get UiTexts correctly from Provider
    final uiTexts = Provider.of<UiTexts>(context);

    // Fixed dimensions to prevent layout breaks
    final double imageHeight =
        isDesktop
            ? 180
            : isTablet
            ? 160
            : 140;
    final double padding =
        isDesktop
            ? 20
            : isTablet
            ? 16
            : 14;
    final double titleSize = isDesktop ? 18 : 16;
    final double textSize = isDesktop ? 14 : 12;
    final int descLines = 3; // Fixed number of description lines

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image with fixed height
            Stack(
              children: [
                Container(
                  height: imageHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.zero,
                    image: DecorationImage(
                      image: AssetImage(activity.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Status indicator
                if (isUserEnrolled == true || hasConflict == true)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isUserEnrolled == true
                            ? cGreen
                            : hasConflict == true
                            ? cOrange
                            : Colors.transparent,
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Text(
                        isUserEnrolled == true
                            ? uiTexts.enrolled
                            : hasConflict == true
                            ? uiTexts.adjustable
                            : "",
                        style: styleBold(
                          fontSize: textSize,
                          color: cWhite,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content with consistent padding
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          activity.name,
                          style: styleBold(fontSize: titleSize),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: adjustOpacity(cBlack, 0.1),
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Text(
                          "${activity.startTime} - ${activity.endTime}",
                          style: styleMedium(fontSize: textSize),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Day
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: adjustOpacity(cBlack, 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _useCases.capitalizeFirstLetter(
                          uiTexts.getDayName(activity.day),
                        ),
                        style: styleRegular(
                          fontSize: textSize,
                          color: adjustOpacity(cBlack, 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Trainer
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: adjustOpacity(cBlack, 0.6),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _useCases.getTrainerFullName(activity, uiTexts),
                          style: styleRegular(
                            fontSize: textSize,
                            color: adjustOpacity(cBlack, 0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: adjustOpacity(cBlack, 0.6),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          activity.location,
                          style: styleRegular(
                            fontSize: textSize,
                            color: adjustOpacity(cBlack, 0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Description with limited lines
                  Text(
                    activity.description,
                    maxLines: descLines,
                    overflow: TextOverflow.ellipsis,
                    style: styleRegular(
                      fontSize: textSize,
                      color: adjustOpacity(cBlack, 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
