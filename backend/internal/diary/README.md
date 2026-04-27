# Food Diary Module

## Overview

The Food Diary module implements the food tracking functionality for NutriBunda, allowing users to record food consumption for two separate profiles: Baby (MPASI) and Mother (post-partum diet).

## Features

### Dual Profile Support
- **Baby Profile**: Track MPASI (complementary feeding) for babies aged 6-24 months
- **Mother Profile**: Track post-partum diet and nutrition for mothers

Each profile maintains separate diary entries and nutrition summaries.

### Entry Types

#### 1. Food Database Entry
Create entries using foods from the database with automatic nutrition calculation:
```json
{
  "profile_type": "baby",
  "food_id": "uuid",
  "serving_size": 150,
  "meal_time": "breakfast",
  "entry_date": "2024-01-15"
}
```

Nutrition is automatically calculated based on serving size:
- `nutrition_value = (nutrition_per_100g * serving_size) / 100`

#### 2. Manual Entry
Create custom entries with manual nutrition input:
```json
{
  "profile_type": "mother",
  "custom_food_name": "Nasi Goreng Rumahan",
  "serving_size": 250,
  "meal_time": "lunch",
  "entry_date": "2024-01-15",
  "calories": 450,
  "protein": 15,
  "carbs": 60,
  "fat": 18
}
```

### Meal Time Categories
- `breakfast` - Morning meal
- `lunch` - Midday meal
- `dinner` - Evening meal
- `snack` - Snacks between meals

### Nutrition Tracking
The module automatically calculates daily nutrition summaries:
- **Calories** (kcal)
- **Protein** (grams)
- **Carbohydrates** (grams)
- **Fat** (grams)

## API Endpoints

### POST /api/diary
Create a new diary entry.

**Authentication**: Required (JWT Bearer token)

**Request Body**:
```json
{
  "profile_type": "baby|mother",
  "food_id": "uuid (optional)",
  "custom_food_name": "string (optional)",
  "serving_size": 150,
  "meal_time": "breakfast|lunch|dinner|snack",
  "entry_date": "YYYY-MM-DD",
  "calories": 100 (required for custom food),
  "protein": 10 (required for custom food),
  "carbs": 20 (required for custom food),
  "fat": 5 (required for custom food)
}
```

