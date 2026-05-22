import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ads/ad_service.dart';
import 'ads/app_lifecycle_observer.dart';
import 'firebase_options.dart';
import 'screens/tani_screen.dart';
import 'services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 Background : ${message.notification?.title}');
}

final AdService adService = AdService();
final NotificationService notificationService = NotificationService();
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Firebase obligatoire en premier
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // L'app s'affiche immédiatement
  runApp(const SnapVoyanceApp());

  // AdMob + Notifications en arrière-plan
  Future.wait([
    MobileAds.instance.initialize().then((_) => adService.initAll()),
    notificationService.init().then((_) =>
        notificationService.subscribeToTopic('horoscope_daily')),
  ]);
}

class SnapVoyanceApp extends StatefulWidget {
  const SnapVoyanceApp({Key? key}) : super(key: key);

  @override
  State<SnapVoyanceApp> createState() => _SnapVoyanceAppState();
}

class _SnapVoyanceAppState extends State<SnapVoyanceApp> {
  late final AppLifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();
    _lifecycleObserver = AppLifecycleObserver(adService);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);

    // ATT : demandé après que le widget soit construit
    // Délai de 1s pour laisser l'app s'afficher et éviter
    // les conflits avec le dialog de notifications FCM
    if (Platform.isIOS) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(seconds: 1));
        await _requestTrackingAuthorization();
      });
    }
  }

  Future<void> _requestTrackingAuthorization() async {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    debugPrint('🔍 ATT status: $status');

    if (status == TrackingStatus.notDetermined) {
      // Dialog explicatif AVANT le dialog système (recommandé par Apple)
      if (mounted) await _showTrackingDialog();
      await Future.delayed(const Duration(milliseconds: 300));

      final newStatus =
      await AppTrackingTransparency.requestTrackingAuthorization();
      debugPrint('✅ ATT new status: $newStatus');
    }
  }

  Future<void> _showTrackingDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '🔮 Snap Voyance',
          style: TextStyle(
              color: Color(0xFFD4A017), fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Pour garder cette app gratuite, nous affichons des publicités.\n\n'
              'Autoriser le suivi publicitaire nous aide à vous montrer des annonces '
              'adaptées à vos intérêts. Vous pouvez modifier ce choix à tout moment '
              'dans les réglages de votre iPhone.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Continuer',
              style: TextStyle(
                  color: Color(0xFFD4A017), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    adService.disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snap Voyance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      home: const TaniScreen(),
    );
  }
}