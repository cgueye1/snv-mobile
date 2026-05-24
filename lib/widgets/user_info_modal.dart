import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class _Country {
  final String name;
  final String flag;
  final String dialCode;
  final String isoCode;
  const _Country(this.name, this.flag, this.dialCode, this.isoCode);
}

const List<_Country> _kCountries = [
  _Country('Afghanistan',           '🇦🇫', '+93',   'AF'),
  _Country('Afrique du Sud',        '🇿🇦', '+27',   'ZA'),
  _Country('Albanie',               '🇦🇱', '+355',  'AL'),
  _Country('Algérie',               '🇩🇿', '+213',  'DZ'),
  _Country('Allemagne',             '🇩🇪', '+49',   'DE'),
  _Country('Andorre',               '🇦🇩', '+376',  'AD'),
  _Country('Angola',                '🇦🇴', '+244',  'AO'),
  _Country('Arabie Saoudite',       '🇸🇦', '+966',  'SA'),
  _Country('Argentine',             '🇦🇷', '+54',   'AR'),
  _Country('Arménie',               '🇦🇲', '+374',  'AM'),
  _Country('Australie',             '🇦🇺', '+61',   'AU'),
  _Country('Autriche',              '🇦🇹', '+43',   'AT'),
  _Country('Azerbaïdjan',           '🇦🇿', '+994',  'AZ'),
  _Country('Bahreïn',               '🇧🇭', '+973',  'BH'),
  _Country('Bangladesh',            '🇧🇩', '+880',  'BD'),
  _Country('Belgique',              '🇧🇪', '+32',   'BE'),
  _Country('Bénin',                 '🇧🇯', '+229',  'BJ'),
  _Country('Birmanie',              '🇲🇲', '+95',   'MM'),
  _Country('Bolivie',               '🇧🇴', '+591',  'BO'),
  _Country('Bosnie-Herzégovine',    '🇧🇦', '+387',  'BA'),
  _Country('Botswana',              '🇧🇼', '+267',  'BW'),
  _Country('Brésil',                '🇧🇷', '+55',   'BR'),
  _Country('Brunei',                '🇧🇳', '+673',  'BN'),
  _Country('Bulgarie',              '🇧🇬', '+359',  'BG'),
  _Country('Burkina Faso',          '🇧🇫', '+226',  'BF'),
  _Country('Burundi',               '🇧🇮', '+257',  'BI'),
  _Country('Cambodge',              '🇰🇭', '+855',  'KH'),
  _Country('Cameroun',              '🇨🇲', '+237',  'CM'),
  _Country('Canada',                '🇨🇦', '+1',    'CA'),
  _Country('Cap-Vert',              '🇨🇻', '+238',  'CV'),
  _Country('Chili',                 '🇨🇱', '+56',   'CL'),
  _Country('Chine',                 '🇨🇳', '+86',   'CN'),
  _Country('Chypre',                '🇨🇾', '+357',  'CY'),
  _Country('Colombie',              '🇨🇴', '+57',   'CO'),
  _Country('Comores',               '🇰🇲', '+269',  'KM'),
  _Country('Congo (Brazzaville)',   '🇨🇬', '+242',  'CG'),
  _Country('Congo (Kinshasa)',      '🇨🇩', '+243',  'CD'),
  _Country('Corée du Nord',         '🇰🇵', '+850',  'KP'),
  _Country('Corée du Sud',          '🇰🇷', '+82',   'KR'),
  _Country('Costa Rica',            '🇨🇷', '+506',  'CR'),
  _Country('Côte d\'Ivoire',        '🇨🇮', '+225',  'CI'),
  _Country('Croatie',               '🇭🇷', '+385',  'HR'),
  _Country('Cuba',                  '🇨🇺', '+53',   'CU'),
  _Country('Danemark',              '🇩🇰', '+45',   'DK'),
  _Country('Djibouti',              '🇩🇯', '+253',  'DJ'),
  _Country('Égypte',                '🇪🇬', '+20',   'EG'),
  _Country('Émirats Arabes Unis',   '🇦🇪', '+971',  'AE'),
  _Country('Équateur',              '🇪🇨', '+593',  'EC'),
  _Country('Érythrée',              '🇪🇷', '+291',  'ER'),
  _Country('Espagne',               '🇪🇸', '+34',   'ES'),
  _Country('Estonie',               '🇪🇪', '+372',  'EE'),
  _Country('Éthiopie',              '🇪🇹', '+251',  'ET'),
  _Country('Finlande',              '🇫🇮', '+358',  'FI'),
  _Country('France',                '🇫🇷', '+33',   'FR'),
  _Country('Gabon',                 '🇬🇦', '+241',  'GA'),
  _Country('Gambie',                '🇬🇲', '+220',  'GM'),
  _Country('Géorgie',               '🇬🇪', '+995',  'GE'),
  _Country('Ghana',                 '🇬🇭', '+233',  'GH'),
  _Country('Grèce',                 '🇬🇷', '+30',   'GR'),
  _Country('Guatemala',             '🇬🇹', '+502',  'GT'),
  _Country('Guinée',                '🇬🇳', '+224',  'GN'),
  _Country('Guinée-Bissau',         '🇬🇼', '+245',  'GW'),
  _Country('Guinée Équatoriale',    '🇬🇶', '+240',  'GQ'),
  _Country('Haïti',                 '🇭🇹', '+509',  'HT'),
  _Country('Honduras',              '🇭🇳', '+504',  'HN'),
  _Country('Hongrie',               '🇭🇺', '+36',   'HU'),
  _Country('Inde',                  '🇮🇳', '+91',   'IN'),
  _Country('Indonésie',             '🇮🇩', '+62',   'ID'),
  _Country('Irak',                  '🇮🇶', '+964',  'IQ'),
  _Country('Iran',                  '🇮🇷', '+98',   'IR'),
  _Country('Irlande',               '🇮🇪', '+353',  'IE'),
  _Country('Islande',               '🇮🇸', '+354',  'IS'),
  _Country('Israël',                '🇮🇱', '+972',  'IL'),
  _Country('Italie',                '🇮🇹', '+39',   'IT'),
  _Country('Jamaïque',              '🇯🇲', '+1876', 'JM'),
  _Country('Japon',                 '🇯🇵', '+81',   'JP'),
  _Country('Jordanie',              '🇯🇴', '+962',  'JO'),
  _Country('Kazakhstan',            '🇰🇿', '+7',    'KZ'),
  _Country('Kenya',                 '🇰🇪', '+254',  'KE'),
  _Country('Kirghizistan',          '🇰🇬', '+996',  'KG'),
  _Country('Koweït',                '🇰🇼', '+965',  'KW'),
  _Country('Laos',                  '🇱🇦', '+856',  'LA'),
  _Country('Lesotho',               '🇱🇸', '+266',  'LS'),
  _Country('Lettonie',              '🇱🇻', '+371',  'LV'),
  _Country('Liban',                 '🇱🇧', '+961',  'LB'),
  _Country('Liberia',               '🇱🇷', '+231',  'LR'),
  _Country('Libye',                 '🇱🇾', '+218',  'LY'),
  _Country('Lituanie',              '🇱🇹', '+370',  'LT'),
  _Country('Luxembourg',            '🇱🇺', '+352',  'LU'),
  _Country('Madagascar',            '🇲🇬', '+261',  'MG'),
  _Country('Malawi',                '🇲🇼', '+265',  'MW'),
  _Country('Mali',                  '🇲🇱', '+223',  'ML'),
  _Country('Malte',                 '🇲🇹', '+356',  'MT'),
  _Country('Maroc',                 '🇲🇦', '+212',  'MA'),
  _Country('Mauritanie',            '🇲🇷', '+222',  'MR'),
  _Country('Maurice',               '🇲🇺', '+230',  'MU'),
  _Country('Mexique',               '🇲🇽', '+52',   'MX'),
  _Country('Moldavie',              '🇲🇩', '+373',  'MD'),
  _Country('Monaco',                '🇲🇨', '+377',  'MC'),
  _Country('Mongolie',              '🇲🇳', '+976',  'MN'),
  _Country('Mozambique',            '🇲🇿', '+258',  'MZ'),
  _Country('Namibie',               '🇳🇦', '+264',  'NA'),
  _Country('Népal',                 '🇳🇵', '+977',  'NP'),
  _Country('Nicaragua',             '🇳🇮', '+505',  'NI'),
  _Country('Niger',                 '🇳🇪', '+227',  'NE'),
  _Country('Nigeria',               '🇳🇬', '+234',  'NG'),
  _Country('Norvège',               '🇳🇴', '+47',   'NO'),
  _Country('Nouvelle-Zélande',      '🇳🇿', '+64',   'NZ'),
  _Country('Oman',                  '🇴🇲', '+968',  'OM'),
  _Country('Ouganda',               '🇺🇬', '+256',  'UG'),
  _Country('Ouzbékistan',           '🇺🇿', '+998',  'UZ'),
  _Country('Pakistan',              '🇵🇰', '+92',   'PK'),
  _Country('Palestine',             '🇵🇸', '+970',  'PS'),
  _Country('Panama',                '🇵🇦', '+507',  'PA'),
  _Country('Paraguay',              '🇵🇾', '+595',  'PY'),
  _Country('Pays-Bas',              '🇳🇱', '+31',   'NL'),
  _Country('Pérou',                 '🇵🇪', '+51',   'PE'),
  _Country('Philippines',           '🇵🇭', '+63',   'PH'),
  _Country('Pologne',               '🇵🇱', '+48',   'PL'),
  _Country('Portugal',              '🇵🇹', '+351',  'PT'),
  _Country('Qatar',                 '🇶🇦', '+974',  'QA'),
  _Country('République Centrafricaine','🇨🇫','+236','CF'),
  _Country('République Dominicaine','🇩🇴', '+1809', 'DO'),
  _Country('Roumanie',              '🇷🇴', '+40',   'RO'),
  _Country('Royaume-Uni',           '🇬🇧', '+44',   'GB'),
  _Country('Russie',                '🇷🇺', '+7',    'RU'),
  _Country('Rwanda',                '🇷🇼', '+250',  'RW'),
  _Country('Salvador',              '🇸🇻', '+503',  'SV'),
  _Country('Sénégal',               '🇸🇳', '+221',  'SN'),
  _Country('Serbie',                '🇷🇸', '+381',  'RS'),
  _Country('Sierra Leone',          '🇸🇱', '+232',  'SL'),
  _Country('Singapour',             '🇸🇬', '+65',   'SG'),
  _Country('Slovaquie',             '🇸🇰', '+421',  'SK'),
  _Country('Slovénie',              '🇸🇮', '+386',  'SI'),
  _Country('Somalie',               '🇸🇴', '+252',  'SO'),
  _Country('Soudan',                '🇸🇩', '+249',  'SD'),
  _Country('Soudan du Sud',         '🇸🇸', '+211',  'SS'),
  _Country('Sri Lanka',             '🇱🇰', '+94',   'LK'),
  _Country('Suède',                 '🇸🇪', '+46',   'SE'),
  _Country('Suisse',                '🇨🇭', '+41',   'CH'),
  _Country('Syrie',                 '🇸🇾', '+963',  'SY'),
  _Country('Tadjikistan',           '🇹🇯', '+992',  'TJ'),
  _Country('Tanzanie',              '🇹🇿', '+255',  'TZ'),
  _Country('Tchad',                 '🇹🇩', '+235',  'TD'),
  _Country('Thaïlande',             '🇹🇭', '+66',   'TH'),
  _Country('Togo',                  '🇹🇬', '+228',  'TG'),
  _Country('Tunisie',               '🇹🇳', '+216',  'TN'),
  _Country('Turkménistan',          '🇹🇲', '+993',  'TM'),
  _Country('Turquie',               '🇹🇷', '+90',   'TR'),
  _Country('Ukraine',               '🇺🇦', '+380',  'UA'),
  _Country('Uruguay',               '🇺🇾', '+598',  'UY'),
  _Country('USA',                   '🇺🇸', '+1',    'US'),
  _Country('Venezuela',             '🇻🇪', '+58',   'VE'),
  _Country('Vietnam',               '🇻🇳', '+84',   'VN'),
  _Country('Yémen',                 '🇾🇪', '+967',  'YE'),
  _Country('Zambie',                '🇿🇲', '+260',  'ZM'),
  _Country('Zimbabwe',              '🇿🇼', '+263',  'ZW'),
];

