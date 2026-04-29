import 'package:flutter/material.dart';
import '../auth/login_page.dart';

class MechanicProfilePage extends StatelessWidget {
  const MechanicProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          "PROFILE",
          style: TextStyle(
            color: Color(0xFFF9A825),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- HEADER: FOTO & IDENTITAS ---
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
                    "Ahmad Syarif",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "SENIOR MECHANIC",
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
            
            // --- DAFTAR MENU (VERSI LIST SEPERTI OPERATOR) ---
            _buildMenuItem(Icons.history, "Repair History"),
            _buildMenuItem(Icons.assignment_outlined, "Task Details"),
            _buildMenuItem(Icons.analytics_outlined, "Technical Stats"),
            _buildMenuItem(Icons.edit_outlined, "Edit Profile"),
            _buildMenuItem(Icons.lock_outline, "Change Password"),
            _buildMenuItem(Icons.notifications_none, "Notification Settings"),
            _buildMenuItem(Icons.help_outline, "Help & Support"),
            
            const Divider(color: Colors.white10, height: 40, indent: 20, endIndent: 20),
            
            // --- TOMBOL LOGOUT ---
            ListTile(
              onTap: () {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
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

  // Widget Helper untuk Baris Menu (Sama dengan versi Operator)
  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      onTap: () {
        // Tambahkan navigasi di sini jika diperlukan
      },
      leading: Icon(icon, color: const Color(0xFFF9A825), size: 22),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
    );
  }
}