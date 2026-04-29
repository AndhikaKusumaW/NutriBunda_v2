# Food Diary Integration Guide

## Overview
Panduan untuk mengintegrasikan Food Diary screens ke dalam aplikasi NutriBunda.

## Prerequisites
- Backend API harus running di `http://localhost:8080`
- User harus sudah login (JWT token tersimpan)
- Database harus sudah di-seed dengan data makanan

## Integration Steps

### 1. Update Main App Navigation

Tambahkan DiaryScreen ke bottom navigation bar di `main.dart` atau main navigation widget:

```dart
import 'package:nutribunda/presentation/pages/diary/diary_screen.dart';
import 'package:nutribunda/presentation/providers/food_diary_provider.dart';
import 'package:nutribunda/injection_container.dart' as di;

// Di dalam build method
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
    ChangeNotifierProvider(create: (_) => di.sl<FoodDiaryProvider>()),
    // ... other providers
  ],
  child: MaterialApp(
    // ... app config
  ),
)
```

### 2. Add to Bottom Navigation

```dart
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.book),
      label: 'Diary',
    ),
    // ... other items
  ],
  onTap: (index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DiaryScreen()),
      );
    }
  },
)
```

### 3. Initialize Provider on App Start

Di `main.dart`, pastikan dependency injection sudah initialized:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await di.init();
  
  runApp(MyApp());
}
```

### 4. Configure Locale for Indonesian Date Format

Di `MaterialApp`, tambahkan locale configuration:

```dart
MaterialApp(
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: [
    const Locale('id', 'ID'), // Indonesian
    const Locale('en', 'US'), // English
  ],
  locale: const Locale('id', 'ID'),
  // ... other config
)
```

Tambahkan dependency di `pubspec.yaml` jika belum ada:
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
```

## API Endpoints Required

Pastikan backend menyediakan endpoints berikut:

1. **GET /api/diary**
   - Query: `profile` (baby/mother), `date` (YYYY-MM-DD)
   - Response: `{ entries: [], nutrition_summary: {} }`

2. **POST /api/diary**
   - Body: `{ profile_type, food_id?, custom_food_name?, serving_size, meal_time, entry_date, calories?, protein?, carbs?, fat? }`
   - Response: Created diary entry

3. **DELETE /api/diary/:id**
   - Response: `{ message: "success" }`

4. **GET /api/foods**
   - Query: `search`, `category` (mpasi/ibu), `limit`
   - Response: `{ foods: [], total: number }`

## Testing

### Manual Testing Checklist

1. **Profile Switching**
   - [ ] Switch dari Bayi ke Ibu
   - [ ] Switch dari Ibu ke Bayi
   - [ ] Verify entries reload correctly

2. **Date Navigation**
   - [ ] Navigate to previous day
   - [ ] Navigate to next day
   - [ ] Select date from date picker
   - [ ] Verify entries load for selected date

3. **Add Entry - Food Search**
   - [ ] Search makanan MPASI (untuk profil Bayi)
   - [ ] Search makanan ibu (untuk profil Ibu)
   - [ ] Select food from search results
   - [ ] Input serving size
   - [ ] Select meal time
   - [ ] Submit entry
   - [ ] Verify entry appears in list
   - [ ] Verify nutrition summary updates

4. **Add Entry - Manual**
   - [ ] Toggle to manual entry
   - [ ] Input custom food name
   - [ ] Input nutrition values
   - [ ] Input serving size
   - [ ] Select meal time
   - [ ] Submit entry
   - [ ] Verify entry appears in list

5. **Delete Entry**
   - [ ] Tap delete icon
   - [ ] Confirm deletion
   - [ ] Verify entry removed
   - [ ] Verify nutrition summary updates

6. **Error Handling**
   - [ ] Test with no internet connection
   - [ ] Test with invalid data
   - [ ] Test with expired token
   - [ ] Verify error messages display correctly

### Unit Tests

Run unit tests:
```bash
cd nutribunda
flutter test test/presentation/providers/food_diary_provider_test.dart
```

## Troubleshooting

### Issue: "No entries loading"
**Solution**: 
- Check backend is running
- Check JWT token is valid
- Check API endpoint URL in `api_constants.dart`
- Check network connectivity

### Issue: "Food search not working"
**Solution**:
- Verify `/api/foods` endpoint is working
- Check category parameter (mpasi/ibu)
- Verify database has food data

### Issue: "Nutrition summary not updating"
**Solution**:
- Check backend returns correct nutrition_summary in response
- Verify FoodDiaryProvider is properly registered in DI
- Check provider is being watched in UI

### Issue: "Date picker shows wrong locale"
**Solution**:
- Add `flutter_localizations` dependency
- Configure `localizationsDelegates` in MaterialApp
- Set `locale: Locale('id', 'ID')`

## Performance Considerations

1. **Debouncing**: Food search sudah menggunakan debouncing (500ms) untuk mengurangi API calls
2. **Pagination**: Untuk future improvement, tambahkan pagination untuk large entry lists
3. **Caching**: Consider caching food search results untuk mengurangi network calls
4. **Offline Support**: Implement SQLite local storage untuk offline functionality (Task 16)

## Next Steps

1. Implement Task 7.2: Nutrition summary visualization dengan charts
2. Implement Task 7.3: Property-based tests untuk nutrition calculations
3. Add offline support dengan SQLite (Task 16)
4. Add data synchronization (Task 16.2)

## Support

Jika ada masalah atau pertanyaan, refer to:
- `TASK_7.1_IMPLEMENTATION_SUMMARY.md` untuk detail implementasi
- Backend API documentation di `backend/README.md`
- Design document di `.kiro/specs/nutribunda/design.md`
