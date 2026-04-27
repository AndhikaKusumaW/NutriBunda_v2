package main

import (
	"fmt"
	"log"
	"nutribunda-backend/configs"
	"nutribunda-backend/internal/database"
)

func main() {
	fmt.Println("Testing database connection...")
	fmt.Println("================================")

	// Load configuration
	config := configs.LoadConfig()

	fmt.Printf("Connecting to database at %s:%s...\n", config.DBHost, config.DBPort)

	// Initialize database connection
	db, err := database.InitDB(config)
	if err != nil {
		log.Fatalf("❌ Failed to connect to database: %v", err)
	}

	fmt.Println("✅ Database connection successful!")

	// Run migrations
	fmt.Println("\nRunning database migrations...")
	if err := database.RunMigrations(db); err != nil {
		log.Fatalf("❌ Failed to run migrations: %v", err)
	}

	fmt.Println("✅ Database migrations completed!")

	// Get database stats
	sqlDB, err := db.DB()
	if err != nil {
		log.Fatalf("❌ Failed to get database instance: %v", err)
	}

	stats := sqlDB.Stats()
	fmt.Println("\nDatabase Statistics:")
	fmt.Printf("  - Open Connections: %d\n", stats.OpenConnections)
	fmt.Printf("  - In Use: %d\n", stats.InUse)
	fmt.Printf("  - Idle: %d\n", stats.Idle)

	// Test query
	fmt.Println("\nTesting query execution...")
	var result int
	if err := db.Raw("SELECT 1").Scan(&result).Error; err != nil {
		log.Fatalf("❌ Failed to execute test query: %v", err)
	}

	fmt.Println("✅ Query execution successful!")

	// List tables
	fmt.Println("\nDatabase Tables:")
	var tables []string
	db.Raw("SELECT tablename FROM pg_tables WHERE schemaname = 'public'").Scan(&tables)
	for _, table := range tables {
		fmt.Printf("  - %s\n", table)
	}

	fmt.Println("\n================================")
	fmt.Println("✅ All database tests passed!")
}
