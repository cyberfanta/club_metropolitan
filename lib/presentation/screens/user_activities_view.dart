import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../core/lang/ui_texts.dart';
import '../../core/theme/ui_colors.dart';
import '../../core/theme/ui_text_styles.dart';
import '../../domain/cubit/user_activities/user_activities_cubit.dart';
import '../../domain/cubit/user_activities/user_activities_state.dart';
import '../../domain/use_cases/screens/user_activities_view_use_cases.dart';
import '../components/activity_card.dart';

class UserActivitiesView extends StatefulWidget {
  const UserActivitiesView({super.key});

  static const routeName = '/UserActivitiesView';

  @override
  State<UserActivitiesView> createState() => _UserActivitiesViewState();
}

class _UserActivitiesViewState extends State<UserActivitiesView> {
  final UserActivitiesViewUseCases _useCases = UserActivitiesViewUseCases();
  late UiTexts _uiTexts;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _uiTexts = Provider.of<UiTexts>(context);
  }

  @override
  void initState() {
    super.initState();

    // Load all user data through the Cubit
    context.read<UserActivitiesCubit>().loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (value, _) async {
        if (value) {
          return;
        }

        await _useCases.backActions(
          UserActivitiesView.routeName.substring(
            1,
            UserActivitiesView.routeName.length,
          ),
          context,
          _uiTexts,
        )();
      },
      child: Scaffold(
        key: const ValueKey(UserActivitiesView.routeName),
        backgroundColor: cLightGray,
        appBar: AppBar(
          backgroundColor: cWhite,
          elevation: 0,
          title: BlocBuilder<UserActivitiesCubit, UserActivitiesState>(
            builder: (context, state) {
              return Text(
                state.isLoadingMember
                    ? _uiTexts.myActivities
                    : "${_uiTexts.myActivities} (${state.memberName})",
                style: styleBold(fontSize: 20),
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.list, color: cBlack),
              onPressed:
                  () => _useCases.navigateToAllActivities(
                    context,
                    () => context.read<UserActivitiesCubit>().refreshUserData(),
                  ),
              tooltip: _uiTexts.viewAllActivities,
            ),
          ],
        ),
        body: Stack(
          children: [
            // Background with author and GitHub link
            Positioned.fill(child: _buildBackgroundCredit()),
            // Main content
            BlocBuilder<UserActivitiesCubit, UserActivitiesState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.userActivities.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh:
                      () =>
                          context.read<UserActivitiesCubit>().refreshUserData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.userActivities.length,
                    itemBuilder: (context, index) {
                      final activity = state.userActivities[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ActivityCard(
                          activity: activity,
                          onTap:
                              () => _useCases.showActivityDetail(
                                context,
                                activity,
                                _uiTexts,
                              ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundCredit() {
    String gitHubUrl = 'https://github.com/cyberfanta/club_metropolitan';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Logo image (will be displayed when available)
          const Spacer(),
          Image.asset(
            'assets/images/extras/club_metropolitan_logo.png',
            width: 120,
            height: 120,
            opacity: const AlwaysStoppedAnimation<double>(0.4),
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: adjustOpacity(cOrange, 0.05),
                ),
                child: Icon(
                  Icons.fitness_center,
                  size: 60,
                  color: adjustOpacity(cOrange, 0.2),
                ),
              );
            },
          ),
          // Creator information
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  key: Key("MyName"),
                  "Julio César León",
                  style: styleRegular(
                    color: adjustOpacity(cBlack, 0.5),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () async {
                    await _useCases.openUrl(context, gitHubUrl);
                  },
                  child: Text(
                    gitHubUrl,
                    style: styleRegular(
                      color: adjustOpacity(cBlack, 0.5),
                      fontSize: 12,
                      useUnderline: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: adjustOpacity(cBlack, 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _uiTexts.noActivitiesEnrolled,
            style: styleRegular(
              fontSize: 18,
              color: adjustOpacity(cBlack, 0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed:
                () => _useCases.navigateToAllActivities(
                  context,
                  () => context.read<UserActivitiesCubit>().refreshUserData(),
                ),
            style: ElevatedButton.styleFrom(
              backgroundColor: cBlack,
              foregroundColor: cWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(_uiTexts.exploreActivities, style: styleMedium()),
            ),
          ),
        ],
      ),
    );
  }
}
