import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ads/banner_ad_widget.dart';
import '../main.dart' show adService;
import '../models/app_param_model.dart';
import '../services/app_param_service.dart';

import '../models/prediction_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../widgets/audio_controls.dart';
import '../widgets/language_selector.dart';
import '../widgets/user_info_modal.dart';

const List<String> kZodiacSigns = [
  'BELIER', 'TAUREAU', 'GEMEAUX', 'CANCER',
  'LION', 'VIERGE', 'BALANCE', 'SCORPION',
  'SAGITTAIRE', 'CAPRICORNE', 'VERSEAU', 'POISSONS',
];

class _SignQueue {
  final _rnd = Random();
  late List<String> _queue;
  int _queueIndex = 0;
  int _callCount = 0;
  static const int callsPerSign = 5;

  _SignQueue() {
    _queue = List<String>.from(kZodiacSigns);
    _queue.shuffle(_rnd);
  }

  String get current => _queue[_queueIndex];

  void consume() {
    _callCount++;
    if (_callCount >= callsPerSign) {
      _callCount = 0;
      _queueIndex++;
      if (_queueIndex >= _queue.length) {
        final lastSign = _queue.last;
        _queue = List<String>.from(kZodiacSigns);
        _queue.shuffle(_rnd);
        if (_queue.first == lastSign) {
          _queue.remove(lastSign);
          _queue.add(lastSign);
        }
        _queueIndex = 0;
      }
    }
  }
}

class _Obj {
  final String img;
  double x, y;
  double vx, vy;
  double rot;
  double vrot;
  bool flying;

  _Obj({
    required this.img,
    required this.x,
    required this.y,
    this.rot = 0,
    this.vx = 0,
    this.vy = 0,
    this.vrot = 0,
    this.flying = false,
  });
}

class TaniScreen extends StatefulWidget {
  const TaniScreen({Key? key}) : super(key: key);
  @override
  State<TaniScreen> createState() => _TaniScreenState();
}

class _TaniScreenState extends State<TaniScreen> with TickerProviderStateMixin {

  bool _loading = false;
  bool _isPlaying = false;
  bool _showControls = false;
  bool _isSpeaking = false; // ← AJOUT : true uniquement pendant lecture audio/TTS
  int _throwCount = 0; // interstitiel toutes les 3 prédictions
  AppParamModel? _appParams; // ← paramètres serveur
  UserModel? _user;
  String _language = 'wo';
  PredictionModel? _currentPrediction;
  String _predictionText = '';

  final _signQueue = _SignQueue();
  bool _handDropped = false;
  bool _isDragging = false;

  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final _rnd = Random();

  List<_Obj> _objs = [];
  Size _screenSize = Size.zero;

  Ticker? _ticker;
  Duration _lastTick = Duration.zero;
  bool _simulating = false;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _ticker = createTicker(_onTick);

