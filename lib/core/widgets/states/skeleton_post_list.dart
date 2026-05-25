import 'package:flutter/material.dart';

import 'package:humoruniv/core/themes/app_spacing.dart';
import 'package:humoruniv/core/widgets/atoms/skeleton_box.dart';

class SkeletonPostList extends StatelessWidget {
  final int itemCount;

  const SkeletonPostList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => const _SkeletonPostItem(),
    );
  }
}

class _SkeletonPostItem extends StatelessWidget {
  const _SkeletonPostItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.edgeH16V8,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: MediaQuery.sizeOf(context).width * 0.7,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
                AppSpacing.sbH8,
                SkeletonBox(
                  width: MediaQuery.sizeOf(context).width * 0.4,
                  height: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          AppSpacing.sbW12,
          const SkeletonBox(
            width: 48,
            height: 48,
          ),
        ],
      ),
    );
  }
}
