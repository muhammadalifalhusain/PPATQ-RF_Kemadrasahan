import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  final int idUser;
  final String nama;
  final String photo;
  final bool isWaliKelas; 

  UserSession({
    required this.idUser,
    required this.nama,
    required this.photo,
    required this.isWaliKelas,
  });
}

class SessionManager {
  static Future<void> saveUserSession({
    required int idUser,
    required String nama,
    String? photo,
    required bool isWaliKelas, 
    required String accessToken,
    required int expiresIn,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', idUser);
    await prefs.setString('nama', nama);
    await prefs.setString('photo', photo ?? '');
    await prefs.setBool('isWaliKelas', isWaliKelas); 
    await prefs.setString('accessToken', accessToken);
    await prefs.setInt('expiresIn', expiresIn);
    await prefs.setInt(
      'loginTimestamp',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<UserSession?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();

    final id = prefs.getInt('id');
    final nama = prefs.getString('nama');
    final photo = prefs.getString('photo');
    final isWaliKelas = prefs.getBool('isWaliKelas') ?? false; 

    if (id == null || nama == null) return null;

    return UserSession(
      idUser: id,
      nama: nama,
      photo: photo ?? '',
      isWaliKelas: isWaliKelas,
    );
  }
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final loginTime = prefs.getInt('loginTimestamp');
    final expiresIn = prefs.getInt('expiresIn');

    if (token == null || loginTime == null || expiresIn == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final expiredTime = loginTime + (expiresIn * 1000);

    return now < expiredTime;
  }
}