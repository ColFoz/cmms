-- ============================================================================
-- Atlas STR Test Data - Migration 002
-- ============================================================================
-- Purpose: Create 3 test properties with metadata for development
-- Date: 2025-11-08
-- Properties: Villa 12, Newport House, Blouberg Apartment
-- ============================================================================

-- ============================================================================
-- 1. CREATE TEST LOCATIONS (Properties as Locations)
-- ============================================================================

-- Villa 12 - Cape Town
INSERT INTO location (
  id, name, address, created_at, updated_at, company_id
) VALUES (
  nextval('location_seq'),
  'Villa 12',
  'Camps Bay, Cape Town, South Africa',
  NOW(),
  NOW(),
  1
) RETURNING id;

-- Store the ID for reference (we'll use subqueries below)
DO $$
DECLARE
  villa_12_location_id BIGINT;
  newport_location_id BIGINT;
  blouberg_location_id BIGINT;
BEGIN
  -- Get the location IDs we just created
  SELECT id INTO villa_12_location_id FROM location WHERE name = 'Villa 12';

  RAISE NOTICE 'Created location: Villa 12 (ID: %)', villa_12_location_id;
END $$;

-- Newport House - Cape Town
INSERT INTO location (
  id, name, address, created_at, updated_at, company_id
) VALUES (
  nextval('location_seq'),
  'Newport House',
  'Strand, Cape Town, South Africa',
  NOW(),
  NOW(),
  1
);

-- Blouberg Beachfront Apartment
INSERT INTO location (
  id, name, address, created_at, updated_at, company_id
) VALUES (
  nextval('location_seq'),
  'Blouberg Beachfront Apartment',
  'Bloubergstrand, Cape Town, South Africa',
  NOW(),
  NOW(),
  1
);

-- ============================================================================
-- 2. CREATE TEST ASSETS (Properties)
-- ============================================================================

-- Villa 12 Asset
INSERT INTO asset (
  id,
  name,
  description,
  status,
  location_id,
  company_id,
  created_at,
  updated_at,
  archived,
  is_property,
  property_code
) VALUES (
  nextval('asset_seq'),
  'Villa 12',
  'Luxury 3-bedroom villa in Camps Bay with ocean views',
  1, -- Active status
  (SELECT id FROM location WHERE name = 'Villa 12'),
  1,
  NOW(),
  NOW(),
  FALSE,
  TRUE,
  'VILLA-12'
);

-- Newport House Asset
INSERT INTO asset (
  id,
  name,
  description,
  status,
  location_id,
  company_id,
  created_at,
  updated_at,
  archived,
  is_property,
  property_code
) VALUES (
  nextval('asset_seq'),
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

-- Blouberg Apartment Asset
INSERT INTO asset (
  id,
  name,
  description,
  status,
  location_id,
  company_id,
  created_at,
  updated_at,
  archived,
  is_property,
  property_code
) VALUES (
  nextval('asset_seq'),
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
-- 3. CREATE PROPERTY METADATA
-- ============================================================================

-- Villa 12 Metadata
INSERT INTO property_metadata (
  asset_id,
  listing_platform,
  listing_url,
  listing_id,
  check_in_time,
  check_out_time,
  wifi_ssid,
  wifi_password,
  lockbox_code,
  property_type,
  bedrooms,
  bathrooms,
  max_guests,
  avg_rating,
  total_reviews,
  region,
  primary_housekeeper_id,
  guest_favorite,
  created_at,
  updated_at
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
  39, -- Super Admin as temporary housekeeper
  TRUE,
  NOW(),
  NOW()
);

-- Newport House Metadata
INSERT INTO property_metadata (
  asset_id,
  listing_platform,
  listing_url,
  listing_id,
  check_in_time,
  check_out_time,
  wifi_ssid,
  wifi_password,
  lockbox_code,
  property_type,
  bedrooms,
  bathrooms,
  max_guests,
  avg_rating,
  total_reviews,
  region,
  primary_housekeeper_id,
  created_at,
  updated_at
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
  39,
  FALSE,
  NOW(),
  NOW()
);

-- Blouberg Apartment Metadata
INSERT INTO property_metadata (
  asset_id,
  listing_platform,
  listing_url,
  listing_id,
  check_in_time,
  check_out_time,
  wifi_ssid,
  wifi_password,
  lockbox_code,
  property_type,
  bedrooms,
  bathrooms,
  max_guests,
  avg_rating,
  total_reviews,
  region,
  primary_housekeeper_id,
  pet_friendly,
  created_at,
  updated_at
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
  39,
  FALSE,
  NOW(),
  NOW()
);

-- ============================================================================
-- 4. CREATE TEST APPLIANCES (Child Assets)
-- ============================================================================

-- Villa 12 - Dishwasher
INSERT INTO asset (
  id,
  name,
  description,
  model,
  manufacturer,
  status,
  location_id,
  company_id,
  parent_asset_id,
  created_at,
  updated_at,
  archived,
  is_property
) VALUES (
  nextval('asset_seq'),
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

-- Villa 12 - Coffee Machine
INSERT INTO asset (
  id,
  name,
  description,
  model,
  manufacturer,
  status,
  location_id,
  company_id,
  parent_asset_id,
  created_at,
  updated_at,
  archived,
  is_property
) VALUES (
  nextval('asset_seq'),
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

-- Newport House - Washing Machine
INSERT INTO asset (
  id,
  name,
  description,
  model,
  manufacturer,
  status,
  location_id,
  company_id,
  parent_asset_id,
  created_at,
  updated_at,
  archived,
  is_property
) VALUES (
  nextval('asset_seq'),
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

-- Blouberg Apt - Air Conditioner
INSERT INTO asset (
  id,
  name,
  description,
  model,
  manufacturer,
  status,
  location_id,
  company_id,
  parent_asset_id,
  created_at,
  updated_at,
  archived,
  is_property
) VALUES (
  nextval('asset_seq'),
  'Daikin Air Conditioner',
  'Living room AC unit',
  'FTXM35R',
  'Daikin',
  1,
  (SELECT id FROM location WHERE name = 'Blouberg Beachfront Apartment'),
  1,
  (SELECT id FROM asset WHERE property_code = 'BLOU-APT'),
  NOW(),
  NOW(),
  FALSE,
  FALSE
);

-- Blouberg Apt - TV
INSERT INTO asset (
  id,
  name,
  description,
  model,
  manufacturer,
  status,
  location_id,
  company_id,
  parent_asset_id,
  created_at,
  updated_at,
  archived,
  is_property
) VALUES (
  nextval('asset_seq'),
  'Samsung Smart TV',
  '55" 4K TV in living room',
  'UE55AU7170',
  'Samsung',
  1,
  (SELECT id FROM location WHERE name = 'Blouberg Beachfront Apartment'),
  1,
  (SELECT id FROM asset WHERE property_code = 'BLOU-APT'),
  NOW(),
  NOW(),
  FALSE,
  FALSE
);

-- ============================================================================
-- 5. CREATE SAMPLE CHECKLIST TEMPLATE
-- ============================================================================

-- Dishwasher Deep Clean Template
INSERT INTO checklist_template (
  name,
  description,
  appliance_type,
  brand,
  model,
  source,
  steps,
  photos_required,
  estimated_duration_minutes,
  frequency_type,
  frequency_value,
  difficulty_level,
  created_by,
  company_id,
  created_at,
  updated_at
) VALUES (
  'Bosch Dishwasher Deep Clean',
  'Complete maintenance checklist for Bosch dishwashers',
  'dishwasher',
  'Bosch',
  'SMS88TW06G',
  'manual',
  '[
    {
      "order": 1,
      "title": "Remove and clean lower spray arm",
      "description": "Twist counterclockwise to remove. Clean with soft brush under warm water.",
      "estimated_minutes": 5,
      "requires_photo": true
    },
    {
      "order": 2,
      "title": "Clean filter assembly",
      "description": "Remove cylindrical filter, rinse under hot water, scrub with brush.",
      "estimated_minutes": 10,
      "requires_photo": true
    },
    {
      "order": 3,
      "title": "Wipe door seals",
      "description": "Clean rubber seals around door with damp cloth.",
      "estimated_minutes": 3,
      "requires_photo": false
    },
    {
      "order": 4,
      "title": "Run empty cycle with cleaner",
      "description": "Use Finish Machine Cleaner or citric acid, run hottest cycle.",
      "estimated_minutes": 90,
      "requires_photo": false
    },
    {
      "order": 5,
      "title": "Check spray arms spin freely",
      "description": "Manually rotate both spray arms to ensure no obstruction.",
      "estimated_minutes": 2,
      "requires_photo": false
    },
    {
      "order": 6,
      "title": "Clean exterior and control panel",
      "description": "Wipe down with microfiber cloth and mild cleaner.",
      "estimated_minutes": 5,
      "requires_photo": true
    }
  ]'::jsonb,
  3,
  120,
  'months',
  6,
  'easy',
  39,
  1,
  NOW(),
  NOW()
);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Show created properties
DO $$
BEGIN
  RAISE NOTICE '============================================';
  RAISE NOTICE 'Test Data Created Successfully!';
  RAISE NOTICE '============================================';
END $$;

-- Count properties
SELECT
  'Properties Created' as item,
  COUNT(*) as count
FROM asset
WHERE is_property = TRUE;

-- Count appliances
SELECT
  'Appliances Created' as item,
  COUNT(*) as count
FROM asset
WHERE is_property = FALSE AND parent_asset_id IS NOT NULL;

-- Count checklist templates
SELECT
  'Checklist Templates' as item,
  COUNT(*) as count
FROM checklist_template;

-- Show property summary
SELECT
  a.property_code,
  a.name as property_name,
  pm.region,
  pm.bedrooms,
  pm.bathrooms,
  pm.max_guests,
  pm.avg_rating,
  pm.listing_platform
FROM asset a
JOIN property_metadata pm ON a.id = pm.asset_id
WHERE a.is_property = TRUE
ORDER BY a.name;

-- Show appliances by property
SELECT
  pa.name as property_name,
  a.name as appliance_name,
  a.manufacturer,
  a.model
FROM asset a
JOIN asset pa ON a.parent_asset_id = pa.id
WHERE a.parent_asset_id IS NOT NULL
ORDER BY pa.name, a.name;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
