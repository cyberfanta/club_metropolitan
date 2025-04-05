import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/lang/ui_texts.dart';
import '../../core/theme/ui_colors.dart';
import '../../core/theme/ui_text_styles.dart';
import '../../data/services/data_service.dart';
import '../../domain/models/activity.dart';
import '../../utils/stamp.dart';
import '../components/activity_card.dart';
import '../components/activity_detail_modal.dart';

class AllActivitiesView extends StatefulWidget {
  final Function(List<Activity>) onUserActivitiesChanged;

  const AllActivitiesView({super.key, required this.onUserActivitiesChanged});

  @override
  State<AllActivitiesView> createState() => _AllActivitiesViewState();
}

class _AllActivitiesViewState extends State<AllActivitiesView> {
  final DataService _dataService = DataService();
  List<Activity> _allActivities = [];
  // ignore: unused_field
  List<Activity> _userActivities = [];
  bool _isLoading = true;

  // Para la búsqueda
  final TextEditingController _searchController = TextEditingController();
  List<Activity> _filteredActivities = [];
  String _searchQuery = '';

  // Agrega UiTexts como variable de clase
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

    try {
      final allActivities = await _dataService.getActivities();
      final userActivities = await _dataService.getUserActivities();

      setState(() {
        _allActivities = allActivities;
        _userActivities = userActivities;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      stamp('AllActivitiesView', 'Error loading activities: $e');
    }
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredActivities = List.from(_allActivities);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredActivities =
          _allActivities.where((activity) {
            return activity.name.toLowerCase().contains(query) ||
                activity.day.toLowerCase().contains(query) ||
                (activity.trainerName?.toLowerCase().contains(query) ?? false);
          }).toList();
    }
  }

  bool _isUserEnrolled(Activity activity) {
    return activity.enrolledMembers.contains(_dataService.currentUserId);
  }

  Future<bool> _hasTimeConflict(Activity activity) async {
    return await _dataService.hasTimeConflict(activity);
  }

  // Obtener la actividad que está en conflicto con la actividad actual
  Future<Activity?> _getConflictingActivity(Activity activity) async {
    return await _dataService.getConflictingActivity(activity);
  }

  void _showActivityDetail(Activity activity) async {
    final bool isEnrolled = _isUserEnrolled(activity);
    final bool hasConflict = await _hasTimeConflict(activity);

    // Obtener la actividad conflictiva si existe
    Activity? conflictingActivity;
    if (hasConflict) {
      conflictingActivity = await _getConflictingActivity(activity);
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
                      final success = await _dataService.cancelEnrollment(
                        activity.id,
                      );
                      if (success) {
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

                        // Actualizar la lista de actividades del usuario
                        final userActivities =
                            await _dataService.getUserActivities();
                        widget.onUserActivitiesChanged(userActivities);
                      }
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      setState(() {}); // Refrescar la UI
                    }
                    : hasConflict
                    ? () async {
                      // Show confirmation dialog to change activity
                      if (conflictingActivity != null) {
                        final shouldReplace = await showDialog<bool>(
                          context: context,
                          barrierDismissible: true,
                          builder:
                              (context) => AlertDialog(
                                title: Text(
                                  _uiTexts.changeActivity,
                                  style: styleBold(fontSize: 18),
                                ),
                                content: Text(
                                  _uiTexts.changeActivityQuestion(
                                    conflictingActivity!.name,
                                    activity.name,
                                  ),
                                  style: styleRegular(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: Text(
                                      _uiTexts.no,
                                      style: styleRegular(),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: cBlack,
                                      foregroundColor: cWhite,
                                    ),
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                    child: Text(
                                      _uiTexts.yesChange,
                                      style: styleRegular(color: cWhite),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (shouldReplace == true) {
                          // Cancel previous activity
                          await _dataService.cancelEnrollment(
                            conflictingActivity.id,
                          );

                          // Enroll in new activity
                          final success = await _dataService.enrollInActivity(
                            activity.id,
                          );

                          if (success) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _uiTexts.activityChanged(
                                    conflictingActivity.name,
                                    activity.name,
                                  ),
                                  style: styleRegular(),
                                ),
                                backgroundColor: cGreen,
                              ),
                            );

                            // Actualizar la lista de actividades del usuario
                            final userActivities =
                                await _dataService.getUserActivities();
                            widget.onUserActivitiesChanged(userActivities);

                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                            setState(() {}); // Refrescar la UI
                          }
                        }
                      }
                    }
                    : () async {
                      // Enroll in activity
                      final success = await _dataService.enrollInActivity(
                        activity.id,
                      );
                      if (success) {
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

                        // Actualizar la lista de actividades del usuario
                        final userActivities =
                            await _dataService.getUserActivities();
                        widget.onUserActivitiesChanged(userActivities);
                      }
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);

                      setState(() {}); // Refrescar la UI
                    },
            actionLabel:
                isEnrolled
                    ? _uiTexts.cancelEnrollment
                    : hasConflict && conflictingActivity != null
                    ? _uiTexts.changeActivityFor(conflictingActivity.name)
                    : _uiTexts.enroll,
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
                                  final bool isEnrolled = _isUserEnrolled(
                                    activity,
                                  );

                                  return FutureBuilder<bool>(
                                    future: _hasTimeConflict(activity),
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
