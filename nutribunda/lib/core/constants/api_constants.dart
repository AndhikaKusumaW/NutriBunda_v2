class ApiConstants {
  // Base URL - will be configured later
  static const String baseUrl = 'http://localhost:8080/api';
  
  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  
  // Profile endpoints
  static const String profile = '/profile';
  static const String uploadImage = '/profile/upload-image';
  
  // Food endpoints
  static const String foods = '/foods';
  static const String foodsSync = '/foods/sync';
  
  // Diary endpoints
  static const String diary = '/diary';
  
  // Recipe endpoints
  static const String recipes = '/recipes';
  static const String recipesRandom = '/recipes/random';
  static const String recipesFavorites = '/recipes/favorites';
  
  // Quiz endpoints
  static const String quizQuestions = '/quiz/questions';
  static const String quizSubmit = '/quiz/submit';
  
  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
