import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/models/activity.dart';
import '../../domain/models/trainer.dart';
import '../../utils/stamp.dart';

class DataService {
  // Singleton pattern
  static final DataService _instance = DataService._internal();

  factory DataService() => _instance;

  DataService._internal();

  // Data caching
  List<Activity>? _activities;
  List<Trainer>? _trainers;

  // Current user ID (for demo purposes)
  final int _currentUserId = 1; // Assuming user with ID 1 for this demo

  // Getter for the current user ID
  int get currentUserId => _currentUserId;

  // Load activities from JSON
  Future<List<Activity>> getActivities() async {
    if (_activities != null) {
      return _activities!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/entry_data/list_activities.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      _activities = jsonList.map((json) => Activity.fromJson(json)).toList();

      // Load trainers to associate with activities
      final trainers = await getTrainers();

      // Associate trainer names with activities
      for (var activity in _activities!) {
        final trainer = trainers.firstWhere(
          (trainer) => trainer.id == activity.trainerId,
          orElse:
              () => Trainer(
                id: 0,
                name: 'Unknown',
                lastName: '',
                dni: '',
                cv: '',
                activities: [],
              ),
        );

        activity.trainerName = trainer.name;
        activity.trainerLastName = trainer.lastName;
      }

      return _activities!;
    } catch (e) {
      stamp('DataService', 'Error loading activities: $e');

      return [];
    }
  }

  // Load trainers from JSON
  Future<List<Trainer>> getTrainers() async {
    if (_trainers != null) {
      return _trainers!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/entry_data/list_trainers.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      _trainers = jsonList.map((json) => Trainer.fromJson(json)).toList();

      return _trainers!;
    } catch (e) {
      stamp('DataService', 'Error loading trainers: $e');
      return [];
    }
  }

  // Get activities where the current user is enrolled
  Future<List<Activity>> getUserActivities() async {
    final activities = await getActivities();

    return activities
        .where((activity) => activity.enrolledMembers.contains(_currentUserId))
        .toList();
  }

  // Enroll current user in an activity
  Future<bool> enrollInActivity(int activityId) async {
    final activities = await getActivities();
    final activityIndex = activities.indexWhere((a) => a.id == activityId);

    if (activityIndex != -1) {
      if (!activities[activityIndex].enrolledMembers.contains(_currentUserId)) {
        activities[activityIndex].enrolledMembers.add(_currentUserId);

        return true;
      }
    }

    return false;
  }

  // Cancel enrollment from an activity
  Future<bool> cancelEnrollment(int activityId) async {
    final activities = await getActivities();
    final activityIndex = activities.indexWhere((a) => a.id == activityId);

    if (activityIndex != -1) {
      if (activities[activityIndex].enrolledMembers.contains(_currentUserId)) {
        activities[activityIndex].enrolledMembers.remove(_currentUserId);

        return true;
      }
    }

    return false;
  }

  // Check if the current user has any time conflict with the given activity
  Future<bool> hasTimeConflict(Activity activity) async {
    final userActivities = await getUserActivities();

    // Skip the conflict check if the user is already enrolled in this activity
    if (activity.enrolledMembers.contains(_currentUserId)) {
      return false;
    }

    return userActivities.any(
      (userActivity) =>
          userActivity.id != activity.id &&
          userActivity.conflictsWith(activity),
    );
  }

  // Get the activity that conflicts with the given activity
  Future<Activity?> getConflictingActivity(Activity activity) async {
    final userActivities = await getUserActivities();

    // Skip the conflict check if the user is already enrolled in this activity
    if (activity.enrolledMembers.contains(_currentUserId)) {
      return null;
    }

    // Find the first conflicting activity
    for (var userActivity in userActivities) {
      if (userActivity.id != activity.id &&
          userActivity.conflictsWith(activity)) {
        return userActivity;
      }
    }

    return null;
  }
}
