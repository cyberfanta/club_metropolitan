import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../core/lang/ui_texts.dart';
import '../../core/theme/ui_colors.dart';
import '../../core/theme/ui_text_styles.dart';
import '../../domain/cubit/all_activities/all_activities_cubit.dart';
import '../../domain/cubit/all_activities/all_activities_state.dart';
import '../../domain/models/activity.dart';
import '../../domain/use_cases/screens/all_activities_view_use_cases.dart';
import '../components/activity_card.dart';
import '../components/activity_detail_modal.dart';

class CustomSliverGridDelegate extends SliverGridDelegate {
  final int crossAxisCount;
  final double spacing;
  final double childHeight;

  const CustomSliverGridDelegate({
    required this.crossAxisCount,
    required this.spacing,
    required this.childHeight,
  });

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    // Calculate total available width
    final double availableWidth = constraints.crossAxisExtent;

    // Calculate width of each item considering spacing
    final double usableWidth = availableWidth - spacing * (crossAxisCount - 1);
    final double cellWidth = usableWidth / crossAxisCount;

    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childHeight + spacing,
      crossAxisStride: cellWidth + spacing,
      childMainAxisExtent: childHeight,
      childCrossAxisExtent: cellWidth,
      reverseCrossAxis: false,
    );
  }

  @override
  bool shouldRelayout(CustomSliverGridDelegate oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount ||
        oldDelegate.spacing != spacing ||
        oldDelegate.childHeight != childHeight;
  }
}

class AllActivitiesView extends StatefulWidget {
  final Function(List<Activity>) onUserActivitiesChanged;

  const AllActivitiesView({super.key, required this.onUserActivitiesChanged});

  @override
  State<AllActivitiesView> createState() => _AllActivitiesViewState();
}

class _AllActivitiesViewState extends State<AllActivitiesView> {
  final AllActivitiesViewUseCases _useCases = AllActivitiesViewUseCases();

  // For search functionality
  final TextEditingController _searchController = TextEditingController();

  // Add UiTexts as a class variable
  late UiTexts _uiTexts;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _uiTexts = Provider.of<UiTexts>(context);
    
