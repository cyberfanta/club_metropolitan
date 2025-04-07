import 'package:flutter/material.dart';

import 'ui_text_en.dart';
import 'ui_text_es.dart';

class UiTexts extends ChangeNotifier {
  UiTexts(this._locale);

  Locale _locale;

  set locale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  String get title {
    if (_locale.languageCode == 'es') {
      return UiTextEs().title;
    }
    return UiTextEn().title;
  }

  String get yes {
    if (_locale.languageCode == 'es') {
      return UiTextEs().yes;
    }

    return UiTextEn().yes;
  }

  String get no {
    if (_locale.languageCode == 'es') {
      return UiTextEs().no;
    }

    return UiTextEn().no;
  }

  String get appCloseTitleText {
    if (_locale.languageCode == 'es') {
      return UiTextEs().appCloseTitleText;
    }

    return UiTextEn().appCloseTitleText;
  }

  String get appCloseSubText {
    if (_locale.languageCode == 'es') {
      return UiTextEs().appCloseSubText;
    }

    return UiTextEn().appCloseSubText;
  }

  String get appCloseContext {
    if (_locale.languageCode == 'es') {
      return UiTextEs().appCloseContext;
    }

    return UiTextEn().appCloseContext;
  }

  // User Activities View
  String get myActivities {
    if (_locale.languageCode == 'es') {
      return UiTextEs().myActivities;
    }
    return UiTextEn().myActivities;
  }

  String get noActivitiesEnrolled {
    if (_locale.languageCode == 'es') {
      return UiTextEs().noActivitiesEnrolled;
    }
    return UiTextEn().noActivitiesEnrolled;
  }

  String get exploreActivities {
    if (_locale.languageCode == 'es') {
      return UiTextEs().exploreActivities;
    }
    return UiTextEn().exploreActivities;
  }

  String get viewAllActivities {
    if (_locale.languageCode == 'es') {
      return UiTextEs().viewAllActivities;
    }
    return UiTextEn().viewAllActivities;
  }

  // All Activities View
  String get allActivities {
    if (_locale.languageCode == 'es') {
      return UiTextEs().allActivities;
    }
    return UiTextEn().allActivities;
  }

  String get searchActivities {
    if (_locale.languageCode == 'es') {
      return UiTextEs().searchActivities;
    }
    return UiTextEn().searchActivities;
  }

  String get noActivitiesFound {
    if (_locale.languageCode == 'es') {
      return UiTextEs().noActivitiesFound;
    }
    return UiTextEn().noActivitiesFound;
  }

  String get enrolled {
    if (_locale.languageCode == 'es') {
      return UiTextEs().enrolled;
    }
    return UiTextEn().enrolled;
  }

  String get adjustable {
    if (_locale.languageCode == 'es') {
      return UiTextEs().adjustable;
    }
    return UiTextEn().adjustable;
  }

  // Activity Detail
  String get trainer {
    if (_locale.languageCode == 'es') {
      return UiTextEs().trainer;
    }
    return UiTextEn().trainer;
  }

  String get description {
    if (_locale.languageCode == 'es') {
      return UiTextEs().description;
    }
    return UiTextEn().description;
  }

  String get cancelEnrollment {
    if (_locale.languageCode == 'es') {
      return UiTextEs().cancelEnrollment;
    }
    return UiTextEn().cancelEnrollment;
  }

  String get enroll {
    if (_locale.languageCode == 'es') {
      return UiTextEs().enroll;
    }
    return UiTextEn().enroll;
  }

  String get trainerNotAssigned {
    if (_locale.languageCode == 'es') {
      return UiTextEs().trainerNotAssigned;
    }
    return UiTextEn().trainerNotAssigned;
  }

  String get participants {
    if (_locale.languageCode == 'es') {
      return UiTextEs().participants;
    }
    return UiTextEn().participants;
  }

  String get timeConflict {
    if (_locale.languageCode == 'es') {
      return UiTextEs().timeConflict;
    }
    return UiTextEn().timeConflict;
  }

  String conflictDescription(
    String activityName,
    String day,
    String startTime,
    String endTime,
  ) {
    String template =
        _locale.languageCode == 'es'
            ? UiTextEs().conflictDescription
            : UiTextEn().conflictDescription;
    return template
        .replaceAll('{0}', activityName)
        .replaceAll('{1}', getDayName(day))
        .replaceAll('{2}', startTime)
        .replaceAll('{3}', endTime);
  }

  // Dialog texts
  String get changeActivity {
    if (_locale.languageCode == 'es') {
      return UiTextEs().changeActivity;
    }
    return UiTextEn().changeActivity;
  }

  String changeActivityQuestion(String activity1, String activity2) {
    String template =
        _locale.languageCode == 'es'
            ? UiTextEs().changeActivityQuestion
            : UiTextEn().changeActivityQuestion;
    return template.replaceAll('{0}', activity1).replaceAll('{1}', activity2);
  }

  String get yesChange {
    if (_locale.languageCode == 'es') {
      return UiTextEs().yesChange;
    }
    return UiTextEn().yesChange;
  }

  String changeActivityFor(String activityName) {
    String template =
        _locale.languageCode == 'es'
            ? UiTextEs().changeActivityFor
            : UiTextEn().changeActivityFor;
    return template.replaceAll('{0}', activityName);
  }

  String get conflictingSchedule {
    if (_locale.languageCode == 'es') {
      return UiTextEs().conflictingSchedule;
    }
    return UiTextEn().conflictingSchedule;
  }

  String alreadyEnrolledMessage(String activityName) {
    String template =
        _locale.languageCode == 'es'
            ? UiTextEs().alreadyEnrolledMessage
            : UiTextEn().alreadyEnrolledMessage;
    return template.replaceAll('{0}', activityName);
  }

  // Days of the week
  String getDayName(String day) {
    if (_locale.languageCode == 'es') {
      return UiTextEs().getDayName(day);
    }
    return UiTextEn().getDayName(day);
  }

  // Snackbar messages
  String enrollmentCancelled(String activityName) {
    String template =
        _locale.languageCode == 'es'
            ? UiTextEs().enrollmentCancelled
            : UiTextEn().enrollmentCancelled;
    return template.replaceAll('{0}', activityName);
  }

  String enrollmentSuccessful(String activityName) {
    String template =
        _locale.languageCode == 'es'
            ? UiTextEs().enrollmentSuccessful
            : UiTextEn().enrollmentSuccessful;
    return template.replaceAll('{0}', activityName);
  }

  String activityChanged(String oldActivity, String newActivity) {
    String template =
        _locale.languageCode == 'es'
            ? UiTextEs().activityChanged
            : UiTextEn().activityChanged;
    return template
        .replaceAll('{0}', oldActivity)
        .replaceAll('{1}', newActivity);
  }

  // Cancel enrollment confirmation dialog
  String get cancelEnrollmentTitle {
    if (_locale.languageCode == 'es') {
      return UiTextEs().cancelEnrollmentTitle;
    }
    return UiTextEn().cancelEnrollmentTitle;
  }

  String cancelEnrollmentQuestion(String activityName) {
    String template =
        _locale.languageCode == 'es'
            ? UiTextEs().cancelEnrollmentQuestion
            : UiTextEn().cancelEnrollmentQuestion;
    return template.replaceAll('{0}', activityName);
  }

  String get yesCancel {
    if (_locale.languageCode == 'es') {
      return UiTextEs().yesCancel;
    }
    return UiTextEn().yesCancel;
  }
}
