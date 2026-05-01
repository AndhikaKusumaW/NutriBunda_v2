package database

import (
	"log"

	"gorm.io/gorm"
)

// SeedDatabase seeds the database with initial data
func SeedDatabase(db *gorm.DB) error {
	log.Println("Seeding database with initial data...")

	// Seed sample foods
	if err := seedFoods(db); err != nil {
		return err
	}

	// Seed sample recipes
	if err := seedRecipes(db); err != nil {
		return err
	}

	// Seed quiz questions
	if err := seedQuizQuestions(db); err != nil {
		return err
	}

	log.Println("Database seeding completed successfully")
	return nil
}

func seedFoods(db *gorm.DB) error {
	// Check if foods already exist
	var count int64
	db.Model(&Food{}).Count(&count)
	if count > 0 {
		log.Println("Foods already seeded, skipping...")
		return nil
	}

	foods := []Food{
    // === MPASI: Karbohidrat ===
    {Name: "Bubur Beras", Category: "mpasi",
        CaloriesPer100g: 130, ProteinPer100g: 2.7, CarbsPer100g: 28.2, FatPer100g: 0.3,
        EstimatedPricePer100g: floatPtr(1500)},  // ~Rp 15.000/kg
    {Name: "Bubur Beras Merah", Category: "mpasi",
        CaloriesPer100g: 111, ProteinPer100g: 2.6, CarbsPer100g: 23.5, FatPer100g: 0.9,
        EstimatedPricePer100g: floatPtr(2500)},  // ~Rp 25.000/kg
    {Name: "Kentang", Category: "mpasi",
        CaloriesPer100g: 77, ProteinPer100g: 2.0, CarbsPer100g: 17.5, FatPer100g: 0.1,
        EstimatedPricePer100g: floatPtr(2000)},
    {Name: "Ubi Jalar", Category: "mpasi",
        CaloriesPer100g: 86, ProteinPer100g: 1.6, CarbsPer100g: 20.1, FatPer100g: 0.1,
        EstimatedPricePer100g: floatPtr(1500)},
    {Name: "Ubi Ungu", Category: "mpasi",
        CaloriesPer100g: 90, ProteinPer100g: 1.8, CarbsPer100g: 20.7, FatPer100g: 0.2,
        EstimatedPricePer100g: floatPtr(2000)},
    {Name: "Oatmeal Bayi", Category: "mpasi",
        CaloriesPer100g: 68, ProteinPer100g: 2.4, CarbsPer100g: 12.0, FatPer100g: 1.4,
        EstimatedPricePer100g: floatPtr(5000)},
    {Name: "Pasta", Category: "mpasi",
        CaloriesPer100g: 131, ProteinPer100g: 5.0, CarbsPer100g: 25.0, FatPer100g: 1.1,
        EstimatedPricePer100g: floatPtr(3500)},
    {Name: "Roti Gandum", Category: "mpasi",
        CaloriesPer100g: 247, ProteinPer100g: 13.0, CarbsPer100g: 41.0, FatPer100g: 3.4,
        EstimatedPricePer100g: floatPtr(4000)},

    // === MPASI: Buah ===
    {Name: "Pisang", Category: "mpasi",
        CaloriesPer100g: 89, ProteinPer100g: 1.1, CarbsPer100g: 22.8, FatPer100g: 0.3,
        EstimatedPricePer100g: floatPtr(2000)},
    {Name: "Alpukat", Category: "mpasi",
        CaloriesPer100g: 160, ProteinPer100g: 2.0, CarbsPer100g: 8.5, FatPer100g: 14.7,
        EstimatedPricePer100g: floatPtr(3500)},
    {Name: "Apel", Category: "mpasi",
        CaloriesPer100g: 52, ProteinPer100g: 0.3, CarbsPer100g: 13.8, FatPer100g: 0.2,
        EstimatedPricePer100g: floatPtr(4500)},
    {Name: "Pir", Category: "mpasi",
        CaloriesPer100g: 57, ProteinPer100g: 0.4, CarbsPer100g: 15.2, FatPer100g: 0.1,
        EstimatedPricePer100g: floatPtr(5000)},
    {Name: "Pepaya", Category: "mpasi",
        CaloriesPer100g: 43, ProteinPer100g: 0.5, CarbsPer100g: 10.8, FatPer100g: 0.3,
        EstimatedPricePer100g: floatPtr(1500)},
    {Name: "Mangga", Category: "mpasi",
        CaloriesPer100g: 60, ProteinPer100g: 0.8, CarbsPer100g: 15.0, FatPer100g: 0.4,
        EstimatedPricePer100g: floatPtr(3000)},
    {Name: "Jeruk", Category: "mpasi",
        CaloriesPer100g: 47, ProteinPer100g: 0.9, CarbsPer100g: 11.8, FatPer100g: 0.1,
        EstimatedPricePer100g: floatPtr(3000)},
    {Name: "Melon", Category: "mpasi",
        CaloriesPer100g: 34, ProteinPer100g: 0.8, CarbsPer100g: 8.2, FatPer100g: 0.2,
        EstimatedPricePer100g: floatPtr(2500)},
    {Name: "Semangka", Category: "mpasi",
        CaloriesPer100g: 30, ProteinPer100g: 0.6, CarbsPer100g: 7.6, FatPer100g: 0.2,
        EstimatedPricePer100g: floatPtr(1500)},
    {Name: "Blueberry", Category: "mpasi",
        CaloriesPer100g: 57, ProteinPer100g: 0.7, CarbsPer100g: 14.5, FatPer100g: 0.3,
        EstimatedPricePer100g: floatPtr(15000)}, // impor
    {Name: "Strawberry", Category: "mpasi",
        CaloriesPer100g: 32, ProteinPer100g: 0.7, CarbsPer100g: 7.7, FatPer100g: 0.3,
        EstimatedPricePer100g: floatPtr(8000)},

    // === MPASI: Sayuran ===
    {Name: "Wortel", Category: "mpasi",
        CaloriesPer100g: 41, ProteinPer100g: 0.9, CarbsPer100g: 9.6, FatPer100g: 0.2,
        EstimatedPricePer100g: floatPtr(1500)},
    {Name: "Brokoli", Category: "mpasi",
        CaloriesPer100g: 34, ProteinPer100g: 2.8, CarbsPer100g: 6.6, FatPer100g: 0.4,
        EstimatedPricePer100g: floatPtr(4000)},
    {Name: "Labu", Category: "mpasi",
        CaloriesPer100g: 26, ProteinPer100g: 1.0, CarbsPer100g: 6.5, FatPer100g: 0.1,
        EstimatedPricePer100g: floatPtr(1500)},
    {Name: "Bayam", Category: "mpasi",
        CaloriesPer100g: 23, ProteinPer100g: 2.9, CarbsPer100g: 3.6, FatPer100g: 0.4,
        EstimatedPricePer100g: floatPtr(2000)},
    {Name: "Kacang Polong", Category: "mpasi",
        CaloriesPer100g: 81, ProteinPer100g: 5.4, CarbsPer100g: 14.5, FatPer100g: 0.4,
        EstimatedPricePer100g: floatPtr(3000)},
    {Name: "Jagung Manis", Category: "mpasi",
        CaloriesPer100g: 86, ProteinPer100g: 3.3, CarbsPer100g: 18.7, FatPer100g: 1.4,
        EstimatedPricePer100g: floatPtr(2000)},
    {Name: "Tomat", Category: "mpasi",
        CaloriesPer100g: 18, ProteinPer100g: 0.9, CarbsPer100g: 3.9, FatPer100g: 0.2,
        EstimatedPricePer100g: floatPtr(2000)},
    {Name: "Timun", Category: "mpasi",
        CaloriesPer100g: 15, ProteinPer100g: 0.7, CarbsPer100g: 3.6, FatPer100g: 0.1,
        EstimatedPricePer100g: floatPtr(1500)},
    {Name: "Kembang Kol", Category: "mpasi",
        CaloriesPer100g: 25, ProteinPer100g: 1.9, CarbsPer100g: 5.0, FatPer100g: 0.3,
        EstimatedPricePer100g: floatPtr(4000)},
    {Name: "Zucchini", Category: "mpasi",
        CaloriesPer100g: 17, ProteinPer100g: 1.2, CarbsPer100g: 3.1, FatPer100g: 0.3,
        EstimatedPricePer100g: floatPtr(5000)},

    // === MPASI: Protein ===
    {Name: "Ayam Giling", Category: "mpasi",
        CaloriesPer100g: 165, ProteinPer100g: 31.0, CarbsPer100g: 0.0, FatPer100g: 3.6,
        EstimatedPricePer100g: floatPtr(4000)},
    {Name: "Daging Sapi Giling", Category: "mpasi",
        CaloriesPer100g: 250, ProteinPer100g: 26.0, CarbsPer100g: 0.0, FatPer100g: 15.0,
        EstimatedPricePer100g: floatPtr(12000)},
    {Name: "Ikan Salmon", Category: "mpasi",
        CaloriesPer100g: 208, ProteinPer100g: 20.0, CarbsPer100g: 0.0, FatPer100g: 13.0,
        EstimatedPricePer100g: floatPtr(20000)},
    {Name: "Ikan Kakap", Category: "mpasi",
        CaloriesPer100g: 100, ProteinPer100g: 20.5, CarbsPer100g: 0.0, FatPer100g: 1.3,
        EstimatedPricePer100g: floatPtr(5000)},
    {Name: "Ikan Tuna", Category: "mpasi",
        CaloriesPer100g: 144, ProteinPer100g: 23.3, CarbsPer100g: 0.0, FatPer100g: 4.9,
        EstimatedPricePer100g: floatPtr(6000)},
    {Name: "Telur", Category: "mpasi",
        CaloriesPer100g: 155, ProteinPer100g: 13.0, CarbsPer100g: 1.1, FatPer100g: 11.0,
        EstimatedPricePer100g: floatPtr(2800)},
    {Name: "Tahu", Category: "mpasi",
        CaloriesPer100g: 76, ProteinPer100g: 8.0, CarbsPer100g: 1.9, FatPer100g: 4.8,
        EstimatedPricePer100g: floatPtr(1500)},
    {Name: "Tempe", Category: "mpasi",
        CaloriesPer100g: 193, ProteinPer100g: 20.8, CarbsPer100g: 7.6, FatPer100g: 10.8,
        EstimatedPricePer100g: floatPtr(1500)},
    {Name: "Keju", Category: "mpasi",
        CaloriesPer100g: 402, ProteinPer100g: 25.0, CarbsPer100g: 1.3, FatPer100g: 33.0,
        EstimatedPricePer100g: floatPtr(10000)},
    {Name: "Yogurt Plain", Category: "mpasi",
        CaloriesPer100g: 59, ProteinPer100g: 10.0, CarbsPer100g: 3.6, FatPer100g: 0.4,
        EstimatedPricePer100g: floatPtr(5000)},

    // === IBU: Karbohidrat ===
    {Name: "Nasi Putih", Category: "ibu",
        CaloriesPer100g: 130, ProteinPer100g: 2.7, CarbsPer100g: 28.2, FatPer100g: 0.3,
        EstimatedPricePer100g: floatPtr(1500)},
    {Name: "Nasi Merah", Category: "ibu",
        CaloriesPer100g: 111, ProteinPer100g: 2.6, CarbsPer100g: 23.5, FatPer100g: 0.9,
        EstimatedPricePer100g: floatPtr(2500)},
    {Name: "Nasi Coklat", Category: "ibu",
        CaloriesPer100g: 112, ProteinPer100g: 2.3, CarbsPer100g: 23.5, FatPer100g: 0.8,
        EstimatedPricePer100g: floatPtr(3000)},
    {Name: "Quinoa", Category: "ibu",
        CaloriesPer100g: 120, ProteinPer100g: 4.4, CarbsPer100g: 21.3, FatPer100g: 1.9,
        EstimatedPricePer100g: floatPtr(12000)},
    {Name: "Oatmeal", Category: "ibu",
        CaloriesPer100g: 389, ProteinPer100g: 16.9, CarbsPer100g: 66.3, FatPer100g: 6.9,
        EstimatedPricePer100g: floatPtr(4000)},
    {Name: "Roti Gandum Utuh", Category: "ibu",
        CaloriesPer100g: 247, ProteinPer100g: 13.0, CarbsPer100g: 41.0, FatPer100g: 3.4,
        EstimatedPricePer100g: floatPtr(4000)},
    {Name: "Kentang Rebus", Category: "ibu",
        CaloriesPer100g: 77, ProteinPer100g: 2.0, CarbsPer100g: 17.5, FatPer100g: 0.1,
        EstimatedPricePer100g: floatPtr(2000)},
    {Name: "Ubi Jalar Panggang", Category: "ibu",
        CaloriesPer100g: 90, ProteinPer100g: 2.0, CarbsPer100g: 20.7, FatPer100g: 0.2,
        EstimatedPricePer100g: floatPtr(1500)},

    // === IBU: Protein ===
    {Name: "Dada Ayam", Category: "ibu",
        CaloriesPer100g: 165, ProteinPer100g: 31.0, CarbsPer100g: 0.0, FatPer100g: 3.6,
        EstimatedPricePer100g: floatPtr(4500)},
    {Name: "Paha Ayam Tanpa Kulit", Category: "ibu",
        CaloriesPer100g: 209, ProteinPer100g: 26.0, CarbsPer100g: 0.0, FatPer100g: 10.9,
        EstimatedPricePer100g: floatPtr(3500)},
    {Name: "Daging Sapi Tanpa Lemak", Category: "ibu",
        CaloriesPer100g: 250, ProteinPer100g: 26.0, CarbsPer100g: 0.0, FatPer100g: 15.0,
        EstimatedPricePer100g: floatPtr(12000)},
    {Name: "Ikan Salmon Panggang", Category: "ibu",
        CaloriesPer100g: 208, ProteinPer100g: 20.0, CarbsPer100g: 0.0, FatPer100g: 13.0,
        EstimatedPricePer100g: floatPtr(20000)},
    {Name: "Ikan Tuna", Category: "ibu",
        CaloriesPer100g: 144, ProteinPer100g: 23.3, CarbsPer100g: 0.0, FatPer100g: 4.9,
        EstimatedPricePer100g: floatPtr(6000)},
    {Name: "Ikan Kembung", Category: "ibu",
        CaloriesPer100g: 205, ProteinPer100g: 19.0, CarbsPer100g: 0.0, FatPer100g: 13.9,
        EstimatedPricePer100g: floatPtr(3500)},
    {Name: "Udang", Category: "ibu",
        CaloriesPer100g: 99, ProteinPer100g: 24.0, CarbsPer100g: 0.2, FatPer100g: 0.3,
        EstimatedPricePer100g: floatPtr(7000)},
    {Name: "Telur Ayam", Category: "ibu",
        CaloriesPer100g: 155, ProteinPer100g: 13.0, CarbsPer100g: 1.1, FatPer100g: 11.0,
        EstimatedPricePer100g: floatPtr(2800)},
    {Name: "Tempe Goreng", Category: "ibu",
        CaloriesPer100g: 193, ProteinPer100g: 20.8, CarbsPer100g: 7.6, FatPer100g: 10.8,
        EstimatedPricePer100g: floatPtr(1500)},
    {Name: "Tahu Putih", Category: "ibu",
        CaloriesPer100g: 76, ProteinPer100g: 8.0, CarbsPer100g: 1.9, FatPer100g: 4.8,
        EstimatedPricePer100g: floatPtr(1500)},

    // === IBU: Sayuran ===
    {Name: "Bayam Hijau", Category: "ibu",
        CaloriesPer100g: 23, ProteinPer100g: 2.9, CarbsPer100g: 3.6, FatPer100g: 0.4,
        EstimatedPricePer100g: floatPtr(2000)},
    {Name: "Kangkung", Category: "ibu",
        CaloriesPer100g: 19, ProteinPer100g: 2.6, CarbsPer100g: 3.1, FatPer100g: 0.3,
        EstimatedPricePer100g: floatPtr(1500)},
    {Name: "Brokoli Hijau", Category: "ibu",
        CaloriesPer100g: 34, ProteinPer100g: 2.8, CarbsPer100g: 6.6, FatPer100g: 0.4,
        EstimatedPricePer100g: floatPtr(4000)},
    {Name: "Wortel Mentah", Category: "ibu",
        CaloriesPer100g: 41, ProteinPer100g: 0.9, CarbsPer100g: 9.6, FatPer100g: 0.2,
        EstimatedPricePer100g: floatPtr(1500)},
    {Name: "Tomat Merah", Category: "ibu",
        CaloriesPer100g: 18, ProteinPer100g: 0.9, CarbsPer100g: 3.9, FatPer100g: 0.2,
        EstimatedPricePer100g: floatPtr(2000)},
    {Name: "Paprika Merah", Category: "ibu",
        CaloriesPer100g: 31, ProteinPer100g: 1.0, CarbsPer100g: 6.0, FatPer100g: 0.3,
        EstimatedPricePer100g: floatPtr(6000)},
    {Name: "Kacang Panjang", Category: "ibu",
        CaloriesPer100g: 31, ProteinPer100g: 1.8, CarbsPer100g: 7.1, FatPer100g: 0.1,
        EstimatedPricePer100g: floatPtr(2000)},
    {Name: "Terong", Category: "ibu",
        CaloriesPer100g: 25, ProteinPer100g: 1.0, CarbsPer100g: 5.9, FatPer100g: 0.2,
        EstimatedPricePer100g: floatPtr(2000)},

    // === IBU: Buah ===
    {Name: "Pisang Ambon", Category: "ibu",
        CaloriesPer100g: 89, ProteinPer100g: 1.1, CarbsPer100g: 22.8, FatPer100g: 0.3,
        EstimatedPricePer100g: floatPtr(2000)},
    {Name: "Apel Merah", Category: "ibu",
        CaloriesPer100g: 52, ProteinPer100g: 0.3, CarbsPer100g: 13.8, FatPer100g: 0.2,
        EstimatedPricePer100g: floatPtr(4500)},
    {Name: "Jeruk Manis", Category: "ibu",
        CaloriesPer100g: 47, ProteinPer100g: 0.9, CarbsPer100g: 11.8, FatPer100g: 0.1,
        EstimatedPricePer100g: floatPtr(3000)},
    {Name: "Pepaya Matang", Category: "ibu",
        CaloriesPer100g: 43, ProteinPer100g: 0.5, CarbsPer100g: 10.8, FatPer100g: 0.3,
        EstimatedPricePer100g: floatPtr(1500)},
    {Name: "Mangga Harum Manis", Category: "ibu",
        CaloriesPer100g: 60, ProteinPer100g: 0.8, CarbsPer100g: 15.0, FatPer100g: 0.4,
        EstimatedPricePer100g: floatPtr(3000)},
}

	result := db.Create(&foods)
	if result.Error != nil {
		return result.Error
	}

	log.Printf("Seeded %d foods", len(foods))
	return nil
}

