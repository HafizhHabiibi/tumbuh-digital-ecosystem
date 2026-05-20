class UserModel {
  final String id;
  final String userId;
  final String namaLengkap;
  final String noHp;
  final String alamat;
  final String nik;
  final String? fcmToken;
  final String createdAt;
  final String updatedAt;

  UserModel({
    required this.id,
    required this.userId,
    required this.namaLengkap,
    required this.noHp,
    required this.alamat,
    required this.nik,
    this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
      noHp: json['no_hp'] ?? '',
      alamat: json['alamat'] ?? '',
      nik: json['nik'] ?? '',
      fcmToken: json['fcm_token'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
