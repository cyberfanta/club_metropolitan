import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/lang/ui_texts.dart';
import '../../core/theme/ui_colors.dart';
import '../../core/theme/ui_text_styles.dart';
import '../../domain/models/activity.dart';
import '../../domain/use_cases/components/activity_card_use_cases.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback onTap;
  final ActivityCardUseCases _useCases = ActivityCardUseCases();

  ActivityCard({super.key, required this.activity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final uiTexts = Provider.of<UiTexts>(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.zero,
        child: Container(
          decoration: BoxDecoration(
            color: cWhite,
            borderRadius: BorderRadius.zero,
            boxShadow: [
              BoxShadow(
                color: adjustOpacity(cBlack, 0.1),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.zero,
                  image: DecorationImage(
                    image: AssetImage(activity.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(activity.name, style: styleBold(fontSize: 18)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: adjustOpacity(cBlack, 0.1),
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Text(
                            "${activity.startTime} - ${activity.endTime}",
                            style: styleMedium(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: adjustOpacity(cBlack, 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _useCases.capitalizeFirstLetter(uiTexts.getDayName(activity.day)),
                          style: styleRegular(
                            color: adjustOpacity(cBlack, 0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: adjustOpacity(cBlack, 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _useCases.getTrainerFullName(activity, uiTexts),
                          style: styleRegular(
                            color: adjustOpacity(cBlack, 0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: adjustOpacity(cBlack, 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          activity.location,
                          style: styleRegular(
                            color: adjustOpacity(cBlack, 0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activity.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: styleRegular(color: adjustOpacity(cBlack, 0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
