import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_strings.dart';
import 'sound_service.dart';

class UpdateInfo {
  const UpdateInfo({
    required this.latestBuildNumber,
    required this.latestVersion,
    required this.releaseNotes,
    this.downloadUrl,
  });

  final int latestBuildNumber;
  final String latestVersion;
  final String releaseNotes;
  final String? downloadUrl;

  static UpdateInfo? fromFirestoreMap(
    Map<String, dynamic> data,
    TargetPlatform platform,
  ) {
    final isAndroid = platform == TargetPlatform.android;
    final isIos = platform == TargetPlatform.iOS;

    final buildNumber = _readInt(
      isAndroid
          ? data['androidBuildNumber'] ?? data['latestBuildNumber']
          : isIos
          ? data['iosBuildNumber'] ?? data['latestBuildNumber']
          : data['latestBuildNumber'],
    );
    if (buildNumber == null || buildNumber <= 0) return null;

    final version =
        (isAndroid
                ? data['androidVersion'] ?? data['latestVersion']
                : isIos
                ? data['iosVersion'] ?? data['latestVersion']
                : data['latestVersion'])
            as String? ??
        '1.0.0';

    final releaseNotes =
        (data['releaseNotes'] as String?)?.trim() ?? 'New GrimGrind version';

    final url = isAndroid
        ? (data['androidUrl'] as String?) ?? (data['fallbackUrl'] as String?)
        : isIos
        ? (data['iosUrl'] as String?) ?? (data['fallbackUrl'] as String?)
        : (data['fallbackUrl'] as String?);

    return UpdateInfo(
      latestBuildNumber: buildNumber,
      latestVersion: version,
      releaseNotes: releaseNotes,
      downloadUrl: url,
    );
  }

  static int? _readInt(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }
}

class UpdateCheckResult {
  const UpdateCheckResult({
    required this.info,
    required this.currentBuildNumber,
    required this.currentVersion,
  });

  final UpdateInfo info;
  final int currentBuildNumber;
  final String currentVersion;

  bool get isUpdateAvailable => info.latestBuildNumber > currentBuildNumber;
}

class DistributionUpdateService {
  DistributionUpdateService({
    Future<UpdateCheckResult?> Function()? customFetcher,
    Future<bool> Function(String url)? customLauncher,
  }) : _customFetcher = customFetcher,
       _customLauncher = customLauncher;

  final Future<UpdateCheckResult?> Function()? _customFetcher;
  final Future<bool> Function(String url)? _customLauncher;

  static const String defaultFirebaseAppTesterUrl =
      'https://appdistribution.firebase.dev/i/152f586ed88ca49c';

  Future<({String version, int buildNumber})> currentAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return (
        version: packageInfo.version,
        buildNumber: int.tryParse(packageInfo.buildNumber) ?? 0,
      );
    } catch (_) {
      return (version: '1.0.0', buildNumber: 0);
    }
  }

  Future<UpdateCheckResult?> checkForUpdate({TargetPlatform? platform}) async {
    if (_customFetcher != null) {
      return _customFetcher();
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      final current = await currentAppVersion();
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('distribution')
          .get();
      final data = doc.data();
      if (!doc.exists || data == null) return null;

      final info = UpdateInfo.fromFirestoreMap(
        data,
        platform ?? defaultTargetPlatform,
      );
      if (info == null) return null;

      return UpdateCheckResult(
        info: info,
        currentBuildNumber: current.buildNumber,
        currentVersion: current.version,
      );
    } catch (_) {
      // Gracefully ignore when Firebase is not configured (local demo/tests)
      // or when offline.
      return null;
    }
  }

  Future<bool> openUpdateUrl(UpdateInfo info) async {
    final target = (info.downloadUrl?.trim().isNotEmpty ?? false)
        ? info.downloadUrl!.trim()
        : defaultFirebaseAppTesterUrl;
    if (_customLauncher != null) {
      return _customLauncher(target);
    }
    final uri = Uri.tryParse(target);
    if (uri == null) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class UpdateBanner extends StatelessWidget {
  const UpdateBanner({
    super.key,
    required this.result,
    required this.onUpdate,
    required this.onDismiss,
  });

  final UpdateCheckResult result;
  final VoidCallback onUpdate;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final info = result.info;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF17171A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC6A15B), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.system_update_alt,
                color: Color(0xFFC6A15B),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.newVersionTitle(info.latestVersion, info.latestBuildNumber),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE9E0D0),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          if (info.releaseNotes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              info.releaseNotes,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF968C80),
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: withButtonSound(onDismiss),
                child: Text(
                  s.updateLaterBtn,
                  style: const TextStyle(color: Color(0xFF968C80)),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6E1830),
                  foregroundColor: const Color(0xFFF7EEE0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
                onPressed: withButtonSound(onUpdate),
                icon: const Icon(Icons.download_rounded, size: 16),
                label: Text(s.updateNowBtn),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
