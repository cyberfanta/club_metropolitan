import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../core/lang/ui_texts.dart';
import '../../core/theme/ui_colors.dart';
import '../../core/theme/ui_text_styles.dart';
import '../../domain/cubit/user_activities/user_activities_cubit.dart';
import '../../domain/cubit/user_activities/user_activities_state.dart';
import '../../domain/models/activity.dart';
import '../../domain/use_cases/screens/user_activities_view_use_cases.dart';
import '../components/activity_card.dart';
import '../components/activity_detail_modal.dart';
import 'all_activities_view.dart';

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

  void _showActivityDetail(Activity activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: cTransparent,
      builder:
          (context) => ActivityDetailModal(
            activity: activity,
            isUserEnrolled: true,
            onAction: () async {
              // Show confirmation dialog before canceling enrollment
              final confirmed = await _showCancelConfirmationDialog(activity);

              if (confirmed && mounted) {
                // Cancel enrollment using the Cubit
                // ignore: use_build_context_synchronously
                await context.read<UserActivitiesCubit>().cancelActivity(
                  activity,
                );

                // Display feedback to the user about cancellation
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _uiTexts.enrollmentCancelled(activity.name),
                      style: styleRegular(color: cWhite),
                    ),
                    backgroundColor: cRedError,
                  ),
                );

                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              }
            },
            actionLabel: _uiTexts.cancelEnrollment,
          ),
    );
  }

  // Show a confirmation dialog for canceling enrollment
  Future<bool> _showCancelConfirmationDialog(Activity activity) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.zero, // Square corners for the dialog
                ),
                title: Text(
                  _uiTexts.cancelEnrollmentTitle,
                  style: styleBold(fontSize: 18),
                ),
                content: Text(
                  _uiTexts.cancelEnrollmentQuestion(activity.name),
                  style: styleRegular(),
                ),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .zero, // Square corners for the 'No' button
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(_uiTexts.no, style: styleRegular()),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cRedError,
                      foregroundColor: cWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .zero, // Square corners for the 'Yes' button
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      _uiTexts.yesCancel,
                      style: styleRegular(color: cWhite),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
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
              icon: Icon(Icons.list, color: cBlack),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AllActivitiesView(
                          onUserActivitiesChanged: (_) {
                            context
                                .read<UserActivitiesCubit>()
                                .refreshUserData();
                          },
                        ),
                  ),
                );
              },
              tooltip: _uiTexts.viewAllActivities,
            ),
          ],
        ),
        body: BlocBuilder<UserActivitiesCubit, UserActivitiesState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.userActivities.isEmpty) {
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => AllActivitiesView(
                                  onUserActivitiesChanged: (_) {
                                    context
                                        .read<UserActivitiesCubit>()
                                        .refreshUserData();
                                  },
                                ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cBlack,
                        foregroundColor: cWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Text(
                          _uiTexts.exploreActivities,
                          style: styleMedium(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh:
                  () => context.read<UserActivitiesCubit>().refreshUserData(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.userActivities.length,
                itemBuilder: (context, index) {
                  final activity = state.userActivities[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ActivityCard(
                      activity: activity,
                      onTap: () => _showActivityDetail(activity),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
