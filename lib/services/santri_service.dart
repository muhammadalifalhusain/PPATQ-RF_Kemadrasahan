import 'dart:convert';

import '../utils/api_helper.dart';
import '../utils/session_manager.dart';

import '../models/santri_model.dart';
import '../models/detail_santri_model.dart';

class SantriService {
  static Future<DashboardResponse> getListSantri() async {
    final session = await SessionManager.getUserSession();

    if (session == null) {
      throw Exception('Session user tidak ditemukan. Silakan login ulang.');
    }

    final idUser = session.idUser;

    final response = await ApiHelper.get(
      '/kemadrasahan/get-santri/$idUser',
    );

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        json['message'] ?? 'Gagal mengambil data santri',
      );
    }

    return DashboardResponse.fromJson(json);
  }

  static Future<LaporanResponse> getDetailSantri(int noInduk) async {
    final response = await ApiHelper.get(
      '/kemadrasahan/get-data-santri/$noInduk',
    );

    final Map<String, dynamic> json = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        json['message'] ?? 'Gagal mengambil detail santri',
      );
    }

    return LaporanResponse.fromJson(json);
  }
}