    // Set context in cubit to access UiTexts
    context.read<AllActivitiesCubit>().setContext(context);
  }

  @override
  void initState() {
    super.initState();

    // Load activities using the Cubit
    context.read<AllActivitiesCubit>().loadAllActivities();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  void _showActivityDetail(Activity activity) async {
    final cubit = context.read<AllActivitiesCubit>();
    final bool isEnrolled = cubit.isUserEnrolled(activity);
    final Activity? conflictingActivity = await cubit.getConflictingActivity(activity);
    final bool hasConflict = conflictingActivity != null;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: cTransparent,
      builder: (context) => ActivityDetailModal(
        activity: activity,
        isUserEnrolled: isEnrolled,
        conflictingActivity: conflictingActivity,
        onAction: isEnrolled
            ? () async {
                // Show confirmation dialog before canceling enrollment
                final confirmed = await _showCancelConfirmationDialog(activity);
                
                if (confirmed && mounted) {
                  // Cancel enrollment
                  final updatedActivities = await cubit.cancelEnrollment(activity);
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
                  widget.onUserActivitiesChanged(updatedActivities);
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              }
            : hasConflict
                ? () async {
                    // Show confirmation dialog to change activity
                    final shouldReplace = await _useCases.showChangeActivityDialog(
                      context,
                      _uiTexts,
                      activity,
                      conflictingActivity,
                    );

                    if (shouldReplace && mounted) {
                      final updatedActivities = await cubit.changeActivity(
                        conflictingActivity,
                        activity
                      );
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _uiTexts.activityChanged(
                              conflictingActivity.name,
                              activity.name,
                            ),
                            style: styleRegular(color: cWhite),
                          ),
                          backgroundColor: cGreen,
                        ),
                      );
                      widget.onUserActivitiesChanged(updatedActivities);
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    }
                                    }
                : () async {
                    // Enroll in activity
                    final updatedActivities = await cubit.enrollInActivity(activity);
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _uiTexts.enrollmentSuccessful(activity.name),
                          style: styleRegular(color: cWhite),
                        ),
                        backgroundColor: cGreen,
                      ),
                    );
                    widget.onUserActivitiesChanged(updatedActivities);
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  },
        actionLabel: _useCases.getActionLabel(
          _uiTexts,
          isEnrolled,
          hasConflict,
          conflictingActivity,
        ),
      ),
    );
  }
  
  // Show a confirmation dialog for canceling enrollment
  Future<bool> _showCancelConfirmationDialog(Activity activity) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Square corners for the dialog
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
                borderRadius: BorderRadius.zero, // Square corners for the 'No' button
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
                borderRadius: BorderRadius.zero, // Square corners for the 'Yes' button
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
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get current orientation
        final orientation = MediaQuery.of(context).orientation;
        final isLandscape = orientation == Orientation.landscape;

        // Improve device type detection considering orientation
        final bool isMobile = constraints.maxWidth < 600;
        final bool isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 960;
        final bool isDesktop = constraints.maxWidth >= 960;

        // Detect specifically horizontal mobile
        final bool isMobileLandscape = isMobile && isLandscape;

        // Use grid view for tablet, desktop or horizontal mobile
        final bool useGridView = !isMobile || isMobileLandscape;

        // Fixed card sizes for width and height - adjust for horizontal mobile
        final double cardWidth = isDesktop ? 400 : 350;
        final double cardHeight =
            isDesktop ? 400 : (isMobileLandscape ? 300 : 350);

        // Dynamically calculate number of columns based on available width
        int calculateColumnCount(double availableWidth) {
          if (isMobile && !isLandscape) {
            return 1;
          }

          if (isMobile && isLandscape) {
            return 2; // 2 columns in horizontal mobile
          }

          if (isTablet) {
            return 2;
          }

          // For desktop, calculate columns based on available width
          // Allowing up to 6 columns on very wide screens
          final int maxColumns = 6;
          final double availableSpace =
              availableWidth - 32; // 32 = total padding

          // Considering space between columns (16px)
          int calculatedColumns = (availableSpace / (cardWidth + 16)).floor();

          // Limit between 3 and maxColumns
          return calculatedColumns.clamp(3, maxColumns);
        }

        // Calculate column count for current view
        final int columnCount = calculateColumnCount(constraints.maxWidth);

        return Scaffold(
          backgroundColor: cLightGray,
          appBar: AppBar(
            backgroundColor: cWhite,
            elevation: 0,
            title: Text(_uiTexts.allActivities, style: styleBold(fontSize: 20)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: cBlack),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: BlocBuilder<AllActivitiesCubit, AllActivitiesState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search and filters - adaptive to available width
                    Container(
                      width:
                          isDesktop
                              ? 400
                              : isMobileLandscape
                              ? constraints.maxWidth * 0.6
                              : MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: cWhite,
                        borderRadius: BorderRadius.zero,
                        boxShadow: [
                          BoxShadow(
                            color: adjustOpacity(cBlack, 0.1),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (query) {
                          context.read<AllActivitiesCubit>().filterActivities(
                            query,
                            _uiTexts,
                          );
                        },
                        decoration: InputDecoration(
                          hintText: _uiTexts.searchActivities,
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),

                    // Switch vertical spacing in horizontal mode for mobile
                    SizedBox(height: isMobileLandscape ? 16 : 24),

                    // Activities list - adaptable to grid or list based on width
                    Expanded(
                      child:
                          state.filteredActivities.isEmpty
                              ? Center(
                                child: Text(
                                  _uiTexts.noActivitiesFound,
                                  style: styleMedium(fontSize: 16),
                                ),
                              )
                              : useGridView
                              // Grid view for tablet and desktop screens
                              ? GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: columnCount,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: cardWidth / cardHeight,
                                    ),
                                itemCount: state.filteredActivities.length,
                                itemBuilder: (context, index) {
                                  return _buildActivityItem(
                                    context,
                                    state.filteredActivities[index],
                                    isDesktop: isDesktop,
                                    useGridView: useGridView,
                                  );
                                },
                              )
                              // List view for mobile screens
                              : ListView.builder(
                                itemCount: state.filteredActivities.length,
                                itemBuilder: (context, index) {
                                  return _buildActivityItem(
                                    context,
                                    state.filteredActivities[index],
                                    isDesktop: isDesktop,
                                    useGridView: useGridView,
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    Activity activity, {
    required bool isDesktop,
    required bool useGridView,
  }) {
    final cubit = context.read<AllActivitiesCubit>();

    // Check if user is enrolled in this activity
    final bool isEnrolled = cubit.isUserEnrolled(activity);

    // For conflict determination, we use a simplified approach here
    // The full analysis happens when opening the activity details
    bool hasConflict = false;

    if (!isEnrolled) {
      for (final userActivity in cubit.state.userActivities) {
        if (userActivity.day == activity.day &&
            cubit.timesOverlap(userActivity, activity)) {
          hasConflict = true;
          break;
        }
      }
    }

    // Method to build each activity item (reusable for grid and list)
    return Padding(
      padding: EdgeInsets.only(bottom: useGridView ? 0 : 16),
      child: ActivityCard(
        activity: activity,
        onTap: () => _showActivityDetail(activity),
        isDesktop: isDesktop,
        isTablet: !isDesktop && useGridView,
        isUserEnrolled: isEnrolled,
        hasConflict: hasConflict,
      ),
    );
  }
}
