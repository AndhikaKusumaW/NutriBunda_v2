import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lbs_provider.dart';
import '../../../injection_container.dart';
import 'lbs_screen.dart';

/// Example demonstrating how to use LBS feature
/// 
/// This shows how to:
/// 1. Register LBSProvider with dependency injection
/// 2. Navigate to LBS screen
/// 3. Handle location permissions and errors
/// 
/// **Usage in main navigation:**
/// ```dart
/// // In your main navigation or bottom nav bar:
/// ChangeNotifierProvider(
///   create: (_) => sl<LBSProvider>(),
///   child: LBSScreen(),
/// )
/// ```

class LBSExample extends StatelessWidget {
  const LBSExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LBS Feature Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Location-Based Service',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Cari fasilitas kesehatan terdekat seperti Rumah Sakit, Puskesmas, Posyandu, dan Apotek',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to LBS screen with provider
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (_) => sl<LBSProvider>(),
                      child: const LBSScreen(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.location_on),
              label: const Text('Buka Peta Fasilitas'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Fitur ini memerlukan izin akses lokasi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example of using LBS in a bottom navigation bar
class MainNavigationWithLBS extends StatefulWidget {
  const MainNavigationWithLBS({Key? key}) : super(key: key);

  @override
  State<MainNavigationWithLBS> createState() => _MainNavigationWithLBSState();
}

class _MainNavigationWithLBSState extends State<MainNavigationWithLBS> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home screen
          const Center(child: Text('Home')),
          
          // Diary screen
          const Center(child: Text('Diary')),
          
          // LBS screen with provider
          ChangeNotifierProvider(
            create: (_) => sl<LBSProvider>(),
            child: const LBSScreen(),
          ),
          
          // Profile screen
          const Center(child: Text('Profile')),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Diary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Peta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
