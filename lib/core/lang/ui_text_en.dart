class UiTextEn {
  String get title {
    return "Club Metropolitan App Challenge";
  }

  String get yes {
    return "Yes";
  }

  String get no {
    return "No";
  }

  String get appCloseTitleText {
    return "WARNING";
  }

  String get appCloseSubText {
    return "Are you sure?";
  }

  String get appCloseContext {
    return "You are about to close the app.";
  }

  // User Activities View
  String get myActivities {
    return "My Activities";
  }

  String get noActivitiesEnrolled {
    return "You don't have any enrolled activities";
  }

  String get exploreActivities {
    return "Explore activities";
  }

  String get viewAllActivities {
    return "View all activities";
  }

  // All Activities View
  String get allActivities {
    return "All Activities";
  }

  String get searchActivities {
    return "Search by name, day or trainer";
  }

  String get noActivitiesFound {
    return "No activities found";
  }

  String get enrolled {
    return "Enrolled";
  }

  String get adjustable {
    return "Adjustable";
  }

  // Activity Detail
  String get trainer {
    return "Trainer";
  }

  String get description {
    return "Description";
  }

  String get cancelEnrollment {
    return "Cancel enrollment";
  }

  String get enroll {
    return "Enroll";
  }

  String get trainerNotAssigned {
    return "Trainer not assigned";
  }

  String get participants {
    return "participants";
  }

  String get timeConflict {
    return "Time Conflict";
  }

  String get conflictDescription {
    return "You're already enrolled in \"{0}\" on {1} from {2} to {3}. You can replace that activity with this one if you wish.";
  }

  // Dialog texts
  String get changeActivity {
    return "Change activity?";
  }

  String get changeActivityQuestion {
    return "Do you want to cancel your enrollment to \"{0}\" and enroll in \"{1}\"?";
  }

  String get yesChange {
    return "Yes, change";
  }

  String get changeActivityFor {
    return "Change {0} for this activity";
  }

  String get conflictingSchedule {
    return "Conflicting schedule";
  }

  String get alreadyEnrolledMessage {
    return "You are already enrolled in \"{0}\" at the same day and time. You can replace that activity with this one if you wish.";
  }

  // Snackbar messages
  String get enrollmentCancelled {
    return "You have cancelled your enrollment to {0}";
  }

  String get enrollmentSuccessful {
    return "You have enrolled in {0}";
  }

  String get activityChanged {
    return "You have changed {0} for {1}";
  }

  // Days of the week
  String getDayName(String dayKey) {
    switch (dayKey.toLowerCase()) {
      case 'lunes':
        return 'Monday';
      case 'martes':
        return 'Tuesday';
      case 'miercoles':
        return 'Wednesday';
      case 'jueves':
        return 'Thursday';
      case 'viernes':
        return 'Friday';
      case 'sabado':
        return 'Saturday';
      case 'domingo':
        return 'Sunday';
      default:
        return dayKey;
    }
  }

  String get cancelEnrollmentTitle {
    return 'Cancel Enrollment';
  }

  String get cancelEnrollmentQuestion {
    return 'Are you sure you want to cancel your enrollment in {0}?';
  }

  String get yesCancel {
    return 'Yes, Cancel';
  }

  // Today's activities
  String get todayActivities {
    return 'Today\'s Activities';
  }

  // Activity conflict resolution
  String get conflictDetectedTitle {
    return 'Schedule Conflict Detected';
  }

  String activityConflictDescription(
    String currentActivity,
    String newActivity,
  ) {
    return 'You are already enrolled in "$currentActivity" at this time.\nWould you like to switch to "$newActivity"?';
  }

  String get stayWithCurrent {
    return 'Stay with Current';
  }

  String get changeToNew {
    return 'Switch to New';
  }

  String replaceActivity(String activityName) {
    return 'Replace $activityName';
  }

  String get joinActivity {
    return 'Enroll Activity';
  }
}