class UserInfoModal extends StatefulWidget {
  final VoidCallback onSaved;
  const UserInfoModal({Key? key, required this.onSaved}) : super(key: key);

  @override
  State<UserInfoModal> createState() => _UserInfoModalState();
}

class _UserInfoModalState extends State<UserInfoModal> {
  final _nameCtrl   = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  String _selectedDate = '';
  bool   _saving = false;
  _Country _selectedCountry = _kCountries.firstWhere((c) => c.isoCode == 'SN');

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
        '${picked.day.toString().padLeft(2, '0')}-'
            '${picked.month.toString().padLeft(2, '0')}-'
            '${picked.year}';
      });
    }
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CountryPickerSheet(
        selected: _selectedCountry,
        onSelected: (c) => setState(() => _selectedCountry = c),
      ),
    );
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

    final fullPhone = '${_selectedCountry.dialCode}${_phoneCtrl.text.trim()}';

    final apiUser = await ApiService.createOrGetUser(
      fullName: _nameCtrl.text.trim(),
      phone:    fullPhone,
      date:     _selectedDate,
    );

    final userToSave = apiUser ?? UserModel(
      fullName:  _nameCtrl.text.trim(),
      birthDate: _selectedDate,
      phone:     fullPhone,
    );

    await StorageService.saveUser(userToSave);

    final defaultLang = _selectedCountry.isoCode == 'SN' ? 'wo' : 'fr';
    await StorageService.saveLanguage(defaultLang);

    setState(() => _saving = false);
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
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
                const Text('SNAP VOYANCE',
                    style: TextStyle(
                        color: Color(0xFFD4A017),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3)),
                const SizedBox(height: 6),
                const Text('Donnez vos informations pour continuer',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 13)),
                const SizedBox(height: 24),

                _buildField(
                    controller: _nameCtrl,
                    hint: 'Nom complet',
                    icon: Icons.person_outline),
                const SizedBox(height: 14),

                // Date
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
                    child: Row(children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: Color(0xFFD4A017), size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate.isEmpty ? 'Date de naissance' : _selectedDate,
                        style: TextStyle(
                            color: _selectedDate.isEmpty
                                ? Colors.white38
                                : Colors.white,
                            fontSize: 15),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 14),

                // Téléphone avec indicatif
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: Row(children: [
                    GestureDetector(
                      onTap: _showCountryPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: const BoxDecoration(
                          border: Border(
                              right: BorderSide(color: Color(0xFF333333))),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(_selectedCountry.flag,
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 6),
                          Text(_selectedCountry.dialCode,
                              style: const TextStyle(
                                  color: Color(0xFFD4A017), fontSize: 14)),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down,
                              color: Colors.white38, size: 18),
                        ]),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          hintText: 'Numéro de téléphone',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 28),

                GestureDetector(
                  onTap: _saving ? null : _save,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFD4A017), Color(0xFFB8860B)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _saving
                          ? const CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 2)
                          : const Text('CONTINUER',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 2)),
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
            borderSide: const BorderSide(color: Color(0xFF333333))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF333333))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD4A017))),
      ),
    );
  }
}

