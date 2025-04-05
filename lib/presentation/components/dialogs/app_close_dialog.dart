import 'package:flutter/material.dart';

import '../../../core/lang/ui_texts.dart';
import '../../../core/theme/ui_colors.dart';
import '../../../core/theme/ui_text_styles.dart';
import 'templates/two_button_dialog.dart';

class AppCloseDialog extends StatelessWidget {
  const AppCloseDialog({
    super.key,
    required this.tag,
    required this.uiTexts,
    required this.okAction,
    required this.cancelAction,
  });

  final String tag;
  final UiTexts uiTexts;
  final Future<void> Function() okAction;
  final Future<void> Function() cancelAction;

  @override
  Widget build(BuildContext context) {
    return TwoButtonDialog(
      tag: tag,
      titleText: uiTexts.appCloseTitleText,
      titleTextStyle: const TextStyle(
        fontFamily: 'CreatoDisplay',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: cBlack,
      ),
      contentWidget: Text(
        textAlign: TextAlign.center,
        '${uiTexts.appCloseContext}\n${uiTexts.appCloseSubText}',
        style: const TextStyle(
          fontFamily: 'CreatoDisplay',
          fontSize: 16,
          color: cBlack,
        ),
      ),
      backgroundColor: cWhite,
      borderColor: cBlack.withOpacity(0.1),
      borderWidth: 1,
      firstButtonText: uiTexts.yes,
      firstButtonTextStyle: const TextStyle(
        fontFamily: 'CreatoDisplay',
        color: cWhite,
        fontWeight: FontWeight.w500,
      ),
      firstButtonAction: okAction,
      firstButtonColor: cBlack,
      firstButtonBorderColor: cBlack,
      firstButtonBorderWidth: 0,
      firstButtonSize: const Size(120, 40),
      secondButtonText: uiTexts.no,
      secondButtonTextStyle: const TextStyle(
        fontFamily: 'CreatoDisplay',
        color: cBlack,
        fontWeight: FontWeight.w500,
      ),
      secondButtonAction: cancelAction,
      secondButtonColor: cWhite,
      secondButtonBorderColor: cBlack,
      secondButtonBorderWidth: 1,
      secondButtonSize: const Size(120, 40),
    );
  }
}
