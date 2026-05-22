class UserModel {
  final int? id;        // ← ID retourné par l'API
  final String fullName;
  final String birthDate;
  final String phone;

  UserModel({
    this.id,
    required this.fullName,
    required this.birthDate,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'birthDate': birthDate,
    'phone': phone,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    fullName: json['fullName'] ?? '',
    birthDate: json['birthDate'] ?? '',
    phone: json['phone'] ?? '',
  );
}