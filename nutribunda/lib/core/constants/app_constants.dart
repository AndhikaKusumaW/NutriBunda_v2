class AppConstants {
  // App Info
  static const String appName = 'NutriBunda';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String jwtTokenKey = 'jwt_token';
  static const String userIdKey = 'user_id';
  static const String biometricEnabledKey = 'biometric_enabled';
  
  // Database
  static const String localDatabaseName = 'nutribunda.db';
  static const int databaseVersion = 1;
  
  // Validation
  static const double minWeight = 30.0;
  static const double maxWeight = 200.0;
  static const double minHeight = 100.0;
  static const double maxHeight = 250.0;
  
  // Image
  static const int maxImageSizeKB = 500;
  
  // Sensor
  static const double shakeThreshold = 15.0;
  static const int shakeCooldownMs = 3000;
  
  // Activity Factors for TDEE
  static const double sedentaryFactor = 1.2;
  static const double lightlyActiveFactor = 1.375;
  static const double moderatelyActiveFactor = 1.55;
  
  // Calorie
  static const double maxCalorieDeficit = 500.0;
  static const double breastfeedingCalorieBonus = 400.0;
  static const double caloriesPerStep = 0.04; // per kg body weight per 1000 steps
  
  // Timezone
  static const String timezoneWIB = 'WIB';
  static const String timezoneWITA = 'WITA';
  static const String timezoneWIT = 'WIT';
  
  // Notification
  static const String mpasChannelId = 'mpasi_channel';
  static const String mpasChannelName = 'MPASI Reminders';
  static const String vitaminChannelId = 'vitamin_channel';
  static const String vitaminChannelName = 'Vitamin Reminders';
  
  // Default MPASI meal times
  static const List<String> defaultMealTimes = ['07:00', '12:00', '17:00', '19:00'];
}
