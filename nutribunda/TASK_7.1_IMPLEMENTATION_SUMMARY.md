# Task 7.1 Implementation Summary: FoodDiaryProvider dan UI Screens

## Overview
Implementasi lengkap untuk Task 7.1 dari NutriBunda spec: "Buat FoodDiaryProvider dan UI screens" dengan dual profile support (baby and mother profiles), food search dengan autocomplete, dan UI untuk pencatatan makanan.

## Requirements Implemented
- **Requirement 4.1**: Food_Diary memungkinkan pencatatan makanan untuk dua profil terpisah (Bayi dan Ibu)
- **Requirement 4.2**: Pengguna dapat memilih makanan dari Food_Database atau input manual dengan kandungan nutrisi
- **Requirement 4.4**: Entri makanan dikategorikan ke dalam slot waktu (Makan Pagi, Makan Siang, Makan Malam, Makanan Selingan)

## Files Created

### 1. Data Models
- **`lib/data/models/food_model.dart`**
  - Model untuk makanan dari Food_Database
  - Menyimpan informasi nutrisi per 100g
  - Method `calculateNutrition()` untuk menghitung nutrisi berdasarkan serving size
  
- **`lib/data/models/nutrition_summary.dart`**
  - Model untuk ringkasan nutrisi harian
  - Method `add()` dan `remove()` untuk update nutrisi saat entry ditambah/dihapus
  - Implements Equatable untuk comparison
  
- **`lib/data/models/diary_entry.dart`**
  - Model untuk entri makanan harian
  - Support dual profile (baby/mother)
  - Support food dari database atau custom food manual
  - Meal time categorization (breakfast, lunch, dinner, snack)

### 2. Provider (State Management)
- **`lib/presentation/providers/food_diary_provider.dart`**
  - State management untuk Food Diary menggunakan ChangeNotifier
  - **Key Features**:
    - Dual profile support (baby/mother) dengan method `setSelectedProfile()`
    - Date selection dengan method `setSelectedDate()`
    - Load entries dengan `loadEntries()` - fetch dari API berdasarkan profile dan date
    - Add entry dengan `addEntry()` - support food dari database atau manual entry
    - Delete entry dengan `deleteEntry()` - update nutrition summary otomatis
    - Food search dengan `searchFoods()` - autocomplete dengan debouncing
    - Automatic nutrition calculation saat add/delete entry
    - Grouping entries by meal time dengan getter `entriesByMealTime`
  - **Error Handling**: Comprehensive error handling untuk network, validation, dan server errors

### 3. UI Screens
- **`lib/presentation/pages/diary/diary_screen.dart`**
  - Main screen untuk Food Diary
  - **Features**:
    - Tab bar untuk switch antara profil Bayi dan Ibu
    - Date picker dengan navigation (previous/next day)
    - Nutrition summary card menampilkan total kalori, protein, karbo, lemak
    - Entries grouped by meal time dengan icons
    - Pull-to-refresh untuk reload data
    - Empty state dengan helpful message
    - FAB untuk add new entry
    - Delete confirmation dialog
  
- **`lib/presentation/pages/diary/add_diary_entry_screen.dart`**
  - Screen untuk menambah entri makanan baru
  - **Features**:
    - Toggle antara food search dan manual entry
    - Food search dengan autocomplete (FoodSearchWidget)
    - Manual entry dengan input untuk nama dan nutrisi (kalori, protein, karbo, lemak)
    - Serving size input dengan validation
    - Meal time selector dengan ChoiceChips (visual dan user-friendly)
    - Date picker untuk entry date
    - Nutrition preview untuk food dari database (real-time calculation)
    - Form validation comprehensive
    - Loading state saat submit

### 4. Widgets
- **`lib/presentation/widgets/diary/food_search_widget.dart`**
  - Autocomplete search widget untuk mencari makanan
  - **Features**:
    - Debounced search (500ms) untuk mengurangi API calls
    - Loading indicator saat searching
    - Search results dalam scrollable list
    - Clear button untuk reset search
    - Empty state message
    - Category filter berdasarkan selected profile
  
- **`lib/presentation/widgets/diary/nutrition_summary_card.dart`**
  - Card widget untuk menampilkan ringkasan nutrisi harian
  - **Features**:
    - Gradient background dengan primary color
    - Icons untuk setiap nutrient
    - Display kalori, protein, karbohidrat, lemak
    - Responsive layout dengan Row/Column
  
- **`lib/presentation/widgets/diary/diary_entry_card.dart`**
  - Card widget untuk menampilkan single diary entry
  - **Features**:
    - Food icon dengan colored background
    - Display food name, serving size
    - Nutrition chips dengan color coding (kalori, protein, karbo, lemak)
    - Delete button dengan confirmation
    - Tap untuk show details (placeholder)

### 5. Dependency Injection
- **Updated `lib/injection_container.dart`**
  - Registered FoodDiaryProvider dengan GetIt
  - Factory registration untuk proper lifecycle management

