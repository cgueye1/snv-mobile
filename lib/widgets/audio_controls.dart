import 'package:flutter/material.dart';

class AudioControls extends StatelessWidget {
  final VoidCallback onReplay;
  final VoidCallback onContinue;
  final String language;

  const AudioControls({
    Key? key,
    required this.onReplay,
    required this.onContinue,
    required this.language,
  }) : super(key: key);

  String get _replayLabel {
    switch (language) {
      case 'wo':
        return 'Wax ci kanam';
      case 'en':
        return 'Replay';
      default:
        return 'Réécouter';
    }
  }

  String get _continueLabel {
    switch (language) {
      case 'wo':
        return 'Continuer';
      case 'en':
        return 'Continue';
      default:
        return 'Continuer';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(color: const Color(0xFFD4A017).withOpacity(0.4)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Replay
          _ControlButton(
            icon: Icons.replay_rounded,
            label: _replayLabel,
            color: const Color(0xFF555555),
            onTap: onReplay,
          ),
          // Continue
          _ControlButton(
            icon: Icons.arrow_forward_rounded,
            label: _continueLabel,
            color: const Color(0xFFD4A017),
            textColor: Colors.black,
            onTap: onContinue,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    this.textColor = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
