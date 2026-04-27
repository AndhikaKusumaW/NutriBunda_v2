-- Add sync-related fields to diary_entries table
ALTER TABLE diary_entries 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP;

-- Create index on deleted_at for soft delete queries
CREATE INDEX IF NOT EXISTS idx_diary_entries_deleted_at ON diary_entries(deleted_at);

-- Add sync-related fields to favorite_recipes table
ALTER TABLE favorite_recipes 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP;

-- Create index on deleted_at for soft delete queries
CREATE INDEX IF NOT EXISTS idx_favorite_recipes_deleted_at ON favorite_recipes(deleted_at);

-- Update existing records to have updated_at = created_at
UPDATE diary_entries SET updated_at = created_at WHERE updated_at IS NULL;
UPDATE favorite_recipes SET updated_at = created_at WHERE updated_at IS NULL;
