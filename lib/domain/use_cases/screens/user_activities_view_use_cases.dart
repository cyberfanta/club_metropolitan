import 'package:flutter/material.dart';

import '../../../core/lang/ui_texts.dart';
import '../../../presentation/components/dialogs/app_close_dialog.dart';
import '../../../utils/stamp.dart';
import '../components/app_close_dialog_use_cases.dart';

class UserActivitiesViewUseCases {
  Future<void> Function() initState(BuildContext context) => () async {};

  Future<void> Function() backActions(
    String tag,
    BuildContext context,
    UiTexts uiTexts,
  ) => () async {
    stamp(tag, "Button Pressed: \"Back\"", decoratorChar: " * ");

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        AppCloseDialogUseCases logoutUseCases = AppCloseDialogUseCases();

        return AppCloseDialog(
          tag: tag,
          uiTexts: uiTexts,
          okAction: logoutUseCases.logout(context),
          cancelAction: logoutUseCases.cancel(context),
        );
      },
    );
  };
}
