import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humoruniv/core/widgets/molecules/dark_mode_selector.dart';
import 'package:humoruniv/core/widgets/molecules/settings_group.dart';
import 'package:humoruniv/core/widgets/molecules/settings_tile.dart';
import 'package:humoruniv/core/widgets/molecules/update_banner.dart';
import 'package:humoruniv/presentation/providers/nsfw_provider.dart';
import 'package:humoruniv/presentation/providers/theme_provider.dart';
import 'package:humoruniv/presentation/providers/update_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final nsfwEnabled = ref.watch(nsfwProvider);
    final updateState = ref.watch(updateProvider);

    return ListView(
      children: [
        SettingsGroup(
          title: '화면 설정',
          children: [
            SettingsTile(
              title: '다크 모드',
              trailing: DarkModeSelector(
                currentMode: themeMode,
                onChanged: (option) {
                  ref.read(themeProvider.notifier).setThemeMode(option);
                },
              ),
            ),
          ],
        ),
        SettingsGroup(
          title: '콘텐츠',
          children: [
            SettingsTile(
              title: '성인 콘텐츠 경고',
              trailing: Switch(
                value: nsfwEnabled,
                onChanged: (v) {
                  ref.read(nsfwProvider.notifier).setEnabled(v);
                },
              ),
            ),
          ],
        ),
        SettingsGroup(
          title: '앱 정보',
          children: [
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final version = snapshot.hasData
                    ? 'v${snapshot.data!.version}'
                    : 'v1.1.0';
                return SettingsTile(title: '버전', subtitle: version);
              },
            ),
            UpdateBanner(
              status: updateState.status,
              newVersion: updateState.release?.version,
              onCheck: () {
                ref.read(updateProvider.notifier).checkForUpdate();
              },
              onUpdate: () {
                final url =
                    updateState.release?.downloadUrl ??
                    updateState.release?.htmlUrl;
                if (url != null && url.isNotEmpty) {
                  _openUpdateUrl(url);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openUpdateUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
