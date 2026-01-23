import '../utils/model_helper.dart';

class PenilaianRequest {
  final int idUser;
  final int? noInduk;
  final String bulan;
  final int semester;
  final int idMapel;
  final String tipeInput; 
  final int mingguKe;
  final String materi;
  final String deskripsiPenilaian;

  PenilaianRequest({
    required this.idUser,
    this.noInduk,
    required this.bulan,
    required this.semester,
    required this.idMapel,
    required this.tipeInput,
    required this.mingguKe,
    required this.materi,
    required this.deskripsiPenilaian,
  });
  Map<String, dynamic> toJson() {
    return {
      'idUser': idUser,
      'noInduk': noInduk,
      'bulan': bulan,
      'semester': semester,
      'idMapel': idMapel,
      'tipeInput': tipeInput,
      'mingguKe': mingguKe,
      'materi': materi,
      'deskripsiPenilaian': deskripsiPenilaian,
    };
  }
}
class StorePenilaianResponse {
  final String status;
  final String message;

  StorePenilaianResponse({
    required this.status,
    required this.message,
  });
  bool get isSuccess => status == 'success';

  factory StorePenilaianResponse.fromJson(Map<String, dynamic> json) {
    return StorePenilaianResponse(
      status: ModelHelper.safeString(json['status']) ?? 'error',
      message: ModelHelper.safeString(json['message']) ?? 'Terjadi kesalahan sistem',
    );
  }
}