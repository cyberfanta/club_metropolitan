import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/lang/ui_texts.dart';
import '../../core/theme/ui_colors.dart';
import '../../core/theme/ui_text_styles.dart';
import '../../domain/models/activity.dart';
import '../../domain/use_cases/components/activity_detail_modal_use_cases.dart';

class ActivityDetailModal extends StatelessWidget {
  final Activity activity;
  final bool isUserEnrolled;
  final Activity? conflictingActivity;
  final VoidCallback onAction;
  final String actionLabel;
  final ActivityDetailModalUseCases _useCases = ActivityDetailModalUseCases();

  ActivityDetailModal({
    super.key,
    required this.activity,
    required this.isUserEnrolled,
    this.conflictingActivity,
    required this.onAction,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final uiTexts = Provider.of<UiTexts>(context);
    final size = MediaQuery.of(context).size;
    final double top = size.height * 0.1;

    return Container(
      margin: EdgeInsets.only(top: top),
      decoration: const BoxDecoration(
        color: cWhite,
        borderRadius: BorderRadius.zero,
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(activity.name, style: styleBold(fontSize: 22)),
                    IconButton(
                      onPressed: () => _useCases.closeModal(context),
                      icon: const Icon(Icons.close, color: cBlack),
                    ),
                  ],
                ),
              ),

              // Activity image
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: ClipRect(
                  child: Image.asset(
                    activity.imagePath,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Activity details
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time and day
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: adjustOpacity(cBlack, 0.08),
                              borderRadius: BorderRadius.zero,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "${activity.startTime} - ${activity.endTime}",
                                  style: styleMedium(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: adjustOpacity(cBlack, 0.08),
                              borderRadius: BorderRadius.zero,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  uiTexts.getDayName(activity.day),
                                  style: styleMedium(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Location
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              activity.location,
                              style: styleRegular(fontSize: 16),
                            ),
                          ],
                        ),
                      ),

                      // Trainer
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.person, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _useCases.getTrainerFullName(activity, uiTexts),
                              style: styleRegular(fontSize: 16),
                            ),
                          ],
                        ),
                      ),

                      // Capacity
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.people, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "${activity.enrolledMembers.length}/${activity.capacity} ${uiTexts.participants}",
                              style: styleRegular(fontSize: 16),
                            ),
                          ],
                        ),
                      ),

                      // Description title
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Text(
                          uiTexts.description,
                          style: styleBold(fontSize: 18),
                        ),
                      ),

                      // Description
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          activity.description,
                          style: styleRegular(height: 1.5),
                        ),
                      ),

                      // Warning about conflicting activity
                      if (conflictingActivity != null && !isUserEnrolled)
                        Container(
                          margin: const EdgeInsets.only(top: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: adjustOpacity(cOrange, 0.2),
                            borderRadius: BorderRadius.zero,
                            border: Border.all(color: cOrange, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: cOrange,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    uiTexts.timeConflict,
                                    style: styleBold(color: cOrange),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                uiTexts.conflictDescription(
                                  conflictingActivity!.name,
                                  conflictingActivity!.day,
                                  conflictingActivity!.startTime,
                                  conflictingActivity!.endTime,
                                ),
                                style: styleRegular(),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Action button at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cWhite,
                boxShadow: [
                  BoxShadow(
                    color: adjustOpacity(cBlack, 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _useCases.getActionButtonColor(
                    isUserEnrolled,
                    conflictingActivity,
                    cBlack,
                    cRed,
                    cOrange,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: styleBold(color: cWhite, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
