import 'package:flutter/material.dart';
import 'package:humoruniv/core/themes/app_spacing.dart';
import 'package:humoruniv/core/widgets/atoms/count_badge.dart';

class CommentTile extends StatelessWidget {
  final String author;
  final String content;
  final int recommendCount;
  final bool isBest;
  final List<CommentReply> replies;

  const CommentTile({
    super.key,
    required this.author,
    required this.content,
    this.recommendCount = 0,
    this.isBest = false,
    this.replies = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.edgeOnlyBottom12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBest) ...[
            const BestBadge(),
            AppSpacing.sbH4,
          ],
          Row(
            children: [
              Text(author, style: Theme.of(context).textTheme.labelMedium),
              AppSpacing.sbW8,
              Icon(
                Icons.thumb_up,
                size: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
              AppSpacing.sbW4,
              Text(
                '$recommendCount',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          AppSpacing.sbH4,
          Text(content, style: Theme.of(context).textTheme.bodyMedium),
          if (replies.isNotEmpty)
            ...replies.map((reply) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                          width: 2,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              reply.author,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            AppSpacing.sbW8,
                            Text(
                              '${reply.recommendCount}',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                        AppSpacing.sbH4,
                        Text(
                          reply.content,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

class CommentReply {
  final String author;
  final String content;
  final int recommendCount;

  const CommentReply({
    required this.author,
    required this.content,
    this.recommendCount = 0,
  });
}
