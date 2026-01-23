import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_config.dart';
import '../../models/detail_santri_model.dart';
import '../../services/santri_service.dart';

class DetailSantriScreen extends StatefulWidget {
  final int noInduk;

  const DetailSantriScreen({super.key, required this.noInduk});

  @override
  State<DetailSantriScreen> createState() => _DetailSantriScreenState();
}

class _DetailSantriScreenState extends State<DetailSantriScreen>
    with SingleTickerProviderStateMixin {
  late Future<LaporanResponse> _detailFuture;
  late TabController _tabController;
  List<String> _tabs = [];

  @override
  void initState() {
    super.initState();
    _detailFuture = SantriService.getDetailSantri(widget.noInduk);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: const Color(0xFF00695C),
      title: Text(
        'Detail Santri',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),

      body: FutureBuilder<LaporanResponse>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          final data = snapshot.data!;
          _tabs = data.laporan.keys.toList();
          _tabController = TabController(length: _tabs.length, vsync: this);

          return Column(
            children: [
              _buildSantriHeader(data.santri),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabController,
                tabs: _tabs.map((t) => Tab(text: t.toUpperCase())).toList(),
                indicatorColor: const Color.fromARGB(255, 0, 0, 0),
                labelColor: const Color.fromARGB(255, 0, 0, 0),
                unselectedLabelColor: const Color.fromARGB(255, 11, 102, 26),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _tabs.map((semesterKey) {
                    final items = data.laporan[semesterKey]!;
                    return ListView.separated(
                      padding: const EdgeInsets.all(12),
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        final laporan = items[index];
                        return _buildLaporanCard(laporan);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSantriHeader(Santri santri) {
    final photoUrl = (santri.foto != null && santri.foto!.isNotEmpty)
        ? AppConfig.photoBaseUrl + santri.foto!
        : null;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null ? const Icon(Icons.person, size: 36) : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                santri.nama,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'No Induk: ${santri.noInduk} • Kelas: ${santri.kodeKelas}',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLaporanCard(LaporanItem laporan) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bulan: ${laporan.bulan ?? "-"} | Semester: ${laporan.semester ?? "-"}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (laporan.detail.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Tidak ada data penilaian',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
            ...laporan.detail.map((d) => _buildDetailTile(d)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(LaporanDetail detail) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          detail.materi ?? '-',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (detail.namaMapel != null)
              Text('Mapel: ${detail.namaMapel}', style: GoogleFonts.poppins(fontSize: 12)),
            if (detail.deskripsiPenilaian != null)
              Text('Penilaian: ${detail.deskripsiPenilaian}', style: GoogleFonts.poppins(fontSize: 12)),
            if (detail.pengampu != null)
              Text('Pengampu: ${detail.pengampu}', style: GoogleFonts.poppins(fontSize: 12)),
            if (detail.mingguKe != null)
              Text('Minggu ke: ${detail.mingguKe}', style: GoogleFonts.poppins(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