func seedRecipes(db *gorm.DB) error {
	// Check if recipes already exist
	var count int64
	db.Model(&Recipe{}).Count(&count)
	if count > 0 {
		log.Println("Recipes already seeded, skipping...")
		return nil
	}

	recipes := []Recipe{
		{
			Name:          "Bubur Ayam Wortel",
			Ingredients:   `["50g beras", "100g ayam giling", "50g wortel", "500ml air", "1 sdm minyak zaitun"]`,
			Instructions:  "1. Cuci beras dan masak dengan air hingga menjadi bubur\n2. Tumis ayam giling hingga matang\n3. Kukus wortel hingga lunak, lalu haluskan\n4. Campurkan semua bahan dan aduk rata\n5. Sajikan hangat",
			NutritionInfo: `{"calories": 180, "protein": 12, "carbs": 25, "fat": 4}`,
			Category:      "mpasi",
		},
		{
			Name:          "Pure Alpukat Pisang",
			Ingredients:   `["1/2 buah alpukat", "1 buah pisang", "50ml ASI/susu formula"]`,
			Instructions:  "1. Kerok daging alpukat\n2. Haluskan pisang\n3. Campurkan alpukat dan pisang\n4. Tambahkan ASI/susu formula\n5. Aduk hingga rata dan sajikan",
			NutritionInfo: `{"calories": 150, "protein": 2, "carbs": 20, "fat": 8}`,
			Category:      "mpasi",
		},
		{
			Name:          "Bubur Kentang Brokoli",
			Ingredients:   `["100g kentang", "50g brokoli", "1 butir telur", "200ml air"]`,
			Instructions:  "1. Kukus kentang dan brokoli hingga lunak\n2. Rebus telur hingga matang\n3. Haluskan semua bahan dengan air\n4. Aduk hingga tekstur sesuai\n5. Sajikan hangat",
			NutritionInfo: `{"calories": 160, "protein": 8, "carbs": 22, "fat": 5}`,
			Category:      "mpasi",
		},
		{
			Name:          "Bubur Salmon Bayam",
			Ingredients:   `["50g beras merah", "80g ikan salmon", "30g bayam", "400ml air", "1 sdt minyak zaitun"]`,
			Instructions:  "1. Masak beras merah dengan air hingga menjadi bubur\n2. Kukus salmon hingga matang, lalu suwir halus\n3. Rebus bayam sebentar, lalu cincang halus\n4. Campurkan semua bahan\n5. Tambahkan minyak zaitun dan sajikan",
			NutritionInfo: `{"calories": 195, "protein": 15, "carbs": 20, "fat": 7}`,
			Category:      "mpasi",
		},
		{
			Name:          "Pure Ubi Ungu Apel",
			Ingredients:   `["100g ubi ungu", "1 buah apel", "100ml air"]`,
			Instructions:  "1. Kukus ubi ungu hingga lunak\n2. Kupas dan kukus apel hingga lunak\n3. Haluskan ubi dan apel bersama air\n4. Aduk hingga tekstur halus\n5. Sajikan hangat atau dingin",
			NutritionInfo: `{"calories": 120, "protein": 1.5, "carbs": 28, "fat": 0.2}`,
			Category:      "mpasi",
		},
		{
			Name:          "Bubur Daging Sapi Labu",
			Ingredients:   `["50g beras", "80g daging sapi giling", "70g labu kuning", "400ml air", "1 siung bawang putih"]`,
			Instructions:  "1. Masak beras dengan air hingga menjadi bubur\n2. Tumis bawang putih, masukkan daging sapi hingga matang\n3. Kukus labu hingga lunak, lalu haluskan\n4. Campurkan semua bahan\n5. Sajikan hangat",
			NutritionInfo: `{"calories": 210, "protein": 18, "carbs": 22, "fat": 6}`,
			Category:      "mpasi",
		},
		{
			Name:          "Oatmeal Pisang Blueberry",
			Ingredients:   `["30g oatmeal bayi", "1 buah pisang", "20g blueberry", "150ml ASI/susu formula"]`,
			Instructions:  "1. Masak oatmeal dengan ASI/susu hingga lembut\n2. Haluskan pisang\n3. Cuci bersih blueberry dan haluskan\n4. Campurkan semua bahan\n5. Sajikan hangat",
			NutritionInfo: `{"calories": 165, "protein": 4, "carbs": 32, "fat": 2.5}`,
			Category:      "mpasi",
		},
		{
			Name:          "Bubur Tuna Jagung",
			Ingredients:   `["50g beras", "70g ikan tuna", "50g jagung manis", "400ml air", "1 lembar daun salam"]`,
			Instructions:  "1. Masak beras dengan air dan daun salam hingga menjadi bubur\n2. Kukus ikan tuna hingga matang, lalu suwir halus\n3. Rebus jagung hingga lunak, lalu pipil\n4. Campurkan semua bahan\n5. Buang daun salam dan sajikan",
			NutritionInfo: `{"calories": 185, "protein": 16, "carbs": 24, "fat": 3}`,
			Category:      "mpasi",
		},
		{
			Name:          "Pure Tempe Wortel",
			Ingredients:   `["80g tempe", "60g wortel", "1 butir telur", "200ml air"]`,
			Instructions:  "1. Kukus tempe hingga matang\n2. Kukus wortel hingga lunak\n3. Rebus telur hingga matang\n4. Haluskan semua bahan dengan air\n5. Sajikan hangat",
			NutritionInfo: `{"calories": 190, "protein": 16, "carbs": 12, "fat": 10}`,
			Category:      "mpasi",
		},
		{
			Name:          "Bubur Ayam Kacang Polong",
			Ingredients:   `["50g beras", "80g ayam giling", "50g kacang polong", "400ml air", "1 sdt minyak zaitun"]`,
			Instructions:  "1. Masak beras dengan air hingga menjadi bubur\n2. Tumis ayam giling hingga matang\n3. Rebus kacang polong hingga lunak\n4. Campurkan semua bahan\n5. Tambahkan minyak zaitun dan sajikan",
			NutritionInfo: `{"calories": 195, "protein": 18, "carbs": 23, "fat": 4.5}`,
			Category:      "mpasi",
		},
		{
			Name:          "Pure Pepaya Yogurt",
			Ingredients:   `["100g pepaya", "50g yogurt plain", "1 buah pisang"]`,
			Instructions:  "1. Potong pepaya dan haluskan\n2. Haluskan pisang\n3. Campurkan pepaya dan pisang\n4. Tambahkan yogurt dan aduk rata\n5. Sajikan dingin",
			NutritionInfo: `{"calories": 110, "protein": 5, "carbs": 22, "fat": 1}`,
			Category:      "mpasi",
		},
		{
			Name:          "Bubur Ikan Kakap Tomat",
			Ingredients:   `["50g beras", "80g ikan kakap", "1 buah tomat", "400ml air", "1 lembar daun jeruk"]`,
			Instructions:  "1. Masak beras dengan air dan daun jeruk hingga menjadi bubur\n2. Kukus ikan kakap hingga matang, lalu suwir halus\n3. Rebus tomat, kupas kulitnya, lalu haluskan\n4. Campurkan semua bahan\n5. Buang daun jeruk dan sajikan",
			NutritionInfo: `{"calories": 170, "protein": 17, "carbs": 22, "fat": 2}`,
			Category:      "mpasi",
		},
		{
			Name:          "Pasta Keju Brokoli",
			Ingredients:   `["50g pasta", "30g keju parut", "50g brokoli", "200ml air", "1 sdm mentega"]`,
			Instructions:  "1. Rebus pasta hingga sangat lunak\n2. Kukus brokoli hingga lunak, lalu cincang halus\n3. Lelehkan mentega, masukkan pasta dan brokoli\n4. Tambahkan keju parut dan aduk rata\n5. Sajikan hangat",
			NutritionInfo: `{"calories": 220, "protein": 12, "carbs": 28, "fat": 8}`,
			Category:      "mpasi",
		},
		{
			Name:          "Bubur Tahu Bayam",
			Ingredients:   `["50g beras", "100g tahu", "40g bayam", "400ml air", "1 siung bawang putih"]`,
			Instructions:  "1. Masak beras dengan air hingga menjadi bubur\n2. Kukus tahu, lalu haluskan\n3. Rebus bayam sebentar, lalu cincang halus\n4. Tumis bawang putih, campurkan semua bahan\n5. Sajikan hangat",
			NutritionInfo: `{"calories": 175, "protein": 10, "carbs": 26, "fat": 4}`,
			Category:      "mpasi",
		},
		{
			Name:          "Pure Mangga Alpukat",
			Ingredients:   `["100g mangga", "1/2 buah alpukat", "50ml ASI/susu formula"]`,
			Instructions:  "1. Potong mangga dan haluskan\n2. Kerok daging alpukat\n3. Campurkan mangga dan alpukat\n4. Tambahkan ASI/susu formula\n5. Aduk rata dan sajikan",
			NutritionInfo: `{"calories": 140, "protein": 1.5, "carbs": 18, "fat": 7}`,
			Category:      "mpasi",
		},
	}

	result := db.Create(&recipes)
	if result.Error != nil {
		return result.Error
	}

	log.Printf("Seeded %d recipes", len(recipes))
	return nil
}

