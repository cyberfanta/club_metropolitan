import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../core/lang/ui_texts.dart';
import '../../../core/theme/ui_text_styles.dart';
import '../../../domain/cubit/all_activities/all_activities_cubit.dart';
import '../../../domain/cubit/all_activities/all_activities_state.dart';
import '../../../domain/models/activity.dart';
import '../activity_card.dart';
import '../grids/custom_sliver_grid_delegate.dart';

/// A component that displays activities in either a grid or list view
/// depending on the screen size and orientation
class ActivityListView extends StatelessWidget {
  final bool useGridView;
  final bool isDesktop;
  final int columnCount;
  final double cardWidth;
  final double cardHeight;
  final Function(Activity) onActivityTap;

  const ActivityListView({
    super.key,
    required this.useGridView,
    required this.isDesktop,
    required this.columnCount,
    required this.cardWidth,
    required this.cardHeight,
    required this.onActivityTap,
  });

  @override
  Widget build(BuildContext context) {
    final UiTexts uiTexts = Provider.of<UiTexts>(context);

    return BlocBuilder<AllActivitiesCubit, AllActivitiesState>(
      builder: (context, state) {
        if (state.filteredActivities.isEmpty) {
          return Center(
            child: Text(
              uiTexts.noActivitiesFound,
              style: styleMedium(fontSize: 16),
            ),
          );
        }

        return useGridView
            // Grid view for tablet and desktop screens
            ? GridView.builder(
              gridDelegate: CustomSliverGridDelegate(
                crossAxisCount: columnCount,
                spacing: 16,
                childHeight: cardHeight,
              ),
              itemCount: state.filteredActivities.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: _buildActivityItem(
                    context,
                    state.filteredActivities[index],
                  ),
                );
              },
            )
            // List view for mobile screens
            : ListView.builder(
              itemCount: state.filteredActivities.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildActivityItem(
                    context,
                    state.filteredActivities[index],
                  ),
                );
              },
            );
      },
    );
  }

  Widget _buildActivityItem(BuildContext context, Activity activity) {
    final cubit = context.read<AllActivitiesCubit>();

    // Check if user is enrolled in this activity
    final bool isEnrolled = cubit.isUserEnrolled(activity);

    // For conflict determination, we use a simplified approach here
    // The full analysis happens when opening the activity details
    bool hasConflict = false;

    // Only check for conflicts if not already enrolled
    if (!isEnrolled) {
      for (final userActivity in cubit.state.userActivities) {
        // Skip if not on the same day or no time overlap
        if (userActivity.day != activity.day ||
            !cubit.timesOverlap(userActivity, activity)) {
          continue;
        }

        hasConflict = true;

        break;
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: useGridView ? 0 : 16),
      child: ActivityCard(
        activity: activity,
        onTap: () => onActivityTap(activity),
        isDesktop: isDesktop,
        isTablet: !isDesktop && useGridView,
        isUserEnrolled: isEnrolled,
        hasConflict: hasConflict,
      ),
    );
  }
}
