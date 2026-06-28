import 'package:flutter/material.dart';

import 'package:humoruniv/core/themes/app_spacing.dart';
import 'package:humoruniv/domain/entities/comment.dart';
import 'package:humoruniv/presentation/widgets/comment_tile.dart';

class FeedCommentsSheet extends StatelessWidget {
  const FeedCommentsSheet({
    required this.comments,
    required this.count,
    super.key,
  });
  final List<Comment> comments;
  final int count;

  List<Comment> get _sorted {
    final list = [...comments];
    list.sort((a, b) {
      if (a.isBest != b.isBest) return a.isBest ? -1 : 1;
      return b.recommendCount.compareTo(a.recommendCount);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sorted = _sorted;
    return SafeArea(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.outline.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  '댓글 $count개',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outline.withOpacity(0.12)),
          Expanded(
            child: ListView.separated(
              padding: AppSpacing.edgeH16V8,
              itemCount: sorted.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: colorScheme.outline.withOpacity(0.08),
              ),
              itemBuilder: (context, index) =>
                  CommentTile(comment: sorted[index]),
            ),
          ),
        ],
      ),
    );
  }
}

void showFeedCommentsSheet(
  BuildContext context,
  List<Comment> comments,
  int count,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: FeedCommentsSheet(comments: comments, count: count),
    ),
  );
}
