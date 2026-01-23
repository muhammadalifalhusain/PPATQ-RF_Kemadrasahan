import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_config.dart';
import '../../models/detail_santri_model.dart';
import '../../services/santri_service.dart';
import '../../services/penilaian_service.dart';
class DetailSantriScreen extends StatefulWidget {
  final int noInduk;

  const DetailSantriScreen({super.key, required this.noInduk});

  @override
  State<DetailSantriScreen> createState() => _DetailSantriScreenState();
}

class _DetailSantriScreenState extends State<DetailSantriScreen>
    with SingleTickerProviderStateMixin {
  late Future<LaporanResponse> _detailFuture;
  TabController? _tabController;
  List<String> _tabs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fungsi untuk mengambil data (digunakan juga untuk refresh setelah hapus)
  void _fetchData() {
    setState(() {
      _detailFuture = SantriService.getDetailSantri(widget.noInduk);
    });
  }

  // --- LOGIKA DELETE ---
  void _confirmDelete(int? id) {
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ID Laporan tidak ditemukan")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            "Konfirmasi Hapus",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Text(
            "Apakah Anda yakin ingin menghapus data penilaian ini?",
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal", style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                _handleDelete(id); // Jalankan hapus
              },
              child: Text("Hapus", style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDelete(int id) async {
    setState(() => _isLoading = true);

    try {
      final response = await PenilaianService.deletePenilaian(id);

      if (response.isSuccess) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: const Color(0xFF00695C),
          ),
        );
        _fetchData(); 
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00695C),
        title: Text(
          'Detail Santri',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          FutureBuilder<LaporanResponse>(
            future: _detailFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString(), style: GoogleFonts.poppins(color: Colors.red)),
                );
              }

              final data = snapshot.data!;
              _tabs = data.laporan.keys.toList();
              
              // Inisialisasi controller hanya jika belum ada
              _tabController ??= TabController(length: _tabs.length, vsync: this);

              return Column(
                children: [
                  _buildSantriHeader(data.santri),
                  TabBar(
                    controller: _tabController,
                    tabs: _tabs.map((t) => Tab(text: t.toUpperCase())).toList(),
                    indicatorColor: const Color(0xFF00695C),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
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
                            return _buildLaporanCard(items[index]);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
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
            backgroundColor: const Color(0xFF00695C).withOpacity(0.1),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null ? const Icon(Icons.person, size: 36, color: Color(0xFF00695C)) : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                santri.nama,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                'No Induk: ${santri.noInduk} • ${santri.kodeKelas}',
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
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      shadowColor: Colors.black12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF00695C).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Text(
              'Periode: ${laporan.bulan ?? "-"}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: const Color(0xFF00695C),
              ),
            ),
          ),
          if (laporan.detail.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Tidak ada data penilaian',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                ),
              ),
            ),
          ...laporan.detail.map((d) => _buildDetailTile(d)).toList(),
        ],
      ),
    );
  }

  Widget _buildDetailTile(LaporanDetail d) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Tile: Mapel, Materi, dan Tombol Aksi
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00695C),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  (d.namaMapel ?? "Mapel").toUpperCase(),
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  d.materi ?? "-",
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _confirmDelete(d.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                      child: Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            d.deskripsiPenilaian ?? "-",
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87.withOpacity(0.8), height: 1.5),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: Color(0xFF00695C)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        d.pengampu ?? "-",
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF00695C)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  "Minggu ke-${d.mingguKe}",
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}