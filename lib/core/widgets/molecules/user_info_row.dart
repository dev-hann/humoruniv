import 'package:flutter/material.dart';

import 'package:humoruniv/core/themes/app_spacing.dart';

class UserInfoRow extends StatelessWidget {
  final String author;
  final String? date;
  final int recommendCount;
  final int? notRecommendCount;
  final int? viewCount;

  const UserInfoRow({
    super.key,
    required this.author,
    this.date,
    required this.recommendCount,
    this.notRecommendCount,
    this.viewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(author, style: Theme.of(context).textTheme.labelLarge),
        if (date != null) ...[
          AppSpacing.sbW12,
          Text(
            date!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
        const Spacer(),
        _metric(context, Icons.thumb_up, '$recommendCount',
            Theme.of(context).colorScheme.primary),
        if (notRecommendCount != null) ...[
          AppSpacing.sbW12,
          _metric(context, Icons.thumb_down, '$notRecommendCount',
              Theme.of(context).colorScheme.error),
        ],
        if (viewCount != null) ...[
          AppSpacing.sbW12,
          _metric(context, Icons.remove_red_eye, '$viewCount',
              Theme.of(context).colorScheme.onSurfaceVariant),
        ],
      ],
    );
  }

  Widget _metric(BuildContext context, IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        AppSpacing.sbW4,
        Text(
          value,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
