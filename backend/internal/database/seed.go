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
		// MPASI Foods
		{Name: "Bubur Beras", Category: "mpasi", CaloriesPer100g: 130, ProteinPer100g: 2.7, CarbsPer100g: 28.2, FatPer100g: 0.3},
		{Name: "Pisang", Category: "mpasi", CaloriesPer100g: 89, ProteinPer100g: 1.1, CarbsPer100g: 22.8, FatPer100g: 0.3},
		{Name: "Alpukat", Category: "mpasi", CaloriesPer100g: 160, ProteinPer100g: 2.0, CarbsPer100g: 8.5, FatPer100g: 14.7},
		{Name: "Wortel", Category: "mpasi", CaloriesPer100g: 41, ProteinPer100g: 0.9, CarbsPer100g: 9.6, FatPer100g: 0.2},
		{Name: "Kentang", Category: "mpasi", CaloriesPer100g: 77, ProteinPer100g: 2.0, CarbsPer100g: 17.5, FatPer100g: 0.1},
		{Name: "Ayam Giling", Category: "mpasi", CaloriesPer100g: 165, ProteinPer100g: 31.0, CarbsPer100g: 0.0, FatPer100g: 3.6},
		{Name: "Telur", Category: "mpasi", CaloriesPer100g: 155, ProteinPer100g: 13.0, CarbsPer100g: 1.1, FatPer100g: 11.0},
		{Name: "Brokoli", Category: "mpasi", CaloriesPer100g: 34, ProteinPer100g: 2.8, CarbsPer100g: 6.6, FatPer100g: 0.4},
		{Name: "Labu", Category: "mpasi", CaloriesPer100g: 26, ProteinPer100g: 1.0, CarbsPer100g: 6.5, FatPer100g: 0.1},
		{Name: "Ubi Jalar", Category: "mpasi", CaloriesPer100g: 86, ProteinPer100g: 1.6, CarbsPer100g: 20.1, FatPer100g: 0.1},

		// Mother Foods
		{Name: "Nasi Putih", Category: "ibu", CaloriesPer100g: 130, ProteinPer100g: 2.7, CarbsPer100g: 28.2, FatPer100g: 0.3},
		{Name: "Dada Ayam", Category: "ibu", CaloriesPer100g: 165, ProteinPer100g: 31.0, CarbsPer100g: 0.0, FatPer100g: 3.6},
		{Name: "Ikan Salmon", Category: "ibu", CaloriesPer100g: 208, ProteinPer100g: 20.0, CarbsPer100g: 0.0, FatPer100g: 13.0},
		{Name: "Tempe", Category: "ibu", CaloriesPer100g: 193, ProteinPer100g: 20.8, CarbsPer100g: 7.6, FatPer100g: 10.8},
		{Name: "Tahu", Category: "ibu", CaloriesPer100g: 76, ProteinPer100g: 8.0, CarbsPer100g: 1.9, FatPer100g: 4.8},
		{Name: "Bayam", Category: "ibu", CaloriesPer100g: 23, ProteinPer100g: 2.9, CarbsPer100g: 3.6, FatPer100g: 0.4},
		{Name: "Kacang Almond", Category: "ibu", CaloriesPer100g: 579, ProteinPer100g: 21.2, CarbsPer100g: 21.6, FatPer100g: 49.9},
		{Name: "Yogurt", Category: "ibu", CaloriesPer100g: 59, ProteinPer100g: 10.0, CarbsPer100g: 3.6, FatPer100g: 0.4},
		{Name: "Oatmeal", Category: "ibu", CaloriesPer100g: 389, ProteinPer100g: 16.9, CarbsPer100g: 66.3, FatPer100g: 6.9},
		{Name: "Susu", Category: "ibu", CaloriesPer100g: 61, ProteinPer100g: 3.2, CarbsPer100g: 4.8, FatPer100g: 3.3},
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

func stringPtr(s string) *string {
	return &s
}
