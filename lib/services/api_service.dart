import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prediction_model.dart';
import '../models/user_model.dart';

// Code custom : user supprimé côté backend
const int kUserNotFoundCode = 460;

class UserNotFoundException implements Exception {}

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
        body: jsonEncode({'fullName': fullName, 'phone': phone, 'date': date}),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return UserModel(
          id: json['id'],
          fullName: json['fullName'] ?? fullName,
          birthDate: json['date'] ?? date,
          phone: json['phone'] ?? phone,
        );
      }
    } catch (e) {
      print('ApiService.createOrGetUser exception: $e');
    }
    return null;
  }

  /// Récupère une prédiction — lance [UserNotFoundException] si 460
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
      if (response.statusCode == kUserNotFoundCode) {
        throw UserNotFoundException();
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  /// URL audio WAV
  static String getAudioUrl(int predictionId) =>
      '$_baseUrl/api/horoscope/audio/$predictionId';
}