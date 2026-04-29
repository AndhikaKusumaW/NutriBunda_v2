# SQLite Local Database Implementation

## Overview

This directory contains the SQLite local database implementation for NutriBunda. The database provides offline-first functionality, allowing the app to work without an internet connection and sync data when connectivity is restored.

## Architecture

### Database Helper
- **File**: `database_helper.dart`
- **Purpose**: Singleton database manager that handles database initialization, schema creation, and migrations
- **Database Name**: `nutribunda.db`
- **Current Version**: 1

### Data Sources
Each table has a dedicated data source class that provides CRUD operations:

1. **LocalUserDataSource** - User profile management
2. **LocalFoodDataSource** - Food database with search functionality
3. **LocalDiaryDataSource** - Food diary entries with nutrition tracking
4. **LocalRecipeDataSource** - Recipe storage
5. **LocalFavoriteRecipeDataSource** - Favorite recipes management
6. **LocalQuizDataSource** - Quiz questions cache
7. **LocalNotificationDataSource** - Notification settings

### Local Models
Local models extend the API models with additional fields for offline functionality:
- `id` - Local SQLite auto-increment ID
- `server_id` - UUID from PostgreSQL server
- `sync_status` - Tracks synchronization state ('synced', 'pending', 'failed')
- `deleted_at` - Soft delete timestamp for sync tracking

## Database Schema

### Tables

#### 1. users
Stores local user profile data.

```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  server_id TEXT UNIQUE,
  email TEXT NOT NULL,
  full_name TEXT NOT NULL,
  weight REAL,
  height REAL,
  age INTEGER,
  is_breastfeeding INTEGER DEFAULT 0,
  activity_level TEXT DEFAULT 'sedentary',
  profile_image_url TEXT,
  timezone TEXT DEFAULT 'WIB',
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  sync_status TEXT DEFAULT 'synced'
)
```

#### 2. foods
Local copy of food database for offline search.

```sql
CREATE TABLE foods (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  server_id TEXT UNIQUE,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  calories_per_100g REAL NOT NULL,
  protein_per_100g REAL NOT NULL,
  carbs_per_100g REAL NOT NULL,
  fat_per_100g REAL NOT NULL,
  created_at TEXT NOT NULL,
  sync_status TEXT DEFAULT 'synced'
)
```

**Indexes**:
- `idx_foods_name` - For name search
- `idx_foods_category` - For category filtering

#### 3. recipes
Stores recipes for offline access.

```sql
CREATE TABLE recipes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  server_id TEXT UNIQUE,
  name TEXT NOT NULL,
  ingredients TEXT NOT NULL,
  instructions TEXT NOT NULL,
  nutrition_info TEXT,
  category TEXT DEFAULT 'mpasi',
  created_at TEXT NOT NULL,
  sync_status TEXT DEFAULT 'synced'
)
```

#### 4. diary_entries
Food diary entries with offline creation support.

```sql
CREATE TABLE diary_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  server_id TEXT UNIQUE,
  user_id INTEGER NOT NULL,
  profile_type TEXT NOT NULL,
  food_id INTEGER,
  custom_food_name TEXT,
  serving_size REAL NOT NULL,
  meal_time TEXT NOT NULL,
  calories REAL NOT NULL,
  protein REAL NOT NULL,
  carbs REAL NOT NULL,
  fat REAL NOT NULL,
  entry_date TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  deleted_at TEXT,
  sync_status TEXT DEFAULT 'pending',
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (food_id) REFERENCES foods(id)
)
```

**Indexes**:
- `idx_diary_user_date` - For date-based queries
- `idx_diary_profile_type` - For profile filtering
- `idx_diary_sync_status` - For sync operations

#### 5. favorite_recipes
User's favorite recipes with sync tracking.

```sql
CREATE TABLE favorite_recipes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  server_id TEXT UNIQUE,
  user_id INTEGER NOT NULL,
  recipe_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  deleted_at TEXT,
  sync_status TEXT DEFAULT 'pending',
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
  UNIQUE(user_id, recipe_id)
)
```

#### 6. quiz_questions
Cached quiz questions for offline play.

```sql
CREATE TABLE quiz_questions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  server_id TEXT UNIQUE,
  question TEXT NOT NULL,
  option_a TEXT NOT NULL,
  option_b TEXT NOT NULL,
  option_c TEXT NOT NULL,
  option_d TEXT NOT NULL,
  correct_answer TEXT NOT NULL,
  explanation TEXT,
  created_at TEXT NOT NULL,
  sync_status TEXT DEFAULT 'synced'
)
```

#### 7. notifications
Local notification settings.

```sql
CREATE TABLE notifications (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  server_id TEXT UNIQUE,
  user_id INTEGER NOT NULL,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  scheduled_time TEXT NOT NULL,
  is_active INTEGER DEFAULT 1,
  created_at TEXT NOT NULL,
  sync_status TEXT DEFAULT 'pending',
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
)
```

#### 8. sync_metadata
Tracks last sync time for each table.

