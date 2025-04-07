import 'package:club_metropolitan/domain/models/activity.dart';
import 'package:equatable/equatable.dart';

enum UserActivitiesStatus { initial, loading, loaded, error }

class UserActivitiesState extends Equatable {
  final List<Activity> userActivities;
  final UserActivitiesStatus status;
  final String? errorMessage;
  final bool isLoading;
  final String memberName;
  final bool isLoadingMember;

  const UserActivitiesState({
    this.userActivities = const [],
    this.status = UserActivitiesStatus.initial,
    this.errorMessage,
    this.isLoading = false,
    this.memberName = "",
    this.isLoadingMember = true,
  });

  UserActivitiesState copyWith({
    List<Activity>? userActivities,
    UserActivitiesStatus? status,
    String? errorMessage,
    bool? isLoading,
    String? memberName,
    bool? isLoadingMember,
  }) {
    return UserActivitiesState(
      userActivities: userActivities ?? this.userActivities,
      status: status ?? this.status,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
      memberName: memberName ?? this.memberName,
      isLoadingMember: isLoadingMember ?? this.isLoadingMember,
    );
  }

  @override
  List<Object?> get props => [
    userActivities, 
    status, 
    errorMessage, 
    isLoading, 
    memberName, 
    isLoadingMember
  ];
}
