import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'form_penilaian_screen.dart';

class GuruBiasaView extends StatelessWidget {
  const GuruBiasaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Icon(Icons.assignment_turned_in_outlined, size: 100, color: Colors.grey[300]),
        const SizedBox(height: 20),
        Text(
          'Input Nilai Santri',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Gunakan tombol di bawah untuk\nmelakukan input penilaian massal.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormPenilaianScreen(tipeInput: 'bulk')),
          ),
          icon: const Icon(Icons.group_add),
          label: const Text('Mulai Input Massal'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00695C),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}