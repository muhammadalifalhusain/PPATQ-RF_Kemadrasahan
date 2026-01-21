import '../utils/model_helper.dart';

class Mapel {
  final int id;
  final String nama;

  Mapel({
    required this.id,
    required this.nama,
  });

  factory Mapel.fromJson(Map<String, dynamic> json) {
    return Mapel(
      id: ModelHelper.safeInt(json['id']),
      nama: ModelHelper.safeString(json['nama']) ?? '-',
    );
  }
}

class MapelResponse {
  final String status;
  final List<Mapel> data;

  MapelResponse({
    required this.status,
    required this.data,
  });

  bool get isSuccess => status == 'success';

  factory MapelResponse.fromJson(Map<String, dynamic> json) {
    return MapelResponse(
      status: ModelHelper.safeString(json['status']) ?? 'unknown',
      data: ModelHelper.safeList(
        json['data'],
        (e) => Mapel.fromJson(e),
      ),
    );
  }
}
