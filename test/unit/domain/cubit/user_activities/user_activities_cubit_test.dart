import 'package:bloc_test/bloc_test.dart';
import 'package:club_metropolitan/data/services/data_service.dart';
import 'package:club_metropolitan/domain/cubit/user_activities/user_activities_cubit.dart';
import 'package:club_metropolitan/domain/cubit/user_activities/user_activities_state.dart';
import 'package:club_metropolitan/domain/models/activity.dart';
import 'package:club_metropolitan/utils/stamp.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../all_activities/all_activities_cubit_test.mocks.dart';

@GenerateMocks([DataService])
void main() {
  late MockDataService mockDataService;
  late UserActivitiesCubit userActivitiesCubit;

  setUp(() {
    stamp('TEST_SETUP', 'Initializing UserActivitiesCubit test dependencies');
    mockDataService = MockDataService();
    userActivitiesCubit = UserActivitiesCubit(mockDataService);
  });

  group('UserActivitiesCubit', () {
    final testActivities = [
      Activity(
        id: 1,
        name: 'Yoga',
        description: 'Yoga class',
        imageUrl: 'assets/images/yoga.jpg',
        trainerId: 1,
        enrolledMembers: const [],
        day: 'lunes',
        startTime: '10:00',
        endTime: '11:00',
        capacity: 20,
        location: 'Room 1',
        trainerName: 'John',
        trainerLastName: 'Doe',
      ),
      Activity(
        id: 2,
        name: 'Spinning',
        description: 'Spinning class',
        imageUrl: 'assets/images/spinning.jpg',
        trainerId: 2,
        enrolledMembers: const [],
        day: 'martes',
        startTime: '14:00',
        endTime: '15:00',
        capacity: 15,
        location: 'Room 2',
        trainerName: 'Jane',
        trainerLastName: 'Smith',
      ),
    ];

    test('initial state is correct', () {
      stamp(
        'TEST_INITIAL_STATE',
        'Verifying initial state of UserActivitiesCubit',
      );
      expect(
        userActivitiesCubit.state.status,
        equals(UserActivitiesStatus.initial),
      );
      expect(userActivitiesCubit.state.isLoading, isFalse);
      stamp('TEST_RESULT', 'Initial state test completed successfully\n');
    });

    blocTest<UserActivitiesCubit, UserActivitiesState>(
      'emits loading and loaded states when activities are loaded successfully',
      build: () {
        stamp(
          'TEST_SETUP',
          'Configuring mock for successful user activities loading',
        );
        when(
          mockDataService.getUserActivities(),
        ).thenAnswer((_) async => testActivities);
        return userActivitiesCubit;
      },
      act: (cubit) {
        stamp(
          'TEST_ACT',
          'Calling loadUserActivities() to load user activities',
        );
        return cubit.loadUserActivities();
      },
      expect: () {
        stamp(
          'TEST_EXPECT',
          'Verifying states emitted during successful loading',
        );
        return [
          predicate<UserActivitiesState>((state) {
            stamp('TEST_STATE', 'Checking loading state: ${state.status}');
            return state.status == UserActivitiesStatus.loading &&
                state.isLoading;
          }),
          predicate<UserActivitiesState>((state) {
            stamp(
              'TEST_STATE',
              'Checking loaded state: ${state.status}, activities: ${state.userActivities.length}',
            );
            return state.status == UserActivitiesStatus.loaded &&
                !state.isLoading &&
                state.userActivities.length == 2;
          }),
        ];
      },
      verify: (_) {
        stamp(
          'TEST_RESULT',
          'Loading user activities test completed successfully\n',
        );
      },
    );

    blocTest<UserActivitiesCubit, UserActivitiesState>(
      'emits loading and error states when activities loading fails',
      build: () {
        stamp(
          'TEST_SETUP',
          'Configuring mock to throw exception during user activities loading',
        );
        when(
          mockDataService.getUserActivities(),
        ).thenThrow(Exception('Error loading user activities'));
        return userActivitiesCubit;
      },
      act: (cubit) {
        stamp('TEST_ACT', 'Calling loadUserActivities() with error scenario');
        return cubit.loadUserActivities();
      },
      expect: () {
        stamp('TEST_EXPECT', 'Verifying states emitted during error handling');
        return [
          predicate<UserActivitiesState>((state) {
            stamp('TEST_STATE', 'Checking loading state: ${state.status}');
            return state.status == UserActivitiesStatus.loading &&
                state.isLoading;
          }),
          predicate<UserActivitiesState>((state) {
            stamp(
              'TEST_STATE',
              'Checking error state: ${state.status}, error: ${state.errorMessage}',
            );
            return state.status == UserActivitiesStatus.error &&
                !state.isLoading &&
                state.errorMessage != null;
          }),
        ];
      },
      verify: (_) {
        stamp('TEST_RESULT', 'Error handling test completed successfully\n');
      },
    );

    blocTest<UserActivitiesCubit, UserActivitiesState>(
      'cancelActivity correctly removes an activity from user activities',
      build: () {
        stamp('TEST_SETUP', 'Configuring mock for activity cancellation');
        when(
          mockDataService.cancelActivityForUser(any),
        ).thenAnswer((_) async => [testActivities[1]]);
        return userActivitiesCubit;
      },
      seed: () {
        stamp('TEST_SEED', 'Setting initial state with test activities');
        return UserActivitiesState(
          userActivities: testActivities,
          status: UserActivitiesStatus.loaded,
        );
      },
      act: (cubit) {
        stamp('TEST_ACT', 'Calling cancelActivity() to remove an activity');
        return cubit.cancelActivity(testActivities[0]);
      },
      expect: () {
        stamp(
          'TEST_EXPECT',
          'Verifying states emitted during activity cancellation',
        );
        return [
          predicate<UserActivitiesState>((state) {
            stamp('TEST_STATE', 'Checking loading state during cancellation');
            return state.isLoading;
          }),
          predicate<UserActivitiesState>((state) {
            stamp(
              'TEST_STATE',
              'Checking updated state after cancellation: ${state.userActivities.length} activities',
            );
            return !state.isLoading &&
                state.userActivities.length == 1 &&
                state.userActivities.first.id == 2;
          }),
        ];
      },
      verify: (_) {
        stamp(
          'TEST_RESULT',
          'Activity cancellation test completed successfully\n',
        );
      },
    );

    blocTest<UserActivitiesCubit, UserActivitiesState>(
      'loadUserData loads both activities and member name',
      build: () {
        stamp('TEST_SETUP', 'Configuring mocks for user data loading');
        when(
          mockDataService.getUserActivities(),
        ).thenAnswer((_) async => testActivities);
        when(
          mockDataService.getMemberName(),
        ).thenAnswer((_) async => 'John Doe');
        return userActivitiesCubit;
      },
      act: (cubit) {
        stamp(
          'TEST_ACT',
          'Calling loadUserData() to load activities and member name',
        );
        return cubit.loadUserData();
      },
      expect: () {
        stamp(
          'TEST_EXPECT',
          'Verifying states emitted during user data loading',
        );
        return [
          predicate<UserActivitiesState>((state) {
            stamp('TEST_STATE', 'Checking loading state for user data');
            return state.status == UserActivitiesStatus.loading &&
                state.isLoading &&
                state.isLoadingMember;
          }),
          predicate<UserActivitiesState>((state) {
            stamp(
              'TEST_STATE',
              'Checking loaded state with activities and member name',
            );
            return state.status == UserActivitiesStatus.loaded &&
                !state.isLoading &&
                !state.isLoadingMember &&
                state.userActivities.length == 2 &&
                state.memberName == 'John Doe';
          }),
        ];
      },
      verify: (_) {
        stamp('TEST_RESULT', 'User data loading test completed successfully\n');
      },
    );

    blocTest<UserActivitiesCubit, UserActivitiesState>(
      'refreshUserActivities reloads activities while keeping loading state',
      build: () {
        stamp('TEST_SETUP', 'Configuring mock for activities refresh');
        when(
          mockDataService.getUserActivities(),
        ).thenAnswer((_) async => testActivities);
        return userActivitiesCubit;
      },
      seed: () {
        stamp('TEST_SEED', 'Setting initial state with partial activities');
        return UserActivitiesState(
          userActivities: [testActivities[0]],
          status: UserActivitiesStatus.loaded,
        );
      },
      act: (cubit) {
        stamp(
          'TEST_ACT',
          'Calling refreshUserActivities() to reload activities',
        );
        return cubit.refreshUserActivities();
      },
      expect: () {
        stamp(
          'TEST_EXPECT',
          'Verifying states emitted during activities refresh',
        );
        return [
          predicate<UserActivitiesState>((state) {
            stamp('TEST_STATE', 'Checking initial loading state');
            return state.isLoading &&
                state.userActivities.length == 1 &&
                state.status == UserActivitiesStatus.loaded;
          }),
          predicate<UserActivitiesState>((state) {
            stamp('TEST_STATE', 'Checking loading state during refresh');
            return state.isLoading &&
                state.status == UserActivitiesStatus.loading;
          }),
          predicate<UserActivitiesState>((state) {
            stamp(
              'TEST_STATE',
              'Checking refreshed state with updated activities',
            );
            return state.status == UserActivitiesStatus.loaded &&
                !state.isLoading &&
                state.userActivities.length == 2;
          }),
        ];
      },
      verify: (_) {
        stamp('TEST_VERIFY', 'Verifying getUserActivities was called once');
        verify(mockDataService.getUserActivities()).called(1);
        stamp(
          'TEST_RESULT',
          'Activities refresh test completed successfully\n',
        );
      },
    );
  });
}
