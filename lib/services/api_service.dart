import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prediction_model.dart';
import '../models/user_model.dart';

class ApiService {
  static const String _baseUrl = 'https://seddo.innovimpactdev.cloud';

  /// Crée ou récupère un utilisateur existant via le téléphone
  static Future<UserModel?> createOrGetUser({
    required String fullName,
    required String phone,
    required String date,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/snap/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'phone': phone,
          'date': date,
        }),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // L'API retourne : id, fullName, phone, date
        return UserModel(
          id: json['id'],
          fullName: json['fullName'] ?? fullName,
          birthDate: json['date'] ?? date,
          phone: json['phone'] ?? phone,
        );
      }
      print('ApiService.createOrGetUser error: ${response.statusCode} ${response.body}');
    } catch (e) {
      print('ApiService.createOrGetUser exception: $e');
    }
    return null;
  }

  /// Récupère une prédiction aléatoire non vue
  static Future<PredictionModel?> getPrediction({
    required String zodiacSign,
    required String language,
    required int userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/horoscope/prediction'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'zodiacSign': zodiacSign,
          'language': language,
          'userId': userId,
        }),
      );
      if (response.statusCode == 200) {
        return PredictionModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('ApiService.getPrediction error: $e');
    }
    return null;
  }

  /// Retourne l'URL de l'audio WAV pour une prédiction
  static String getAudioUrl(int predictionId) {
    return '$_baseUrl/api/horoscope/audio/$predictionId';
  }
}