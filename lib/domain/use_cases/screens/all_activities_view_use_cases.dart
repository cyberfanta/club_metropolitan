import 'package:flutter/material.dart';

import '../../../core/lang/ui_texts.dart';
import '../../../core/theme/ui_colors.dart';
import '../../../core/theme/ui_text_styles.dart';
import '../../../data/services/data_service.dart';
import '../../../domain/models/activity.dart';
import '../../../utils/stamp.dart';

class AllActivitiesViewUseCases {
  final DataService _dataService = DataService();

  // Method to load activities
  Future<Map<String, dynamic>> loadActivities() async {
    try {
      final allActivities = await _dataService.getActivities();
      final userActivities = await _dataService.getUserActivities();

      return {
        'success': true,
        'allActivities': allActivities,
        'userActivities': userActivities
      };
    } catch (e) {
      stamp('AllActivitiesViewUseCases', 'Error loading activities: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Method to apply filter to activities
  List<Activity> applyFilter(List<Activity> allActivities, String query) {
    if (query.isEmpty) {
      return List.from(allActivities);
    } else {
      final lowercaseQuery = query.toLowerCase();
      return allActivities.where((activity) {
        return activity.name.toLowerCase().contains(lowercaseQuery) ||
            activity.day.toLowerCase().contains(lowercaseQuery) ||
            (activity.trainerName?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();
    }
  }

  // Method to check if a user is enrolled in an activity
  bool isUserEnrolled(Activity activity) {
    return activity.enrolledMembers.contains(_dataService.currentUserId);
  }

  // Method to check if an activity has a time conflict
  Future<bool> hasTimeConflict(Activity activity) async {
    return await _dataService.hasTimeConflict(activity);
  }

  // Method to get the conflicting activity
  Future<Activity?> getConflictingActivity(Activity activity) async {
    return await _dataService.getConflictingActivity(activity);
  }

  // Methods for actions
  
  // Cancel enrollment
  Future<Map<String, dynamic>> cancelEnrollment(Activity activity) async {
    final success = await _dataService.cancelEnrollment(activity.id);
    if (success) {
      final userActivities = await _dataService.getUserActivities();
      return {
        'success': true,
        'userActivities': userActivities,
        'message': 'enrollmentCancelled'
      };
    }
    return {'success': false};
  }

  // Change activity (replace conflicting activity with new one)
  Future<Map<String, dynamic>> changeActivity(Activity activity, Activity conflictingActivity) async {
    // Cancel the previous activity
    await _dataService.cancelEnrollment(conflictingActivity.id);
    
    // Enroll in the new activity
    final success = await _dataService.enrollInActivity(activity.id);
    
    if (success) {
      final userActivities = await _dataService.getUserActivities();
      return {
        'success': true,
        'userActivities': userActivities,
        'message': 'activityChanged',
        'oldActivity': conflictingActivity.name,
        'newActivity': activity.name
      };
    }
    return {'success': false};
  }

  // Enroll in activity
  Future<Map<String, dynamic>> enrollInActivity(Activity activity) async {
    final success = await _dataService.enrollInActivity(activity.id);
    if (success) {
      final userActivities = await _dataService.getUserActivities();
      return {
        'success': true,
        'userActivities': userActivities,
        'message': 'enrollmentSuccessful'
      };
    }
    return {'success': false};
  }

  // Display confirmation dialog to change activity
  Future<bool> showChangeActivityDialog(BuildContext context, UiTexts uiTexts, Activity activity, Activity conflictingActivity) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text(
          uiTexts.changeActivity,
          style: styleBold(fontSize: 18),
        ),
        content: Text(
          uiTexts.changeActivityQuestion(conflictingActivity.name, activity.name),
          style: styleRegular(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              uiTexts.no,
              style: styleRegular(),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cBlack,
              foregroundColor: cWhite,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              uiTexts.yesChange,
              style: styleRegular(color: cWhite),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  // Get the action label for activity detail
  String getActionLabel(UiTexts uiTexts, bool isUserEnrolled, bool hasConflict, Activity? conflictingActivity) {
    if (isUserEnrolled) {
      return uiTexts.cancelEnrollment;
    } else if (hasConflict && conflictingActivity != null) {
      return uiTexts.changeActivityFor(conflictingActivity.name);
    } else {
      return uiTexts.enroll;
    }
  }
} 