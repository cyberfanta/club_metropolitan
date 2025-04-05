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

  // Días de la semana
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
}
