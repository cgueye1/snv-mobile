import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_service.dart';

/// Widget bannière réutilisable.
/// S'affiche en bas de l'écran uniquement si la bannière est chargée.
class BannerAdWidget extends StatelessWidget {
  final AdService adService;

  const BannerAdWidget({Key? key, required this.adService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!adService.isBannerLoaded || adService.bannerAd == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: adService.bannerAd!.size.width.toDouble(),
      height: adService.bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: adService.bannerAd!),
    );
  }
}
