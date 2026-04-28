import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/accelerometer_service.dart';
import '../providers/recipe_provider.dart';
import '../pages/recipe/recipe_detail_screen.dart';

/// Widget untuk menampilkan shake-to-recipe feature
/// Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6
class ShakeToRecipeWidget extends StatefulWidget {
  const ShakeToRecipeWidget({super.key});

  @override
  State<ShakeToRecipeWidget> createState() => _ShakeToRecipeWidgetState();
}

class _ShakeToRecipeWidgetState extends State<ShakeToRecipeWidget>
    with SingleTickerProviderStateMixin {
  final AccelerometerService _accelerometerService = AccelerometerService();
  bool _isShakeEnabled = false;
  bool _isShaking = false;
  
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize shake animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticIn,
      ),
    );
    
    _startShakeDetection();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _accelerometerService.dispose();
    super.dispose();
  }

  /// Start shake detection
  /// Requirements: 6.1 - Memantau akselerometer saat aplikasi aktif
  void _startShakeDetection() {
    _accelerometerService.startListening(() {
      // Callback when shake is detected
      // Requirements: 6.3 - Menampilkan resep acak saat shake terdeteksi
      _onShakeDetected();
    });
    
    setState(() {
      _isShakeEnabled = true;
    });
  }

  /// Handle shake detection
  /// Requirements: 6.2, 6.3 - Memicu peristiwa shake dan menampilkan resep
  void _onShakeDetected() {
    if (!mounted || _isShaking) return;

    setState(() {
      _isShaking = true;
    });

    // Start shake animation
    _animationController.repeat(reverse: true);

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            const Text('Mencari resep acak...'),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange,
      ),
    );

    // Get random recipe
    final recipeProvider = context.read<RecipeProvider>();
    recipeProvider.getRandomRecipe().then((_) {
      // Stop animation
      _animationController.stop();
      _animationController.reset();
      
      setState(() {
        _isShaking = false;
      });

      if (mounted && recipeProvider.currentRecipe != null) {
        // Navigate to recipe detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(
              recipe: recipeProvider.currentRecipe!,
            ),
          ),
        );
      } else if (mounted && recipeProvider.errorMessage != null) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(recipeProvider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value * (_isShaking ? 1 : 0), 0),
          child: Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.shade50,
                    Colors.orange.shade100,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isShaking ? Icons.restaurant_menu : Icons.phone_android,
                        size: 48,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isShaking ? 'Mencari Resep...' : 'Shake untuk Resep Acak',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isShaking
                          ? 'Mohon tunggu sebentar'
                          : _isShakeEnabled
                              ? 'Goyangkan smartphone Anda untuk mendapatkan resep MPASI acak!'
                              : 'Mengaktifkan sensor...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    if (_accelerometerService.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _accelerometerService.errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
