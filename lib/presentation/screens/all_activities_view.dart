import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../core/lang/ui_texts.dart';
import '../../core/theme/ui_colors.dart';
import '../../core/theme/ui_text_styles.dart';
import '../../domain/cubit/all_activities/all_activities_cubit.dart';
import '../../domain/cubit/all_activities/all_activities_state.dart';
import '../../domain/models/activity.dart';
import '../../domain/use_cases/screens/all_activities_view_use_cases.dart';
import '../components/activities/activity_list_view.dart';
import '../components/activities/activity_search_bar.dart';
import '../components/layout/responsive_layout_helper.dart';

class AllActivitiesView extends StatefulWidget {
  final Function(List<Activity>) onUserActivitiesChanged;

  const AllActivitiesView({super.key, required this.onUserActivitiesChanged});

  @override
  State<AllActivitiesView> createState() => _AllActivitiesViewState();
}

class _AllActivitiesViewState extends State<AllActivitiesView> {
  final AllActivitiesViewUseCases _useCases = AllActivitiesViewUseCases();
  final TextEditingController _searchController = TextEditingController();
  late UiTexts _uiTexts;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _uiTexts = Provider.of<UiTexts>(context);
    context.read<AllActivitiesCubit>().setContext(context);
  }

  @override
  void initState() {
    super.initState();

    context.read<AllActivitiesCubit>().loadAllActivities();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = ResponsiveLayoutHelper(context, constraints);
        final columnCount = layout.calculateColumnCount();

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
                    // Search bar
                    ActivitySearchBar(
                      controller: _searchController,
                      isDesktop: layout.isDesktop,
                      isMobileLandscape: layout.isMobileLandscape,
                      constraints: constraints,
                      onSearchChanged:
                          (query) =>
                              _useCases.handleSearch(context, query, _uiTexts),
                    ),

                    // Spacing
                    SizedBox(height: layout.isMobileLandscape ? 16 : 24),

                    // Activities list
                    Expanded(
                      child: ActivityListView(
                        useGridView: layout.useGridView,
                        isDesktop: layout.isDesktop,
                        columnCount: columnCount,
                        cardWidth: layout.cardWidth,
                        cardHeight: layout.cardHeight,
                        onActivityTap:
                            (activity) => _useCases.showActivityDetail(
                              context,
                              activity,
                              _uiTexts,
                              widget.onUserActivitiesChanged,
                            ),
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
}
