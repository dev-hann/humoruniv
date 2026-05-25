import 'package:meta/meta.dart';

@immutable
class AppRelease {
  const AppRelease({
    required this.version,
    required this.htmlUrl,
    this.downloadUrl,
    this.releaseNotes,
  });
  final String version;
  final String htmlUrl;
  final String? downloadUrl;
  final String? releaseNotes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppRelease &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          htmlUrl == other.htmlUrl &&
          downloadUrl == other.downloadUrl &&
          releaseNotes == other.releaseNotes;

  @override
  int get hashCode => Object.hash(version, htmlUrl, downloadUrl, releaseNotes);
}
