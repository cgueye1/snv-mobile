import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class UserInfoModal extends StatefulWidget {
  final VoidCallback onSaved;
  const UserInfoModal({Key? key, required this.onSaved}) : super(key: key);

  @override
  State<UserInfoModal> createState() => _UserInfoModalState();
}

class _UserInfoModalState extends State<UserInfoModal> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _selectedDate = '';
  bool _saving = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD4A017),
            surface: Color(0xFF1A1A1A),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate =
        '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      });
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().isEmpty ||
        _selectedDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _saving = true);

    // 1. Appel API → crée ou récupère l'utilisateur existant
    final apiUser = await ApiService.createOrGetUser(
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      date: _selectedDate,
    );

    // 2. Stocker en local : si l'API répond on utilise ses données (avec l'id),
    //    sinon on stocke les données saisies sans id (fallback offline)
    final userToSave = apiUser ?? UserModel(
      fullName: _nameCtrl.text.trim(),
      birthDate: _selectedDate,
      phone: _phoneCtrl.text.trim(),
    );

    await StorageService.saveUser(userToSave);
    setState(() => _saving = false);
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // empêche de fermer sans remplir
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD4A017), width: 1.5),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Titre
                const Text(
                  'SNAP VOYANCE',
                  style: TextStyle(
                    color: Color(0xFFD4A017),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Donnez vos informations pour continuer',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Nom complet
                _buildField(
                  controller: _nameCtrl,
                  hint: 'Nom complet',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 14),

                // Date de naissance
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            color: Color(0xFFD4A017), size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDate.isEmpty
                              ? 'Date de naissance'
                              : _selectedDate,
                          style: TextStyle(
                            color: _selectedDate.isEmpty
                                ? Colors.white38
                                : Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Téléphone
                _buildField(
                  controller: _phoneCtrl,
                  hint: 'Téléphone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 28),

                // Bouton
                GestureDetector(
                  onTap: _saving ? null : _save,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4A017), Color(0xFFB8860B)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _saving
                          ? const CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 2)
                          : const Text(
                        'CONTINUER',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: const Color(0xFFD4A017), size: 20),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF333333)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF333333)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD4A017)),
        ),
      ),
    );
  }
}