```sql
CREATE TABLE sync_metadata (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  table_name TEXT UNIQUE NOT NULL,
  last_sync_at TEXT NOT NULL
)
```

## Sync Strategy

### Sync Status Values
- **synced**: Data is synchronized with server
- **pending**: Local changes waiting to be synced
- **failed**: Sync attempt failed, will retry

### Sync Flow

1. **Download (Server → Local)**
   - Fetch data modified since last sync
   - Insert/update local records
   - Update `sync_metadata` with current timestamp

2. **Upload (Local → Server)**
   - Query records with `sync_status = 'pending'`
   - POST/PUT to server API
   - Update `server_id` and set `sync_status = 'synced'`
   - Handle failures by setting `sync_status = 'failed'`

3. **Soft Deletes**
   - Set `deleted_at` timestamp instead of hard delete
   - Sync deletion to server
   - Hard delete after successful sync

## Usage Examples

### Initialize Database

```dart
final dbHelper = DatabaseHelper.instance;
final db = await dbHelper.database;
```

### Food Search (Offline)

```dart
final foodDataSource = LocalFoodDataSource();

// Search foods by name
final foods = await foodDataSource.searchFoods(
  query: 'pisang',
  category: 'mpasi',
  limit: 10,
);

// Get foods by category
final mpasiFoods = await foodDataSource.getFoodsByCategory('mpasi');
```

### Diary Entry Management

```dart
final diaryDataSource = LocalDiaryDataSource();

// Add diary entry (offline)
final entry = LocalDiaryEntry(
  userId: 1,
  profileType: 'baby',
  foodId: 5,
  servingSize: 100.0,
  mealTime: 'breakfast',
  calories: 89.0,
  protein: 1.1,
  carbs: 22.8,
  fat: 0.3,
  entryDate: DateTime.now(),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  syncStatus: 'pending',
);

final id = await diaryDataSource.insertDiaryEntry(entry);

// Get entries by date
final entries = await diaryDataSource.getDiaryEntriesByDate(
  userId: 1,
  profileType: 'baby',
  date: DateTime.now(),
);

// Calculate nutrition summary
final summary = await diaryDataSource.calculateNutritionSummary(
  userId: 1,
  profileType: 'baby',
  date: DateTime.now(),
);
```

### Favorite Recipes

```dart
final favoriteDataSource = LocalFavoriteRecipeDataSource();

// Add to favorites
await favoriteDataSource.addFavorite(
  userId: 1,
  recipeId: 10,
);

// Check if favorite
final isFav = await favoriteDataSource.isFavorite(
  userId: 1,
  recipeId: 10,
);

// Get all favorites
final favorites = await favoriteDataSource.getFavoriteRecipes(1);
```

### Random Recipe (Shake-to-Recipe)

```dart
final recipeDataSource = LocalRecipeDataSource();

// Get random MPASI recipe
final recipe = await recipeDataSource.getRandomRecipe(
  category: 'mpasi',
);
```

### Quiz Questions

```dart
final quizDataSource = LocalQuizDataSource();

// Get 10 random questions
final questions = await quizDataSource.getRandomQuizQuestions(limit: 10);
```

## Migration Support

The database helper includes migration support for future schema changes:

```dart
Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    // Add new column
    await db.execute('ALTER TABLE users ADD COLUMN new_field TEXT');
  }
  
  if (oldVersion < 3) {
    // Create new table
    await db.execute('''
      CREATE TABLE new_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ...
      )
    ''');
  }
}
```

## Testing

### Clear Database (for testing)

```dart
// Clear all data
await DatabaseHelper.instance.clearAllData();

// Delete database file
await DatabaseHelper.instance.deleteDatabase();
```

### Check Data Counts

```dart
final foodCount = await foodDataSource.getFoodsCount();
final diaryCount = await diaryDataSource.getDiaryEntriesCount(userId: 1);
final favCount = await favoriteDataSource.getFavoritesCount(1);
```

## Requirements Mapping

This implementation satisfies the following requirements:

- **3.3**: Offline food search from local SQLite database
- **3.4**: Initial download and local storage of food database
- **4.1-4.6**: Food diary with offline support and dual profiles
- **6.1**: Random recipe selection for shake-to-recipe
- **7.1-7.4**: Favorite recipes with offline access
- **10.1-10.7**: Quiz game with cached questions
- **11.1-11.5**: Notification settings management

## Performance Considerations

1. **Indexes**: Created on frequently queried columns (name, category, date, sync_status)
2. **Batch Operations**: Use batch inserts for bulk data sync
3. **Soft Deletes**: Preserve data for sync before hard deletion
4. **Query Optimization**: Use WHERE clauses to filter deleted records

## Security

- Database is stored in app's private directory
- No sensitive data (passwords, tokens) stored in SQLite
- Use `flutter_secure_storage` for sensitive data
- Foreign key constraints enforce referential integrity

## Next Steps

1. Implement sync service to coordinate data synchronization
2. Add conflict resolution for concurrent edits
3. Implement background sync with WorkManager
4. Add data compression for large datasets
5. Implement incremental sync for efficiency
