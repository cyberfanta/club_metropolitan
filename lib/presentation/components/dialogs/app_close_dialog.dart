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
      titleTextStyle: styleSemiBold(fontSize: 24),
      contentWidget: Text(
        textAlign: TextAlign.center,
        '${uiTexts.appCloseContext}\n${uiTexts.appCloseSubText}',
        style: styleSemiBold(fontSize: 14),
      ),
      backgroundColor: cBackground,
      borderColor: cFullBlack,
      borderWidth: 1,
      firstButtonText: uiTexts.yes,
      firstButtonTextStyle: styleRegular(),
      firstButtonAction: okAction,
      firstButtonColor: cBackground,
      firstButtonBorderColor: cFullBlack,
      firstButtonBorderWidth: 0,
      firstButtonSize: const Size(100, 30),
      secondButtonText: uiTexts.no,
      secondButtonTextStyle: styleRegular(),
      secondButtonAction: cancelAction,
      secondButtonColor: cBackground,
      secondButtonBorderColor: cFullBlack,
      secondButtonBorderWidth: 0,
      secondButtonSize: const Size(100, 30),
    );
  }
}
