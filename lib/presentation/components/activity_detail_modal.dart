import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/lang/ui_texts.dart';
import '../../core/theme/ui_colors.dart';
import '../../core/theme/ui_text_styles.dart';
import '../../domain/models/activity.dart';
import '../../domain/use_cases/components/activity_detail_modal_use_cases.dart';

class ActivityDetailModal extends StatelessWidget {
  final Activity activity;
  final bool isUserEnrolled;
  final Activity? conflictingActivity;
  final VoidCallback onAction;
  final String actionLabel;
  final ActivityDetailModalUseCases _useCases = ActivityDetailModalUseCases();

  ActivityDetailModal({
    super.key,
    required this.activity,
    required this.isUserEnrolled,
    this.conflictingActivity,
    required this.onAction,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Get UiTexts from Provider correctly
    final uiTexts = Provider.of<UiTexts>(context);
    final size = MediaQuery.of(context).size;
    
    // Detect orientation
    final orientation = MediaQuery.of(context).orientation;

    // More granular responsive breakpoints
    final bool isMobileLandscape = orientation == Orientation.landscape;
    final bool isMediumScreen = size.width >= 600 && size.width < 960;
    final bool isWideScreen = size.width >= 960;

    // Adjust modal size and position based on screen width for smoother transitions
    final double horizontalPadding =
        isWideScreen
            ? 32
            : isMediumScreen
            ? 24
            : 16;

    final double maxWidth =
        isWideScreen
            ? 900
            : isMediumScreen
            ? 700
            : size.width;
    
    // Adjust maximum height in landscape mode for mobile devices
    final double maxModalHeight = isMobileLandscape
        ? size.height * 0.9  // 90% of height in landscape mode
        : size.height * 0.85; // 85% in normal mode

    double lineSideMargin = (size.width - 30) / 2;
    // Use a fixed width for the button that is sufficient to display the text in a single line
    // The minimum width will be 280px and will adjust depending on the screen size
    double buttonWidth = isWideScreen ? 400 : isMediumScreen ? 350 : 280;

    // Make sure the button is not wider than the modal minus a margin
    buttonWidth = buttonWidth > (maxWidth - 32) ? (maxWidth - 32) : buttonWidth;
    
    return Container(
      width: maxWidth,
      constraints: BoxConstraints(
        maxHeight: maxModalHeight,
      ),
      decoration: BoxDecoration(
        color: cWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Stack(
        children: [
          // Drag handle at the top
          Positioned(
            top: 6,
            left: lineSideMargin,
            right: lineSideMargin,
            child: Container(height: 3, color: adjustOpacity(cBlack, 0.3)),
          ),

          // Complete content with scroll
          Container(
            margin: EdgeInsets.only(bottom: isMobileLandscape ? 84 : 96),
            child: ListView(
              shrinkWrap: true,
              physics: isMobileLandscape
                  ? const AlwaysScrollableScrollPhysics()
                  : const ClampingScrollPhysics(),
              children: [
                // Header with close button
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    24,
                    horizontalPadding,
                    0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          activity.name,
                          style: styleBold(
                            fontSize:
                                isWideScreen
                                    ? 24
                                    : isMediumScreen
                                    ? 22
                                    : 20,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _useCases.closeModal(context),
                        icon: const Icon(Icons.close, color: cBlack),
                      ),
                    ],
                  ),
                ),

                // Activity image - reduced size in landscape mode for mobile
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    16,
                    horizontalPadding,
                    16,
                  ),
                  child: ClipRect(
                    child: Image.asset(
                      activity.imagePath,
                      height: isMobileLandscape
                          ? 120  // Reduced height in mobile landscape
                          : isWideScreen
                              ? 300
                              : isMediumScreen
                              ? 200
                              : 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Activity details
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    isMobileLandscape ? 16 : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time and day - responsive layout
                      isMobileLandscape
                          ? Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                // Time
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: adjustOpacity(cBlack, 0.08),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.access_time, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${activity.startTime} - ${activity.endTime}",
                                        style: styleMedium(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                // Day
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: adjustOpacity(cBlack, 0.08),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.calendar_today, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        uiTexts.getDayName(activity.day),
                                        style: styleMedium(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: adjustOpacity(cBlack, 0.08),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${activity.startTime} - ${activity.endTime}",
                                        style: styleMedium(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: adjustOpacity(cBlack, 0.08),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        uiTexts.getDayName(activity.day),
                                        style: styleMedium(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                      // Location, Trainer, Capacity - Adapted for landscape mode
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Location
                          Padding(
                            padding: EdgeInsets.only(top: isMobileLandscape ? 8 : 16),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    activity.location,
                                    style: styleRegular(
                                      fontSize: isWideScreen ? 18 : isMediumScreen ? 16 : 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Trainer
                          Padding(
                            padding: EdgeInsets.only(top: isMobileLandscape ? 4 : 8),
                            child: Row(
                              children: [
                                const Icon(Icons.person, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _useCases.getTrainerFullName(activity, uiTexts),
                                    style: styleRegular(
                                      fontSize: isWideScreen ? 18 : isMediumScreen ? 16 : 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Capacity
                          Padding(
                            padding: EdgeInsets.only(top: isMobileLandscape ? 4 : 8),
                            child: Row(
                              children: [
                                const Icon(Icons.people, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  "${activity.enrolledMembers.length}/${activity.capacity} ${uiTexts.participants}",
                                  style: styleRegular(
                                    fontSize: isWideScreen ? 18 : isMediumScreen ? 16 : 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Description
                          Padding(
                            padding: EdgeInsets.only(top: isMobileLandscape ? 8 : 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  uiTexts.description,
                                  style: styleBold(
                                    fontSize: isWideScreen ? 20 : isMediumScreen ? 18 : 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  activity.description,
                                  style: styleRegular(
                                    fontSize: isWideScreen ? 16 : 14,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Warning about conflicting activity
                      if (conflictingActivity != null && !isUserEnrolled)
                        Container(
                          margin: const EdgeInsets.only(top: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: adjustOpacity(cOrange, 0.2),
                            borderRadius: BorderRadius.zero,
                            border: Border.all(color: cOrange, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: cOrange,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    uiTexts.timeConflict,
                                    style: styleBold(color: cOrange),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                uiTexts.conflictDescription(
                                  conflictingActivity!.name,
                                  conflictingActivity!.day,
                                  conflictingActivity!.startTime,
                                  conflictingActivity!.endTime,
                                ),
                                style: styleRegular(
                                  fontSize:
                                      isWideScreen
                                          ? 16
                                          : isMediumScreen
                                          ? 14
                                          : 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action button - adjusted for landscape mode
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: buttonWidth,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _useCases.getActionButtonColor(
                      isUserEnrolled,
                      conflictingActivity,
                      adjustOpacity(cGreen, .7),
                      cRedError,
                      cOrange,
                    ),
                    foregroundColor: cWhite,
                    padding: EdgeInsets.symmetric(
                      vertical: isMobileLandscape ? 12 : 16,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    minimumSize: Size(buttonWidth, 0), // Set minimum width
                  ),
                  child: Text(
                    actionLabel,
                    style: styleSemiBold(color: cWhite),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis, // Prevent text overflow
                  ),
                ),
              ),
            ),
          ),
          
          // Scroll indicator for mobile in horizontal mode
          if (isMobileLandscape)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      adjustOpacity(cBlack, 0),
                      adjustOpacity(cBlack, 0.1),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
