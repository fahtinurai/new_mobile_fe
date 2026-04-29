import 'package:flutter/material.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Color(0xFFF9A825),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- BAGIAN HEADER (FOTO & NAMA) ---
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF1E1E1E),
                    child: Icon(Icons.person, size: 60, color: Color(0xFFF9A825)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Mochammad Raffli", // Kamu bisa ganti dengan nama dinamis nanti
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "OPERATOR", // Label Role disesuaikan jadi Operator
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // --- BAGIAN DAFTAR MENU (IDENTIK DENGAN MEKANIK) ---
            _buildMenuItem(Icons.edit_outlined, "Edit Profile"),
            _buildMenuItem(Icons.lock_outline, "Change Password"),
            _buildMenuItem(Icons.notifications_none, "Notification Settings"),
            _buildMenuItem(Icons.language_outlined, "Language"),
            _buildMenuItem(Icons.help_outline, "Help & Support"),
            _buildMenuItem(Icons.privacy_tip_outlined, "Privacy Policy"),
            
            const Divider(color: Colors.white10, height: 40, indent: 20, endIndent: 20),
            
            // --- TOMBOL LOGOUT ---
            ListTile(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk membuat baris menu agar kode rapi
  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      onTap: () {
        // Tambahkan navigasi jika diperlukan nanti
      },
      leading: Icon(icon, color: Colors.white70, size: 22),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
    );
  }
}