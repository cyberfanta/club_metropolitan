import 'package:bloc/bloc.dart';
import 'package:club_metropolitan/domain/cubit/all_activities/all_activities_state.dart';
import 'package:club_metropolitan/domain/models/activity.dart';
import 'package:flutter/material.dart';

import '../../../data/services/data_service.dart';
import '../../../utils/stamp.dart';

class AllActivitiesCubit extends Cubit<AllActivitiesState> {
  final DataService _dataService;

  AllActivitiesCubit(this._dataService) : super(const AllActivitiesState());

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

  void filterActivities(String query) {
    if (query.isEmpty) {
      emit(
        state.copyWith(
          filteredActivities: state.allActivities,
          searchQuery: '',
        ),
      );
      return;
    }

    final normalizedQuery = query.toLowerCase();
    final filtered =
        state.allActivities.where((activity) {
          final name = activity.name.toLowerCase();
          final description = activity.description.toLowerCase();
          final trainer = activity.trainer.name.toLowerCase();

          return name.contains(normalizedQuery) ||
              description.contains(normalizedQuery) ||
              trainer.contains(normalizedQuery);
        }).toList();

    emit(
      state.copyWith(
        filteredActivities: filtered,
        searchQuery: query,
        status: AllActivitiesStatus.filtering,
      ),
    );
  }

  bool isUserEnrolled(Activity activity) {
    return state.userActivities.any(
      (userActivity) => userActivity.id == activity.id,
    );
  }

  Future<Activity?> getConflictingActivity(Activity activity) async {
    try {
      for (final userActivity in state.userActivities) {
        if (userActivity.id != activity.id &&
            userActivity.day == activity.day &&
            timesOverlap(userActivity, activity)) {
          return userActivity;
        }
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

  bool timesOverlap(Activity a, Activity b) {
    final aStart = TimeOfDay(hour: a.startHour, minute: a.startMinute);
    final aEnd = TimeOfDay(hour: a.endHour, minute: a.endMinute);
    final bStart = TimeOfDay(hour: b.startHour, minute: b.startMinute);
    final bEnd = TimeOfDay(hour: b.endHour, minute: b.endMinute);

    final aStartMinutes = aStart.hour * 60 + aStart.minute;
    final aEndMinutes = aEnd.hour * 60 + aEnd.minute;
    final bStartMinutes = bStart.hour * 60 + bStart.minute;
    final bEndMinutes = bEnd.hour * 60 + bEnd.minute;

    return (aStartMinutes < bEndMinutes && aEndMinutes > bStartMinutes);
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
}
