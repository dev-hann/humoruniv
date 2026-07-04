import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humoruniv/core/widgets/molecules/dark_mode_selector.dart';
import 'package:humoruniv/core/widgets/molecules/settings_group.dart';
import 'package:humoruniv/core/widgets/molecules/settings_tile.dart';
import 'package:humoruniv/core/widgets/molecules/update_banner.dart';
import 'package:humoruniv/presentation/providers/theme_provider.dart';
import 'package:humoruniv/presentation/providers/update_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final updateState = ref.watch(updateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
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
            title: '앱 정보',
            children: [
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.hasData
                      ? 'v${snapshot.data!.version}'
                      : '...';
                  return SettingsTile(title: '버전', subtitle: version);
                },
              ),
              UpdateBanner(
                status: updateState.status,
                newVersion: updateState.release?.version,
                downloadProgress: updateState.downloadProgress,
                hasApkDownloadUrl: updateState.release?.downloadUrl != null,
                onCheck: () {
                  ref.read(updateProvider.notifier).checkForUpdate();
                },
                onUpdate: () {
                  final notifier = ref.read(updateProvider.notifier);
                  if (updateState.release?.downloadUrl != null) {
                    notifier.downloadUpdate();
                  } else {
                    final url = updateState.release?.htmlUrl;
                    if (url != null && url.isNotEmpty) {
                      _openUpdateUrl(context, url);
                    }
                  }
                },
                onCancelDownload: () {
                  ref.read(updateProvider.notifier).cancelDownload();
                },
                onInstall: () {
                  ref.read(updateProvider.notifier).launchInstaller();
                },
                onRetryDownload: () {
                  ref.read(updateProvider.notifier).downloadUpdate();
                },
                onOpenPermissionSettings: () {
                  ref
                      .read(updateProvider.notifier)
                      .openInstallPermissionSettings();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openUpdateUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final launched =
        await canLaunchUrl(uri) &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('업데이트 페이지를 열 수 없습니다.')));
    }
  }
}
