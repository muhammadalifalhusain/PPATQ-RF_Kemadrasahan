class Users {
  final int idUser;
  final String nama;
  final String? photo;
  final String accessToken;
  final int expiresIn;

  Users({
    required this.idUser,
    required this.nama,
    this.photo,
    required this.accessToken,
    required this.expiresIn,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      idUser: json['id'],
      nama: json['nama'],
      photo: json['photo'],
      accessToken: json['accesToken'],
      expiresIn: json['expiresIn'],
    );
  }
}
