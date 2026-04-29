import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lbs_provider.dart';
import '../../injection_container.dart' as di;
import 'dashboard/dashboard_screen.dart';
import 'diary/diary_screen.dart';
import 'lbs/lbs_screen.dart';
import 'profile/profile_screen.dart';

/// Main navigation widget dengan bottom navigation bar
/// Requirements: 13.1, 13.3, 13.4, 13.5, 13.6 - Bottom navigation dengan 4 tabs
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // List of screens untuk setiap tab
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(), // Home tab
      const DiaryScreen(),     // Diary tab
      ChangeNotifierProvider(  // Peta tab dengan LBSProvider
        create: (_) => di.sl<LBSProvider>(),
        child: const LBSScreen(),
      ),
      const ProfileScreen(),   // Profil tab
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            tooltip: 'Dashboard dengan ringkasan nutrisi harian',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Diary',
            tooltip: 'Pencatatan makanan bayi dan ibu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Peta',
            tooltip: 'Cari fasilitas kesehatan terdekat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
            tooltip: 'Profil pengguna dan pengaturan',
          ),
        ],
      ),
    );
  }
}