import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import '../../models/penilaian_model.dart';
import '../../models/mapel_model.dart';
import '../../services/mapel_service.dart';
import '../../services/penilaian_service.dart';
import '../../utils/session_manager.dart';
class FormPenilaianScreen extends StatefulWidget {
  final String tipeInput; 
  final int? noInduk;    
  final String? namaSantri; 

  const FormPenilaianScreen({
    super.key, 
    required this.tipeInput, 
    this.noInduk, 
    this.namaSantri
  });

  @override
  State<FormPenilaianScreen> createState() => _FormPenilaianScreenState();
}

class _FormPenilaianScreenState extends State<FormPenilaianScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Mapel> _listMapel = [];
  bool _isLoadingMapel = true;
  bool _isSubmitting = false;
  int? _selectedMapelId;
  String _selectedBulan = 'Januari';
  int _selectedSemester = 1;
  int _selectedMinggu = 1;
  final TextEditingController _materiController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  final List<String> _bulanList = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final response = await MapelService.getListMapel();
      setState(() {
        _listMapel = response.data;
        _isLoadingMapel = false;
      });
    } catch (e) {
      setState(() => _isLoadingMapel = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengambil data mapel: $e")),
      );
    }
  }

  Future<void> _handleSimpan() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMapelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih Mata Pelajaran")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final session = await SessionManager.getUserSession();
      
      if (session == null) {
        throw Exception("Sesi berakhir, silakan login ulang");
      }

      final Map<String, String> bulanToAngka = {
        'Januari': '1', 'Februari': '2', 'Maret': '3', 'April': '4',
        'Mei': '5', 'Juni': '6', 'Juli': '7', 'Agustus': '8',
        'September': '9', 'Oktober': '10', 'November': '11', 'Desember': '12',
      };

      final request = PenilaianRequest(
        idUser: session.idUser,
        tipeInput: widget.tipeInput,
        noInduk: widget.noInduk,
        idMapel: _selectedMapelId!,
        bulan: bulanToAngka[_selectedBulan] ?? '1',
        semester: _selectedSemester,
        mingguKe: _selectedMinggu,
        materi: _materiController.text,
        deskripsiPenilaian: _deskripsiController.text,
      );

      print("--- DATA DEBUG ---");
      print("Payload: ${jsonEncode(request.toJson())}");

      final response = await PenilaianService.storePenilaian(request);

      print("Status: ${response.status}");
      print("Message: ${response.message}");

      if (response.isSuccess) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message), 
            backgroundColor: const Color(0xFF00695C),
          ),
        );
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message), 
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"), 
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00695C),
        elevation: 0,
        centerTitle: false, 
        title: Text(
          widget.tipeInput == 'bulk' 
              ? "Input Penilaian Kelas" 
              : "${widget.namaSantri}",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18, 
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
      body: _isLoadingMapel 
      ? const Center(child: CircularProgressIndicator(color: Color(0xFF00695C)))
      : SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(),
                const SizedBox(height: 24),
                _buildFormInput(),
                const SizedBox(height: 60), 
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
    );
  }
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF00695C).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Informasi Akademik",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF00695C),
                ),
              ),
              Container(
                height: 32,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildSemesterTab("Ganjil", 1), 
                    _buildSemesterTab("Genap", 2),  
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDropdownContainer(
            icon: Icons.menu_book_rounded,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: _selectedMapelId,
                style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
                hint: Text("Pilih Mata Pelajaran", style: GoogleFonts.poppins(fontSize: 14)),
                items: _listMapel.map((m) {
                  return DropdownMenuItem(
                    value: m.id,
                    child: Text(m.nama, style: GoogleFonts.poppins()),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedMapelId = val),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildDropdownContainer(
                  icon: Icons.calendar_month_rounded,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedBulan,
                      style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
                      items: _bulanList.map((b) => DropdownMenuItem(
                        value: b,
                        child: Text(b, style: GoogleFonts.poppins()),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedBulan = val!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDropdownContainer(
                  icon: Icons.view_week_rounded,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _selectedMinggu,
                      style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
                      items: List.generate(4, (i) => i + 1)
                          .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text("Minggu-$m", style: GoogleFonts.poppins()),
                          ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedMinggu = val!),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildSemesterTab(String label, int value) {
    bool isSelected = _selectedSemester == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedSemester = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 159, 14, 23) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : const Color.fromARGB(255, 171, 17, 17),
          ),
        ),
      ),
    );
  }
  Widget _buildDropdownContainer({required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF00695C)),
          const SizedBox(width: 8),
          Expanded(child: child),
        ],
      ),
    );
  }
  Widget _buildFormInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Detail Penilaian",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00695C),
            ),
          ),
        ),
        Material(
          elevation: 3,
          shadowColor: Colors.black12,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                TextFormField(
                  controller: _materiController,
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    labelText: "Materi Pokok",
                    labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                    hintText: "Contoh: Tajwid Al-Fatihah",
                    hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                    prefixIcon: const Icon(Icons.edit_note_rounded, color: Color(0xFF00695C)),
                    filled: true,
                    fillColor: const Color(0xFFF9F9F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  ),
                  validator: (v) => v!.isEmpty ? "Materi wajib diisi" : null,
                ),
                
                const SizedBox(height: 20),
                TextFormField(
                  controller: _deskripsiController,
                  maxLines: 9,
                  style: GoogleFonts.poppins(fontSize: 14),
                  textAlignVertical: TextAlignVertical.top, 
                  decoration: InputDecoration(
                    labelText: "Deskripsi Penilaian",
                    labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                    hintText: "Berikan catatan lengkap mengenai capaian santri, evaluasi, dan saran perbaikan...",
                    hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                    alignLabelWithHint: true, // Label tetap di pojok kiri atas
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 160), // Menyesuaikan icon dengan kotak yang besar
                      child: Icon(Icons.description_outlined, color: Color(0xFF00695C)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9F9F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00695C), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (v) => v!.isEmpty ? "Deskripsi wajib diisi" : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00695C), 
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _isSubmitting ? null : _handleSimpan,
          child: _isSubmitting
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Text(
                  "SIMPAN DATA PENILAIAN",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}