import 'package:flutter/material.dart';
import 'ad_service.dart';

/// Observer du cycle de vie pour afficher l'App Open Ad
/// quand l'utilisateur revient dans l'app depuis le background.
class AppLifecycleObserver extends WidgetsBindingObserver {
  final AdService adService;
  bool _isShowingAd = false;
  bool _isFirstResume = true; // ne pas montrer l'app open au 1er lancement

  AppLifecycleObserver(this.adService);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_isFirstResume) {
        _isFirstResume = false;
        return; // pas de pub au tout premier lancement
      }
      _showAppOpenIfAvailable();
    }
  }

  void _showAppOpenIfAvailable() {
    if (_isShowingAd) return;
    _isShowingAd = true;
    adService.showAppOpen(
      onDismissed: () => _isShowingAd = false,
    );
  }
}
