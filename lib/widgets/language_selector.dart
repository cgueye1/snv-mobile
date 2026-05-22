import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class LanguageSelector extends StatelessWidget {
  final String currentLang;
  final Function(String) onChanged;

  const LanguageSelector({
    Key? key,
    required this.currentLang,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ['wo', 'fr', 'en'].map((lang) {
        final isSelected = currentLang == lang;
        return GestureDetector(
          onTap: () async {
            await StorageService.saveLanguage(lang);
            onChanged(lang);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFD4A017)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFD4A017)
                    : Colors.white24,
              ),
            ),
            child: Text(
              lang.toUpperCase(),
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
