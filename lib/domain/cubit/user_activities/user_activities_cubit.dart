import 'package:bloc/bloc.dart';

import '../../../data/services/data_service.dart';
import '../../../utils/stamp.dart';
import '../../models/activity.dart';
import 'user_activities_state.dart';

class UserActivitiesCubit extends Cubit<UserActivitiesState> {
  final DataService _dataService;

  UserActivitiesCubit(this._dataService) : super(const UserActivitiesState());

  Future<void> loadUserData() async {
    emit(state.copyWith(
      status: UserActivitiesStatus.loading, 
      isLoading: true,
      isLoadingMember: true,
    ));

    try {
      // Load activities and member name in parallel
      final activitiesFuture = _dataService.getUserActivities();
      final memberNameFuture = _dataService.getMemberName();
      
      final results = await Future.wait([activitiesFuture, memberNameFuture]);
      
      final activities = results[0] as List<Activity>;
      final memberName = results[1] as String;

      emit(state.copyWith(
        userActivities: activities,
        memberName: memberName,
        status: UserActivitiesStatus.loaded,
        isLoading: false,
        isLoadingMember: false,
      ));
    } catch (e) {
      stamp('loadUserData', 'Error loading user data: $e');

      emit(state.copyWith(
        status: UserActivitiesStatus.error,
        errorMessage: 'Failed to load user data: $e',
        isLoading: false,
        isLoadingMember: false,
      ));
    }
  }

  Future<void> loadUserActivities() async {
    emit(state.copyWith(
      status: UserActivitiesStatus.loading,
      isLoading: true,
    ));

    try {
      final userActivities = await _dataService.getUserActivities();

      emit(state.copyWith(
        userActivities: userActivities,
        status: UserActivitiesStatus.loaded,
        isLoading: false,
      ));
    } catch (e) {
      stamp('loadUserActivities', 'Error loading user activities: $e');

      emit(state.copyWith(
        status: UserActivitiesStatus.error,
        errorMessage: 'Failed to load activities: $e',
        isLoading: false,
      ));
    }
  }

  Future<void> refreshUserActivities() async {
    // Keep the existing activities but start loading again
    emit(state.copyWith(isLoading: true));
    await loadUserActivities();
  }

  Future<void> refreshUserData() async {
    // Keep the existing state but start loading again
    emit(state.copyWith(isLoading: true, isLoadingMember: true));

    await loadUserData();
  }

  Future<void> cancelActivity(Activity activity) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      final updatedActivities = await _dataService.cancelActivityForUser(activity);

      emit(state.copyWith(
        userActivities: updatedActivities,
        isLoading: false,
      ));
    } catch (e) {
      stamp('cancelActivity', 'Error canceling activity: $e');

      emit(state.copyWith(
        status: UserActivitiesStatus.error,
        errorMessage: 'Failed to cancel activity: $e',
        isLoading: false,
      ));
    }
  }
}
