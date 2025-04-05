import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/lang/ui_texts.dart';
import '../../core/theme/ui_colors.dart';
import '../../domain/use_cases/screens/user_activities_view_use_cases.dart';

class UserActivitiesView extends StatefulWidget {
  const UserActivitiesView({super.key});

  static const routeName = '/UserActivitiesView';

  @override
  State<UserActivitiesView> createState() => _UserActivitiesViewState();
}

class _UserActivitiesViewState extends State<UserActivitiesView> {
  String tag = UserActivitiesView.routeName.substring(
    1,
    UserActivitiesView.routeName.length,
  );

  UserActivitiesViewUseCases userActivitiesViewUseCases =
      UserActivitiesViewUseCases();

  @override
  Widget build(BuildContext context) {
    UiTexts uiTexts = Provider.of<UiTexts>(context);
    // Size screenSize = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (value, _) async {
        if (value) {
          return;
        }

        await userActivitiesViewUseCases.backActions(tag, context, uiTexts)();
      },
      child: Scaffold(
        key: const ValueKey(UserActivitiesView.routeName),
        resizeToAvoidBottomInset: false,
        backgroundColor: cBackground,
        body: SizedBox.shrink(),
      ),
    );
  }
}
