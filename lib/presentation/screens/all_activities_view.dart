import 'package:flutter/material.dart';

import '../../core/theme/ui_colors.dart';
import '../../data/services/data_service.dart';
import '../../domain/models/activity.dart';
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
  List<Activity> _userActivities = [];
  bool _isLoading = true;

  // Para la búsqueda
  final TextEditingController _searchController = TextEditingController();
  List<Activity> _filteredActivities = [];
  String _searchQuery = '';

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
      print('Error loading activities: $e');
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
                      // Cancelar inscripción
                      final success = await _dataService.cancelEnrollment(
                        activity.id,
                      );
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Has cancelado tu inscripción a ${activity.name}',
                              style: TextStyle(fontFamily: 'CreatoDisplay'),
                            ),
                            backgroundColor: cGray,
                          ),
                        );

                        // Actualizar la lista de actividades del usuario
                        final userActivities =
                            await _dataService.getUserActivities();
                        widget.onUserActivitiesChanged(userActivities);
                      }
                      Navigator.pop(context);
                      setState(() {}); // Refrescar la UI
                    }
                    : hasConflict
                    ? () async {
                      // Mostrar diálogo de confirmación para cambiar actividad
                      if (conflictingActivity != null) {
                        final shouldReplace = await showDialog<bool>(
                          context: context,
                          barrierDismissible: true,
                          builder:
                              (context) => AlertDialog(
                                title: Text(
                                  '¿Cambiar actividad?',
                                  style: TextStyle(
                                    fontFamily: 'CreatoDisplay',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  '¿Deseas cancelar tu inscripción a "${conflictingActivity?.name}" y inscribirte a "${activity.name}"?',
                                  style: TextStyle(fontFamily: 'CreatoDisplay'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: Text(
                                      'No',
                                      style: TextStyle(
                                        fontFamily: 'CreatoDisplay',
                                        color: cBlack,
                                      ),
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
                                      'Sí, cambiar',
                                      style: TextStyle(
                                        fontFamily: 'CreatoDisplay',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (shouldReplace == true) {
                          // Cancelar la actividad anterior
                          await _dataService.cancelEnrollment(
                            conflictingActivity.id,
                          );

                          // Inscribir en la nueva actividad
                          final success = await _dataService.enrollInActivity(
                            activity.id,
                          );

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Has cambiado ${conflictingActivity.name} por ${activity.name}',
                                  style: TextStyle(fontFamily: 'CreatoDisplay'),
                                ),
                                backgroundColor: cGreen,
                              ),
                            );

                            // Actualizar la lista de actividades del usuario
                            final userActivities =
                                await _dataService.getUserActivities();
                            widget.onUserActivitiesChanged(userActivities);
                            Navigator.pop(context);
                            setState(() {}); // Refrescar la UI
                          }
                        }
                      }
                    }
                    : () async {
                      // Inscribirse a la actividad
                      final success = await _dataService.enrollInActivity(
                        activity.id,
                      );
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Te has inscrito a ${activity.name}',
                              style: TextStyle(fontFamily: 'CreatoDisplay'),
                            ),
                            backgroundColor: cGreen,
                          ),
                        );

                        // Actualizar la lista de actividades del usuario
                        final userActivities =
                            await _dataService.getUserActivities();
                        widget.onUserActivitiesChanged(userActivities);
                      }
                      Navigator.pop(context);
                      setState(() {}); // Refrescar la UI
                    },
            actionLabel:
                isEnrolled
                    ? 'Cancelar inscripción'
                    : hasConflict && conflictingActivity != null
                    ? 'Cambiar ${conflictingActivity.name} por esta actividad'
                    : 'Inscribirse',
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
        title: const Text(
          'Todas las Actividades',
          style: TextStyle(
            fontFamily: 'CreatoDisplay',
            fontWeight: FontWeight.bold,
            color: cBlack,
          ),
        ),
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
                  // Búsqueda y filtros
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
                        color: cBlack.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: cBlack),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Buscar por nombre, día o entrenador',
                                hintStyle: TextStyle(
                                  fontFamily: 'CreatoDisplay',
                                  color: cGray,
                                ),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                fontFamily: 'CreatoDisplay',
                                color: cBlack,
                              ),
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

                  // Lista de actividades
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
                                    color: cBlack.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No se encontraron actividades',
                                    style: TextStyle(
                                      fontFamily: 'CreatoDisplay',
                                      fontSize: 16,
                                      color: cBlack.withOpacity(0.7),
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
                                                      ? 'Inscrito'
                                                      : 'Ajustable',
                                                  style: const TextStyle(
                                                    fontFamily: 'CreatoDisplay',
                                                    color: cWhite,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
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
