import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/lang/ui_texts.dart';
import '../../../core/theme/ui_colors.dart';
import '../../../core/theme/ui_text_styles.dart';
import '../../../data/services/data_service.dart';
import '../../../domain/cubit/all_activities/all_activities_cubit.dart';
import '../../../domain/models/activity.dart';
import '../../../presentation/components/activity_detail_modal.dart';
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
    if (isUserEnrolled(activity)) {
      return false;
    }

    // No conflict possible if there's no available space
    if (activity.capacity <= activity.enrolledMembers.length) {
      return false;
    }

    // Check if there are other user activities on the same day and time
    try {
      // Only check activities on the same day (quick check)
      final userActivities = _dataService.getUserActivitiesSync();

      for (final userActivity in userActivities) {
        // Skip if not on the same day
        if (userActivity.day != activity.day) {
          continue;
        }

        // Check for time overlap
        // Convert times to minutes for easy comparison
        final actStartMinutes = _timeToMinutes(activity.startTime);
        final actEndMinutes = _timeToMinutes(activity.endTime);
        final userStartMinutes = _timeToMinutes(userActivity.startTime);
        final userEndMinutes = _timeToMinutes(userActivity.endTime);

        // There's a conflict if the start of one is between the start and end of the other
        bool hasOverlap =
            (actStartMinutes >= userStartMinutes &&
                actStartMinutes < userEndMinutes) ||
            (userStartMinutes >= actStartMinutes &&
                userStartMinutes < actEndMinutes);

        if (hasOverlap) {
          return true;
        }
      }

      return false;
    } catch (e) {
      // If there's an error, assume no conflict to avoid showing incorrect indicator
      stamp('hasQuickTimeConflict', 'Error checking quick conflict: $e');
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
    stamp(
      'showChangeActivityDialog',
      'Showing change activity dialog for ${newActivity.name}',
    );

    return await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder:
              (context) => ActivityDialog(
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
        ) ??
        false;
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

  /// Shows activity detail modal with enrollment options
  void showActivityDetail(
    BuildContext context,
    Activity activity,
    UiTexts uiTexts,
    Function(List<Activity>) onUserActivitiesChanged,
  ) {
    stamp('showActivityDetail', 'Showing activity detail: ${activity.name}');

    final cubit = context.read<AllActivitiesCubit>();
    final bool isEnrolled = cubit.isUserEnrolled(activity);

    // Check if activity conflicts with another user activity
    Activity? conflictingActivity;
    bool hasConflict = false;

    if (!isEnrolled) {
      // Check for conflicts only if not already enrolled
      for (final userActivity in cubit.state.userActivities) {
        if (userActivity.day != activity.day ||
            !cubit.timesOverlap(userActivity, activity)) {
          continue;
        }

        hasConflict = true;
        conflictingActivity = userActivity;

        break;
      }
    }

    final actionLabel = getActionLabel(
      uiTexts,
      isEnrolled,
      hasConflict,
      conflictingActivity,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: cTransparent,
      builder:
          (context) => ActivityDetailModal(
            activity: activity,
            isUserEnrolled: isEnrolled,
            conflictingActivity: conflictingActivity,
            onAction:
                () => handleEnrollment(
                  context,
                  activity,
                  uiTexts,
                  onUserActivitiesChanged,
                ),
            actionLabel: actionLabel,
          ),
    );
  }

  /// Handles activity enrollment, cancellation, or conflict resolution
  Future<void> handleEnrollment(
    BuildContext context,
    Activity activity,
    UiTexts uiTexts,
    Function(List<Activity>) onUserActivitiesChanged,
  ) async {
    stamp('handleEnrollment', 'Handling enrollment for: ${activity.name}');

    final cubit = context.read<AllActivitiesCubit>();
    final bool isEnrolled = cubit.isUserEnrolled(activity);
    final Activity? conflictingActivity = await cubit.getConflictingActivity(
      activity,
    );
    final bool hasConflict = conflictingActivity != null;

    if (isEnrolled) {
      await handleCancelEnrollment(
        // ignore: use_build_context_synchronously
        context,
        activity,
        uiTexts,
        onUserActivitiesChanged,
      );

      return;
    }

    if (hasConflict) {
      await handleActivityConflict(
        // ignore: use_build_context_synchronously
        context,
        activity,
        conflictingActivity,
        uiTexts,
        onUserActivitiesChanged,
      );

      return;
    }

    await handleDirectEnrollment(
      // ignore: use_build_context_synchronously
      context,
      activity,
      uiTexts,
      onUserActivitiesChanged,
    );
  }

  /// Handles cancellation of activity enrollment
  Future<void> handleCancelEnrollment(
    BuildContext context,
    Activity activity,
    UiTexts uiTexts,
    Function(List<Activity>) onUserActivitiesChanged,
  ) async {
    stamp(
      'handleCancelEnrollment',
      'Handling cancel enrollment for: ${activity.name}',
    );

    final cubit = context.read<AllActivitiesCubit>();

    // Show confirmation dialog before canceling enrollment
    final confirmed = await showCancelConfirmationDialog(
      context,
      activity,
      uiTexts,
    );

    if (!confirmed || !context.mounted) {
      return;
    }

    // Cancel enrollment
    final updatedActivities = await cubit.cancelEnrollment(activity);

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          uiTexts.enrollmentCancelled(activity.name),
          style: styleRegular(color: cWhite),
        ),
        backgroundColor: cRedError,
      ),
    );

    onUserActivitiesChanged(updatedActivities);

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  /// Handles activity conflict resolution
  Future<void> handleActivityConflict(
    BuildContext context,
    Activity newActivity,
    Activity conflictingActivity,
    UiTexts uiTexts,
    Function(List<Activity>) onUserActivitiesChanged,
  ) async {
    stamp(
      'handleActivityConflict',
      'Handling activity conflict between ${conflictingActivity.name} and ${newActivity.name}',
    );

    final cubit = context.read<AllActivitiesCubit>();

    // Show confirmation dialog to change activity
    final shouldReplace = await showChangeActivityDialog(
      context,
      uiTexts,
      newActivity,
      conflictingActivity,
    );

    if (!shouldReplace || !context.mounted) return;

    final updatedActivities = await cubit.changeActivity(
      conflictingActivity,
      newActivity,
    );

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          uiTexts.activityChanged(conflictingActivity.name, newActivity.name),
          style: styleRegular(color: cWhite),
        ),
        backgroundColor: cGreen,
      ),
    );

    onUserActivitiesChanged(updatedActivities);

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  /// Handles direct enrollment in an activity (no conflicts)
  Future<void> handleDirectEnrollment(
    BuildContext context,
    Activity activity,
    UiTexts uiTexts,
    Function(List<Activity>) onUserActivitiesChanged,
  ) async {
    stamp(
      'handleDirectEnrollment',
      'Handling direct enrollment for: ${activity.name}',
    );

    final cubit = context.read<AllActivitiesCubit>();

    // Enroll in activity
    final updatedActivities = await cubit.enrollInActivity(activity);

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          uiTexts.enrollmentSuccessful(activity.name),
          style: styleRegular(color: cWhite),
        ),
        backgroundColor: cGreen,
      ),
    );

    onUserActivitiesChanged(updatedActivities);

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  /// Shows a confirmation dialog for canceling enrollment
  Future<bool> showCancelConfirmationDialog(
    BuildContext context,
    Activity activity,
    UiTexts uiTexts,
  ) async {
    stamp(
      'showCancelConfirmationDialog',
      'Showing cancel confirmation for: ${activity.name}',
    );

    return await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder:
              (context) => ActivityDialog(
                title: uiTexts.cancelEnrollmentTitle,
                content: uiTexts.cancelEnrollmentQuestion(activity.name),
                negativeButtonText: uiTexts.no,
                positiveButtonText: uiTexts.yesCancel,
                positiveButtonColor: cRedError,
                positiveButtonTextColor: cWhite,
                onPositivePressed: () => Navigator.of(context).pop(true),
                onNegativePressed: () => Navigator.of(context).pop(false),
              ),
        ) ??
        false;
  }

  /// Handles search text changes
  void handleSearch(BuildContext context, String query, UiTexts uiTexts) {
    stamp('handleSearch', 'Handling search: $query');

    context.read<AllActivitiesCubit>().filterActivities(query, uiTexts);
  }
}
