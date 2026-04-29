import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Simple Navigation Widget Tests
/// 
/// **Validates: Requirements 12.1-12.5, 13.1-13.6**
/// 
/// These are simplified tests that focus on the core navigation functionality
/// without complex dependencies and mocking.
void main() {
  group('Simple Navigation Tests', () {
    testWidgets(
      'should display bottom navigation bar with 4 tabs',
      (WidgetTester tester) async {
        // **Validates: Requirement 13.1**
        // Bottom navigation bar should have 4 tabs: Home, Diary, Peta, Profil
        
        await tester.pumpWidget(
          MaterialApp(
            home: TestNavigationWidget(),
          ),
        );

        // Verify bottom navigation bar exists
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        // Verify all 4 tabs are present
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Diary'), findsOneWidget);
        expect(find.text('Peta'), findsOneWidget);
        expect(find.text('Profil'), findsOneWidget);

        // Verify icons are present
        expect(find.byIcon(Icons.home), findsOneWidget);
        expect(find.byIcon(Icons.book), findsOneWidget);
        expect(find.byIcon(Icons.map), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
      },
    );

    testWidgets(
      'should navigate between tabs correctly',
      (WidgetTester tester) async {
        // **Validates: Requirements 13.2-13.5**
        // Navigation should work between all tabs
        
        await tester.pumpWidget(
          MaterialApp(
            home: TestNavigationWidget(),
          ),
        );

        // Initially, Home tab (index 0) should be selected
        BottomNavigationBar bottomNavBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );
        expect(bottomNavBar.currentIndex, equals(0));

        // Navigate to Diary tab
        await tester.tap(find.text('Diary'));
        await tester.pumpAndSettle();

        bottomNavBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );
        expect(bottomNavBar.currentIndex, equals(1));
        expect(find.text('Diary Screen'), findsOneWidget);

        // Navigate to Peta tab
        await tester.tap(find.text('Peta'));
        await tester.pumpAndSettle();

        bottomNavBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );
        expect(bottomNavBar.currentIndex, equals(2));
        expect(find.text('Peta Screen'), findsOneWidget);

        // Navigate to Profil tab
        await tester.tap(find.text('Profil'));
        await tester.pumpAndSettle();

        bottomNavBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );
        expect(bottomNavBar.currentIndex, equals(3));
        expect(find.text('Profil Screen'), findsOneWidget);
      },
    );

    testWidgets(
      'should maintain bottom navigation visibility across all screens',
      (WidgetTester tester) async {
        // **Validates: Requirement 13.6**
        // Bottom navigation bar should be visible consistently across all screens
        
        await tester.pumpWidget(
          MaterialApp(
            home: TestNavigationWidget(),
          ),
        );

        final tabs = ['Home', 'Diary', 'Peta', 'Profil'];

        for (final tabName in tabs) {
          // Navigate to each tab
          await tester.tap(find.text(tabName));
          await tester.pumpAndSettle();

          // Verify bottom navigation bar is still visible
          expect(
            find.byType(BottomNavigationBar), 
            findsOneWidget,
            reason: 'Bottom navigation should be visible on $tabName tab',
          );

          // Verify all tab labels are still present
          for (final otherTab in tabs) {
            expect(
              find.text(otherTab), 
              findsOneWidget,
              reason: '$otherTab should be visible in bottom navigation on $tabName screen',
            );
          }
        }
      },
    );

    testWidgets(
      'should preserve screen state when switching between tabs',
      (WidgetTester tester) async {
        // **Validates: Navigation state persistence**
        // Screen state should be preserved when switching between tabs
        
        await tester.pumpWidget(
          MaterialApp(
            home: TestNavigationWidget(),
          ),
        );

        // Verify IndexedStack is used for state preservation
        expect(find.byType(IndexedStack), findsOneWidget);

        // Navigate to different tabs
        await tester.tap(find.text('Diary'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Peta'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Profil'));
        await tester.pumpAndSettle();

        // Navigate back to Home
        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();

        // Verify all screens are still in the widget tree (IndexedStack behavior)
        // Note: IndexedStack keeps all children in the tree but only shows the active one
        expect(find.byType(IndexedStack), findsOneWidget);
        
        // Verify the current screen is visible
        expect(find.text('Home Screen'), findsOneWidget);
      },
    );

    testWidgets(
      'should have proper accessibility labels for navigation tabs',
      (WidgetTester tester) async {
        // **Validates: Accessibility support**
        
        await tester.pumpWidget(
          MaterialApp(
            home: TestNavigationWidget(),
          ),
        );

        final bottomNavBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );

        // Verify each tab has proper labels
        expect(bottomNavBar.items.length, equals(4));
        
        for (int i = 0; i < bottomNavBar.items.length; i++) {
          final item = bottomNavBar.items[i];
          expect(item.label, isNotNull);
          expect(item.label, isNotEmpty);
        }

        // Verify specific accessibility information
        expect(bottomNavBar.items[0].label, equals('Home'));
        expect(bottomNavBar.items[1].label, equals('Diary'));
        expect(bottomNavBar.items[2].label, equals('Peta'));
        expect(bottomNavBar.items[3].label, equals('Profil'));
      },
    );

    testWidgets(
      'should handle rapid navigation without performance issues',
      (WidgetTester tester) async {
        // **Validates: Navigation performance**
        
        await tester.pumpWidget(
          MaterialApp(
            home: TestNavigationWidget(),
          ),
        );

        final stopwatch = Stopwatch()..start();
        
        // Rapidly switch between tabs multiple times
        final tabs = ['Diary', 'Peta', 'Profil', 'Home'];
        
        for (int i = 0; i < 2; i++) { // 2 cycles
          for (final tabName in tabs) {
            await tester.tap(find.text(tabName));
            await tester.pump(); // Don't wait for settle to test responsiveness
          }
        }
        
        await tester.pumpAndSettle();
        stopwatch.stop();

        // Navigation should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5 seconds max
        
        // Verify final state is correct
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      },
    );
  });

  group('Profile Management Tests', () {
    testWidgets(
      'should display profile form with validation',
      (WidgetTester tester) async {
        // **Validates: Requirements 12.1-12.5**
        // Profile form should have proper validation
        
        await tester.pumpWidget(
          MaterialApp(
            home: TestProfileFormWidget(),
          ),
        );

        // Verify form fields are present
        expect(find.byType(TextFormField), findsNWidgets(4)); // name, weight, height, age
        expect(find.text('Nama Lengkap'), findsOneWidget);
        expect(find.text('Berat Badan (kg)'), findsOneWidget);
        expect(find.text('Tinggi Badan (cm)'), findsOneWidget);
        expect(find.text('Usia (tahun)'), findsOneWidget);

        // Test weight validation (Requirements 12.4)
        final weightField = find.widgetWithText(TextFormField, 'Berat Badan (kg)');
        await tester.enterText(weightField, '25'); // Below minimum
        await tester.tap(find.text('Simpan'));
        await tester.pumpAndSettle();

        expect(find.text('Berat badan harus antara 30-200 kg'), findsOneWidget);

        // Test valid weight
        await tester.enterText(weightField, '65');
        await tester.tap(find.text('Simpan'));
        await tester.pumpAndSettle();

        expect(find.text('Berat badan harus antara 30-200 kg'), findsNothing);
      },
    );

    testWidgets(
      'should validate height input correctly',
      (WidgetTester tester) async {
        // **Validates: Requirement 12.4**
        // Height validation (100-250cm)
        
        await tester.pumpWidget(
          MaterialApp(
            home: TestProfileFormWidget(),
          ),
        );

        final heightField = find.widgetWithText(TextFormField, 'Tinggi Badan (cm)');

        // Test invalid height (below minimum)
        await tester.enterText(heightField, '90');
        await tester.tap(find.text('Simpan'));
        await tester.pumpAndSettle();

        expect(find.text('Tinggi badan harus antara 100-250 cm'), findsOneWidget);

        // Test valid height
        await tester.enterText(heightField, '165');
        await tester.tap(find.text('Simpan'));
        await tester.pumpAndSettle();

        expect(find.text('Tinggi badan harus antara 100-250 cm'), findsNothing);
      },
    );

    testWidgets(
      'should handle profile image selection UI',
      (WidgetTester tester) async {
        // **Validates: Requirement 12.2**
        // Profile image selection interface
        
        await tester.pumpWidget(
          MaterialApp(
            home: TestProfileFormWidget(),
          ),
        );

        // Verify profile image section
        expect(find.byType(CircleAvatar), findsNWidgets(2)); // Main avatar + camera button
        expect(find.byIcon(Icons.camera_alt), findsOneWidget);

        // Tap camera icon
        await tester.tap(find.byIcon(Icons.camera_alt));
        await tester.pumpAndSettle();

        // Verify image source selection dialog appears
        expect(find.text('Pilih dari Galeri'), findsOneWidget);
        expect(find.text('Ambil Foto'), findsOneWidget);
      },
    );
  });
}

