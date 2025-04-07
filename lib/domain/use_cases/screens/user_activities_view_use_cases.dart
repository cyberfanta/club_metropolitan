import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/lang/ui_texts.dart';
import '../../../core/theme/ui_colors.dart';
import '../../../core/theme/ui_text_styles.dart';
import '../../../domain/cubit/user_activities/user_activities_cubit.dart';
import '../../../domain/models/activity.dart';
import '../../../presentation/components/activity_detail_modal.dart';
import '../../../presentation/components/dialogs/activity_dialog.dart';
import '../../../presentation/components/dialogs/app_close_dialog.dart';
import '../../../presentation/screens/all_activities_view.dart';
import '../../../utils/stamp.dart';
import '../components/app_close_dialog_use_cases.dart';

class UserActivitiesViewUseCases {
  Future<void> Function() initState(BuildContext context) => () async {};

  Future<void> Function() backActions(
    String tag,
    BuildContext context,
    UiTexts uiTexts,
  ) => () async {
    stamp(tag, "Button Pressed: \"Back\"", decoratorChar: " * ");

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        AppCloseDialogUseCases logoutUseCases = AppCloseDialogUseCases();

        return AppCloseDialog(
          tag: tag,
          uiTexts: uiTexts,
          okAction: logoutUseCases.logout(context),
          cancelAction: logoutUseCases.cancel(context),
        );
      },
    );
  };

  /// Shows activity detail modal with options to cancel enrollment
  void showActivityDetail(
    BuildContext context,
    Activity activity,
    UiTexts uiTexts,
  ) {
    stamp('UserActivitiesView', 'Showing activity detail: ${activity.name}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: cTransparent,
      builder:
          (context) => ActivityDetailModal(
            activity: activity,
            isUserEnrolled: true,
            onAction: () async {
              // Show confirmation dialog before canceling enrollment
              final confirmed = await showCancelConfirmationDialog(
                context,
                activity,
                uiTexts,
              );

              if (confirmed && context.mounted) {
                // Cancel enrollment using the Cubit
                // ignore: use_build_context_synchronously
                await context.read<UserActivitiesCubit>().cancelActivity(
                  activity,
                );

                // Display feedback to the user about cancellation
                // ignore: use_build_context_synchronously
                showCancellationFeedback(
                  // ignore: use_build_context_synchronously
                  context,
                  activity,
                  uiTexts,
                );

                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              }
            },
            actionLabel: uiTexts.cancelEnrollment,
          ),
    );
  }

  /// Shows a confirmation dialog for canceling enrollment
  Future<bool> showCancelConfirmationDialog(
    BuildContext context,
    Activity activity,
    UiTexts uiTexts,
  ) async {
    stamp(
      'UserActivitiesView',
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

  /// Navigate to All Activities screen
  void navigateToAllActivities(
    BuildContext context,
    Function() onRefreshUserData,
  ) {
    stamp('UserActivitiesView', 'Navigating to All Activities');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AllActivitiesView(
              onUserActivitiesChanged: (_) {
                onRefreshUserData();
              },
            ),
      ),
    );
  }

  /// Displays feedback SnackBar when canceling an activity
  void showCancellationFeedback(
    BuildContext context,
    Activity activity,
    UiTexts uiTexts,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          uiTexts.enrollmentCancelled(activity.name),
          style: styleRegular(color: cWhite),
        ),
        backgroundColor: cRedError,
      ),
    );
  }
}
