import 'dart:convert';
import '../models/user_model.dart';
import '../utils/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiHelper.post('/ustad/login', body: {
        'email': email,
        'password': password,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final murroby = Users.fromJson(data['data']);
        return {
          'success': true,
          'data': murroby,
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
