import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'injection_container.dart' as di;
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/food_diary_provider.dart';
import 'presentation/pages/auth/login_screen.dart';
import 'presentation/pages/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Indonesian locale for date formatting
  await initializeDateFormatting('id_ID', null);
  
  // Initialize dependency injection
  await di.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => di.sl<AuthProvider>()..initializeAuth(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<FoodDiaryProvider>(),
        ),
      ],
      child: MaterialApp(
        title: 'NutriBunda',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // Show loading while initializing
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Show login screen if not authenticated
            if (!authProvider.isAuthenticated) {
              return const LoginScreen();
            }

            // Show dashboard if authenticated
            return const DashboardScreen();
          },
        ),
        routes: {
          '/home': (context) => const DashboardScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}
