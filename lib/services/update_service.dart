import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Dados de uma versão mais nova do app, publicados junto com o APK
/// em https://medconnect-r71.web.app/version.json.
class UpdateInfo {
  const UpdateInfo({required this.version, required this.apkUrl, this.notes});

  final String version;
  final String apkUrl;
  final String? notes;
}

/// Verifica, ao abrir o app, se existe uma versão mais nova publicada.
/// Falha silenciosamente (sem internet, arquivo ausente etc.) para
/// nunca atrapalhar o uso do app.
abstract final class UpdateService {
  static const String _versionUrl =
      'https://medconnect-r71.web.app/version.json';

  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      final int currentBuild = int.tryParse(info.buildNumber) ?? 0;

      final http.Response response = await http
          .get(Uri.parse(_versionUrl))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return null;

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      final int latestBuild = json['buildNumber'] as int? ?? 0;
      if (latestBuild <= currentBuild) return null;

      return UpdateInfo(
        version: json['version'] as String? ?? '',
        apkUrl: json['apkUrl'] as String? ??
            'https://medconnect-r71.web.app/medconnect.apk.bin',
        notes: json['notes'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> openDownload(String url) {
    return launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
