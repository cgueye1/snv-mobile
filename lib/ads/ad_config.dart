import 'dart:io';

class AdConfig {
  static const String _androidPublisher = 'ca-app-pub-7248255245937838';
  static const String _iosPublisher     = 'ca-app-pub-7248255245937838';

  // ── Android ──────────────────────────────────────────────
  static const _android = {
    'banner':        '$_androidPublisher/7910428571',
    'interstitial':  '$_androidPublisher/1592255405',
    'appOpen':       '$_androidPublisher/2452302663',
    'rewarded':      '$_androidPublisher/5339928720',
  };

  // ── iOS ──────────────────────────────────────────────────
  static const _ios = {
    'banner':        '$_iosPublisher/1153448530',
    'interstitial':  '$_iosPublisher/7529093890',
    'appOpen':       '$_iosPublisher/7736418936',
    'rewarded':      '$_iosPublisher/7337522202',
  };

  static String get banner       => Platform.isIOS ? _ios['banner']!       : _android['banner']!;
  static String get interstitial => Platform.isIOS ? _ios['interstitial']! : _android['interstitial']!;
  static String get appOpen      => Platform.isIOS ? _ios['appOpen']!      : _android['appOpen']!;
  static String get rewarded     => Platform.isIOS ? _ios['rewarded']!     : _android['rewarded']!;
}
