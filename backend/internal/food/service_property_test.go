package food

import (
	"math"
	"nutribunda-backend/internal/database"
	"reflect"
	"testing"

	"github.com/leanovate/gopter"
	"github.com/leanovate/gopter/gen"
	"github.com/leanovate/gopter/prop"
	"github.com/stretchr/testify/require"
)

// **Validates: Requirements 3.1, 4.3**
// Property-based tests for nutrition calculation consistency

// NutritionValues represents calculated nutrition for a serving
type NutritionValues struct {
	Calories float64
	Protein  float64
	Carbs    float64
	Fat      float64
}

// CalculateNutrition calculates nutrition values for a given serving size
func CalculateNutrition(food database.Food, servingSize float64) NutritionValues {
	multiplier := servingSize / 100.0
	return NutritionValues{
		Calories: food.CaloriesPer100g * multiplier,
		Protein:  food.ProteinPer100g * multiplier,
		Carbs:    food.CarbsPer100g * multiplier,
		Fat:      food.FatPer100g * multiplier,
	}
}

// SumNutrition sums multiple nutrition values
func SumNutrition(values []NutritionValues) NutritionValues {
	sum := NutritionValues{}
	for _, v := range values {
		sum.Calories += v.Calories
		sum.Protein += v.Protein
		sum.Carbs += v.Carbs
		sum.Fat += v.Fat
	}
	return sum
}

// floatEquals checks if two floats are approximately equal (within epsilon)
func floatEquals(a, b, epsilon float64) bool {
	return math.Abs(a-b) < epsilon
}

