import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

const _baseUrl = 'https://snv.innovimpactdev.cloud';

void main() {
  group('SNV API integration', () {
    test('loads app parameters from the production API', () async {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/appparam'))
          .timeout(const Duration(seconds: 20));

      expect(response.statusCode, 200);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      expect(body, contains('id'));
      expect(body, contains('appVersionList'));
    });

    test('rejects a prediction request for an unknown user', () async {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/horoscope/prediction'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'zodiacSign': 'BELIER',
              'language': 'FR',
              'userId': -1,
            }),
          )
          .timeout(const Duration(seconds: 20));

      expect(response.statusCode, 460);
    });

    test('clears history through the mobile endpoint', () async {
      final response = await http
          .delete(Uri.parse('$_baseUrl/api/horoscope/history/-1'))
          .timeout(const Duration(seconds: 20));

      expect(response.statusCode, 200);
    });
  });
}
