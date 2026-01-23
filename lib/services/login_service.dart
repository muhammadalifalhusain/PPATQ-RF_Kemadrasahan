import 'dart:convert';
import '../models/user_model.dart';
import '../utils/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/session_manager.dart';

class LoginService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiHelper.post('/ustad/login', body: {
        'email': email,
        'password': password,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // 1. Parse data menjadi model Users
        // Pastikan model Users Anda sudah menangani field 'data' seperti diskusi sebelumnya
        final users = Users.fromJson(data); 

        // 2. SIMPAN KE SESSION (Penting!)
        await SessionManager.saveUserSession(
          idUser: users.idUser,
          nama: users.nama,
          photo: users.photo,
          isWaliKelas: users.isWaliKelas,
          accessToken: users.accessToken,
          expiresIn: users.expiresIn,
        );

        return {
          'success': true,
          'data': users,
        };
      } else {
        return {
          'success': false,
          'message': data['errors']?['Verifikasi']?[0] ?? 'Login gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat login: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final response = await ApiHelper.post('/ustad/logout');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await prefs.clear();

        return {
          'success': true,
          'message': data['message'] ?? 'Logout berhasil',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Logout gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat logout: ${e.toString()}',
      };
    }
  }
}
