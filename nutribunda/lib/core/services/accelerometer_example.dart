/// Example usage of AccelerometerService with RecipeProvider
/// This file demonstrates how to integrate shake detection with recipe selection
/// 
/// Requirements: 6.1, 6.2, 6.3, 6.6

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'accelerometer_service.dart';
import '../../presentation/providers/recipe_provider.dart';

/// Example 1: Basic shake detection
/// 
/// This example shows the simplest way to use AccelerometerService
void exampleBasicShakeDetection() {
  final accelerometer = AccelerometerService();
  
  // Start listening for shake events
  accelerometer.startListening(() {
    print('Shake detected!');
    // Do something when shake is detected
  });
  
  // Later, when done
  accelerometer.stopListening();
  accelerometer.dispose();
}

/// Example 2: Shake-to-Recipe integration
/// 
/// This example shows how to integrate shake detection with recipe selection
class ShakeToRecipeExample extends StatefulWidget {
  const ShakeToRecipeExample({super.key});

  @override
  State<ShakeToRecipeExample> createState() => _ShakeToRecipeExampleState();
}

class _ShakeToRecipeExampleState extends State<ShakeToRecipeExample> {
  final AccelerometerService _accelerometer = AccelerometerService();

  @override
  void initState() {
    super.initState();
    
    // Start shake detection when widget is initialized
    // Requirements: 6.1 - Memantau akselerometer saat aplikasi aktif
    _accelerometer.startListening(() {
      _handleShakeDetected();
    });
  }

  @override
  void dispose() {
    // Clean up when widget is disposed
    _accelerometer.dispose();
    super.dispose();
  }

  /// Handle shake detection
  /// Requirements: 6.2, 6.3 - Deteksi shake dan tampilkan resep acak
  void _handleShakeDetected() {
    if (!mounted) return;

    print('Shake detected! Getting random recipe...');
    
    // Get random recipe from provider
    final recipeProvider = context.read<RecipeProvider>();
    recipeProvider.getRandomRecipe().then((_) {
      if (mounted && recipeProvider.currentRecipe != null) {
        // Recipe loaded successfully
        print('Recipe: ${recipeProvider.currentRecipe!.name}');
        _showRecipeSnackbar();
      } else if (mounted && recipeProvider.errorMessage != null) {
        // Error occurred
        print('Error: ${recipeProvider.errorMessage}');
      }
    });
  }

  void _showRecipeSnackbar() {
    final recipe = context.read<RecipeProvider>().currentRecipe;
    if (recipe == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Resep baru: ${recipe.name}'),
        action: SnackBarAction(
          label: 'Lihat',
          onPressed: () {
            // Navigate to recipe detail
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shake to Recipe Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.phone_android,
              size: 100,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            const Text(
              'Goyangkan smartphone Anda',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'untuk mendapatkan resep MPASI acak',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            Consumer<RecipeProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const CircularProgressIndicator();
                }
                
                if (provider.currentRecipe != null) {
                  return Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            provider.currentRecipe!.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${provider.currentRecipe!.ingredients.length} bahan',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return const Text('Belum ada resep');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 3: Custom shake threshold
/// 
/// This example shows how to test different shake thresholds
void exampleCustomThreshold() {
  final accelerometer = AccelerometerService();
  
  // Note: The threshold is a constant in the service
  // To test different thresholds, you would need to modify the service
  // or create a custom implementation
  
  print('Current threshold: ${AccelerometerService.shakeThreshold} m/s²');
  print('Current cooldown: ${AccelerometerService.shakeCooldownMs} ms');
  print('Current duration: ${AccelerometerService.shakeDurationMs} ms');
  
  accelerometer.dispose();
}

/// Example 4: Monitoring shake events
/// 
/// This example shows how to track shake events for debugging
class ShakeMonitorExample extends StatefulWidget {
  const ShakeMonitorExample({super.key});

  @override
  State<ShakeMonitorExample> createState() => _ShakeMonitorExampleState();
}

class _ShakeMonitorExampleState extends State<ShakeMonitorExample> {
  final AccelerometerService _accelerometer = AccelerometerService();
  int _shakeCount = 0;
  DateTime? _lastShake;

  @override
  void initState() {
    super.initState();
    
    _accelerometer.startListening(() {
      setState(() {
        _shakeCount++;
        _lastShake = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _accelerometer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shake Monitor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Shake Count: $_shakeCount',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            if (_lastShake != null)
              Text(
                'Last shake: ${_lastShake!.toLocal()}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _shakeCount = 0;
                  _lastShake = null;
                });
                _accelerometer.resetLastShakeTime();
              },
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 5: Error handling
/// 
/// This example shows how to handle accelerometer errors
class ShakeErrorHandlingExample extends StatefulWidget {
  const ShakeErrorHandlingExample({super.key});

  @override
  State<ShakeErrorHandlingExample> createState() => _ShakeErrorHandlingExampleState();
}

class _ShakeErrorHandlingExampleState extends State<ShakeErrorHandlingExample> {
  final AccelerometerService _accelerometer = AccelerometerService();

  @override
  void initState() {
    super.initState();
    
    _accelerometer.startListening(() {
      print('Shake detected!');
    });
    
    // Check for errors after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _accelerometer.errorMessage != null) {
        _showErrorDialog();
      }
    });
  }

  @override
  void dispose() {
    _accelerometer.dispose();
    super.dispose();
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accelerometer Error'),
        content: Text(_accelerometer.errorMessage ?? 'Unknown error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Handling Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_accelerometer.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      _accelerometer.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              )
            else
              const Text('Accelerometer is working fine'),
          ],
        ),
      ),
    );
  }
}
