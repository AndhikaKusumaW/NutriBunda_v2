# Diary Module Documentation

Dokumentasi lengkap untuk Food Diary module.

## 📚 Contents

- [Sync API](./sync-api.md) - API endpoints untuk data synchronization
- [Sync Implementation](./sync-implementation.md) - Detail implementasi sync mechanism
- [Property Testing](./property-testing.md) - Panduan property-based testing
- [Property Test Summary](./property-test-summary.md) - Hasil property tests

## 🎯 Overview

Food Diary module menangani pencatatan makanan harian untuk bayi dan ibu dengan fitur:

- Dual profile support (bayi & ibu)
- CRUD operations untuk diary entries
- Nutrition summary calculation
- Offline-first dengan data synchronization
- Conflict resolution

## 🔧 Key Features

### 1. Diary Entry Management

```go
// Create diary entry
POST /api/diary
{
  "food_id": "uuid",
  "portion_size": 100.0,
  "meal_time": "breakfast",
  "profile_type": "baby",
  "date": "2026-04-29"
}

// Get diary entries
GET /api/diary?profile_type=baby&date=2026-04-29

// Delete diary entry
DELETE /api/diary/:id
```

### 2. Nutrition Summary

Automatic calculation of:
- Total calories
- Total protein
- Total carbohydrates
- Total fat

### 3. Data Synchronization

```go
// Sync diary data
POST /api/diary/sync
{
  "entries": [...],
  "last_sync_time": "2026-04-29T10:00:00Z"
}
```

Features:
- Timestamp-based conflict resolution
- Server wins on conflicts
- Batch sync support

## 📊 Database Schema

```sql
CREATE TABLE diary_entries (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  food_id UUID NOT NULL,
  portion_size FLOAT NOT NULL,
  meal_time VARCHAR(50),
  profile_type VARCHAR(10),
  date DATE NOT NULL,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (food_id) REFERENCES foods(id)
);
```

## 🧪 Testing

### Unit Tests

```bash
go test ./internal/diary
```

### Property-Based Tests

```bash
go test ./internal/diary -run Property
```

Properties tested:
- Nutrition tracking consistency
- Sync conflict resolution
- Data integrity

See: [Property Testing Guide](./property-testing.md)

## 📝 API Documentation

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/diary` | Get diary entries |
| POST | `/api/diary` | Create diary entry |
| DELETE | `/api/diary/:id` | Delete diary entry |
| POST | `/api/diary/sync` | Sync diary data |

### Query Parameters

- `profile_type` - Filter by baby/mother
- `date` - Filter by date (YYYY-MM-DD)
- `start_date` - Range start date
- `end_date` - Range end date

See: [Sync API Documentation](./sync-api.md)

## 🔗 Related Documentation

- [Backend Documentation](../../)
- [Sync Implementation](./sync-implementation.md)
- [Property Testing](./property-testing.md)

---

**Last Updated**: April 29, 2026
