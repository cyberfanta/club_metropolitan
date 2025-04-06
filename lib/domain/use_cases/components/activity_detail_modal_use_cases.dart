import 'package:flutter/material.dart';

import '../../../core/lang/ui_texts.dart';
import '../../../domain/models/activity.dart';

class ActivityDetailModalUseCases {
  // Get the trainer's full name
  String getTrainerFullName(Activity activity, UiTexts uiTexts) {
    return activity.trainerName != null
        ? '${activity.trainerName} ${activity.trainerLastName ?? ""}'
        : uiTexts.trainerNotAssigned;
  }

  // Close the modal
  void closeModal(BuildContext context) {
    Navigator.pop(context);
  }

  // Get appropriate background color for the action button
  Color getActionButtonColor(
    bool isUserEnrolled,
    Activity? conflictingActivity,
    Color defaultColor,
    Color cancelColor,
    Color warningColor,
  ) {
    if (isUserEnrolled) {
      return cancelColor; // Red for cancellation
    }

    if (conflictingActivity != null) {
      return warningColor; // Orange for conflicting activities
    }

    return defaultColor; // Default color (usually black)
  }
}
