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
      titleTextStyle: styleBold(fontSize: 20),
      contentWidget: Text(
        textAlign: TextAlign.center,
        '${uiTexts.appCloseContext}\n${uiTexts.appCloseSubText}',
        style: styleRegular(),
      ),
      backgroundColor: cWhite,
      borderColor: adjustOpacity(cBlack, 0.1),
      borderWidth: 1,
      firstButtonText: uiTexts.yes,
      firstButtonTextStyle: styleMedium(color: cWhite),
      firstButtonAction: okAction,
      firstButtonColor: cBlack,
      firstButtonBorderColor: cBlack,
      firstButtonBorderWidth: 0,
      firstButtonSize: const Size(120, 40),
      secondButtonText: uiTexts.no,
      secondButtonTextStyle: styleMedium(),
      secondButtonAction: cancelAction,
      secondButtonColor: cWhite,
      secondButtonBorderColor: cBlack,
      secondButtonBorderWidth: 1,
      secondButtonSize: const Size(120, 40),
    );
  }
}
