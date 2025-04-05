import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppCloseDialogUseCases {
  Future<void> Function() cancel(BuildContext context) => () async {
    Navigator.pop(context);
  };

  Future<void> Function() logout(BuildContext context) => () async {
    Navigator.pop(context);
    SystemNavigator.pop();
  };
}
