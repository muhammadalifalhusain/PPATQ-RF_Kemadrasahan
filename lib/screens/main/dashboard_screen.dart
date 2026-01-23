import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/session_manager.dart';
import '../../services/santri_service.dart';
import '../../models/santri_model.dart';
import '../../config/app_config.dart';
import '../login_screen.dart';
import 'wali_kelas_screen.dart';
import 'guru_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? nama, photo;
  bool isWaliKelas = false;
  bool _isLoading = true;
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
      isWaliKelas = session.isWaliKelas;
    });

    if (isWaliKelas) {
      try {
        final response = await SantriService.getListSantri();
        setState(() {
          _allSantri = response.data;
          _filteredSantri = _allSantri;
        });
      } catch (e) {
        debugPrint("Error load santri: $e");
      }
    }

    setState(() => _isLoading = false);
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00695C),
        title: Text('Dashboard', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Color.fromARGB(179, 238, 10, 10)), onPressed: _forceLogout),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00695C)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 25),
                  if (isWaliKelas) ...[
                    const SizedBox(height: 10),
                    WaliKelasView(santriList: _filteredSantri, onRefresh: _initDashboard),
                  ] else
                    const GuruBiasaView(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileCard() {
    final imageUrl = (photo != null && photo!.isNotEmpty)
        ? (photo!.startsWith('http') ? photo! : AppConfig.photoBaseUrl + photo!)
        : null;

    return Row(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: Colors.white,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
          child: imageUrl == null ? const Icon(Icons.person, size: 35, color: Colors.grey) : null,
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selamat Datang,', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
              Text(
                nama ?? '-',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4), 
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isWaliKelas ? Colors.orange[100] : Colors.blue[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isWaliKelas ? 'Wali Kelas' : 'Guru Pengampu',
                  style: TextStyle(fontSize: 10, color: isWaliKelas ? Colors.orange[800] : Colors.blue[800], fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}