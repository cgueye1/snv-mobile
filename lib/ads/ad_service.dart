import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';

/// Service centralisé pour gérer les 4 types de publicités AdMob.
/// Bonnes pratiques respectées :
/// - Préchargement dès le démarrage
/// - Rechargement automatique après affichage
/// - Gestion des erreurs sans crash
/// - Pas de pub sur le premier lancement (app open seulement au 2e)
class AdService {

  // ── Banner ────────────────────────────────────────────────
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;

  bool get isBannerLoaded => _bannerLoaded;
  BannerAd? get bannerAd => _bannerAd;

  void loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: AdConfig.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => _bannerLoaded = true,
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed: $error');
          ad.dispose();
          _bannerLoaded = false;
          // Retry après 30s
          Future.delayed(const Duration(seconds: 30), loadBanner);
        },
      ),
    )..load();
  }

  void disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _bannerLoaded = false;
  }

  // ── Interstitiel ──────────────────────────────────────────
  InterstitialAd? _interstitialAd;
  bool _interstitialReady = false;
  int _interstitialFailCount = 0;
  static const int _maxRetries = 3;

  void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AdConfig.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialReady = true;
          _interstitialFailCount = 0;
          ad.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed: $error');
          _interstitialReady = false;
          _interstitialFailCount++;
          if (_interstitialFailCount < _maxRetries) {
            Future.delayed(const Duration(seconds: 30), loadInterstitial);
          }
        },
      ),
    );
  }

  /// Affiche l'interstitiel si prêt.
  /// [onDismissed] appelé quand l'utilisateur ferme la pub.
  void showInterstitial({VoidCallback? onDismissed}) {
    if (!_interstitialReady || _interstitialAd == null) {
      debugPrint('Interstitial not ready');
      onDismissed?.call();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _interstitialReady = false;
        loadInterstitial(); // précharger le suivant
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial show failed: $error');
        ad.dispose();
        _interstitialAd = null;
        _interstitialReady = false;
        loadInterstitial();
        onDismissed?.call();
      },
    );
    _interstitialAd!.show();
    _interstitialReady = false;
  }

  // ── Rewarded ──────────────────────────────────────────────
  RewardedAd? _rewardedAd;
  bool _rewardedReady = false;
  int _rewardedFailCount = 0;

  void loadRewarded() {
    RewardedAd.load(
      adUnitId: AdConfig.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedReady = true;
          _rewardedFailCount = 0;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded failed: $error');
          _rewardedReady = false;
          _rewardedFailCount++;
          if (_rewardedFailCount < _maxRetries) {
            Future.delayed(const Duration(seconds: 30), loadRewarded);
          }
        },
      ),
    );
  }

  /// Affiche la pub récompensée.
  /// [onRewarded] appelé si l'utilisateur gagne la récompense.
  /// [onDismissed] appelé dans tous les cas à la fermeture.
  void showRewarded({
    required void Function(RewardItem reward) onRewarded,
    VoidCallback? onDismissed,
  }) {
    if (!_rewardedReady || _rewardedAd == null) {
      debugPrint('Rewarded not ready');
      onDismissed?.call();
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _rewardedReady = false;
        loadRewarded();
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded show failed: $error');
        ad.dispose();
        _rewardedAd = null;
        _rewardedReady = false;
        loadRewarded();
        onDismissed?.call();
      },
    );
    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
      onUserEarnedReward: (_, reward) => onRewarded(reward),
    );
    _rewardedReady = false;
  }

  // ── App Open ──────────────────────────────────────────────
  AppOpenAd? _appOpenAd;
  bool _appOpenReady = false;
  DateTime? _appOpenLoadTime;
  // L'app open n'est valide que 4h
  static const Duration _appOpenMaxAge = Duration(hours: 4);

  void loadAppOpen() {
    AppOpenAd.load(
      adUnitId: AdConfig.appOpen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenReady = true;
          _appOpenLoadTime = DateTime.now();
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpen failed: $error');
          _appOpenReady = false;
        },
      ),
    );
  }

  bool get _isAppOpenAdValid {
    if (!_appOpenReady || _appOpenAd == null || _appOpenLoadTime == null) return false;
    return DateTime.now().difference(_appOpenLoadTime!) < _appOpenMaxAge;
  }

  void showAppOpen({VoidCallback? onDismissed}) {
    if (!_isAppOpenAdValid) {
      debugPrint('AppOpen not valid, reloading...');
      loadAppOpen();
      onDismissed?.call();
      return;
    }
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        _appOpenReady = false;
        loadAppOpen(); // précharger pour le prochain retour en app
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AppOpen show failed: $error');
        ad.dispose();
        _appOpenAd = null;
        _appOpenReady = false;
        loadAppOpen();
        onDismissed?.call();
      },
    );
    _appOpenAd!.show();
    _appOpenReady = false;
  }

  // ── Init ──────────────────────────────────────────────────
  /// À appeler dans main() après MobileAds.instance.initialize()
  void initAll() {
    loadBanner();
    loadInterstitial();
    loadRewarded();
    loadAppOpen();
  }

  void disposeAll() {
    disposeBanner();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
  }
}
