package configs

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	// Server
	ServerPort string

	// Database
	DBHost     string
	DBPort     string
	DBUser     string
	DBPassword string
	DBName     string
	DBSSLMode  string

	// JWT
	JWTSecret     string
	JWTExpiration string

	// External APIs
	GeminiAPIKey    string
	GoogleMapsAPIKey string
}

func LoadConfig() *Config {
	// Load .env file if it exists
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using environment variables")
	}

	return &Config{
		// Server
		ServerPort: getEnv("SERVER_PORT", "8080"),

		// Database
		DBHost:     getEnv("DB_HOST", "localhost"),
		DBPort:     getEnv("DB_PORT", "5432"),
		DBUser:     getEnv("DB_USER", "nutribunda_user"),
		DBPassword: getEnv("DB_PASSWORD", "nutribunda_pass"),
		DBName:     getEnv("DB_NAME", "nutribunda"),
		DBSSLMode:  getEnv("DB_SSLMODE", "disable"),

		// JWT
		JWTSecret:     getEnv("JWT_SECRET", "your-secret-key-change-this-in-production"),
		JWTExpiration: getEnv("JWT_EXPIRATION", "24h"),

		// External APIs
		GeminiAPIKey:    getEnv("GEMINI_API_KEY", ""),
		GoogleMapsAPIKey: getEnv("GOOGLE_MAPS_API_KEY", ""),
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
