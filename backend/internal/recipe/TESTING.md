# Recipe API Testing Guide

This guide provides manual testing instructions for the Recipe API endpoints.

## Prerequisites

1. Start the PostgreSQL database:
   ```bash
   docker-compose up -d
   ```

2. Start the API server:
   ```bash
   cd backend
   go run cmd/api/main.go
   ```

3. The API should be running on `http://localhost:8080`

## Test Scenarios

### 1. Search All Recipes

**Request:**
```bash
curl -X GET "http://localhost:8080/api/recipes?limit=10"
```

**Expected Response:**
- Status: 200 OK
- Body contains array of recipes
- Total count is returned

### 2. Search Recipes by Category

**Request:**
```bash
curl -X GET "http://localhost:8080/api/recipes?category=mpasi&limit=5"
```

**Expected Response:**
- Status: 200 OK
- All recipes have category "mpasi"
- Maximum 5 recipes returned

### 3. Get Recipe by ID

First, get a recipe ID from the search results, then:

**Request:**
```bash
curl -X GET "http://localhost:8080/api/recipes/{recipe_id}"
```

**Expected Response:**
- Status: 200 OK
- Recipe object with full details

**Error Case:**
```bash
curl -X GET "http://localhost:8080/api/recipes/00000000-0000-0000-0000-000000000000"
```
- Status: 404 Not Found
- Error message: "Recipe not found"

### 4. Get Random Recipe (Shake-to-Recipe)

**Request:**
```bash
curl -X GET "http://localhost:8080/api/recipes/random"
```

**Expected Response:**
- Status: 200 OK
- Single random recipe object

**With Category Filter:**
```bash
curl -X GET "http://localhost:8080/api/recipes/random?category=mpasi"
```

### 5. User Registration (for testing favorites)

**Request:**
```bash
curl -X POST "http://localhost:8080/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "full_name": "Test User"
  }'
```

**Expected Response:**
- Status: 200 OK
- Returns JWT token and user object
- Save the token for next requests

### 6. Add Recipe to Favorites

**Request:**
```bash
curl -X POST "http://localhost:8080/api/recipes/{recipe_id}/favorite" \
  -H "Authorization: Bearer {your_jwt_token}"
```

**Expected Response:**
- Status: 201 Created
- Message: "Recipe added to favorites"

**Error Cases:**

Duplicate favorite:
```bash
# Add same recipe again
curl -X POST "http://localhost:8080/api/recipes/{recipe_id}/favorite" \
  -H "Authorization: Bearer {your_jwt_token}"
```
- Status: 409 Conflict
- Error: "Recipe already in favorites"

Non-existent recipe:
```bash
curl -X POST "http://localhost:8080/api/recipes/00000000-0000-0000-0000-000000000000/favorite" \
  -H "Authorization: Bearer {your_jwt_token}"
```
- Status: 404 Not Found
- Error: "Recipe not found"

### 7. Get User Favorites

**Request:**
```bash
curl -X GET "http://localhost:8080/api/recipes/favorites" \
  -H "Authorization: Bearer {your_jwt_token}"
```

**Expected Response:**
- Status: 200 OK
- Array of favorite recipes
- Empty array if no favorites

### 8. Remove Recipe from Favorites

**Request:**
```bash
curl -X DELETE "http://localhost:8080/api/recipes/{recipe_id}/favorite" \
  -H "Authorization: Bearer {your_jwt_token}"
```

**Expected Response:**
- Status: 200 OK
- Message: "Recipe removed from favorites"

**Error Case:**
```bash
# Remove non-existent favorite
curl -X DELETE "http://localhost:8080/api/recipes/{recipe_id}/favorite" \
  -H "Authorization: Bearer {your_jwt_token}"
```
- Status: 404 Not Found
- Error: "Favorite recipe not found"

### 9. Unauthorized Access

**Request:**
```bash
curl -X GET "http://localhost:8080/api/recipes/favorites"
```

**Expected Response:**
- Status: 401 Unauthorized
- Error: "Unauthorized"

## Complete Test Flow

Here's a complete test flow to verify all functionality:

```bash
# 1. Register a user
RESPONSE=$(curl -s -X POST "http://localhost:8080/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "recipe_test@example.com",
    "password": "password123",
    "full_name": "Recipe Test User"
  }')

# Extract token (requires jq)
TOKEN=$(echo $RESPONSE | jq -r '.token')
echo "Token: $TOKEN"

# 2. Get all recipes
curl -X GET "http://localhost:8080/api/recipes?limit=5"

# 3. Get a random recipe
RECIPE=$(curl -s -X GET "http://localhost:8080/api/recipes/random?category=mpasi")
RECIPE_ID=$(echo $RECIPE | jq -r '.recipe.id')
echo "Random Recipe ID: $RECIPE_ID"

# 4. Add recipe to favorites
curl -X POST "http://localhost:8080/api/recipes/$RECIPE_ID/favorite" \
  -H "Authorization: Bearer $TOKEN"

# 5. Get favorites list
curl -X GET "http://localhost:8080/api/recipes/favorites" \
  -H "Authorization: Bearer $TOKEN"

# 6. Try to add same recipe again (should fail)
curl -X POST "http://localhost:8080/api/recipes/$RECIPE_ID/favorite" \
  -H "Authorization: Bearer $TOKEN"

# 7. Remove from favorites
curl -X DELETE "http://localhost:8080/api/recipes/$RECIPE_ID/favorite" \
  -H "Authorization: Bearer $TOKEN"

# 8. Verify favorites is empty
curl -X GET "http://localhost:8080/api/recipes/favorites" \
  -H "Authorization: Bearer $TOKEN"
```

## PowerShell Test Script

For Windows users, here's a PowerShell version:

```powershell
# 1. Register a user
$registerBody = @{
    email = "recipe_test@example.com"
    password = "password123"
    full_name = "Recipe Test User"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/register" `
    -Method Post `
    -ContentType "application/json" `
    -Body $registerBody

$token = $response.token
Write-Host "Token: $token"

# 2. Get random recipe
$recipe = Invoke-RestMethod -Uri "http://localhost:8080/api/recipes/random?category=mpasi" `
    -Method Get

$recipeId = $recipe.recipe.id
Write-Host "Recipe ID: $recipeId"

# 3. Add to favorites
$headers = @{
    Authorization = "Bearer $token"
}

Invoke-RestMethod -Uri "http://localhost:8080/api/recipes/$recipeId/favorite" `
    -Method Post `
    -Headers $headers

# 4. Get favorites
$favorites = Invoke-RestMethod -Uri "http://localhost:8080/api/recipes/favorites" `
    -Method Get `
    -Headers $headers

Write-Host "Favorites count: $($favorites.recipes.Count)"

# 5. Remove from favorites
Invoke-RestMethod -Uri "http://localhost:8080/api/recipes/$recipeId/favorite" `
    -Method Delete `
    -Headers $headers
```

## Expected Database State

After seeding, the database should contain:
- 15 MPASI recipes
- All recipes have category "mpasi"
- Each recipe has ingredients (JSON array), instructions, and nutrition_info (JSON object)

## Troubleshooting

### Issue: "Recipe not found" for random recipe
**Solution:** Ensure database is seeded. Run:
```bash
cd backend
go run cmd/seed/main.go
```

### Issue: "Unauthorized" for favorites endpoints
**Solution:** Ensure you're including the JWT token in the Authorization header:
```
Authorization: Bearer <your_token>
```

### Issue: Database connection error
**Solution:** Ensure PostgreSQL is running:
```bash
docker-compose up -d
docker-compose ps
```

### Issue: Port already in use
**Solution:** Check if another instance is running:
```bash
# Windows
netstat -ano | findstr :8080

# Linux/Mac
lsof -i :8080
```

## Integration with Flutter

The Flutter app should implement:

1. **Shake Detection**: Use accelerometer to detect shake gesture
2. **API Call**: Call `GET /api/recipes/random` when shake detected
3. **Display Recipe**: Show recipe details in a modal or new screen
4. **Favorite Button**: Allow users to save recipe to favorites
5. **Favorites Screen**: Display list of saved recipes
6. **Remove Favorite**: Allow users to remove recipes from favorites

Example Flutter code:
```dart
// Get random recipe
Future<Recipe> getRandomRecipe() async {
  final response = await dio.get('/api/recipes/random?category=mpasi');
  return Recipe.fromJson(response.data['recipe']);
}

// Add to favorites
Future<void> addToFavorites(String recipeId) async {
  await dio.post(
    '/api/recipes/$recipeId/favorite',
    options: Options(
      headers: {'Authorization': 'Bearer $token'},
    ),
  );
}

// Get favorites
Future<List<Recipe>> getFavorites() async {
  final response = await dio.get(
    '/api/recipes/favorites',
    options: Options(
      headers: {'Authorization': 'Bearer $token'},
    ),
  );
  return (response.data['recipes'] as List)
      .map((json) => Recipe.fromJson(json))
      .toList();
}
```
