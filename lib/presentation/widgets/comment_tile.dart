import 'package:flutter/material.dart';
import 'package:humoruniv/core/themes/app_spacing.dart';
import 'package:humoruniv/domain/entities/comment.dart';
import 'package:humoruniv/domain/entities/content_block.dart';
import 'package:humoruniv/presentation/widgets/content_block_view.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  const CommentTile({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    final allImageUrls = comment.imageUrls;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (comment.isBest)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('BEST',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                      )),
            ),
          Row(children: [
            Text(comment.author,
                style: Theme.of(context).textTheme.labelMedium),
            AppSpacing.sbW8,
            Icon(Icons.thumb_up,
                size: 12, color: Theme.of(context).colorScheme.primary),
            Text('${comment.recommendCount}',
                style: Theme.of(context).textTheme.labelSmall),
          ]),
          const SizedBox(height: 4),
          Text(comment.content,
              style: Theme.of(context).textTheme.bodyMedium),
          ...comment.mediaBlocks.map((block) => ContentBlockView(
                block: block,
                allImageUrls: allImageUrls,
                mode: ContentBlockViewMode.compact,
              )),
          if (comment.replies.isNotEmpty)
            ...comment.replies.map((reply) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 2),
                      ),
                    ),
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(reply.author,
                              style:
                                  Theme.of(context).textTheme.labelSmall),
                          AppSpacing.sbW8,
                          Text('${reply.recommendCount}',
                              style:
                                  Theme.of(context).textTheme.labelSmall),
                        ]),
                        const SizedBox(height: 4),
                        Text(reply.content,
                            style: Theme.of(context).textTheme.bodySmall),
                        ...reply.mediaBlocks.map((block) => ContentBlockView(
                              block: block,
                              allImageUrls: reply.imageUrls,
                              mode: ContentBlockViewMode.compact,
                            )),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
