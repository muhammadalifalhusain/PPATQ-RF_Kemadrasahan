import '../utils/model_helper.dart';

class Santri {
  final int noInduk;
  final String nama;
  final String? foto;
  final String kodeKelas;

  Santri({
    required this.noInduk,
    required this.nama,
    this.foto,
    required this.kodeKelas,
  });

  factory Santri.fromJson(Map<String, dynamic> json) {
    return Santri(
      noInduk: ModelHelper.safeInt(json['noInduk']),
      nama: ModelHelper.safeString(json['namaSantri']) ?? '-',
      foto: ModelHelper.safeString(json['fotoSantri']),
      kodeKelas: ModelHelper.safeString(json['kodeKelas']) ?? '-',
    );
  }
}

class LaporanDetail {
  final int? id;
  final String? namaMapel;
  final String? materi;
  final int? idLaporan;
  final String? deskripsiPenilaian;
  final int? mingguKe;
  final String? pengampu;

  LaporanDetail({
    this.id,
    this.namaMapel,
    this.materi,
    this.idLaporan,
    this.deskripsiPenilaian,
    this.mingguKe,
    this.pengampu,
  });

  factory LaporanDetail.fromJson(Map<String, dynamic> json) {
    return LaporanDetail(
      id: json['id'] is int ? json['id'] : null,
      namaMapel: ModelHelper.safeString(json['namaMapel']),
      materi: ModelHelper.safeString(json['materi']),
      idLaporan: json['idLaporan'] is int ? json['idLaporan'] : null,
      deskripsiPenilaian:
          ModelHelper.safeString(json['deskripsiPenilaian']),
      mingguKe: json['mingguKe'] is int ? json['mingguKe'] : null,
      pengampu: ModelHelper.safeString(json['pengampu']),
    );
  }
}

class LaporanItem {
  final int? id;
  final String? bulan;
  final String? semester;
  final String? kelas;
  final List<LaporanDetail> detail;

  LaporanItem({
    this.id,
    this.bulan,
    this.semester,
    this.kelas,
    required this.detail,
  });

  factory LaporanItem.fromJson(Map<String, dynamic> json) {
    return LaporanItem(
      id: json['id'] is int ? json['id'] : null,
      bulan: ModelHelper.safeString(json['bulan']),
      semester: ModelHelper.safeString(json['semester']),
      kelas: ModelHelper.safeString(json['kelas']),
      detail: ModelHelper.safeList(
        json['detail'],
        (e) => LaporanDetail.fromJson(e),
      ),
    );
  }
}

class LaporanResponse {
  final String status;
  final Santri santri;
  final Map<String, List<LaporanItem>> laporan;

  LaporanResponse({
    required this.status,
    required this.santri,
    required this.laporan,
  });

  bool get isSuccess => status == 'success';

  factory LaporanResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final laporanRaw = data['laporan'] as Map<String, dynamic>? ?? {};

    final Map<String, List<LaporanItem>> parsedLaporan = {};

    laporanRaw.forEach((key, value) {
      parsedLaporan[key] = ModelHelper.safeList(
        value,
        (e) => LaporanItem.fromJson(e),
      );
    });

    return LaporanResponse(
      status: ModelHelper.safeString(json['status']) ?? 'unknown',
      santri: Santri.fromJson(
        data['santri'] as Map<String, dynamic>? ?? {},
      ),
      laporan: parsedLaporan,
    );
  }
}
