# Recipe API

This package implements the Recipe API for NutriBunda, providing endpoints for recipe management and favorites functionality.

## Features

- **Recipe Search**: Search and filter recipes by category
- **Random Recipe**: Get a random recipe for shake-to-recipe feature
- **Favorites Management**: Add, remove, and list favorite recipes
- **MPASI Recipes**: Comprehensive database of MPASI (complementary feeding) recipes

## API Endpoints

### Public Endpoints

#### GET /api/recipes
Search for recipes with optional filters.

**Query Parameters:**
- `category` (optional): Filter by category (e.g., "mpasi")
- `limit` (optional): Maximum number of results (default: 50)

**Response:**
```json
{
  "recipes": [
    {
      "id": "uuid",
      "name": "Bubur Ayam Wortel",
      "ingredients": "[\"50g beras\", \"100g ayam giling\", \"50g wortel\"]",
      "instructions": "1. Masak beras...",
      "nutrition_info": "{\"calories\": 180, \"protein\": 12, \"carbs\": 25, \"fat\": 4}",
      "category": "mpasi",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "total": 15
}
```

#### GET /api/recipes/:id
Get a specific recipe by ID.

**Response:**
```json
{
  "recipe": {
    "id": "uuid",
    "name": "Bubur Ayam Wortel",
    "ingredients": "[\"50g beras\", \"100g ayam giling\", \"50g wortel\"]",
    "instructions": "1. Masak beras...",
    "nutrition_info": "{\"calories\": 180, \"protein\": 12, \"carbs\": 25, \"fat\": 4}",
    "category": "mpasi",
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

#### GET /api/recipes/random
Get a random recipe for shake-to-recipe feature.

**Query Parameters:**
- `category` (optional): Filter by category (e.g., "mpasi")

**Response:**
```json
{
  "recipe": {
    "id": "uuid",
    "name": "Pure Alpukat Pisang",
    "ingredients": "[\"1/2 buah alpukat\", \"1 buah pisang\"]",
    "instructions": "1. Kerok alpukat...",
    "nutrition_info": "{\"calories\": 150, \"protein\": 2, \"carbs\": 20, \"fat\": 8}",
    "category": "mpasi",
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

### Protected Endpoints (Require JWT Authentication)

#### GET /api/recipes/favorites
Get all favorite recipes for the authenticated user.

**Headers:**
- `Authorization: Bearer <jwt_token>`

**Response:**
```json
{
  "recipes": [
    {
      "id": "uuid",
      "name": "Bubur Ayam Wortel",
      "ingredients": "[\"50g beras\", \"100g ayam giling\", \"50g wortel\"]",
      "instructions": "1. Masak beras...",
      "nutrition_info": "{\"calories\": 180, \"protein\": 12, \"carbs\": 25, \"fat\": 4}",
      "category": "mpasi",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

#### POST /api/recipes/:id/favorite
Add a recipe to favorites.

**Headers:**
- `Authorization: Bearer <jwt_token>`

**Response:**
```json
{
  "message": "Recipe added to favorites"
}
```

**Error Responses:**
- `404 Not Found`: Recipe not found
- `409 Conflict`: Recipe already in favorites

#### DELETE /api/recipes/:id/favorite
Remove a recipe from favorites.

**Headers:**
- `Authorization: Bearer <jwt_token>`

**Response:**
```json
{
  "message": "Recipe removed from favorites"
}
```

**Error Responses:**
- `404 Not Found`: Favorite recipe not found

## Database Schema

### Recipe Table
```sql
CREATE TABLE recipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    ingredients TEXT NOT NULL,  -- JSON array
    instructions TEXT NOT NULL,
    nutrition_info JSONB,       -- JSON object
    category VARCHAR(50) DEFAULT 'mpasi',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### FavoriteRecipe Table
```sql
CREATE TABLE favorite_recipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, recipe_id)
);
```

## Service Methods

### SearchRecipes
Searches for recipes based on category and limit filters.

### GetRecipeByID
Retrieves a single recipe by its UUID.

### GetRandomRecipe
Returns a random recipe, optionally filtered by category. Used for the shake-to-recipe feature.

### AddFavorite
Adds a recipe to a user's favorites list. Prevents duplicates.

### RemoveFavorite
Removes a recipe from a user's favorites list.

### GetUserFavorites
Retrieves all favorite recipes for a specific user.

### IsFavorite
Checks if a recipe is in a user's favorites list.

## Requirements Mapping

This implementation satisfies the following requirements:

- **Requirement 6.3**: Shake-to-recipe feature with random recipe selection
- **Requirement 7.1**: Save recipes to favorites
- **Requirement 7.2**: Display list of favorite recipes
- **Requirement 7.3**: Remove recipes from favorites

## Testing

Unit tests are provided in `service_test.go` covering:
- Recipe search functionality
- Recipe retrieval by ID
- Random recipe selection
- Favorite management (add, remove, list)
- Duplicate favorite prevention
- Error handling for non-existent recipes

To run tests (requires PostgreSQL test database):
```bash
go test -v ./internal/recipe/...
```

## Seeding Data

The database is seeded with 15 MPASI recipes including:
- Bubur Ayam Wortel
- Pure Alpukat Pisang
- Bubur Kentang Brokoli
- Bubur Salmon Bayam
- Pure Ubi Ungu Apel
- And more...

Each recipe includes:
- Ingredients list (JSON array)
- Step-by-step instructions
- Nutrition information (calories, protein, carbs, fat)
- Category (mpasi)

## Usage Example

```go
// Initialize service
recipeService := recipe.NewService(db)

// Search recipes
recipes, err := recipeService.SearchRecipes(&recipe.SearchRequest{
    Category: "mpasi",
    Limit: 10,
})

// Get random recipe for shake-to-recipe
randomRecipe, err := recipeService.GetRandomRecipe("mpasi")

// Add to favorites
err := recipeService.AddFavorite(userID, recipeID)

// Get user favorites
favorites, err := recipeService.GetUserFavorites(userID)
```

## Error Handling

The service defines custom errors:
- `ErrRecipeNotFound`: Recipe with given ID does not exist
- `ErrFavoriteAlreadyExists`: Recipe is already in user's favorites
- `ErrFavoriteNotFound`: Favorite recipe not found for removal

## Integration with Flutter

The Flutter app should:
1. Call `GET /api/recipes/random` when shake gesture is detected
2. Display recipe details with ingredients and instructions
3. Allow users to save recipes using `POST /api/recipes/:id/favorite`
4. Show favorites list from `GET /api/recipes/favorites`
5. Allow removal from favorites using `DELETE /api/recipes/:id/favorite`
