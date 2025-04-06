import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../core/lang/ui_texts.dart';
import '../../core/theme/ui_colors.dart';
import '../../core/theme/ui_text_styles.dart';
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
    // Calcular el ancho total disponible
    final double availableWidth = constraints.crossAxisExtent;

    // Calcular el ancho de cada elemento considerando el espaciado
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
      _filteredActivities =
          _useCases.applyFilter(_allActivities, _searchQuery, _uiTexts);
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
      backgroundColor: cTransparent,
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
    final size = MediaQuery
        .of(context)
        .size;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Obtener orientación actual
        final orientation = MediaQuery
            .of(context)
            .orientation;
        final isLandscape = orientation == Orientation.landscape;

        // Mejorar detección de tipos de dispositivos considerando orientación
        final bool isMobile = constraints.maxWidth < 600;
        final bool isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 960;
        final bool isDesktop = constraints.maxWidth >= 960;

        // Detectar específicamente móvil en horizontal
        final bool isMobileLandscape = isMobile && isLandscape;

        // Usar grid view para tablet, desktop o móvil en horizontal
        final bool useGridView = !isMobile || isMobileLandscape;

        // Fixed card sizes for width and height - ajustar para móvil horizontal
        final double cardWidth = isDesktop ? 400 : 350;
        final double cardHeight =
        isDesktop ? 400 : (isMobileLandscape ? 300 : 350);

        // Calcular dinámicamente el número de columnas basado en el ancho disponible
        int calculateColumnCount(double availableWidth) {
          if (isMobile && !isLandscape) return 1;

          if (isMobile && isLandscape) {
            return 2; // 2 columnas en móvil horizontal
          }

          if (isTablet) return 2;

          // Para desktop, calcular columnas basado en el ancho disponible
          // Permitiendo hasta 6 columnas en pantallas muy anchas
          final int maxColumns = 6;
          final double availableSpace =
              availableWidth - 32; // 32 = padding total

          // Considerando el espacio entre columnas (16px)
          int calculatedColumns = (availableSpace / (cardWidth + 16)).floor();

          // Limitar entre 3 y maxColumns
          return calculatedColumns.clamp(3, maxColumns);
        }

        // Calcular número de columnas para la vista actual
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
          body:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
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
                              : size.width,
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
                              setState(() {
                                _searchQuery = query;
                                _applyFilter();
                              });
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
                        // Reducir espacio vertical en modo horizontal para móviles
                        SizedBox(height: isMobileLandscape ? 16 : 24),

                        // Activities list - adaptable to grid or list based on width
                        Expanded(
                          child:
                              _filteredActivities.isEmpty
                                  ? Center(
                                    child: Text(
                                      _uiTexts.noActivitiesFound,
                                      style: styleMedium(fontSize: 16),
                                    ),
                                  )
                                  : useGridView
                                  // Grid view for tablet and desktop screens
                                  ? GridView.builder(
                                    gridDelegate: CustomSliverGridDelegate(
                                      crossAxisCount: columnCount,
                                      spacing: 16,
                                      childHeight: cardHeight,
                                    ),
                                    itemCount: _filteredActivities.length,
                                    itemBuilder: (context, index) {
                                      return _buildActivityItem(
                                        context,
                                        _filteredActivities[index],
                                        isDesktop: isDesktop,
                                        useGridView: useGridView,
                                      );
                                    },
                                  )
                                  // List view for mobile screens
                                  : ListView.builder(
                                    itemCount: _filteredActivities.length,
                                    itemBuilder: (context, index) {
                                      return _buildActivityItem(
                                        context,
                                        _filteredActivities[index],
                                        isDesktop: isDesktop,
                                        useGridView: useGridView,
                                      );
                                    },
                                  ),
                        ),
                      ],
                    ),
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
    // Check if user is enrolled in this activity
    final bool isEnrolled = _useCases.isUserEnrolled(activity);

    // For hasConflict, we'll just do a first check - the full detailed check happens when opening
    // No debemos mostrar una viñeta "adjustable" solo porque hay espacios disponibles
    // Solo mostrar la viñeta si hay un conflicto real con otra actividad del usuario
    final bool hasConflict = !isEnrolled &&
        _useCases.hasQuickTimeConflict(activity);
    
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
