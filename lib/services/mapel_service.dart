import 'dart:convert';
import '../utils/api_helper.dart';
import '../models/mapel_model.dart'; 

class MapelService {
  static Future<MapelResponse> getListMapel() async {
    final response = await ApiHelper.get(
      '/kemadrasahan/get-data-mapel',
    );
    final Map<String, dynamic> json = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(
        json['message'] ?? 'Gagal mengambil data mata pelajaran',
      );
    }

    return MapelResponse.fromJson(json);
  }
}