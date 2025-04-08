import 'package:bloc/bloc.dart';
import 'package:club_metropolitan/domain/cubit/all_activities/all_activities_state.dart';
import 'package:club_metropolitan/domain/models/activity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/lang/ui_texts.dart';
import '../../../data/services/data_service.dart';
import '../../../utils/stamp.dart';

class AllActivitiesCubit extends Cubit<AllActivitiesState> {
  final DataService _dataService;
  late BuildContext _context;
  late UiTexts _uiTexts;

  AllActivitiesCubit(this._dataService) : super(const AllActivitiesState());

  // Set context to access UiTexts
  void setContext(BuildContext context) {
    _context = context;
    _uiTexts = Provider.of<UiTexts>(_context, listen: false);
  }

  Future<void> loadAllActivities() async {
    emit(state.copyWith(status: AllActivitiesStatus.loading, isLoading: true));

    try {
      // Load activities and user activities in parallel
      final allActivitiesFuture = _dataService.getAllActivities();
      final userActivitiesFuture = _dataService.getUserActivities();

      final results = await Future.wait([
        allActivitiesFuture,
        userActivitiesFuture,
      ]);

      final allActivities = results[0];
      final userActivities = results[1];

      emit(
        state.copyWith(
          allActivities: allActivities,
          filteredActivities: allActivities,
          userActivities: userActivities,
          status: AllActivitiesStatus.loaded,
          isLoading: false,
        ),
      );
    } catch (e) {
      stamp("loadAllActivities", 'Error loading activities: $e');

      emit(
        state.copyWith(
          status: AllActivitiesStatus.error,
          errorMessage: 'Failed to load activities: $e',
          isLoading: false,
        ),
      );
    }
  }

  void filterActivities(String query, [UiTexts? uiTexts]) {
    if (query.isEmpty) {
      emit(
        state.copyWith(
          filteredActivities: state.allActivities,
          searchQuery: '',
        ),
      );
      return;
    }

    // Use provided uiTexts or try to get it from context
    UiTexts? textsToUse = uiTexts;

    if (textsToUse == null) {
      try {
        textsToUse = _uiTexts;
      } catch (e) {
        // If _uiTexts is not initialized, continue without it
        stamp("filterActivities", "UiTexts not available: $e");
      }
    }

    final normalizedQuery = query.toLowerCase();

    final filtered =
        state.allActivities.where((activity) {
          // Filter by activity name
          final name = activity.name.toLowerCase();

          // Filter by activity description
          final description = activity.description.toLowerCase();

          // Filter by trainer name
          final trainerName = activity.trainer.name.toLowerCase();

          // Filter by trainer last name
          final trainerLastName = activity.trainer.lastName.toLowerCase();

          // Filter by day of week (translated if uiTexts is available)
          bool dayMatch = false;
          
          if (textsToUse != null) {
            // First we try with the translated day
            final translatedDay = textsToUse.getDayName(activity.day).toLowerCase();
            dayMatch = translatedDay.contains(normalizedQuery);
            
            // If there's no match, we check if the user is searching for a day in another language
            // and compare it with the original day
            if (!dayMatch) {
              dayMatch = activity.day.toLowerCase().contains(normalizedQuery);
            }
          } else {
            // If UiTexts is not available, we use only the original day
            dayMatch = activity.day.toLowerCase().contains(normalizedQuery);
          }

          return name.contains(normalizedQuery) ||
              description.contains(normalizedQuery) ||
              trainerName.contains(normalizedQuery) ||
              trainerLastName.contains(normalizedQuery) ||
              dayMatch;
        }).toList();

    emit(
      state.copyWith(
        filteredActivities: filtered,
        searchQuery: query,
        status: AllActivitiesStatus.filtering,
      ),
    );
  }

  /// Check if the current user is enrolled in the given activity
  bool isUserEnrolled(Activity activity) {
    final int currentUserId = _dataService.currentUserId;

    // Log for debugging
    stamp(
      "isUserEnrolled",
      "Checking if user $currentUserId is enrolled in ${activity.name}",
    );

    return activity.enrolledMembers.contains(currentUserId);
  }

