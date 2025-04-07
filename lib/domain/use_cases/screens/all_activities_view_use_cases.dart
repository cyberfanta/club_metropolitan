import 'package:flutter/material.dart';

import '../../../core/lang/ui_texts.dart';
import '../../../core/theme/ui_colors.dart';
import '../../../data/services/data_service.dart';
import '../../../domain/models/activity.dart';
import '../../../presentation/components/dialogs/activity_dialog.dart';
import '../../../utils/stamp.dart';

class AllActivitiesViewUseCases {
  final DataService _dataService = DataService();

  // Method to check if a user is enrolled in an activity
  bool isUserEnrolled(Activity activity) {
    return activity.enrolledMembers.contains(_dataService.currentUserId);
  }

  // Method to quickly check if an activity might have a time conflict
  // This is a synchronous version for use in card construction
  bool hasQuickTimeConflict(Activity activity) {
    // No conflict possible if user is already enrolled
    if (isUserEnrolled(activity)) return false;

    // No conflict possible if there's no available space
    if (activity.capacity <= activity.enrolledMembers.length) return false;

    // Check if there are other user activities on the same day and time
    try {
      // Only check activities on the same day (quick check)
      final userActivities = _dataService.getUserActivitiesSync();

      for (final userActivity in userActivities) {
        if (userActivity.day == activity.day) {
          // Check for time overlap
          // Convert times to minutes for easy comparison
          final actStartMinutes = _timeToMinutes(activity.startTime);
          final actEndMinutes = _timeToMinutes(activity.endTime);
          final userStartMinutes = _timeToMinutes(userActivity.startTime);
          final userEndMinutes = _timeToMinutes(userActivity.endTime);

          // There's a conflict if the start of one is between the start and end of the other
          if ((actStartMinutes >= userStartMinutes &&
                  actStartMinutes < userEndMinutes) ||
              (userStartMinutes >= actStartMinutes &&
                  userStartMinutes < actEndMinutes)) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      // If there's an error, assume no conflict to avoid showing incorrect indicator
      stamp('AllActivitiesViewUseCases', 'Error checking quick conflict: $e');

      return false;
    }
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');

    if (parts.length != 2) {
      return 0;
    }

    try {
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);

      return hours * 60 + minutes;
    } catch (e) {
      return 0;
    }
  }

  // Shows a dialog to confirm activity change
  Future<bool> showChangeActivityDialog(
    BuildContext context,
    UiTexts uiTexts,
    Activity newActivity,
    Activity conflictingActivity,
  ) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => ActivityDialog(
        title: uiTexts.conflictDetectedTitle,
        content: uiTexts.activityConflictDescription(
          conflictingActivity.name,
          newActivity.name,
        ),
        negativeButtonText: uiTexts.stayWithCurrent,
        positiveButtonText: uiTexts.changeToNew,
        positiveButtonColor: cOrange,
        positiveButtonTextColor: cBlack,
        onPositivePressed: () => Navigator.of(context).pop(true),
        onNegativePressed: () => Navigator.of(context).pop(false),
      ),
    ) ?? false;
  }

  // Gets the appropriate action label based on enrollment status
  String getActionLabel(
    UiTexts uiTexts,
    bool isEnrolled,
    bool hasConflict,
    Activity? conflictingActivity,
  ) {
    if (isEnrolled) {
      return uiTexts.cancelEnrollment;
    }
    
    if (hasConflict && conflictingActivity != null) {
      return uiTexts.replaceActivity(conflictingActivity.name);
    }
    
    return uiTexts.joinActivity;
  }
}
