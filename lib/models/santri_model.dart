import '../utils/model_helper.dart';

class Santri {
  final int noInduk;
  final String nama;
  final String foto;
  final String kodeKelas;

  Santri({
    required this.noInduk,
    required this.nama,
    required this.foto,
    required this.kodeKelas,
  });

  factory Santri.fromJson(Map<String, dynamic> json) {
    return Santri(
      noInduk: ModelHelper.safeInt(json['noInduk']),
      nama: ModelHelper.safeString(json['namaSantri']) ?? '-',
      foto: ModelHelper.safeString(json['fotoSantri']) ?? '',
      kodeKelas: ModelHelper.safeString(json['kodeKelas']) ?? '-',
    );
  }

  bool get hasPhoto => foto.isNotEmpty;
}


class DashboardResponse {
  final String status;
  final List<Santri> data;

  DashboardResponse({
    required this.status,
    required this.data,
  });

  bool get isSuccess => status == 'success';

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      status: ModelHelper.safeString(json['status']) ?? 'unknown',
      data: ModelHelper.safeList(
        json['data'],
        (e) => Santri.fromJson(e),
      ),
    );
  }
}

