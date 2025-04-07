import 'package:club_metropolitan/domain/models/activity.dart';
import 'package:equatable/equatable.dart';

enum AllActivitiesStatus { initial, loading, loaded, error, filtering }

class AllActivitiesState extends Equatable {
  final List<Activity> allActivities;
  final List<Activity> filteredActivities;
  final List<Activity> userActivities;
  final String searchQuery;
  final AllActivitiesStatus status;
  final String? errorMessage;
  final bool isLoading;

  const AllActivitiesState({
    this.allActivities = const [],
    this.filteredActivities = const [],
    this.userActivities = const [],
    this.searchQuery = '',
    this.status = AllActivitiesStatus.initial,
    this.errorMessage,
    this.isLoading = false,
  });

  AllActivitiesState copyWith({
    List<Activity>? allActivities,
    List<Activity>? filteredActivities,
    List<Activity>? userActivities,
    String? searchQuery,
    AllActivitiesStatus? status,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AllActivitiesState(
      allActivities: allActivities ?? this.allActivities,
      filteredActivities: filteredActivities ?? this.filteredActivities,
      userActivities: userActivities ?? this.userActivities,
      searchQuery: searchQuery ?? this.searchQuery,
      status: status ?? this.status,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    allActivities,
    filteredActivities,
    userActivities,
    searchQuery,
    status,
    errorMessage,
    isLoading,
  ];
}
