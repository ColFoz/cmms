-- ============================================================================
-- Atlas STR Test Properties - Migration 003
-- ============================================================================
-- Purpose: Insert 3 test properties using Hibernate sequence
-- Date: 2025-11-08
-- ============================================================================

-- ============================================================================
-- 1. CREATE LOCATIONS
-- ============================================================================

-- Villa 12
INSERT INTO location (
  id, name, address, created_at, updated_at, company_id
) VALUES (
  nextval('hibernate_sequence'),
  'Villa 12',
  'Camps Bay, Cape Town, South Africa',
  NOW(),
  NOW(),
  1
);

-- Newport House
INSERT INTO location (
  id, name, address, created_at, updated_at, company_id
) VALUES (
  nextval('hibernate_sequence'),
  'Newport House',
  'Strand, Cape Town, South Africa',
  NOW(),
  NOW(),
  1
);

-- Blouberg Apartment
INSERT INTO location (
  id, name, address, created_at, updated_at, company_id
) VALUES (
  nextval('hibernate_sequence'),
  'Blouberg Beachfront Apartment',
  'Bloubergstrand, Cape Town, South Africa',
  NOW(),
  NOW(),
  1
);

-- ============================================================================
-- 2. CREATE PROPERTY ASSETS
-- ============================================================================

-- Villa 12
INSERT INTO asset (
  id, name, description, status, location_id, company_id,
  created_at, updated_at, archived, is_property, property_code
) VALUES (
  nextval('hibernate_sequence'),
  'Villa 12',
  'Luxury 3-bedroom villa in Camps Bay with ocean views',
  1,
  (SELECT id FROM location WHERE name = 'Villa 12'),
  1,
  NOW(),
  NOW(),
  FALSE,
  TRUE,
  'VILLA-12'
);

-- Newport House
INSERT INTO asset (
  id, name, description, status, location_id, company_id,
  created_at, updated_at, archived, is_property, property_code
) VALUES (
  nextval('hibernate_sequence'),
  'Newport House',
  'Modern 2-bedroom house in Strand with garden',
  1,
  (SELECT id FROM location WHERE name = 'Newport House'),
  1,
  NOW(),
  NOW(),
  FALSE,
  TRUE,
  'NPH'
);

-- Blouberg Apartment
INSERT INTO asset (
  id, name, description, status, location_id, company_id,
  created_at, updated_at, archived, is_property, property_code
) VALUES (
  nextval('hibernate_sequence'),
  'Blouberg Beachfront Apartment',
  '1-bedroom apartment with stunning sea views',
  1,
  (SELECT id FROM location WHERE name = 'Blouberg Beachfront Apartment'),
  1,
  NOW(),
  NOW(),
  FALSE,
  TRUE,
  'BLOU-APT'
);

-- ============================================================================
-- 3. ADD PROPERTY METADATA
-- ============================================================================

-- Villa 12 Metadata
INSERT INTO property_metadata (
  asset_id, listing_platform, listing_url, listing_id,
  check_in_time, check_out_time, wifi_ssid, wifi_password, lockbox_code,
  property_type, bedrooms, bathrooms, max_guests,
  avg_rating, total_reviews, region, guest_favorite
) VALUES (
  (SELECT id FROM asset WHERE property_code = 'VILLA-12'),
  'airbnb',
  'https://www.airbnb.com/rooms/12345678',
  '12345678',
  '15:00:00',
  '11:00:00',
  'Villa12_Guest',
  'CampsBay2024!',
  '1234',
  'villa',
  3,
  2.0,
  6,
  4.87,
  143,
  'Cape Town',
  TRUE
);

-- Newport House Metadata
INSERT INTO property_metadata (
  asset_id, listing_platform, listing_url, listing_id,
  check_in_time, check_out_time, wifi_ssid, wifi_password, lockbox_code,
  property_type, bedrooms, bathrooms, max_guests,
  avg_rating, total_reviews, region, guest_favorite
) VALUES (
  (SELECT id FROM asset WHERE property_code = 'NPH'),
  'airbnb',
  'https://www.airbnb.com/rooms/23456789',
  '23456789',
  '15:00:00',
  '11:00:00',
  'Newport_WiFi',
  'Strand2024!',
  '5678',
  'house',
  2,
  1.0,
  4,
  4.92,
  87,
  'Strand',
  FALSE
);

