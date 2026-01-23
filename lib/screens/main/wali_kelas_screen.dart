import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/santri_model.dart';
import '../../../config/app_config.dart';
import 'detail_santri_screen.dart';
import 'form_penilaian_screen.dart';

class WaliKelasView extends StatefulWidget {
  final List<Santri> santriList;
  final VoidCallback onRefresh;

  const WaliKelasView({
    super.key,
    required this.santriList,
    required this.onRefresh,
  });

  @override
  State<WaliKelasView> createState() => _WaliKelasViewState();
}

class _WaliKelasViewState extends State<WaliKelasView> {
  List<Santri> _filteredSantri = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredSantri = widget.santriList;
  }

  @override
  void didUpdateWidget(covariant WaliKelasView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update list jika data dari parent berubah
    if (oldWidget.santriList != widget.santriList) {
      _filteredSantri = widget.santriList;
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredSantri = widget.santriList
          .where((santri) =>
              santri.nama.toLowerCase().contains(query.toLowerCase()) ||
              santri.noInduk.toString().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchAndBulkRow(),
        const SizedBox(height: 20),
        _filteredSantri.isEmpty
            ? _buildEmptyState()
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredSantri.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _santriTile(context, _filteredSantri[index]),
              ),
      ],
    );
  }

  Widget _buildSearchAndBulkRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: _filterSearch,
            decoration: InputDecoration(
              hintText: 'Cari santri...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF00695C)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: Colors.blue.shade700,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FormPenilaianScreen(tipeInput: 'bulk')),
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.group_add_rounded, color: Colors.white, size: 26),
            ),
          ),
        ),
      ],
    );
  }

  Widget _santriTile(BuildContext context, Santri santri) {
    final photoUrl = (santri.foto != null && santri.foto!.isNotEmpty)
        ? AppConfig.photoBaseUrl + santri.foto!
        : null;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailSantriScreen(noInduk: santri.noInduk)),
        ),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF00695C).withOpacity(0.1),
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          child: photoUrl == null ? const Icon(Icons.person, color: Color(0xFF00695C)) : null,
        ),
        title: Text(
          santri.nama,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          '${santri.noInduk} • ${santri.kodeKelas}',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blue, size: 28),
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
                  if (value == true) widget.onRefresh();
                });
              },
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text('Santri tidak ditemukan', style: GoogleFonts.poppins(color: Colors.grey)),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}