#!/bin/bash

# ============================================================================
# Atlas STR - Create Test Properties via API
# ============================================================================
# Purpose: Create 3 test properties with metadata using Atlas REST API
# Date: 2025-11-08
# Usage: ./create_test_properties.sh
# ============================================================================

set -e

API_URL="http://localhost:8080"
EMAIL="superadmin@test.com"
PASSWORD="pls_change_me"

echo "============================================"
echo "Atlas STR - Creating Test Properties"
echo "============================================"
echo ""

# ============================================================================
# 1. LOGIN AND GET TOKEN
# ============================================================================

echo "→ Logging in as $EMAIL..."
LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/auth/signin" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.accessToken')

if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
  echo "❌ Login failed!"
  echo "$LOGIN_RESPONSE"
  exit 1
fi

echo "✓ Logged in successfully"
echo ""

# ============================================================================
# 2. CREATE LOCATIONS
# ============================================================================

echo "→ Creating locations..."

# Villa 12 Location
VILLA_12_LOC=$(curl -s -X POST "$API_URL/locations" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Villa 12",
    "address": "Camps Bay, Cape Town, South Africa"
  }')

VILLA_12_LOC_ID=$(echo $VILLA_12_LOC | jq -r '.id')
echo "  ✓ Villa 12 location created (ID: $VILLA_12_LOC_ID)"

# Newport House Location
NPH_LOC=$(curl -s -X POST "$API_URL/locations" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Newport House",
    "address": "Strand, Cape Town, South Africa"
  }')

NPH_LOC_ID=$(echo $NPH_LOC | jq -r '.id')
echo "  ✓ Newport House location created (ID: $NPH_LOC_ID)"

# Blouberg Apartment Location
BLOU_LOC=$(curl -s -X POST "$API_URL/locations" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Blouberg Beachfront Apartment",
    "address": "Bloubergstrand, Cape Town, South Africa"
  }')

BLOU_LOC_ID=$(echo $BLOU_LOC | jq -r '.id')
echo "  ✓ Blouberg Apartment location created (ID: $BLOU_LOC_ID)"
echo ""

# ============================================================================
# 3. CREATE ASSETS (PROPERTIES)
# ============================================================================

echo "→ Creating property assets..."

# Villa 12 Asset
VILLA_12_ASSET=$(curl -s -X POST "$API_URL/assets" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Villa 12\",
    \"description\": \"Luxury 3-bedroom villa in Camps Bay with ocean views\",
    \"location\": {\"id\": $VILLA_12_LOC_ID}
  }")

VILLA_12_ASSET_ID=$(echo $VILLA_12_ASSET | jq -r '.id')
echo "  ✓ Villa 12 asset created (ID: $VILLA_12_ASSET_ID)"

# Newport House Asset
NPH_ASSET=$(curl -s -X POST "$API_URL/assets" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Newport House\",
    \"description\": \"Modern 2-bedroom house in Strand with garden\",
    \"location\": {\"id\": $NPH_LOC_ID}
  }")

NPH_ASSET_ID=$(echo $NPH_ASSET | jq -r '.id')
echo "  ✓ Newport House asset created (ID: $NPH_ASSET_ID)"

# Blouberg Apartment Asset
BLOU_ASSET=$(curl -s -X POST "$API_URL/assets" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Blouberg Beachfront Apartment\",
    \"description\": \"1-bedroom apartment with stunning sea views\",
    \"location\": {\"id\": $BLOU_LOC_ID}
  }")

BLOU_ASSET_ID=$(echo $BLOU_ASSET | jq -r '.id')
echo "  ✓ Blouberg Apartment asset created (ID: $BLOU_ASSET_ID)"
echo ""

# ============================================================================
# 4. UPDATE ASSETS TO BE PROPERTIES
# ============================================================================

echo "→ Marking assets as properties..."

docker exec atlas_db psql -U rootUser -d atlas -c "
UPDATE asset SET is_property = TRUE, property_code = 'VILLA-12' WHERE id = $VILLA_12_ASSET_ID;
UPDATE asset SET is_property = TRUE, property_code = 'NPH' WHERE id = $NPH_ASSET_ID;
UPDATE asset SET is_property = TRUE, property_code = 'BLOU-APT' WHERE id = $BLOU_ASSET_ID;
" > /dev/null 2>&1

echo "  ✓ Assets marked as properties"
echo ""

# ============================================================================
# 5. CREATE PROPERTY METADATA
# ============================================================================

echo "→ Adding property metadata..."

docker exec atlas_db psql -U rootUser -d atlas -c "
-- Villa 12 Metadata
INSERT INTO property_metadata (
  asset_id, listing_platform, listing_url, listing_id,
  check_in_time, check_out_time, wifi_ssid, wifi_password, lockbox_code,
  property_type, bedrooms, bathrooms, max_guests,
  avg_rating, total_reviews, region, guest_favorite
) VALUES (
  $VILLA_12_ASSET_ID, 'airbnb', 'https://www.airbnb.com/rooms/12345678', '12345678',
  '15:00:00', '11:00:00', 'Villa12_Guest', 'CampsBay2024!', '1234',
  'villa', 3, 2.0, 6,
  4.87, 143, 'Cape Town', TRUE
);

-- Newport House Metadata
INSERT INTO property_metadata (
  asset_id, listing_platform, listing_url, listing_id,
  check_in_time, check_out_time, wifi_ssid, wifi_password, lockbox_code,
  property_type, bedrooms, bathrooms, max_guests,
  avg_rating, total_reviews, region, guest_favorite
) VALUES (
  $NPH_ASSET_ID, 'airbnb', 'https://www.airbnb.com/rooms/23456789', '23456789',
  '15:00:00', '11:00:00', 'Newport_WiFi', 'Strand2024!', '5678',
  'house', 2, 1.0, 4,
  4.92, 87, 'Strand', FALSE
);

-- Blouberg Apartment Metadata
INSERT INTO property_metadata (
  asset_id, listing_platform, listing_url, listing_id,
  check_in_time, check_out_time, wifi_ssid, wifi_password, lockbox_code,
  property_type, bedrooms, bathrooms, max_guests,
  avg_rating, total_reviews, region, pet_friendly
) VALUES (
  $BLOU_ASSET_ID, 'vrbo', 'https://www.vrbo.com/34567890', '34567890',
  '14:00:00', '10:00:00', 'Blouberg_Beach', 'Ocean2024!', '9012',
  'apartment', 1, 1.0, 2,
  4.78, 56, 'Cape Town', FALSE
);
" > /dev/null 2>&1

echo "  ✓ Property metadata added"
echo ""

# ============================================================================
# 6. VERIFY CREATION
# ============================================================================

echo "============================================"
echo "✅ Test Properties Created Successfully!"
echo "============================================"
echo ""

docker exec atlas_db psql -U rootUser -d atlas -c "
SELECT
  a.id,
  a.property_code,
  a.name as property_name,
  pm.region,
  pm.bedrooms || ' bed / ' || pm.bathrooms || ' bath' as layout,
  pm.max_guests as guests,
  pm.avg_rating as rating,
  pm.listing_platform as platform
FROM asset a
JOIN property_metadata pm ON a.id = pm.asset_id
WHERE a.is_property = TRUE
ORDER BY a.name;
"

echo ""
echo "🎉 Ready to view in Atlas UI: http://localhost:3000"
echo ""
