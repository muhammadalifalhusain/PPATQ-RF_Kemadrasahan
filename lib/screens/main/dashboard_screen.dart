import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_config.dart';
import '../../models/santri_model.dart';
import '../../services/santri_service.dart';
import '../../utils/session_manager.dart';
import '../login_screen.dart';
import 'detail_santri_screen.dart';
import 'form_penilaian_screen.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? nama;
  String? photo;

  late Future<DashboardResponse> _santriFuture;

  final TextEditingController _searchController = TextEditingController();

  List<Santri> _allSantri = [];
  List<Santri> _filteredSantri = [];

  @override
  void initState() {
    super.initState();
    _initDashboard();
  }

  Future<void> _initDashboard() async {
    final session = await SessionManager.getUserSession();

    if (session == null) {
      _forceLogout();
      return;
    }

    setState(() {
      nama = session.nama;
      photo = session.photo;
      _santriFuture = SantriService.getListSantri();
    });
  }

  void _forceLogout() async {
    await SessionManager.clearSession();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (_) => false,
    );
  }

  void _filterSantri(String keyword) {
    final query = keyword.toLowerCase();

    setState(() {
      _filteredSantri = _allSantri.where((santri) {
        return santri.nama.toLowerCase().contains(query) ||
            santri.noInduk.toString().contains(query) ||
            santri.kodeKelas.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00695C),
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _forceLogout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            _buildSearchField(),
            const SizedBox(height: 15),
            Expanded(child: _buildSantriList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        _buildAvatar(),
        const SizedBox(height: 12),
        Text(
          nama ?? '-',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    if (photo == null || photo!.isEmpty) {
      return const CircleAvatar(
        radius: 42,
        child: Icon(Icons.person, size: 42),
      );
    }

    final imageUrl = photo!.startsWith('http')
        ? photo!
        : AppConfig.photoBaseUrl + photo!;

    return CircleAvatar(
      radius: 42,
      backgroundImage: NetworkImage(imageUrl),
    );
  }

  Widget _buildSearchField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: _filterSantri,
            decoration: InputDecoration(
              hintText: 'Cari santri binaan...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Tombol Input Massal (Bulk)
        Material(
          color: Colors.blue.shade700,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FormPenilaianScreen(tipeInput: 'bulk')),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const Icon(Icons.group_add, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSantriList() {
    return FutureBuilder<DashboardResponse>(
      future: _santriFuture,
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

        if (_allSantri.isEmpty) {
          _allSantri = snapshot.data!.data;
          _filteredSantri = _allSantri;
        }

        if (_filteredSantri.isEmpty) {
          return Center(
            child: Text(
              'Santri tidak ditemukan',
              style: GoogleFonts.poppins(),
            ),
          );
        }

        return ListView.separated(
          itemCount: _filteredSantri.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final santri = _filteredSantri[index];
            return _santriTile(santri);
          },
        );
      },
    );
  }

  Widget _santriTile(Santri santri) {
    final photoUrl = (santri.foto != null && santri.foto!.isNotEmpty)
        ? AppConfig.photoBaseUrl + santri.foto!
        : null;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          child: photoUrl == null ? const Icon(Icons.person) : null,
        ),
        title: Text(
          santri.nama,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'No Induk: ${santri.noInduk} • ${santri.kodeKelas}',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min, 
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FormPenilaianScreen(
                      tipeInput: 'single',
                      noInduk: santri.noInduk,
                      namaSantri: santri.nama,
                    ),
                  ),
                ).then((value) {
                  if (value == true) {
                    _initDashboard(); 
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black54, size: 18),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailSantriScreen(noInduk: santri.noInduk),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
