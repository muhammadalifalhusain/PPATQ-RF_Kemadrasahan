import '../utils/model_helper.dart';

/// =======================
/// MODEL SANTRI
/// =======================
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

/// =======================
/// MODEL DETAIL LAPORAN
/// =======================
class LaporanDetail {
  final int? id;
  final String? materi;
  final int? idLaporan;
  final String? deskripsiPenilaian;
  final int? mingguKe;
  final String? pengampu;

  LaporanDetail({
    this.id,
    this.materi,
    this.idLaporan,
    this.deskripsiPenilaian,
    this.mingguKe,
    this.pengampu,
  });

  factory LaporanDetail.fromJson(Map<String, dynamic> json) {
    return LaporanDetail(
      id: ModelHelper.safeNullableInt(json['id']),
      materi: ModelHelper.safeString(json['materi']),
      idLaporan: ModelHelper.safeNullableInt(json['idLaporan']),
      deskripsiPenilaian:
          ModelHelper.safeString(json['deskripsiPenilaian']),
      mingguKe: ModelHelper.safeNullableInt(json['mingguKe']),
      pengampu: ModelHelper.safeString(json['pengampu']),
    );
  }
}

/// =======================
/// MODEL LAPORAN PER SEMESTER
/// (VALUE dari Map laporan)
/// =======================
class LaporanSemester {
  final int semester;
  final int? id;
  final int? bulan;
  final LaporanDetail detail;

  LaporanSemester({
    required this.semester,
    this.id,
    this.bulan,
    required this.detail,
  });

  factory LaporanSemester.fromJson(
    Map<String, dynamic> json,
    int semesterKey,
  ) {
    return LaporanSemester(
      semester: semesterKey,
      id: ModelHelper.safeNullableInt(json['id']),
      bulan: ModelHelper.safeNullableInt(json['bulan']),
      detail: LaporanDetail.fromJson(
        ModelHelper.safeMap(json['detail']),
      ),
    );
  }
}

/// =======================
/// ROOT RESPONSE
/// =======================
class LaporanResponse {
  final String status;
  final Santri santri;
  final Map<int, LaporanSemester> laporan;

  LaporanResponse({
    required this.status,
    required this.santri,
    required this.laporan,
  });

  bool get isSuccess => status == 'success';

  factory LaporanResponse.fromJson(Map<String, dynamic> json) {
    final data = ModelHelper.safeMap(json['data']);
    final laporanRaw = ModelHelper.safeMap(data['laporan']);

    final Map<int, LaporanSemester> parsedLaporan = {};

    laporanRaw.forEach((key, value) {
      final semester = int.tryParse(key.toString());
      if (semester != null && value is Map<String, dynamic>) {
        parsedLaporan[semester] =
            LaporanSemester.fromJson(value, semester);
      }
    });

    return LaporanResponse(
      status: ModelHelper.safeString(json['status']) ?? 'unknown',
      santri: Santri.fromJson(
        ModelHelper.safeMap(data['santri']),
      ),
      laporan: parsedLaporan,
    );
  }
}