**Response** (201 Created):
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "profile_type": "baby",
  "food_id": "uuid",
  "food": {
    "id": "uuid",
    "name": "Alpukat",
    "category": "mpasi",
    "calories_per_100g": 160,
    "protein_per_100g": 2,
    "carbs_per_100g": 8.5,
    "fat_per_100g": 14.7
  },
  "serving_size": 150,
  "meal_time": "breakfast",
  "calories": 240,
  "protein": 3,
  "carbs": 12.75,
  "fat": 22.05,
  "entry_date": "2024-01-15T00:00:00Z",
  "created_at": "2024-01-15T10:30:00Z"
}
```

### GET /api/diary
Get diary entries for a specific profile and date with nutrition summary.

**Authentication**: Required (JWT Bearer token)

**Query Parameters**:
- `profile` (required): `baby` or `mother`
- `date` (required): Date in `YYYY-MM-DD` format

**Response** (200 OK):
```json
{
  "entries": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "profile_type": "baby",
      "food_id": "uuid",
      "food": {
        "id": "uuid",
        "name": "Alpukat",
        "category": "mpasi",
        "calories_per_100g": 160,
        "protein_per_100g": 2,
        "carbs_per_100g": 8.5,
        "fat_per_100g": 14.7
      },
      "serving_size": 150,
      "meal_time": "breakfast",
      "calories": 240,
      "protein": 3,
      "carbs": 12.75,
      "fat": 22.05,
      "entry_date": "2024-01-15T00:00:00Z",
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "nutrition_summary": {
    "calories": 240,
    "protein": 3,
    "carbs": 12.75,
    "fat": 22.05
  }
}
```

### DELETE /api/diary/:id
Delete a diary entry.

**Authentication**: Required (JWT Bearer token)

**Path Parameters**:
- `id`: UUID of the diary entry to delete

**Response** (200 OK):
```json
{
  "message": "Diary entry deleted successfully"
}
```

**Error Responses**:
- `404 Not Found`: Entry not found
- `403 Forbidden`: User doesn't own the entry

## Requirements Validation

### Requirement 4.1 ✓
**Food_Diary SHALL memungkinkan pengguna mencatat makanan untuk dua profil terpisah: profil Bayi dan profil Ibu.**

Implemented through `profile_type` field that accepts "baby" or "mother". Each profile maintains separate entries and summaries.

### Requirement 4.2 ✓
**WHEN pengguna menambahkan entri makanan, Food_Diary SHALL memungkinkan pengguna memilih makanan dari Food_Database atau memasukkan data makanan secara manual beserta kandungan nutrisinya.**

Implemented through two entry types:
1. Database entry: Uses `food_id` with automatic nutrition calculation
2. Manual entry: Uses `custom_food_name` with manual nutrition input

### Requirement 4.3 ✓
**WHEN entri makanan ditambahkan, Nutrition_Tracker SHALL menghitung dan memperbarui total Kalori, Protein, Karbohidrat, dan Lemak harian untuk profil yang bersangkutan.**

Implemented through `CalculateNutritionSummary` method that aggregates all entries for a specific profile and date.

### Requirement 4.5 ✓
**WHEN pengguna menghapus entri makanan, Nutrition_Tracker SHALL mengurangi total nutrisi harian sesuai dengan kandungan nutrisi entri yang dihapus.**

Implemented through DELETE endpoint. When an entry is deleted, subsequent GET requests automatically recalculate the summary without the deleted entry.

## Testing

### Manual Testing Results

All features have been tested and verified:

1. **Create Entry with Food ID** ✓
   - Food: Alpukat (160 cal/100g)
   - Serving: 150g
   - Calculated: 240 cal, 3g protein, 12.75g carbs, 22.05g fat

2. **Create Entry with Custom Food** ✓
   - Custom: Nasi Goreng Rumahan
   - Manual input: 450 cal, 15g protein, 60g carbs, 18g fat

3. **Dual Profile Support** ✓
   - Baby profile: 1 entry, 240 calories
   - Mother profile: 2 entries, 770 calories
   - Profiles are completely separate

4. **Nutrition Summary Calculation** ✓
   - Multiple entries correctly aggregated
   - Summary updates when entries are added/deleted

5. **Delete Entry** ✓
   - Entry successfully deleted
   - Summary recalculated without deleted entry
   - Unauthorized access prevented

### Unit Tests

Comprehensive unit tests are available in `service_test.go`:
- CreateEntry with food ID
- CreateEntry with custom food
- Invalid profile type validation
- Invalid meal time validation
- Food not found error handling
- GetEntries with filtering
- Dual profile separation
- DeleteEntry functionality
- Unauthorized delete prevention
- Nutrition calculation accuracy
- Date filtering

**Note**: Tests require CGO for SQLite. Run with: `go test ./internal/diary/...`

## Database Schema

```sql
CREATE TABLE diary_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    profile_type VARCHAR(10) NOT NULL, -- 'baby' or 'mother'
    food_id UUID REFERENCES foods(id),
    custom_food_name VARCHAR(255), -- for manual entries
    serving_size DECIMAL(6,2) NOT NULL, -- grams
    meal_time VARCHAR(20) NOT NULL, -- 'breakfast', 'lunch', 'dinner', 'snack'
    calories DECIMAL(6,2) NOT NULL,
    protein DECIMAL(5,2) NOT NULL,
    carbs DECIMAL(5,2) NOT NULL,
    fat DECIMAL(5,2) NOT NULL,
    entry_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Implementation Details

### Nutrition Calculation Formula

For database entries:
```
nutrition_value = (nutrition_per_100g * serving_size) / 100
```

Example:
- Food: 160 cal/100g
- Serving: 150g
- Result: (160 * 150) / 100 = 240 cal

### Profile Separation

Entries are filtered by:
1. `user_id` - Ensures user can only see their own entries
2. `profile_type` - Separates baby and mother entries
3. `entry_date` - Groups entries by date

### Authorization

All endpoints require JWT authentication. Users can only:
- Create entries for their own account
- View their own entries
- Delete their own entries

Attempting to delete another user's entry returns `403 Forbidden`.

## Error Handling

The module provides descriptive error messages:

- `400 Bad Request`: Invalid input (profile type, meal time, date format)
- `401 Unauthorized`: Missing or invalid JWT token
- `403 Forbidden`: Attempting to delete another user's entry
- `404 Not Found`: Entry or food not found
- `500 Internal Server Error`: Database or server errors

## Future Enhancements

Potential improvements for future versions:

1. **Batch Operations**: Add/delete multiple entries at once
2. **Date Range Queries**: Get entries for a week/month
3. **Nutrition Goals**: Compare actual vs target nutrition
4. **Entry Templates**: Save frequently used meals
5. **Photo Attachments**: Add food photos to entries
6. **Meal Copying**: Copy meals from previous days
7. **Export Data**: Export diary data to CSV/PDF
8. **Nutrition Trends**: Weekly/monthly nutrition analytics
