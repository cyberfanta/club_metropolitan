import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/lang/ui_texts.dart';
import '../../../core/theme/ui_colors.dart';
import '../../../core/theme/ui_text_styles.dart';
import '../../../domain/cubit/all_activities/all_activities_cubit.dart';
import '../../../domain/models/activity.dart';
import '../../../domain/use_cases/screens/all_activities_view_use_cases.dart';
import '../dialogs/activity_dialog.dart';

class ActivityDetailActions {
  final BuildContext context;
  final AllActivitiesViewUseCases useCases;
  final Function(List<Activity>) onUserActivitiesChanged;

  ActivityDetailActions({
    required this.context,
    required this.useCases,
    required this.onUserActivitiesChanged,
  });

  Future<void> handleEnrollment(Activity activity) async {
    final cubit = context.read<AllActivitiesCubit>();
    final bool isEnrolled = cubit.isUserEnrolled(activity);
    final Activity? conflictingActivity = await cubit.getConflictingActivity(
      activity,
    );
    final bool hasConflict = conflictingActivity != null;

    if (isEnrolled) {
      await _handleCancelEnrollment(activity);
    } else if (hasConflict) {
      await _handleActivityConflict(activity, conflictingActivity);
    } else {
      await _handleDirectEnrollment(activity);
    }
  }

  Future<void> _handleCancelEnrollment(Activity activity) async {
    final cubit = context.read<AllActivitiesCubit>();
    final UiTexts uiTexts = Provider.of<UiTexts>(context, listen: false);

    // Show confirmation dialog before canceling enrollment
    final confirmed = await _showCancelConfirmationDialog(activity);

    if (confirmed) {
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
  }

  Future<void> _handleActivityConflict(
    Activity activity,
    Activity conflictingActivity,
  ) async {
    final cubit = context.read<AllActivitiesCubit>();
    final UiTexts uiTexts = Provider.of<UiTexts>(context, listen: false);

    // Show confirmation dialog to change activity
    final shouldReplace = await useCases.showChangeActivityDialog(
      context,
      uiTexts,
      activity,
      conflictingActivity,
    );

    if (shouldReplace) {
      final updatedActivities = await cubit.changeActivity(
        conflictingActivity,
        activity,
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            uiTexts.activityChanged(conflictingActivity.name, activity.name),
            style: styleRegular(color: cWhite),
          ),
          backgroundColor: cGreen,
        ),
      );

      onUserActivitiesChanged(updatedActivities);

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  Future<void> _handleDirectEnrollment(Activity activity) async {
    final cubit = context.read<AllActivitiesCubit>();
    final UiTexts uiTexts = Provider.of<UiTexts>(context, listen: false);

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

  // Show a confirmation dialog for canceling enrollment
  Future<bool> _showCancelConfirmationDialog(Activity activity) async {
    final UiTexts uiTexts = Provider.of<UiTexts>(context, listen: false);

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

  String getActionLabel(Activity activity) {
    final cubit = context.read<AllActivitiesCubit>();
    final UiTexts uiTexts = Provider.of<UiTexts>(context, listen: false);
    final bool isEnrolled = cubit.isUserEnrolled(activity);
    Activity? conflictingActivity;

    // We need to check synchronously for UI display
    bool hasConflict = false;

    if (!isEnrolled) {
      for (final userActivity in cubit.state.userActivities) {
        if (userActivity.day == activity.day &&
            cubit.timesOverlap(userActivity, activity)) {
          hasConflict = true;
          conflictingActivity = userActivity;

          break;
        }
      }
    }

    return useCases.getActionLabel(
      uiTexts,
      isEnrolled,
      hasConflict,
      conflictingActivity,
    );
  }
}
