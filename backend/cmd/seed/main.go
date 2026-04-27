package main

import (
	"log"
	"nutribunda-backend/configs"
	"nutribunda-backend/internal/database"
)

func main() {
	log.Println("Starting database seeding...")

	// Load configuration
	config := configs.LoadConfig()

	// Initialize database connection
	db, err := database.InitDB(config)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	// Run migrations first
	if err := database.RunMigrations(db); err != nil {
		log.Fatalf("Failed to run migrations: %v", err)
	}

	// Seed database
	if err := database.SeedDatabase(db); err != nil {
		log.Fatalf("Failed to seed database: %v", err)
	}

	log.Println("Database seeding completed successfully!")
}
