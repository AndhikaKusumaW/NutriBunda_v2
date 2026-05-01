ALTER TABLE foods 
    ADD COLUMN IF NOT EXISTS estimated_price_per_100g DECIMAL(10,2) DEFAULT NULL; 

COMMENT ON COLUMN foods.estimated_price_per_100g 
    IS 'Estimasi harga bahan makanan per 100 gram dalam Rupiah (IDR)';