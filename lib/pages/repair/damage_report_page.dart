import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'dart:io';

class DamageReportPage extends StatefulWidget {
  const DamageReportPage({super.key});

  @override
  State<DamageReportPage> createState() => _DamageReportPageState();
}

class _DamageReportPageState extends State<DamageReportPage> {
  final TextEditingController _unitNameController = TextEditingController();
  final TextEditingController _damageTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // FUNGSI INSTAN KAMERA
  Future<void> _takePhoto() async {
    // Di sini kita kunci source: ImageSource.camera agar langsung buka kamera
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera, 
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _unitNameController.dispose();
    _damageTypeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitReport() {
    // Validasi: Teks harus diisi DAN Foto harus ada
    if (_unitNameController.text.trim().isEmpty ||
        _damageTypeController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _image == null) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lengkapi semua data dan ambil foto bukti!"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Laporan Berhasil Terkirim!"),
          backgroundColor: Colors.green,
        ),
      );
      // Bersihkan form setelah sukses
      setState(() {
        _unitNameController.clear();
        _damageTypeController.clear();
        _descriptionController.clear();
        _image = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Report Damage", style: TextStyle(color: Color(0xFFF9A825), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Unit Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildInput(_unitNameController, "Contoh: Excavator EX-01"),
            
            const SizedBox(height: 20),
            const Text("Damage Type", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildInput(_damageTypeController, "Contoh: Kebocoran Oli"),

            const SizedBox(height: 20),
            const Text("Bukti Foto (Wajib Kamera)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // Area Tap Kamera
            GestureDetector(
              onTap: _takePhoto, // Begitu di-tap, langsung buka kamera
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _image == null ? Colors.white10 : const Color(0xFFF9A825), 
                    width: 2
                  ),
                ),
                child: _image == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_enhance, color: Colors.white24, size: 50),
                          SizedBox(height: 10),
                          Text("Tap untuk Ambil Foto", style: TextStyle(color: Colors.white24)),
                        ],
                      )
                    : Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(_image!, width: double.infinity, fit: BoxFit.cover),
                          ),
                          // Tombol ganti foto jika hasil kurang bagus
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.white),
                                onPressed: _takePhoto,
                              ),
                            ),
                          )
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 20),
            const Text("Description", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildInput(_descriptionController, "Detail masalah kendaraan...", maxLines: 3),
            
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submitReport,
                child: const Text("SUBMIT REPORT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}