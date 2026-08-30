import 'package:flutter/material.dart';

import '../../../core/constant/app_constants.dart';
import '../../../shared/models/insight_model.dart';

class ChatEntryCard extends StatelessWidget {
  final InsightStatus? insightStatus;
  final VoidCallback onPressed;

  const ChatEntryCard({
    super.key,
    required this.insightStatus,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = insightStatus == InsightStatus.completed;
    final unavailableMessage = insightStatus == InsightStatus.superseded
        ? 'Percakapan tidak tersedia karena AI Insight tidak dibuat untuk '
            'pengukuran historis ini.'
        : 'Percakapan tersedia setelah insight selesai.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAvailable ? AppColors.primarySurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAvailable ? AppColors.primarySurface : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.forum_outlined,
                color: isAvailable ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Punya pertanyaan tentang hasil ini?',
                  style: AppTextStyles.heading3.copyWith(
                    color: isAvailable
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const ValueKey('open-conversational-ai'),
              onPressed: isAvailable ? onPressed : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.border,
                disabledForegroundColor: AppColors.textMuted,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Tanya lebih lanjut'),
            ),
          ),
          if (!isAvailable) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    unavailableMessage,
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
