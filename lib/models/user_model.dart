import '../utils/model_helper.dart';

class Users {
  final int idUser;
  final String nama;
  final String? photo;
  final bool isWaliKelas;
  final String accessToken;
  final int expiresIn;

  Users({
    required this.idUser,
    required this.nama,
    this.photo,
    required this.isWaliKelas,
    required this.accessToken,
    required this.expiresIn,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return Users(
      idUser: ModelHelper.safeInt(data['id']),
      nama: ModelHelper.safeString(data['nama']) ?? '',
      photo: ModelHelper.safeString(data['photo']),
      isWaliKelas: data['isWaliKelas'] ?? false,
      accessToken: ModelHelper.safeString(data['accesToken']) ?? '',
      expiresIn: ModelHelper.safeInt(data['expiresIn']),
    );
  }
}