import 'package:flutter/material.dart';

import 'package:humoruniv/core/themes/app_spacing.dart';
import 'package:humoruniv/core/widgets/atoms/skeleton_box.dart';

class SkeletonPostDetail extends StatelessWidget {
  const SkeletonPostDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.edgeAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(
            width: MediaQuery.sizeOf(context).width * 0.8,
            height: 24,
            borderRadius: BorderRadius.circular(4),
          ),
          AppSpacing.sbH12,
          SkeletonBox(
            width: MediaQuery.sizeOf(context).width * 0.4,
            height: 14,
            borderRadius: BorderRadius.circular(4),
          ),
          AppSpacing.sbH16,
          SkeletonBox(
            width: MediaQuery.sizeOf(context).width * 0.3,
            height: 14,
            borderRadius: BorderRadius.circular(4),
          ),
          AppSpacing.sbH24,
          SkeletonBox(
            width: double.infinity,
            height: 200,
            borderRadius: BorderRadius.circular(4),
          ),
          AppSpacing.sbH16,
          SkeletonBox(
            width: double.infinity,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          AppSpacing.sbH8,
          SkeletonBox(
            width: MediaQuery.sizeOf(context).width * 0.9,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          AppSpacing.sbH8,
          SkeletonBox(
            width: MediaQuery.sizeOf(context).width * 0.6,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