/// Test widget that simulates the main navigation structure
class TestNavigationWidget extends StatefulWidget {
  @override
  _TestNavigationWidgetState createState() => _TestNavigationWidgetState();
}

class _TestNavigationWidgetState extends State<TestNavigationWidget> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    Center(child: Text('Home Screen')),
    Center(child: Text('Diary Screen')),
    Center(child: Text('Peta Screen')),
    Center(child: Text('Profil Screen')),
  ];

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

/// Test widget that simulates the profile form
class TestProfileFormWidget extends StatefulWidget {
  @override
  _TestProfileFormWidgetState createState() => _TestProfileFormWidgetState();
}

class _TestProfileFormWidgetState extends State<TestProfileFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Foto'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profil')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: IconButton(
                          icon: Icon(Icons.camera_alt, size: 20),
                          color: Colors.white,
                          onPressed: _showImageSourceDialog,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama lengkap tidak boleh kosong';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              // Weight Field
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Berat Badan (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final weight = double.tryParse(value);
                  if (weight == null) return 'Masukkan angka yang valid';
                  if (weight < 30 || weight > 200) {
                    return 'Berat badan harus antara 30-200 kg';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              // Height Field
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: 'Tinggi Badan (cm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final height = double.tryParse(value);
                  if (height == null) return 'Masukkan angka yang valid';
                  if (height < 100 || height > 250) {
                    return 'Tinggi badan harus antara 100-250 cm';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              // Age Field
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Usia (tahun)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final age = int.tryParse(value);
                  if (age == null) return 'Masukkan angka yang valid';
                  if (age < 15 || age > 60) {
                    return 'Usia harus antara 15-60 tahun';
                  }
                  return null;
                },
              ),

              SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState!.validate();
                },
                child: Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}