  /// Check if two activities have overlapping times
  bool timesOverlap(Activity activity1, Activity activity2) {
    // Convert times to minutes for easy comparison
    final act1StartMinutes = _timeToMinutes(activity1.startTime);
    final act1EndMinutes = _timeToMinutes(activity1.endTime);
    final act2StartMinutes = _timeToMinutes(activity2.startTime);
    final act2EndMinutes = _timeToMinutes(activity2.endTime);

    // Log for debugging
    stamp(
      "timesOverlap",
      "Checking time overlap between ${activity1.name} (${activity1.startTime}-${activity1.endTime}) and ${activity2.name} (${activity2.startTime}-${activity2.endTime})",
    );

    // There's a conflict if start time of one activity is between start and end of the other
    return (act1StartMinutes >= act2StartMinutes &&
            act1StartMinutes < act2EndMinutes) ||
        (act2StartMinutes >= act1StartMinutes &&
            act2StartMinutes < act1EndMinutes);
  }

  Future<Activity?> getConflictingActivity(Activity activity) async {
    try {
      for (final userActivity in state.userActivities) {
        if (userActivity.id == activity.id) continue;
        if (userActivity.day != activity.day) continue;
        if (!timesOverlap(userActivity, activity)) continue;

        return userActivity;
      }

      return null;
    } catch (e) {
      stamp(
        "getConflictingActivity",
        'Error checking for conflicting activity: $e',
      );

      return null;
    }
  }

  Future<List<Activity>> cancelEnrollment(Activity activity) async {
    emit(state.copyWith(isLoading: true));

    try {
      final updatedUserActivities = await _dataService.cancelActivityForUser(
        activity,
      );

      emit(
        state.copyWith(userActivities: updatedUserActivities, isLoading: false),
      );

      return updatedUserActivities;
    } catch (e) {
      stamp("cancelEnrollment", 'Error canceling enrollment: $e');

      emit(
        state.copyWith(
          status: AllActivitiesStatus.error,
          errorMessage: 'Failed to cancel enrollment: $e',
          isLoading: false,
        ),
      );

      return state.userActivities;
    }
  }

  Future<List<Activity>> changeActivity(
    Activity oldActivity,
    Activity newActivity,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Cancel the old activity and then enroll in the new one
      await _dataService.cancelActivityForUser(oldActivity);

      final updatedUserActivities = await _dataService.enrollUserInActivity(
        newActivity.id,
      );

      emit(
        state.copyWith(userActivities: updatedUserActivities, isLoading: false),
      );

      return updatedUserActivities;
    } catch (e) {
      stamp("changeActivity", 'Error changing activity: $e');

      emit(
        state.copyWith(
          status: AllActivitiesStatus.error,
          errorMessage: 'Failed to change activity: $e',
          isLoading: false,
        ),
      );

      return state.userActivities;
    }
  }

  Future<List<Activity>> enrollInActivity(Activity activity) async {
    emit(state.copyWith(isLoading: true));

    try {
      final updatedUserActivities = await _dataService.enrollUserInActivity(
        activity.id,
      );

      emit(
        state.copyWith(userActivities: updatedUserActivities, isLoading: false),
      );

      return updatedUserActivities;
    } catch (e) {
      stamp("enrollInActivity", 'Error enrolling in activity: $e');

      emit(
        state.copyWith(
          status: AllActivitiesStatus.error,
          errorMessage: 'Failed to enroll in activity: $e',
          isLoading: false,
        ),
      );

      return state.userActivities;
    }
  }

  /// Convert a time string (HH:MM) to minutes
  int _timeToMinutes(String time) {
    final parts = time.split(':');

    if (parts.length != 2) {
      stamp("timeToMinutes", "Invalid time format: $time");

      return 0;
    }

    try {
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);

      return hours * 60 + minutes;
    } catch (e) {
      stamp("timeToMinutes", "Error parsing time: $time - $e");

      return 0;
    }
  }
}
