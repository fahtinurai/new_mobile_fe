import 'package:flutter/material.dart';

// Dashboard
import 'package:djatimobile_project/pages/dashboard/analytics_report_page.dart';

// Repair
import 'package:djatimobile_project/pages/repair/repair_status_page.dart';
import 'package:djatimobile_project/pages/repair/damage_report_page.dart';

// Mechanic
import 'package:djatimobile_project/pages/mechanic/mechanic_history_page.dart';
import 'package:djatimobile_project/pages/mechanic/mechanic_flow.dart';
import 'package:djatimobile_project/pages/mechanic/mechanic_profile_page.dart';

// Profile
import 'package:djatimobile_project/pages/mechanic/profile_page.dart';

class MainNavigation extends StatefulWidget {
  final String userRole;

  const MainNavigation({super.key, required this.userRole});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  late List<Widget> pages;
  late List<BottomNavigationBarItem> items;

  @override
  void initState() {
    super.initState();

    final role = widget.userRole.toUpperCase();

    if (role == "MECHANIC") {
      pages = [
        const MechanicHistoryPage(),
        const MechanicTasksFlow(),
        const MechanicProfilePage(),
      ];

      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Tasks'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
    } else {
      pages = [
        const AnalyticsReportPage(),
        const RepairStatusPage(),
        const DamageReportPage(),
        const ProfilePage(),
      ];

      items = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.track_changes),
          label: 'Status',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Report'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFF9A825),
        unselectedItemColor: Colors.white24,
        backgroundColor: const Color(0xFF1E1E1E),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: items,
      ),
    );
  }
}
