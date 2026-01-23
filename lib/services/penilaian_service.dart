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

  static Future<DeleteResponse> deletePenilaian(int id) async {
    print("--- DEBUG DELETE ---");
    print("Request ID: $id");
    print("Endpoint: /kemadrasahan/delete/$id");

    final response = await ApiHelper.delete(
      '/kemadrasahan/delete/$id',
    );

    print("Status Code: ${response.statusCode}");
    print("Raw Response: ${response.body}");

    final Map<String, dynamic> json = jsonDecode(response.body);
    
    if (response.statusCode != 200) {
      print("Delete Failed: ${json['message']}");
      throw Exception(json['message'] ?? 'Gagal menghapus data');
    }

    print("Delete Success: Data berhasil dihapus");
    print("--------------------");

    return DeleteResponse.fromJson(json);
  }

}