// TestNutritionCalculationConsistencyProperty tests Property 2: Nutrition calculation consistency
func TestNutritionCalculationConsistencyProperty(t *testing.T) {
	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = 100
	properties := gopter.NewProperties(parameters)

	// Generator for valid food items
	genFood := gen.Struct(reflect.TypeOf(database.Food{}), map[string]gopter.Gen{
		"Name":            gen.AlphaString(),
		"Category":        gen.OneConstOf("mpasi", "ibu"),
		"CaloriesPer100g": gen.Float64Range(1.0, 900.0),   // Realistic calorie range
		"ProteinPer100g":  gen.Float64Range(0.0, 100.0),   // Protein can be 0-100g per 100g
		"CarbsPer100g":    gen.Float64Range(0.0, 100.0),   // Carbs can be 0-100g per 100g
		"FatPer100g":      gen.Float64Range(0.0, 100.0),   // Fat can be 0-100g per 100g
	})

	// Generator for valid serving sizes (1g to 1000g)
	genServingSize := gen.Float64Range(1.0, 1000.0)

	// Property 1: Scaling nutrition values by serving size maintains proportional relationships
	properties.Property("Scaling maintains proportional relationships", prop.ForAll(
		func(food database.Food, servingSize1, servingSize2 float64) bool {
			// Calculate nutrition for two different serving sizes
			nutrition1 := CalculateNutrition(food, servingSize1)
			nutrition2 := CalculateNutrition(food, servingSize2)

			// If serving sizes are equal, nutrition should be equal
			if floatEquals(servingSize1, servingSize2, 0.001) {
				return floatEquals(nutrition1.Calories, nutrition2.Calories, 0.01) &&
					floatEquals(nutrition1.Protein, nutrition2.Protein, 0.01) &&
					floatEquals(nutrition1.Carbs, nutrition2.Carbs, 0.01) &&
					floatEquals(nutrition1.Fat, nutrition2.Fat, 0.01)
			}

			// The ratio of nutrition values should equal the ratio of serving sizes
			ratio := servingSize2 / servingSize1
			epsilon := 0.01 // Allow small floating point errors

			// Check if nutrition scales proportionally
			if food.CaloriesPer100g > 0 {
				caloriesRatio := nutrition2.Calories / nutrition1.Calories
				if !floatEquals(caloriesRatio, ratio, epsilon) {
					return false
				}
			}

			if food.ProteinPer100g > 0 {
				proteinRatio := nutrition2.Protein / nutrition1.Protein
				if !floatEquals(proteinRatio, ratio, epsilon) {
					return false
				}
			}

			if food.CarbsPer100g > 0 {
				carbsRatio := nutrition2.Carbs / nutrition1.Carbs
				if !floatEquals(carbsRatio, ratio, epsilon) {
					return false
				}
			}

			if food.FatPer100g > 0 {
				fatRatio := nutrition2.Fat / nutrition1.Fat
				if !floatEquals(fatRatio, ratio, epsilon) {
					return false
				}
			}

			return true
		},
		genFood,
		genServingSize,
		genServingSize,
	))

	// Property 2: Summing multiple food entries produces correct totals
	properties.Property("Sum of individual entries equals total", prop.ForAll(
		func(foods []database.Food, servingSizes []float64) bool {
			// Ensure we have matching foods and serving sizes
			if len(foods) == 0 || len(servingSizes) == 0 {
				return true // Skip empty cases
			}

			// Truncate to minimum length
			minLen := len(foods)
			if len(servingSizes) < minLen {
				minLen = len(servingSizes)
			}
			foods = foods[:minLen]
			servingSizes = servingSizes[:minLen]

			// Calculate nutrition for each food entry
			var nutritionValues []NutritionValues
			expectedTotal := NutritionValues{}

			for i, food := range foods {
				nutrition := CalculateNutrition(food, servingSizes[i])
				nutritionValues = append(nutritionValues, nutrition)

				// Calculate expected total manually
				expectedTotal.Calories += nutrition.Calories
				expectedTotal.Protein += nutrition.Protein
				expectedTotal.Carbs += nutrition.Carbs
				expectedTotal.Fat += nutrition.Fat
			}

			// Calculate total using SumNutrition function
			actualTotal := SumNutrition(nutritionValues)

			// Compare with small epsilon for floating point errors
			epsilon := 0.01
			return floatEquals(actualTotal.Calories, expectedTotal.Calories, epsilon) &&
				floatEquals(actualTotal.Protein, expectedTotal.Protein, epsilon) &&
				floatEquals(actualTotal.Carbs, expectedTotal.Carbs, epsilon) &&
				floatEquals(actualTotal.Fat, expectedTotal.Fat, epsilon)
		},
		gen.SliceOfN(5, genFood),        // Generate up to 5 foods
		gen.SliceOfN(5, genServingSize), // Generate up to 5 serving sizes
	))

	// Property 3: Nutrition values remain consistent regardless of calculation order
	properties.Property("Calculation order independence", prop.ForAll(
		func(foods []database.Food, servingSizes []float64) bool {
			// Ensure we have matching foods and serving sizes
			if len(foods) == 0 || len(servingSizes) == 0 {
				return true // Skip empty cases
			}

			// Truncate to minimum length
			minLen := len(foods)
			if len(servingSizes) < minLen {
				minLen = len(servingSizes)
			}
			foods = foods[:minLen]
			servingSizes = servingSizes[:minLen]

			// Calculate nutrition in original order
			var nutritionValues1 []NutritionValues
			for i, food := range foods {
				nutrition := CalculateNutrition(food, servingSizes[i])
				nutritionValues1 = append(nutritionValues1, nutrition)
			}
			total1 := SumNutrition(nutritionValues1)

			// Calculate nutrition in reverse order
			var nutritionValues2 []NutritionValues
			for i := len(foods) - 1; i >= 0; i-- {
				nutrition := CalculateNutrition(foods[i], servingSizes[i])
				nutritionValues2 = append(nutritionValues2, nutrition)
			}
			total2 := SumNutrition(nutritionValues2)

			// Totals should be equal regardless of order
			epsilon := 0.01
			return floatEquals(total1.Calories, total2.Calories, epsilon) &&
				floatEquals(total1.Protein, total2.Protein, epsilon) &&
				floatEquals(total1.Carbs, total2.Carbs, epsilon) &&
				floatEquals(total1.Fat, total2.Fat, epsilon)
		},
		gen.SliceOfN(5, genFood),        // Generate up to 5 foods
		gen.SliceOfN(5, genServingSize), // Generate up to 5 serving sizes
	))

	// Property 4: Adding and removing the same entry should result in original state
	properties.Property("Add/remove consistency", prop.ForAll(
		func(food database.Food, servingSize float64, existingNutrition NutritionValues) bool {
			// Calculate nutrition for the entry to add
			entryNutrition := CalculateNutrition(food, servingSize)

			// Add the entry to existing nutrition
			afterAdd := NutritionValues{
				Calories: existingNutrition.Calories + entryNutrition.Calories,
				Protein:  existingNutrition.Protein + entryNutrition.Protein,
				Carbs:    existingNutrition.Carbs + entryNutrition.Carbs,
				Fat:      existingNutrition.Fat + entryNutrition.Fat,
			}

			// Remove the same entry
			afterRemove := NutritionValues{
				Calories: afterAdd.Calories - entryNutrition.Calories,
				Protein:  afterAdd.Protein - entryNutrition.Protein,
				Carbs:    afterAdd.Carbs - entryNutrition.Carbs,
				Fat:      afterAdd.Fat - entryNutrition.Fat,
			}

			// Should return to original state
			epsilon := 0.01
			return floatEquals(afterRemove.Calories, existingNutrition.Calories, epsilon) &&
				floatEquals(afterRemove.Protein, existingNutrition.Protein, epsilon) &&
				floatEquals(afterRemove.Carbs, existingNutrition.Carbs, epsilon) &&
				floatEquals(afterRemove.Fat, existingNutrition.Fat, epsilon)
		},
		genFood,
		genServingSize,
		gen.Struct(reflect.TypeOf(NutritionValues{}), map[string]gopter.Gen{
			"Calories": gen.Float64Range(0.0, 5000.0),
			"Protein":  gen.Float64Range(0.0, 500.0),
			"Carbs":    gen.Float64Range(0.0, 500.0),
			"Fat":      gen.Float64Range(0.0, 500.0),
		}),
	))

	// Property 5: Zero serving size should result in zero nutrition
	properties.Property("Zero serving size yields zero nutrition", prop.ForAll(
		func(food database.Food) bool {
			nutrition := CalculateNutrition(food, 0.0)

			epsilon := 0.001
			return floatEquals(nutrition.Calories, 0.0, epsilon) &&
				floatEquals(nutrition.Protein, 0.0, epsilon) &&
				floatEquals(nutrition.Carbs, 0.0, epsilon) &&
				floatEquals(nutrition.Fat, 0.0, epsilon)
		},
		genFood,
	))

	// Property 6: 100g serving should equal the per-100g values
	properties.Property("100g serving equals per-100g values", prop.ForAll(
		func(food database.Food) bool {
			nutrition := CalculateNutrition(food, 100.0)

			epsilon := 0.01
			return floatEquals(nutrition.Calories, food.CaloriesPer100g, epsilon) &&
				floatEquals(nutrition.Protein, food.ProteinPer100g, epsilon) &&
				floatEquals(nutrition.Carbs, food.CarbsPer100g, epsilon) &&
				floatEquals(nutrition.Fat, food.FatPer100g, epsilon)
		},
		genFood,
	))

	properties.TestingRun(t)
}

