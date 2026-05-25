import 'package:flutter/material.dart';

import 'package:humoruniv/core/themes/app_colors.dart';
import 'package:humoruniv/core/themes/app_radius.dart';
import 'package:humoruniv/core/themes/app_spacing.dart';
import 'package:humoruniv/core/widgets/atoms/count_badge.dart';
import 'package:humoruniv/domain/entities/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const PostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p4),
      child: Material(
        color: colorScheme.surface,
        borderRadius: AppRadius.borderRadiusMd,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderRadiusMd,
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.12),
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.borderRadiusMd,
            child: Padding(
              padding: AppSpacing.edgeAll12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.sbH8,
                  Row(
                    children: [
                      const Spacer(),
                      RecommendBadge(count: post.recommendCount),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
