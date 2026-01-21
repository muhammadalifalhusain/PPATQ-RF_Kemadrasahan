import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_config.dart';
import '../../models/santri_model.dart';
import '../../services/santri_service.dart';
import '../../utils/session_manager.dart';
import '../login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? nama;
  String? photo;

  late Future<DashboardResponse> _santriFuture;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00695C),
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: Colors.white
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            onPressed: _forceLogout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
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

        final santriList = snapshot.data!.data;

        if (santriList.isEmpty) {
          return Center(
            child: Text(
              'Data santri tidak ditemukan',
              style: GoogleFonts.poppins(),
            ),
          );
        }

        return ListView.separated(
          itemCount: santriList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final santri = santriList[index];
            return _santriTile(santri);
          },
        );
      },
    );
  }

  Widget _santriTile(Santri santri) {
    final photoUrl = santri.foto.isNotEmpty
        ? AppConfig.photoBaseUrl + santri.foto
        : null;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              photoUrl != null ? NetworkImage(photoUrl) : null,
          child: photoUrl == null ? const Icon(Icons.person) : null,
        ),
        title: Text(
          santri.nama,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'No Induk: ${santri.noInduk} • Kelas ${santri.kodeKelas}',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
      ),
    );
  }
}
