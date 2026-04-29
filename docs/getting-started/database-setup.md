# NutriBunda Database Setup

PostgreSQL database untuk aplikasi NutriBunda menggunakan Docker.

## Prerequisites

- Docker Desktop installed
- Docker Compose installed

## Quick Start

### 1. Start PostgreSQL Container

```bash
docker-compose up -d
```

Container akan:
- Membuat database `nutribunda`
- Membuat user `nutribunda_user` dengan password `nutribunda_pass`
- Menjalankan initialization scripts dari `database/init/`
- Expose port 5432 ke host

### 2. Check Container Status

```bash
docker-compose ps
```

### 3. View Logs

```bash
docker-compose logs postgres
```

### 4. Stop Container

```bash
docker-compose down
```

### 5. Stop and Remove Data

```bash
docker-compose down -v
```

## Database Connection

**Connection String:**
```
postgresql://nutribunda_user:nutribunda_pass@localhost:5432/nutribunda?sslmode=disable
```

**Connection Details:**
- Host: `localhost`
- Port: `5432`
- Database: `nutribunda`
- User: `nutribunda_user`
- Password: `nutribunda_pass`

## Connect to Database

### Using psql (from host):

```bash
docker-compose exec postgres psql -U nutribunda_user -d nutribunda
```

### Using psql (from container):

```bash
docker exec -it nutribunda_postgres psql -U nutribunda_user -d nutribunda
```

### Using GUI Tools:

Configure your favorite PostgreSQL client (DBeaver, pgAdmin, etc.) with the connection details above.

## Initialization Scripts

Scripts di folder `database/init/` akan dijalankan secara otomatis saat container pertama kali dibuat, diurutkan berdasarkan nama file:

- `01_init.sql` - Setup UUID extension dan helper functions

Tambahkan script baru dengan prefix angka untuk menentukan urutan eksekusi.

## Data Persistence

Data PostgreSQL disimpan di Docker volume `postgres_data`. Data akan tetap ada meskipun container dihapus, kecuali volume juga dihapus dengan flag `-v`.

## Troubleshooting

### Port 5432 already in use

Jika port 5432 sudah digunakan oleh PostgreSQL lokal:

1. Stop PostgreSQL lokal, atau
2. Ubah port mapping di `docker-compose.yml`:
   ```yaml
   ports:
     - "5433:5432"  # Map ke port 5433 di host
   ```

### Container fails to start

Check logs:
```bash
docker-compose logs postgres
```

### Reset database

```bash
docker-compose down -v
docker-compose up -d
```

## Health Check

Container memiliki health check yang memeriksa koneksi database setiap 10 detik. Status dapat dilihat dengan:

```bash
docker-compose ps
```

Status `healthy` menandakan database siap digunakan.

---

**Next Step**: [Backend Setup](./backend-setup.md)
