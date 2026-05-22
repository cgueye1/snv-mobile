class PredictionModel {
  final bool success;
  final String message;
  final String zodiacSign;
  final String language;
  final String date;
  final int? predictionId;
  final String? audioPath;

  PredictionModel({
    required this.success,
    required this.message,
    required this.zodiacSign,
    required this.language,
    required this.date,
    this.predictionId,
    this.audioPath,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) =>
      PredictionModel(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        zodiacSign: json['zodiacSign'] ?? '',
        language: json['language'] ?? '',
        date: json['date'] ?? '',
        predictionId: json['id'],
        audioPath: json['audioPath'],
      );
}
