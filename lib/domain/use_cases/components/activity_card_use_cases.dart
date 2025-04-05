import '../../../core/lang/ui_texts.dart';
import '../../../domain/models/activity.dart';

class ActivityCardUseCases {
  // Get the trainer's full name
  String getTrainerFullName(Activity activity, UiTexts uiTexts) {
    return activity.trainerName != null
        ? '${activity.trainerName} ${activity.trainerLastName ?? ""}'
        : uiTexts.trainerNotAssigned;
  }

  // Capitalize the first letter of a string (for day names)
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
} 