import 'package:flutter/material.dart';
import 'package:humoruniv/core/themes/app_radius.dart';
import 'package:humoruniv/core/themes/app_spacing.dart';
import 'package:humoruniv/presentation/providers/update_provider.dart';

class UpdateBanner extends StatelessWidget {
  const UpdateBanner({
    required this.status,
    super.key,
    this.newVersion,
    this.onCheck,
    this.onUpdate,
  });
  final UpdateCheckStatus status;
  final String? newVersion;
  final VoidCallback? onCheck;
  final VoidCallback? onUpdate;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      UpdateCheckStatus.idle => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p16,
            vertical: AppSpacing.p8,
          ),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onCheck,
              child: const Text('업데이트 확인'),
            ),
          ),
        ),
      UpdateCheckStatus.checking => const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.p16,
            vertical: AppSpacing.p12,
          ),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      UpdateCheckStatus.upToDate => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p16,
            vertical: AppSpacing.p8,
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.p8),
              Text(
                '최신 버전입니다',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      UpdateCheckStatus.available => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p16,
            vertical: AppSpacing.p8,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: AppRadius.borderRadiusLg,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.p12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'v$newVersion 사용 가능',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                  ),
                  FilledButton(
                    onPressed: onUpdate,
                    child: const Text('업데이트'),
                  ),
                ],
              ),
            ),
          ),
        ),
      UpdateCheckStatus.error => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p16,
            vertical: AppSpacing.p8,
          ),
          child: InkWell(
            onTap: onCheck,
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 18,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: AppSpacing.p8),
                Text(
                  '확인 실패',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
                const SizedBox(width: AppSpacing.p4),
                Text(
                  '다시 시도',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
        ),
    };
  }
}
