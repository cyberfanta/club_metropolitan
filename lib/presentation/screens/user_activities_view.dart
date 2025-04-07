import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/lang/ui_texts.dart';
import '../../core/theme/ui_colors.dart';
import '../../core/theme/ui_text_styles.dart';
import '../../data/services/data_service.dart';
import '../../domain/models/activity.dart';
import '../../domain/use_cases/screens/user_activities_view_use_cases.dart';
import '../../utils/stamp.dart';
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
  final DataService _dataService = DataService();
  final UserActivitiesViewUseCases _useCases = UserActivitiesViewUseCases();
  List<Activity> _userActivities = [];
  bool _isLoading = true;
  String _memberName = "";

  late UiTexts _uiTexts;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _uiTexts = Provider.of<UiTexts>(context);
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Cargar el nombre del usuario y las actividades en paralelo
      final memberNameFuture = _dataService.getMemberName();
      final activitiesFuture = _dataService.getUserActivities();
      
      // Esperar a que ambas cargas terminen
      final results = await Future.wait([memberNameFuture, activitiesFuture]);
      
      setState(() {
        _memberName = results[0] as String;
        _userActivities = results[1] as List<Activity>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      stamp('UserActivitiesView', 'Error loading user data: $e');
    }
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
              // Cancel enrollment
              final success = await _dataService.cancelEnrollment(activity.id);

              if (success) {
                setState(() {
                  _userActivities.removeWhere((item) => item.id == activity.id);
                });
              }

              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            actionLabel: _uiTexts.cancelEnrollment,
          ),
    );
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
          title: Text("${_uiTexts.myActivities} ($_memberName)", style: styleBold(fontSize: 20)),
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
                            _loadUserData();
                          },
                        ),
                  ),
                );
              },
              tooltip: _uiTexts.viewAllActivities,
            ),
          ],
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _userActivities.isEmpty
                ? Center(
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
                                      _loadUserData();
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
                )
                : RefreshIndicator(
                  onRefresh: _loadUserData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _userActivities.length,
                    itemBuilder: (context, index) {
                      final activity = _userActivities[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ActivityCard(
                          activity: activity,
                          onTap: () => _showActivityDetail(activity),
                        ),
                      );
                    },
                  ),
                ),
      ),
    );
  }
}
