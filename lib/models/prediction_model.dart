class PredictionModel {
  final bool success;
  final String message;
  final String zodiacSign;
  final String language;
  final String date;
  final int? predictionId;
  final String? audioPath;
  final int maxPredictions;
  final int viewedPredictions;
  final int remainingPredictions;
  final bool canRestart;

  PredictionModel({
    required this.success,
    required this.message,
    required this.zodiacSign,
    required this.language,
    required this.date,
    this.predictionId,
    this.audioPath,
    this.maxPredictions = 0,
    this.viewedPredictions = 0,
    this.remainingPredictions = 0,
    this.canRestart = false,
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
        maxPredictions: json['maxPredictions'] ?? 0,
        viewedPredictions: json['viewedPredictions'] ?? 0,
        remainingPredictions: json['remainingPredictions'] ?? 0,
        canRestart: json['canRestart'] ?? false,
      );
}