// ── Sheet de sélection de pays avec recherche ─────────────────────────────────
class _CountryPickerSheet extends StatefulWidget {
  final _Country selected;
  final Function(_Country) onSelected;

  const _CountryPickerSheet({
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchCtrl = TextEditingController();
  List<_Country> _filtered = _kCountries;

  void _onSearch(String query) {
    setState(() {
      _filtered = query.isEmpty
          ? _kCountries
          : _kCountries.where((c) =>
      c.name.toLowerCase().contains(query.toLowerCase()) ||
          c.dialCode.contains(query) ||
          c.isoCode.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.75;
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(children: [
        // Handle
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40, height: 4,
          decoration: BoxDecoration(
              color: Colors.white24, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 12),
        const Text('Choisir un pays',
            style: TextStyle(color: Colors.white,
                fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        // Barre de recherche
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchCtrl,
            autofocus: true,
            onChanged: _onSearch,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Rechercher un pays ou indicatif...',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Color(0xFFD4A017)),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  _onSearch('');
                },
                child: const Icon(Icons.clear, color: Colors.white38),
              )
                  : null,
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Liste
        Expanded(
          child: _filtered.isEmpty
              ? const Center(
              child: Text('Aucun pays trouvé',
                  style: TextStyle(color: Colors.white54)))
              : ListView.builder(
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final c = _filtered[i];
              final isSelected = c.isoCode == widget.selected.isoCode;
              return ListTile(
                leading: Text(c.flag,
                    style: const TextStyle(fontSize: 24)),
                title: Text(c.name,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15)),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(c.dialCode,
                      style: const TextStyle(
                          color: Color(0xFFD4A017), fontSize: 14)),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle,
                        color: Color(0xFFD4A017), size: 18),
                  ],
                ]),
                tileColor: isSelected
                    ? const Color(0xFFD4A017).withOpacity(0.08)
                    : null,
                onTap: () {
                  widget.onSelected(c);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}