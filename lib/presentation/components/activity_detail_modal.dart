import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/lang/ui_texts.dart';
import '../../core/theme/ui_colors.dart';
import '../../core/theme/ui_text_styles.dart';
import '../../domain/models/activity.dart';
import '../../utils/stamp.dart';

class ActivityDetailModal extends StatelessWidget {
  final Activity activity;
  final bool isUserEnrolled;
  final VoidCallback onAction;
  final String actionLabel;
  final Activity? conflictingActivity;

  const ActivityDetailModal({
    super.key,
    required this.activity,
    required this.isUserEnrolled,
    required this.onAction,
    required this.actionLabel,
    this.conflictingActivity,
  });

  @override
  Widget build(BuildContext context) {
    final UiTexts uiTexts = Provider.of<UiTexts>(context);

    // Obtener el nombre completo del entrenador
    final String trainerFullName =
        activity.trainerName != null
            ? '${activity.trainerName} ${activity.trainerLastName ?? ""}'
            : uiTexts.trainerNotAssigned;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: cWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Column(
              children: [
                // Top indicator line
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: adjustOpacity(cGray, 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),

                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: cGray),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // Main content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Activity image
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: adjustOpacity(cGray, 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            activity.imageAssetPath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              stamp(
                                'ActivityDetailModal',
                                'Error loading image: ${activity.imageAssetPath} - $error',
                              );

                              return Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: adjustOpacity(cBlack, 0.3),
                                  size: 60,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title and details
                      Text(activity.name, style: styleBold(fontSize: 24)),
                      const SizedBox(height: 16),

                      // Schedule information
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: adjustOpacity(cBlack, 0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: cBlack,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  uiTexts.getDayName(activity.day),
                                  style: styleRegular(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: adjustOpacity(cBlack, 0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: cBlack,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  activity.time,
                                  style: styleRegular(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Show conflicting activity message if exists
                      if (conflictingActivity != null && !isUserEnrolled)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: adjustOpacity(Colors.orange, 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    uiTexts.conflictingSchedule,
                                    style: styleBold(color: Colors.orange),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                uiTexts.alreadyEnrolledMessage(
                                  conflictingActivity!.name,
                                ),
                                style: styleRegular(),
                              ),
                            ],
                          ),
                        ),
                      if (conflictingActivity != null && !isUserEnrolled)
                        const SizedBox(height: 24),

                      // Trainer
                      Text(uiTexts.trainer, style: styleBold(fontSize: 18)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: adjustOpacity(cBlack, 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: adjustOpacity(cBlack, 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: cBlack,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                trainerFullName,
                                style: styleMedium(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      Text(uiTexts.description, style: styleBold(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(activity.description, style: styleRegular()),
                      const SizedBox(height: 32),

                      // Action button (enroll or cancel)
                      ElevatedButton(
                        onPressed: onAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isUserEnrolled
                                  ? cRedError
                                  : conflictingActivity != null
                                  ? Colors.orange
                                  : cBlack,
                          foregroundColor: cWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          actionLabel,
                          style: styleMedium(fontSize: 16, color: cWhite),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
