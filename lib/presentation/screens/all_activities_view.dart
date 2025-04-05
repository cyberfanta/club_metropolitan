import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/lang/ui_texts.dart';
import '../../core/theme/ui_colors.dart';
import '../../core/theme/ui_text_styles.dart';
import '../../domain/models/activity.dart';
import '../../domain/use_cases/screens/all_activities_view_use_cases.dart';
import '../components/activity_card.dart';
import '../components/activity_detail_modal.dart';

class AllActivitiesView extends StatefulWidget {
  final Function(List<Activity>) onUserActivitiesChanged;

  const AllActivitiesView({super.key, required this.onUserActivitiesChanged});

  @override
  State<AllActivitiesView> createState() => _AllActivitiesViewState();
}

class _AllActivitiesViewState extends State<AllActivitiesView> {
  final AllActivitiesViewUseCases _useCases = AllActivitiesViewUseCases();
  
  List<Activity> _allActivities = [];
  bool _isLoading = true;

  // For search functionality
  final TextEditingController _searchController = TextEditingController();
  List<Activity> _filteredActivities = [];
  String _searchQuery = '';

  // Add UiTexts as a class variable
  late UiTexts _uiTexts;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _uiTexts = Provider.of<UiTexts>(context);
  }

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _useCases.loadActivities();

    if (result['success']) {
      setState(() {
        _allActivities = result['allActivities'];
        _applyFilter();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredActivities = _useCases.applyFilter(_allActivities, _searchQuery);
    });
  }

  void _showActivityDetail(Activity activity) async {
    final bool isEnrolled = _useCases.isUserEnrolled(activity);
    final bool hasConflict = await _useCases.hasTimeConflict(activity);

    // Get conflicting activity if it exists
    Activity? conflictingActivity;
    if (hasConflict) {
      conflictingActivity = await _useCases.getConflictingActivity(activity);
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ActivityDetailModal(
            activity: activity,
            isUserEnrolled: isEnrolled,
            conflictingActivity: conflictingActivity,
            onAction:
                isEnrolled
                    ? () async {
                      // Cancel enrollment
                      final result = await _useCases.cancelEnrollment(activity);
                      if (result['success']) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _uiTexts.enrollmentCancelled(activity.name),
                              style: styleRegular(),
                            ),
                            backgroundColor: cGray,
                          ),
                        );
                        widget.onUserActivitiesChanged(
                          result['userActivities'],
                        );
                      }
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      setState(() {}); // Refresh UI
                    }
                    : hasConflict
                    ? () async {
                      // Show confirmation dialog to change activity
                      if (conflictingActivity != null) {
                        final shouldReplace = await _useCases
                            .showChangeActivityDialog(
                              context,
                              _uiTexts,
                              activity,
                              conflictingActivity,
                            );

                        if (shouldReplace) {
                          final result = await _useCases.changeActivity(
                            activity,
                            conflictingActivity,
                          );

                          if (result['success']) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _uiTexts.activityChanged(
                                    result['oldActivity'],
                                    result['newActivity'],
                                  ),
                                  style: styleRegular(),
                                ),
                                backgroundColor: cGreen,
                              ),
                            );
                            widget.onUserActivitiesChanged(
                              result['userActivities'],
                            );
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                            setState(() {}); // Refresh UI
                          }
                        }
                      }
                    }
                    : () async {
                      // Enroll in activity
                      final result = await _useCases.enrollInActivity(activity);
                      if (result['success']) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _uiTexts.enrollmentSuccessful(activity.name),
                              style: styleRegular(),
                            ),
                            backgroundColor: cGreen,
                          ),
                        );
                        widget.onUserActivitiesChanged(
                          result['userActivities'],
                        );
                      }
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);

                      setState(() {}); // Refresh UI
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cWhite,
      appBar: AppBar(
        backgroundColor: cWhite,
        elevation: 0,
        title: Text(_uiTexts.allActivities, style: styleBold(fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: cBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Search and filters
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: adjustOpacity(cBlack, 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: cBlack),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: _uiTexts.searchActivities,
                                hintStyle: styleRegular(color: cGray),
                                border: InputBorder.none,
                              ),
                              style: styleRegular(),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                  _applyFilter();
                                });
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _applyFilter();
                                });
                              },
                              child: const Icon(Icons.clear, color: cGray),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Activities list
                  Expanded(
                    child:
                        _filteredActivities.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 60,
                                    color: adjustOpacity(cBlack, 0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _uiTexts.noActivitiesFound,
                                    style: styleRegular(
                                      color: adjustOpacity(cBlack, 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : RefreshIndicator(
                              onRefresh: _loadActivities,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredActivities.length,
                                itemBuilder: (context, index) {
                                  final activity = _filteredActivities[index];
                                  final bool isEnrolled = _useCases
                                      .isUserEnrolled(activity);

                                  return FutureBuilder<bool>(
                                    future: _useCases.hasTimeConflict(activity),
                                    builder: (context, snapshot) {
                                      final bool hasConflict =
                                          snapshot.data ?? false;

                                      return Stack(
                                        children: [
                                          ActivityCard(
                                            activity: activity,
                                            onTap:
                                                () => _showActivityDetail(
                                                  activity,
                                                ),
                                          ),
                                          if (isEnrolled || hasConflict)
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      isEnrolled
                                                          ? cGreen
                                                          : Colors.orange,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  isEnrolled
                                                      ? _uiTexts.enrolled
                                                      : _uiTexts.adjustable,
                                                  style: styleBold(
                                                    fontSize: 12,
                                                    color: cWhite,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                  ),
                ],
              ),
    );
  }
}
