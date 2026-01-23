import '../models/penilaian_model.dart';
import '../utils/api_helper.dart';
import 'dart:convert';

class PenilaianService {
  static Future<StorePenilaianResponse> storePenilaian(PenilaianRequest data) async {
    final response = await ApiHelper.post(
      '/kemadrasahan/store', 
      body: data.toJson(),
    );

    final Map<String, dynamic> json = jsonDecode(response.body);
    if (response.statusCode != 200 && response.statusCode != 500) {
       throw Exception(json['message'] ?? 'Gagal menghubungi server');
    }

    return StorePenilaianResponse.fromJson(json);
  }
}