func seedQuizQuestions(db *gorm.DB) error {
	// Check if quiz questions already exist
	var count int64
	db.Model(&QuizQuestion{}).Count(&count)
	if count > 0 {
		log.Println("Quiz questions already seeded, skipping...")
		return nil
	}

	questions := []QuizQuestion{
		{
			Question:      "Berapa kandungan protein dalam 100g dada ayam?",
			OptionA:       "20g",
			OptionB:       "31g",
			OptionC:       "15g",
			OptionD:       "40g",
			CorrectAnswer: "B",
			Explanation:   stringPtr("Dada ayam mengandung sekitar 31g protein per 100g, menjadikannya sumber protein yang sangat baik."),
		},
		{
			Question:      "Makanan mana yang paling tinggi lemak sehat?",
			OptionA:       "Nasi putih",
			OptionB:       "Wortel",
			OptionC:       "Alpukat",
			OptionD:       "Bayam",
			CorrectAnswer: "C",
			Explanation:   stringPtr("Alpukat kaya akan lemak sehat (14.7g per 100g) yang baik untuk perkembangan otak bayi."),
		},
		{
			Question:      "Pada usia berapa bayi mulai diberikan MPASI?",
			OptionA:       "4 bulan",
			OptionB:       "6 bulan",
			OptionC:       "8 bulan",
			OptionD:       "12 bulan",
			CorrectAnswer: "B",
			Explanation:   stringPtr("WHO merekomendasikan pemberian MPASI dimulai pada usia 6 bulan."),
		},
		{
			Question:      "Berapa kalori dalam 100g pisang?",
			OptionA:       "50 kkal",
			OptionB:       "89 kkal",
			OptionC:       "120 kkal",
			OptionD:       "150 kkal",
			CorrectAnswer: "B",
			Explanation:   stringPtr("Pisang mengandung sekitar 89 kalori per 100g dan merupakan sumber energi yang baik untuk bayi."),
		},
		{
			Question:      "Makanan mana yang paling tinggi karbohidrat?",
			OptionA:       "Telur",
			OptionB:       "Ayam",
			OptionC:       "Nasi putih",
			OptionD:       "Brokoli",
			CorrectAnswer: "C",
			Explanation:   stringPtr("Nasi putih mengandung 28.2g karbohidrat per 100g, menjadikannya sumber energi utama."),
		},
	}

	result := db.Create(&questions)
	if result.Error != nil {
		return result.Error
	}

	log.Printf("Seeded %d quiz questions", len(questions))
	return nil
}

func floatPtr(f float64) *float64 {
	return &f
}

func stringPtr(s string) *string {
	return &s
}
