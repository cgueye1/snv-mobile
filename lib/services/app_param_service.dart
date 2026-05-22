import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_param_model.dart';

class AppParamService {
  static const String _baseUrl = 'https://seddo.innovimpactdev.cloud';

  /// Récupère les paramètres depuis l'API
  static Future<AppParamModel?> fetchParams() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/appparam'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return AppParamModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('AppParamService.fetchParams error: $e');
    }
    return null;
  }

  /// Vérifie si les pubs doivent être cachées pour la plateforme actuelle
  static bool shouldHideAds(AppParamModel params) {
    if (Platform.isAndroid) return params.hideVoyanceAndroidAds;
    if (Platform.isIOS) return params.hideVoyanceAdsIos;
    return false;
  }

  /// Vérifie si la version actuelle est dans la liste bloquée
  /// Si oui → affiche un dialog de mise à jour obligatoire
  static Future<void> checkVersion(BuildContext context, AppParamModel params) async {
    if (params.appVersionList.isEmpty) return;

    final info = await PackageInfo.fromPlatform();
    final currentVersion = info.version; // ex: "1.0.0"

    debugPrint('📱 Version actuelle : $currentVersion');
    debugPrint('🚫 Versions bloquées : ${params.appVersionList}');

    if (!params.appVersionList.contains(currentVersion)) {
      // Version bloquée → forcer mise à jour
      if (context.mounted) {
        _showUpdateDialog(context, params);
      }
    }
  }

  static void _showUpdateDialog(BuildContext context, AppParamModel params) {
    final storeLink = Platform.isAndroid
        ? params.voyanceandroidLink
        : params.voyanceiosLink;

    showDialog(
      context: context,
      barrierDismissible: false, // non fermable
      builder: (_) => WillPopScope(
        onWillPop: () async => false, // bouton retour désactivé
        child: AlertDialog(
          backgroundColor: const Color(0xFF0D0D0D),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text(
            '🔮 Mise à jour requise',
            style: TextStyle(
                color: Color(0xFFD4A017), fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Une nouvelle version de Snap Voyance est disponible.\n'
            'Veuillez mettre à jour l\'application pour continuer.',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
          actions: [
            if (storeLink != null && storeLink.isNotEmpty)
              TextButton(
                onPressed: () async {
                  final uri = Uri.parse(storeLink);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4A017), Color(0xFFB8860B)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Mettre à jour',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