### 6. Tests
- **`test/presentation/providers/food_diary_provider_test.dart`**
  - Unit tests untuk FoodDiaryProvider
  - Tests cover:
    - Initial state
    - Profile selection
    - Load entries
    - Entries grouping by meal time
    - Error handling

## API Integration

### Endpoints Used
1. **GET /api/diary**
   - Query params: `profile` (baby/mother), `date` (YYYY-MM-DD)
   - Returns: entries array and nutrition_summary object
   
2. **POST /api/diary**
   - Body: profile_type, food_id (optional), custom_food_name (optional), serving_size, meal_time, entry_date, nutrition values (for manual)
   - Returns: created diary entry
   
3. **DELETE /api/diary/:id**
   - Deletes diary entry by ID
   - Returns: success message
   
4. **GET /api/foods**
   - Query params: `search`, `category` (mpasi/ibu), `limit`
   - Returns: foods array with nutrition info

## Key Features Implemented

### 1. Dual Profile Support (Requirement 4.1)
- Tab-based navigation untuk switch antara profil Bayi dan Ibu
- Automatic reload entries saat profile berubah
- Profile-specific food search (MPASI untuk bayi, makanan ibu untuk mother)

### 2. Food Selection (Requirement 4.2)
- **Option 1**: Search dan pilih dari Food_Database
  - Autocomplete search dengan debouncing
  - Display nutrition info per 100g
  - Automatic nutrition calculation berdasarkan serving size
- **Option 2**: Manual entry
  - Input custom food name
  - Input manual untuk kalori, protein, karbohidrat, lemak
  - Form validation untuk semua fields

### 3. Meal Time Categorization (Requirement 4.4)
- 4 kategori waktu makan:
  - Makan Pagi (breakfast) - icon: wb_sunny
  - Makan Siang (lunch) - icon: wb_sunny_outlined
  - Makan Malam (dinner) - icon: nightlight
  - Makanan Selingan (snack) - icon: cookie
- Visual meal time selector dengan ChoiceChips
- Entries grouped by meal time di diary screen

### 4. Nutrition Tracking (Requirements 4.3, 4.5, 4.6)
- Automatic calculation saat add entry
- Automatic update saat delete entry
- Display ringkasan harian di nutrition summary card
- Real-time nutrition preview saat input serving size

## User Flow

### Add Entry Flow
1. User tap FAB di DiaryScreen
2. Navigate ke AddDiaryEntryScreen
3. User pilih antara:
   - **Food Search**: Search makanan → Select → Input serving size
   - **Manual Entry**: Input nama → Input nutrisi → Input serving size
4. User pilih meal time (breakfast/lunch/dinner/snack)
5. User pilih date (default: selected date dari diary screen)
6. User tap "Simpan"
7. Entry ditambahkan, nutrition summary updated
8. Navigate back ke DiaryScreen dengan success message

### View Entries Flow
1. User buka DiaryScreen
2. User pilih profile (Bayi/Ibu) via tabs
3. User pilih date via date picker
4. Entries loaded dan displayed grouped by meal time
5. Nutrition summary displayed di top
6. User dapat delete entry dengan tap delete icon → confirm

## Error Handling
- Network errors dengan user-friendly messages
- Validation errors dengan specific field messages
- Server errors dengan fallback messages
- Loading states untuk better UX
- Empty states dengan helpful guidance

## Testing
- Unit tests untuk FoodDiaryProvider
- Mock HTTP client untuk isolated testing
- Test coverage untuk:
  - State management
  - Profile selection
  - Entry loading
  - Meal time grouping
  - Error handling

## Dependencies Used
- **provider**: State management
- **dio**: HTTP client
- **intl**: Date formatting (Indonesian locale)
- **equatable**: Model comparison
- **get_it**: Dependency injection

## Next Steps (Future Tasks)
- Task 7.2: Implementasi nutrition summary visualization dengan charts
- Task 7.3: Property-based tests untuk nutrition calculations
- Offline support dengan SQLite local storage
- Data synchronization dengan conflict resolution

## Notes
- All Indonesian text untuk better UX
- Follows clean architecture pattern
- Comprehensive error handling
- Responsive UI dengan proper loading states
- Accessibility considerations (semantic widgets, proper labels)
- Code documentation dengan requirement references

## Testing Instructions
1. Run unit tests:
   ```bash
   cd nutribunda
   flutter test test/presentation/providers/food_diary_provider_test.dart
   ```

2. Generate mocks (if needed):
   ```bash
   flutter pub run build_runner build
   ```

3. Manual testing:
   - Ensure backend is running (localhost:8080)
   - Login dengan valid credentials
   - Navigate to Diary tab
   - Test add entry (both food search and manual)
   - Test delete entry
   - Test profile switching
   - Test date navigation

## Implementation Complete ✅
Task 7.1 telah selesai diimplementasikan dengan lengkap sesuai requirements 4.1, 4.2, dan 4.4.
