import 'package:flutter/material.dart';
import 'package:humoruniv/core/themes/app_spacing.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.title,
    super.key,
    this.leading,
    this.trailing,
    this.subtitle,
    this.onTap,
  });
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p16,
        vertical: AppSpacing.p4,
      ),
      minVerticalPadding: AppSpacing.p8,
    );
  }
}
