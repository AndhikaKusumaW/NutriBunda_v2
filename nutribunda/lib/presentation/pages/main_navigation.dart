import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lbs_provider.dart';
import '../../injection_container.dart' as di;
import '../../core/utils/accessibility_helper.dart';
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
      bottomNavigationBar: Semantics(
        label: 'Navigasi utama aplikasi',
        hint: 'Pilih tab untuk berpindah halaman',
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: [
            BottomNavigationBarItem(
              icon: Semantics(
                label: AccessibilityHelper.navigationTabLabel(
                  tabName: 'Home',
                  index: 0,
                  total: 4,
                  isSelected: _currentIndex == 0,
                ),
                child: const Icon(Icons.home),
              ),
              label: 'Home',
              tooltip: 'Dashboard dengan ringkasan nutrisi harian',
            ),
            BottomNavigationBarItem(
              icon: Semantics(
                label: AccessibilityHelper.navigationTabLabel(
                  tabName: 'Diary',
                  index: 1,
                  total: 4,
                  isSelected: _currentIndex == 1,
                ),
                child: const Icon(Icons.book),
              ),
              label: 'Diary',
              tooltip: 'Pencatatan makanan bayi dan ibu',
            ),
            BottomNavigationBarItem(
              icon: Semantics(
                label: AccessibilityHelper.navigationTabLabel(
                  tabName: 'Peta',
                  index: 2,
                  total: 4,
                  isSelected: _currentIndex == 2,
                ),
                child: const Icon(Icons.map),
              ),
              label: 'Peta',
              tooltip: 'Cari fasilitas kesehatan terdekat',
            ),
            BottomNavigationBarItem(
              icon: Semantics(
                label: AccessibilityHelper.navigationTabLabel(
                  tabName: 'Profil',
                  index: 3,
                  total: 4,
                  isSelected: _currentIndex == 3,
                ),
                child: const Icon(Icons.person),
              ),
              label: 'Profil',
              tooltip: 'Profil pengguna dan pengaturan',
            ),
          ],
        ),
      ),
    );
  }
}