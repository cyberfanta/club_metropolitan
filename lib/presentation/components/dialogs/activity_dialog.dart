import 'package:flutter/material.dart';

import '../../../core/theme/ui_colors.dart';
import '../../../core/theme/ui_text_styles.dart';

/// A simple dialog with two buttons for activity-related actions
class ActivityDialog extends StatelessWidget {
  final String title;
  final String content;
  final String negativeButtonText;
  final String positiveButtonText;
  final Color positiveButtonColor;
  final Color positiveButtonTextColor;
  final VoidCallback onPositivePressed;
  final VoidCallback onNegativePressed;

  const ActivityDialog({
    super.key,
    required this.title,
    required this.content,
    required this.negativeButtonText,
    required this.positiveButtonText,
    this.positiveButtonColor = cOrange,
    this.positiveButtonTextColor = cBlack,
    required this.onPositivePressed,
    required this.onNegativePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Square corners for the dialog
      ),
      title: Text(
        title,
        style: styleBold(fontSize: 18),
      ),
      content: Text(
        content,
        style: styleRegular(),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Square corners for the 'No' button
            ),
          ),
          onPressed: onNegativePressed,
          child: Text(negativeButtonText, style: styleRegular()),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: positiveButtonColor,
            foregroundColor: positiveButtonTextColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Square corners for the 'Yes' button
            ),
          ),
          onPressed: onPositivePressed,
          child: Text(
            positiveButtonText,
            style: styleRegular(color: positiveButtonTextColor),
          ),
        ),
      ],
    );
  }
}
