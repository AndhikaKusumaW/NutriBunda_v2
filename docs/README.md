# NutriBunda Documentation

Dokumentasi lengkap untuk proyek NutriBunda - Aplikasi pemantau gizi MPASI dan diet pemulihan ibu pasca-melahirkan.

## 📋 Documentation Summaries

- [📊 Final Summary](./FINAL_SUMMARY.md) - Ringkasan lengkap reorganisasi dokumentasi
- [📁 Organization Summary](./ORGANIZATION_SUMMARY.md) - Detail struktur dan organisasi
- [🗑️ Cleanup Summary](./CLEANUP_SUMMARY.md) - Detail file yang dihapus

---

## 📚 Struktur Dokumentasi

### 1. [Getting Started](./getting-started/)
Panduan awal untuk memulai development
- [Project Overview](./getting-started/project-overview.md)
- [Database Setup](./getting-started/database-setup.md)
- [Backend Setup](./getting-started/backend-setup.md)
- [Flutter Setup](./getting-started/flutter-setup.md)

### 2. [Backend Documentation](./backend/)
Dokumentasi backend API (Golang)
- [API Testing Guide](./backend/api-testing-guide.md)
- [Testing Guide](./backend/testing-guide.md)
- **Modules:**
  - [Authentication](./backend/modules/auth.md)
  - [User Management](./backend/modules/user.md)
  - [Food Database](./backend/modules/food.md)
  - [Diary Service](./backend/modules/diary/)
  - [Recipe Service](./backend/modules/recipe/)

### 3. [Frontend Documentation](./frontend/)
Dokumentasi Flutter mobile app
- [Testing Guide](./frontend/testing-guide.md)
- [Accessibility Guide](./frontend/accessibility-guide.md)
- [Performance Monitoring](./frontend/performance-monitoring.md)
- **Features:**
  - [Authentication](./frontend/features/auth.md)
  - [Diary Integration](./frontend/features/diary-integration.md)
  - [Location-Based Services](./frontend/features/lbs.md)
  - [Chat Service](./frontend/features/chat-service.md)
  - [Sync Service](./frontend/features/sync-service.md)
- **Architecture:**
  - [Services](./frontend/architecture/services.md)
  - [Data Sources](./frontend/architecture/datasources.md)
  - [Providers](./frontend/architecture/providers/)

### 4. [Implementation Guides](./implementation/)
Panduan implementasi fitur-fitur spesifik
- [Gemini API Setup](./implementation/gemini-api-setup.md)
- [SQLite Implementation](./implementation/sqlite-implementation.md)
- [Sync Implementation](./implementation/sync-implementation.md)
- [Pedometer Implementation](./implementation/pedometer/)
- [Null Safety Fixes](./implementation/null-safety-fix.md)

### 5. [Task Summaries](./tasks/)
Ringkasan implementasi per task
- [Task 6: Authentication](./tasks/task-6/)
- [Task 7: Food Diary](./tasks/task-7/)
- [Task 8: Diet Plan](./tasks/task-8/)
- [Task 10: Pedometer & Accelerometer](./tasks/task-10/)
- [Task 11: Recipe Management](./tasks/task-11/)
- [Task 12: Location-Based Services](./tasks/task-12/)
- [Task 13: AI Chatbot](./tasks/task-13/)
- [Task 14: Quiz & Notifications](./tasks/task-14/)
- [Task 15: Navigation](./tasks/task-15/)
- [Task 19: UI/UX Accessibility](./tasks/task-19/)

### 6. [Test Documentation](./testing/)
Dokumentasi testing dan quality assurance
- [Backend Testing](./testing/backend/)
- [Frontend Testing](./testing/frontend/)
- [Property-Based Testing](./testing/property-based/)

## 🔍 Quick Links

### Backend
- [API Endpoints Overview](./backend/api-testing-guide.md)
- [Diary Sync API](./backend/modules/diary/sync-api.md)
- [Property Testing Guide](./backend/modules/diary/property-testing.md)

### Frontend
- [Gemini API Setup](./implementation/gemini-api-setup.md)
- [Pedometer UI Implementation](./implementation/pedometer/ui-implementation.md)
- [Chat Service README](./frontend/features/chat-service.md)

### Testing
- [Quiz & Notification Tests](./testing/frontend/quiz-notification-tests.md)
- [UI Navigation Tests](./testing/frontend/ui-navigation-tests.md)

## 📊 Project Status

**Progress**: 5/20 Tasks Complete (25%)

Lihat [Project Overview](./getting-started/project-overview.md) untuk detail lengkap status implementasi.

## 🤝 Contributing

Dokumentasi ini dikelola bersama oleh tim development. Untuk menambah atau mengupdate dokumentasi:

1. Tempatkan file di folder yang sesuai
2. Update README.md di folder terkait
3. Update index ini jika menambah kategori baru

## 📝 Notes

- Semua path relatif terhadap folder `docs/`
- Dokumentasi spec (requirements.md, design.md, tasks.md) tetap di `.kiro/specs/`
- Dokumentasi ini fokus pada implementation guides dan technical documentation

---

**Last Updated**: April 29, 2026
