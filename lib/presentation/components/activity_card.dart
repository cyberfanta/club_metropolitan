import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/lang/ui_texts.dart';
import '../../core/theme/ui_colors.dart';
import '../../core/theme/ui_text_styles.dart';
import '../../domain/models/activity.dart';
import '../../utils/stamp.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback onTap;

  const ActivityCard({super.key, required this.activity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final UiTexts uiTexts = Provider.of<UiTexts>(context);

    // Obtener el nombre completo del entrenador
    final String trainerFullName =
        activity.trainerName != null
            ? '${activity.trainerName} ${activity.trainerLastName ?? ""}'
            : uiTexts.trainerNotAssigned;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: adjustOpacity(cBlack, 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section with image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Container(
                height: 120,
                width: double.infinity,
                color: adjustOpacity(cGray, 0.3),
                child: Image.asset(
                  activity.imageAssetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    stamp(
                      'ActivityCard',
                      'Error loading image: ${activity.imageAssetPath} - $error',
                    );

                    return Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: adjustOpacity(cBlack, 0.3),
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Activity information
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity.name, style: styleBold(fontSize: 18)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: cBlack),
                      const SizedBox(width: 8),
                      Text(
                        _capitalizeFirstLetter(
                          uiTexts.getDayName(activity.day),
                        ),
                        style: styleRegular(fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16, color: cBlack),
                      const SizedBox(width: 8),
                      Text(activity.time, style: styleRegular(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: cBlack),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          trainerFullName,
                          style: styleRegular(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