// TestNutritionCalculationEdgeCases tests specific edge cases
func TestNutritionCalculationEdgeCases(t *testing.T) {
	t.Run("Zero nutrition food", func(t *testing.T) {
		food := database.Food{
			Name:            "Water",
			Category:        "mpasi",
			CaloriesPer100g: 0,
			ProteinPer100g:  0,
			CarbsPer100g:    0,
			FatPer100g:      0,
		}

		nutrition := CalculateNutrition(food, 250.0)
		require.Equal(t, 0.0, nutrition.Calories)
		require.Equal(t, 0.0, nutrition.Protein)
		require.Equal(t, 0.0, nutrition.Carbs)
		require.Equal(t, 0.0, nutrition.Fat)
	})

	t.Run("Very small serving size", func(t *testing.T) {
		food := database.Food{
			Name:            "Concentrated Food",
			Category:        "mpasi",
			CaloriesPer100g: 500,
			ProteinPer100g:  50,
			CarbsPer100g:    60,
			FatPer100g:      30,
		}

		nutrition := CalculateNutrition(food, 0.1) // 0.1 gram
		require.InDelta(t, 0.5, nutrition.Calories, 0.01)
		require.InDelta(t, 0.05, nutrition.Protein, 0.01)
		require.InDelta(t, 0.06, nutrition.Carbs, 0.01)
		require.InDelta(t, 0.03, nutrition.Fat, 0.01)
	})

	t.Run("Large serving size", func(t *testing.T) {
		food := database.Food{
			Name:            "Rice",
			Category:        "ibu",
			CaloriesPer100g: 130,
			ProteinPer100g:  2.7,
			CarbsPer100g:    28.2,
			FatPer100g:      0.3,
		}

		nutrition := CalculateNutrition(food, 500.0) // 500 grams
		require.InDelta(t, 650.0, nutrition.Calories, 0.1)
		require.InDelta(t, 13.5, nutrition.Protein, 0.1)
		require.InDelta(t, 141.0, nutrition.Carbs, 0.1)
		require.InDelta(t, 1.5, nutrition.Fat, 0.1)
	})

	t.Run("Sum empty list", func(t *testing.T) {
		sum := SumNutrition([]NutritionValues{})
		require.Equal(t, 0.0, sum.Calories)
		require.Equal(t, 0.0, sum.Protein)
		require.Equal(t, 0.0, sum.Carbs)
		require.Equal(t, 0.0, sum.Fat)
	})

	t.Run("Sum single entry", func(t *testing.T) {
		values := []NutritionValues{
			{Calories: 100, Protein: 10, Carbs: 20, Fat: 5},
		}
		sum := SumNutrition(values)
		require.Equal(t, 100.0, sum.Calories)
		require.Equal(t, 10.0, sum.Protein)
		require.Equal(t, 20.0, sum.Carbs)
		require.Equal(t, 5.0, sum.Fat)
	})

	t.Run("Sum multiple entries", func(t *testing.T) {
		values := []NutritionValues{
			{Calories: 100, Protein: 10, Carbs: 20, Fat: 5},
			{Calories: 200, Protein: 15, Carbs: 30, Fat: 10},
			{Calories: 150, Protein: 12, Carbs: 25, Fat: 8},
		}
		sum := SumNutrition(values)
		require.InDelta(t, 450.0, sum.Calories, 0.01)
		require.InDelta(t, 37.0, sum.Protein, 0.01)
		require.InDelta(t, 75.0, sum.Carbs, 0.01)
		require.InDelta(t, 23.0, sum.Fat, 0.01)
	})
}
