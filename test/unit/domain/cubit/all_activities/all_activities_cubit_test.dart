import 'package:bloc_test/bloc_test.dart';
import 'package:club_metropolitan/data/services/data_service.dart';
import 'package:club_metropolitan/domain/cubit/all_activities/all_activities_cubit.dart';
import 'package:club_metropolitan/domain/cubit/all_activities/all_activities_state.dart';
import 'package:club_metropolitan/domain/models/activity.dart';
import 'package:club_metropolitan/utils/stamp.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../user_activities/user_activities_cubit_test.mocks.dart';

@GenerateMocks([DataService])
void main() {
  late MockDataService mockDataService;
  late AllActivitiesCubit allActivitiesCubit;

  setUp(() {
    stamp('TEST_SETUP', 'Initializing AllActivitiesCubit test dependencies');
    mockDataService = MockDataService();
    allActivitiesCubit = AllActivitiesCubit(mockDataService);
  });

  group('AllActivitiesCubit', () {
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
        'Verifying initial state of AllActivitiesCubit',
      );
      expect(
        allActivitiesCubit.state.status,
        equals(AllActivitiesStatus.initial),
      );
      expect(allActivitiesCubit.state.isLoading, isFalse);
      stamp('TEST_RESULT', 'Initial state test completed successfully\n');
    });

    blocTest<AllActivitiesCubit, AllActivitiesState>(
      'emits loading and loaded states when activities are loaded successfully',
      build: () {
        stamp(
          'TEST_SETUP',
          'Configuring mock for successful activities loading',
        );
        when(
          mockDataService.getAllActivities(),
        ).thenAnswer((_) async => testActivities);
        when(mockDataService.getUserActivities()).thenAnswer((_) async => []);
        return allActivitiesCubit;
      },
      act: (cubit) {
        stamp('TEST_ACT', 'Calling loadAllActivities() to load activities');
        return cubit.loadAllActivities();
      },
      expect: () {
        stamp(
          'TEST_EXPECT',
          'Verifying states emitted during successful loading',
        );
        return [
          predicate<AllActivitiesState>((state) {
            stamp('TEST_STATE', 'Checking loading state: ${state.status}');
            return state.status == AllActivitiesStatus.loading &&
                state.isLoading;
          }),
          predicate<AllActivitiesState>((state) {
            stamp(
              'TEST_STATE',
              'Checking loaded state: ${state.status}, activities: ${state.allActivities.length}',
            );
            return state.status == AllActivitiesStatus.loaded &&
                !state.isLoading &&
                state.allActivities.length == 2 &&
                state.filteredActivities.length == 2;
          }),
        ];
      },
      verify: (_) {
        stamp('TEST_VERIFY', 'Verifying getAllActivities was called once');
        verify(mockDataService.getAllActivities()).called(1);
        stamp('TEST_RESULT', 'Loading activities test completed successfully\n');
      },
    );

    blocTest<AllActivitiesCubit, AllActivitiesState>(
      'emits loading and error states when activities loading fails',
      build: () {
        stamp(
          'TEST_SETUP',
          'Configuring mock to throw exception during activities loading',
        );
        when(
          mockDataService.getAllActivities(),
        ).thenThrow(Exception('Error loading activities'));
        when(mockDataService.getUserActivities()).thenAnswer((_) async => []);
        return allActivitiesCubit;
      },
      act: (cubit) {
        stamp('TEST_ACT', 'Calling loadAllActivities() with error scenario');
        return cubit.loadAllActivities();
      },
      expect: () {
        stamp('TEST_EXPECT', 'Verifying states emitted during error handling');
        return [
          predicate<AllActivitiesState>((state) {
            stamp('TEST_STATE', 'Checking loading state: ${state.status}');
            return state.status == AllActivitiesStatus.loading &&
                state.isLoading;
          }),
          predicate<AllActivitiesState>((state) {
            stamp(
              'TEST_STATE',
              'Checking error state: ${state.status}, error: ${state.errorMessage}',
            );
            return state.status == AllActivitiesStatus.error &&
                !state.isLoading &&
                state.errorMessage != null;
          }),
        ];
      },
      verify: (_) {
        stamp('TEST_VERIFY', 'Verifying getAllActivities was called once');
        verify(mockDataService.getAllActivities()).called(1);
        stamp('TEST_RESULT', 'Error handling test completed successfully\n');
      },
    );

    blocTest<AllActivitiesCubit, AllActivitiesState>(
      'filters activities based on search query',
      build: () {
        stamp('TEST_SETUP', 'Setting up cubit for search filtering test');
        return allActivitiesCubit;
      },
      seed: () {
        stamp('TEST_SEED', 'Setting initial state with test activities');
        return AllActivitiesState(
          allActivities: testActivities,
          filteredActivities: testActivities,
          status: AllActivitiesStatus.loaded,
        );
      },
      act: (cubit) {
        stamp(
          'TEST_ACT',
          'Calling filterActivities() with search query "Yoga"',
        );
        return cubit.filterActivities('Yoga');
      },
      expect: () {
        stamp(
          'TEST_EXPECT',
          'Verifying states emitted during activity filtering',
        );
        return [
          predicate<AllActivitiesState>((state) {
            stamp(
              'TEST_STATE',
              'Checking filtered state: query="${state.searchQuery}", filtered_count=${state.filteredActivities.length}',
            );
            return state.searchQuery == 'Yoga' &&
                state.filteredActivities.length == 1 &&
                state.filteredActivities.first.name == 'Yoga';
          }),
        ];
      },
      verify: (_) {
        stamp('TEST_RESULT', 'Activity filtering test completed successfully\n');
      },
    );

    blocTest<AllActivitiesCubit, AllActivitiesState>(
      'returns all activities when search query is empty',
      build: () {
        stamp('TEST_SETUP', 'Setting up cubit for empty search query test');
        return allActivitiesCubit;
      },
      seed: () {
        stamp(
          'TEST_SEED',
          'Setting initial state with search query and filtered results',
        );
        return AllActivitiesState(
          allActivities: testActivities,
          filteredActivities: [testActivities.first],
          searchQuery: 'Yoga',
          status: AllActivitiesStatus.loaded,
        );
      },
      act: (cubit) {
        stamp('TEST_ACT', 'Calling filterActivities() with empty search query');
        return cubit.filterActivities('');
      },
      expect: () {
        stamp(
          'TEST_EXPECT',
          'Verifying states emitted when clearing search query',
        );
        return [
          predicate<AllActivitiesState>((state) {
            stamp(
              'TEST_STATE',
              'Checking state with empty query: filtered_count=${state.filteredActivities.length}',
            );
            return state.searchQuery == '' &&
                state.filteredActivities.length == 2;
          }),
        ];
      },
      verify: (_) {
        stamp('TEST_RESULT', 'Empty search query test completed successfully\n');
      },
    );

    blocTest<AllActivitiesCubit, AllActivitiesState>(
      'loadAllActivities reloads activities while keeping loading state',
      build: () {
        stamp('TEST_SETUP', 'Configuring mock for activities refresh');
        when(
          mockDataService.getAllActivities(),
        ).thenAnswer((_) async => testActivities);
        when(mockDataService.getUserActivities()).thenAnswer((_) async => []);
        return allActivitiesCubit;
      },
      seed: () {
        stamp('TEST_SEED', 'Setting initial state with partial activities');
        return AllActivitiesState(
          allActivities: [testActivities[0]],
          filteredActivities: [testActivities[0]],
          status: AllActivitiesStatus.loaded,
        );
      },
      act: (AllActivitiesCubit cubit) {
        stamp('TEST_ACT', 'Calling loadAllActivities() to reload activities');
        return cubit.loadAllActivities();
      },
      expect: () {
        stamp(
          'TEST_EXPECT',
          'Verifying states emitted during activities refresh',
        );
        return [
          predicate<AllActivitiesState>((state) {
            stamp('TEST_STATE', 'Checking loading state during refresh');
            return state.isLoading && state.allActivities.length == 1;
          }),
          predicate<AllActivitiesState>((state) {
            stamp(
              'TEST_STATE',
              'Checking refreshed state with updated activities',
            );
            return state.status == AllActivitiesStatus.loaded &&
                !state.isLoading &&
                state.allActivities.length == 2 &&
                state.filteredActivities.length == 2;
          }),
        ];
      },
      verify: (_) {
        stamp(
          'TEST_VERIFY',
          'Verifying getAllActivities was called once during refresh',
        );
        verify(mockDataService.getAllActivities()).called(1);
        stamp('TEST_RESULT', 'Activities reload test completed successfully\n');
      },
    );
  });
}