-- Blouberg Apartment Metadata
INSERT INTO property_metadata (
  asset_id, listing_platform, listing_url, listing_id,
  check_in_time, check_out_time, wifi_ssid, wifi_password, lockbox_code,
  property_type, bedrooms, bathrooms, max_guests,
  avg_rating, total_reviews, region, pet_friendly
) VALUES (
  (SELECT id FROM asset WHERE property_code = 'BLOU-APT'),
  'vrbo',
  'https://www.vrbo.com/34567890',
  '34567890',
  '14:00:00',
  '10:00:00',
  'Blouberg_Beach',
  'Ocean2024!',
  '9012',
  'apartment',
  1,
  1.0,
  2,
  4.78,
  56,
  'Cape Town',
  FALSE
);

-- ============================================================================
-- 4. CREATE SOME TEST APPLIANCES
-- ============================================================================

-- Villa 12 - Bosch Dishwasher
INSERT INTO asset (
  id, name, description, model, manufacturer,
  status, location_id, company_id, parent_asset_id,
  created_at, updated_at, archived, is_property
) VALUES (
  nextval('hibernate_sequence'),
  'Bosch Dishwasher',
  'Main kitchen dishwasher',
  'SMS88TW06G',
  'Bosch',
  1,
  (SELECT id FROM location WHERE name = 'Villa 12'),
  1,
  (SELECT id FROM asset WHERE property_code = 'VILLA-12'),
  NOW(),
  NOW(),
  FALSE,
  FALSE
);

-- Villa 12 - Nespresso
INSERT INTO asset (
  id, name, description, model, manufacturer,
  status, location_id, company_id, parent_asset_id,
  created_at, updated_at, archived, is_property
) VALUES (
  nextval('hibernate_sequence'),
  'Nespresso Vertuo',
  'Kitchen coffee machine',
  'Vertuo Plus',
  'Nespresso',
  1,
  (SELECT id FROM location WHERE name = 'Villa 12'),
  1,
  (SELECT id FROM asset WHERE property_code = 'VILLA-12'),
  NOW(),
  NOW(),
  FALSE,
  FALSE
);

-- Newport - Washing Machine
INSERT INTO asset (
  id, name, description, model, manufacturer,
  status, location_id, company_id, parent_asset_id,
  created_at, updated_at, archived, is_property
) VALUES (
  nextval('hibernate_sequence'),
  'Samsung Washing Machine',
  'Front-loading washing machine',
  'WW90TA046AE',
  'Samsung',
  1,
  (SELECT id FROM location WHERE name = 'Newport House'),
  1,
  (SELECT id FROM asset WHERE property_code = 'NPH'),
  NOW(),
  NOW(),
  FALSE,
  FALSE
);

-- ============================================================================
-- 5. VERIFICATION
-- ============================================================================

-- Summary
SELECT '============================================' as "";
SELECT '✅ Test Properties Created!' as "";
SELECT '============================================' as "";

-- Properties count
SELECT
  'Properties' as item,
  COUNT(*) as count
FROM asset
WHERE is_property = TRUE;

-- Appliances count
SELECT
  'Appliances' as item,
  COUNT(*) as count
FROM asset
WHERE is_property = FALSE AND parent_asset_id IS NOT NULL;

-- Property details
SELECT
  a.property_code as code,
  a.name as property_name,
  pm.region,
  pm.bedrooms || ' bed / ' || pm.bathrooms || ' bath' as layout,
  pm.max_guests as guests,
  pm.avg_rating as rating
FROM asset a
JOIN property_metadata pm ON a.id = pm.asset_id
WHERE a.is_property = TRUE
ORDER BY a.name;

-- Appliances by property
SELECT
  pa.property_code as property,
  a.name as appliance,
  a.manufacturer,
  a.model
FROM asset a
JOIN asset pa ON a.parent_asset_id = pa.id
WHERE a.parent_asset_id IS NOT NULL
ORDER BY pa.name, a.name;

SELECT '============================================' as "";
SELECT '🎉 Ready to view at http://localhost:3000' as "";
SELECT '============================================' as "";