    _initApp();
  }

  Future<void> _initApp() async {
    _language = await StorageService.getLanguage();
    _user = await StorageService.getUser();
    setState(() {});
    if (_user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showUserModal());
    }
    await _setupTts();

    // ── Récupérer les paramètres serveur ──────────────────────────────────
    _appParams = await AppParamService.fetchParams();
    if (_appParams != null) {
      setState(() {});
      // Vérifier si la version est bloquée
      if (mounted) {
        await AppParamService.checkVersion(context, _appParams!);
      }
    }
  }

  /// true = cacher les pubs sur cette plateforme
  bool get _hideAds {
    if (_appParams == null) return false;
    return AppParamService.shouldHideAds(_appParams!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = MediaQuery.of(context).size;
    if (_screenSize != s) {
      _screenSize = s;
      _placeObjects();
    }
  }

  void _placeObjects() {
    if (_screenSize == Size.zero) return;
    final w = _screenSize.width;
    final h = _screenSize.height;
    _objs = [
      _Obj(img: 'cauri', x: w * 0.50, y: h * 0.20, rot: -0.3),
      _Obj(img: 'cauri', x: w * 0.72, y: h * 0.26, rot:  0.8),
      _Obj(img: 'cauri', x: w * 0.82, y: h * 0.44, rot: -0.5),
      _Obj(img: 'cauri', x: w * 0.78, y: h * 0.64, rot:  0.2),
      _Obj(img: 'cauri', x: w * 0.60, y: h * 0.76, rot: -1.0),
      _Obj(img: 'cauri', x: w * 0.40, y: h * 0.76, rot:  0.6),
      _Obj(img: 'cauri', x: w * 0.22, y: h * 0.64, rot: -0.4),
      _Obj(img: 'cauri', x: w * 0.18, y: h * 0.44, rot:  1.2),
      _Obj(img: 'cauri', x: w * 0.28, y: h * 0.26, rot: -0.7),
      _Obj(img: 'cauri', x: w * 0.50, y: h * 0.30, rot:  0.9),
      _Obj(img: 'cauri', x: w * 0.68, y: h * 0.38, rot: -0.3),
      _Obj(img: 'cauri', x: w * 0.68, y: h * 0.58, rot:  0.4),
      _Obj(img: 'cauri', x: w * 0.50, y: h * 0.66, rot: -0.9),
      _Obj(img: 'cauri', x: w * 0.32, y: h * 0.58, rot:  0.6),
      _Obj(img: 'cauri', x: w * 0.32, y: h * 0.38, rot: -0.2),
      _Obj(img: 'piece', x: w * 0.44, y: h * 0.50, rot:  0.3),
      _Obj(img: 'cola',  x: w * 0.56, y: h * 0.48, rot: -0.2),
    ];
    setState(() {});
  }

  void _onTick(Duration elapsed) {
    if (!_simulating) return;

    final dt = _lastTick == Duration.zero
        ? 0.016
        : (elapsed - _lastTick).inMilliseconds / 1000.0;
    _lastTick = elapsed;

    final w = _screenSize.width;
    final h = _screenSize.height;
    const friction = 0.88;

    bool anyFlying = false;
    for (final o in _objs) {
      if (!o.flying) continue;

      o.x += o.vx * dt;
      o.y += o.vy * dt;
      o.rot += o.vrot * dt;

      if (o.x < w * 0.12)  { o.x = w * 0.12;  o.vx =  o.vx.abs(); }
      if (o.x > w * 0.88)  { o.x = w * 0.88;  o.vx = -o.vx.abs(); }
      if (o.y < h * 0.18)  { o.y = h * 0.18;  o.vy =  o.vy.abs(); }
      if (o.y > h * 0.82)  { o.y = h * 0.82;  o.vy = -o.vy.abs(); }

      o.vx   *= friction;
      o.vy   *= friction;
      o.vrot *= friction;

      final speed = sqrt(o.vx * o.vx + o.vy * o.vy);
      if (speed < 2) {
        o.vx = 0; o.vy = 0; o.vrot = 0; o.flying = false;
      } else {
        anyFlying = true;
      }
    }

    if (!anyFlying) {
      _simulating = false; _ticker!.stop(); _lastTick = Duration.zero;
    }

    setState(() {});
  }

  void _throwAll() {
    const maxSpeed = 1800.0;
    const minSpeed = 800.0;
    for (final o in _objs) {
      final angle = _rnd.nextDouble() * 2 * pi;
      final speed = minSpeed + _rnd.nextDouble() * (maxSpeed - minSpeed);
      o.vx   = cos(angle) * speed;
      o.vy   = sin(angle) * speed;
      o.vrot = (_rnd.nextDouble() - 0.5) * 30;
      o.flying = true;
    }
    _simulating = true;
    _lastTick = Duration.zero;
    if (!_ticker!.isActive) _ticker!.start();
    setState(() {});
  }

  void _shakeGently() {
    const gentleSpeed = 180.0;
    for (final o in _objs) {
      final angle = _rnd.nextDouble() * 2 * pi;
      o.vx   = cos(angle) * gentleSpeed;
      o.vy   = sin(angle) * gentleSpeed;
      o.vrot = (_rnd.nextDouble() - 0.5) * 4;
      o.flying = true;
    }
    _simulating = true;
    _lastTick = Duration.zero;
    if (!_ticker!.isActive) _ticker!.start();
    setState(() {});
  }

  void _onDragStarted() {
    if (_loading || _isPlaying) return;
    setState(() => _isDragging = true);
    _shakeGently();
  }

  void _onHandDropped(Offset offset) async {
    if (_loading || _isPlaying) return;
    setState(() { _handDropped = true; _isDragging = false; });
    _throwAll();
    await _fetchAndPlay();
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _handDropped = false);
  }

  Future<void> _fetchAndPlay() async {
    if (_user == null) { _showUserModal(); return; }
    setState(() { _loading = true; _showControls = false; _predictionText = ''; });

    final sign = _signQueue.current;
    debugPrint('🔮 Signe utilisé : $sign (appel ${_signQueue._callCount + 1}/5)');

    final prediction = await ApiService.getPrediction(
      zodiacSign: sign,
      language: _language.toUpperCase(),
      userId: _user!.id ?? 1, // ← utilise l'id réel retourné par l'API
    );

    _signQueue.consume();
    debugPrint('➡️  Prochain signe : ${_signQueue.current}');

    setState(() => _loading = false);

    if (prediction == null) {
      debugPrint('❌ prediction == null → TTS fallback');
      _speakFallback();
      return;
    }

    debugPrint('✅ Prédiction reçue :');
    debugPrint('   success      = ${prediction.success}');
    debugPrint('   language     = ${prediction.language}');
    debugPrint('   predictionId = ${prediction.predictionId}');
    debugPrint('   _language    = $_language');
    debugPrint('   message[60]  = ${prediction.message.substring(0, prediction.message.length.clamp(0, 60))}');

    setState(() {
      _currentPrediction = prediction;
      _predictionText = prediction.message;
      _isPlaying = true;
    });

    if (_language == 'wo' && prediction.predictionId != null) {
      final audioUrl = ApiService.getAudioUrl(prediction.predictionId!);
      debugPrint('🎵 Wolof + predictionId=${prediction.predictionId} → lecture audio : $audioUrl');
      await _playApiAudio(audioUrl);
    } else {
      debugPrint('🗣️  TTS utilisé. Raison : _language=$_language | predictionId=${prediction.predictionId}');
      await _speakText(prediction.message);
    }
  }

  Future<void> _playApiAudio(String url) async {
    try {
      debugPrint('⬇️  Téléchargement WAV : $url');
      await _tts.stop();
      await _audioPlayer.stop();

      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 30));

      debugPrint('   → statusCode : ${response.statusCode}');
      debugPrint('   → bytes      : ${response.bodyBytes.length}');

      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        debugPrint('❌ Téléchargement échoué → TTS fallback');
        await _speakText(_predictionText);
        return;
      }

      final tmpDir = await getTemporaryDirectory();
      final tmpFile = File('${tmpDir.path}/prediction_audio.wav');
      await tmpFile.writeAsBytes(response.bodyBytes);
      debugPrint('✅ Fichier WAV écrit : ${tmpFile.path}');

      if (mounted) setState(() => _isSpeaking = true); // ← AJOUT
      await _audioPlayer.play(DeviceFileSource(tmpFile.path));
      debugPrint('▶️  AudioPlayer démarré depuis fichier local');

    } catch (e) {
      debugPrint('❌ Erreur _playApiAudio : $e → TTS fallback');
      await _speakText(_predictionText);
    }
  }

  Future<void> _setupTts() async {
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(0.95);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() { _showControls = true; _isSpeaking = false; }); // ← MODIF
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      debugPrint('✅ Audio WAV terminé');
      if (mounted) setState(() { _showControls = true; _isSpeaking = false; }); // ← MODIF
    });
  }

  Future<void> _speakText(String text) async {
    if (mounted) setState(() => _isSpeaking = true); // ← AJOUT
    await _tts.setLanguage(_language == 'en' ? 'en-US' : 'fr-FR');
    await _tts.speak(text);
  }

  void _speakFallback() {
    _speakText({'wo': 'Soo ragalul, dellu ellek.', 'fr': 'Il faut revenir demain.', 'en': 'Please come back tomorrow.'}[_language] ?? '');
  }

  Future<void> _replayAudio() async {
    setState(() => _showControls = false);
    if (_language == 'wo' && _currentPrediction?.predictionId != null) {
      final url = ApiService.getAudioUrl(_currentPrediction!.predictionId!);
      await _playApiAudio(url);
    } else {
      await _speakText(_predictionText);
    }
  }

  Future<void> _stopAndReset() async {
    await _tts.stop();
    await _audioPlayer.stop();
    setState(() { _isPlaying = false; _showControls = false; _predictionText = ''; _currentPrediction = null; _isSpeaking = false; }); // ← MODIF

    // Interstitiel toutes les 3 prédictions (si pubs autorisées)
    _throwCount++;
    if (_throwCount % 3 == 0 && !_hideAds) {
      adService.showInterstitial();
    }
  }

  void _showUserModal() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => UserInfoModal(onSaved: () async {
        Navigator.pop(context);
        _user = await StorageService.getUser();
        setState(() {});
      }),
    );
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _pulseCtrl.dispose();
    _tts.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: _buildBoard(size)),
          Positioned(top: 0, left: 0, right: 0,
              child: SafeArea(child: _buildAppBar())),
          if (!_isPlaying && !_loading)
            Positioned(bottom: 50, left: 0, right: 0,
                child: Center(child: _buildHint())),
          if (_isPlaying)
            Positioned.fill(child: _buildPredictionOverlay(size)),
          if (_loading)
            Container(color: Colors.black45,
                child: const Center(child: CircularProgressIndicator(
                    color: Color(0xFFD4A017), strokeWidth: 2))),
          if (_showControls && _isPlaying)
            Positioned(bottom: 0, left: 0, right: 0,
                child: AudioControls(language: _language,
                    onReplay: _replayAudio, onContinue: _stopAndReset)),

          // BANNIÈRE ADMOB — visible uniquement hors lecture et si pubs autorisées
          if (!_isPlaying && !_hideAds)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Center(child: BannerAdWidget(adService: adService)),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.75), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _showUserBottomSheet,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFFD4A017).withOpacity(0.7)),
              ),
              child: const Icon(Icons.person_outline,
                  color: Color(0xFFD4A017), size: 26),
            ),
          ),
          LanguageSelector(
            currentLang: _language,
            onChanged: (lang) { setState(() => _language = lang); _setupTts(); },
          ),
        ],
      ),
    );
  }

  void _showUserBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _UserProfileSheet(
        user: _user,
        onDeleted: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          if (mounted) {
            setState(() => _user = null);
            Navigator.pop(context);
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _showUserModal());
          }
        },
      ),
    );
  }

  Widget _buildBoard(Size size) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
              child: Image.asset('assets/layou.png', fit: BoxFit.cover)),
          if (_isPlaying)
            Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.5))),
          ..._objs.map((o) => _buildObj(o)),
          if (!_isPlaying && !_handDropped)
            Positioned(
              left: size.width * 0.06,
              top: size.height * 0.42,
              child: _buildDraggableHand(),
            ),
        ],
      ),
    );
  }

  Widget _buildObj(_Obj o) {
    double w, h;
    switch (o.img) {
      case 'piece': w = 72;  h = 72;  break;
      case 'cola':  w = 90;  h = 115; break;
      default:      w = 88;  h = 74;  break;
    }
    return Positioned(
      left: o.x - w / 2,
      top:  o.y - h / 2,
      child: Transform.rotate(
        angle: o.rot,
        child: Image.asset(
          'assets/${o.img}.png',
          width: w, height: h, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const SizedBox(),
        ),
      ),
    );
  }

  Widget _buildDraggableHand() {
    return Draggable<String>(
      data: 'hand',
      feedback: Image.asset('assets/hand.png', width: 110, height: 178,
          errorBuilder: (_, __, ___) => const SizedBox()),
      childWhenDragging: const SizedBox(width: 110, height: 178),
      onDragStarted: _onDragStarted,
      onDraggableCanceled: (v, offset) => _onHandDropped(offset),
      onDragEnd: (details) => _onHandDropped(details.offset),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset('assets/hand.png', width: 110, height: 178,
              errorBuilder: (_, __, ___) => const SizedBox()),
          Positioned(
            bottom: -10, left: 10,
            child: Image.asset('assets/drag.png', width: 65,
                errorBuilder: (_, __, ___) => const SizedBox()),
          ),
        ],
      ),
    );
  }

  Widget _buildHint() {
    final labels = {
      'wo': 'Jëlee sa loxo ci kanam',
      'fr': 'Glissez votre main',
      'en': 'Drag your hand',
    };
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, child) => Transform.scale(scale: _pulseAnim.value, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.6)),
        ),
        child: Text(labels[_language] ?? labels['fr']!,
            style: const TextStyle(
              color: Color(0xFFD4A017),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            )),
      ),
    );
  }

  Widget _buildPredictionOverlay(Size size) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 70),
          Expanded(
            flex: 3,
            child: Center(
              child: Image.asset('assets/laf.gif', fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox()),
            ),
          ),
          // ← MODIF : wakh.gif visible seulement pendant la lecture
          if (_isSpeaking)
            Image.asset('assets/wakh.gif', width: size.width * 0.28,
                errorBuilder: (_, __, ___) => const SizedBox()),
          if (_predictionText.isNotEmpty)
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFFD4A017).withOpacity(0.35)),
                ),
                child: SingleChildScrollView(
                  child: Text(_predictionText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                      letterSpacing: 0.3,
                      shadows: [
                        Shadow(color: Colors.black, blurRadius: 4,
                            offset: Offset(1, 1)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: GestureDetector(
              onTap: _stopAndReset,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white12, shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.stop_rounded,
                    color: Colors.white54, size: 24),
              ),
            ),
          ),
          if (_showControls) const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
class _UserProfileSheet extends StatelessWidget {
  final UserModel? user;
  final VoidCallback onDeleted;

  const _UserProfileSheet({
    required this.user,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: const Color(0xFFD4A017), width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A1A1A),
              border: Border.all(color: const Color(0xFFD4A017), width: 2),
            ),
            child: const Icon(Icons.person, color: Color(0xFFD4A017), size: 40),
          ),
          const SizedBox(height: 16),
          if (user != null) ...[
            Text(
              user!.fullName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Date de naissance',
              value: user!.birthDate,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'Téléphone',
              value: user!.phone,
            ),
          ] else
            const Text('Aucun profil',
                style: TextStyle(color: Colors.white54, fontSize: 16)),
          const SizedBox(height: 32),
          const Divider(color: Color(0xFF2A2A2A)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _confirmDelete(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                SizedBox(width: 8),
                Text(
                  'Supprimer mon compte',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer ?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Toutes vos données seront effacées. Cette action est irréversible.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDeleted();
            },
            child: const Text('Supprimer',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD4A017), size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}