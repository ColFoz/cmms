# Atlas STR Database Migrations

This folder contains SQL migration scripts to extend Atlas CMMS for short-term rental management.

## Migration Files

### 001_atlas_str_schema_extensions.sql
**Status:** ✅ Applied (2025-11-08)

Creates the core Atlas STR schema extensions:

**New Tables:**
- `property_metadata` - STR-specific property data
- `checklist_template` - AI-generated maintenance checklists
- `asset_checklist` - Links checklists to properties
- `task_photo` - Photos attached to tasks
- `booking_event` - Booking webhooks from Hospitable
- `inventory_usage` - Supply consumption tracking
- `ai_generation_log` - AI API call monitoring

**Extended Tables:**
- `asset` - Added `is_property`, `property_code`, `qr_code_url`
- `work_order` - Added `task_category`, `booking_event_id`, `checklist_template_id`, `photos_required`, etc.
- `part` - Added `part_category`, `storage_location`, supplier info
- `own_user` - Added `role_type`, `assigned_region`, `phone_number`, etc.

### 002_test_properties.sql
**Status:** ⚠️ Needs manual creation via UI/API

Test data for 3 properties. Due to Atlas using Hibernate-managed IDs, properties should be created through the frontend or API rather than direct SQL.

## How to Run Migrations

### Initial Setup (Migration 001)

```bash
# From project root
docker exec -i atlas_db psql -U rootUser -d atlas < migrations/001_atlas_str_schema_extensions.sql

# Fix foreign key constraints (workaround for IF NOT EXISTS)
docker exec atlas_db psql -U rootUser -d atlas -c "ALTER TABLE work_order ADD CONSTRAINT fk_work_order_booking FOREIGN KEY (booking_event_id) REFERENCES booking_event(id) ON DELETE SET NULL;"
docker exec atlas_db psql -U rootUser -d atlas -c "ALTER TABLE work_order ADD CONSTRAINT fk_work_order_checklist_template FOREIGN KEY (checklist_template_id) REFERENCES checklist_template(id) ON DELETE SET NULL;"
```

### Verify Migration

```bash
# Check new tables exist
docker exec atlas_db psql -U rootUser -d atlas -c "
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('property_metadata', 'checklist_template', 'asset_checklist', 'task_photo', 'booking_event', 'inventory_usage', 'ai_generation_log')
ORDER BY table_name;
"

# Check asset table extensions
docker exec atlas_db psql -U rootUser -d atlas -c "
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'asset'
  AND column_name IN ('is_property', 'property_code', 'qr_code_url');
"
```

## Creating Test Properties

Instead of running `002_test_properties.sql` directly, create properties via the Atlas UI:

### Method 1: Via Atlas Web UI

1. Navigate to http://localhost:3000
2. Login with `superadmin@test.com` / `pls_change_me`
3. Go to **Assets** section
4. Click **"+ New Asset"**
5. Fill in property details:

**Villa 12:**
- Name: `Villa 12`
- Description: `Luxury 3-bedroom villa in Camps Bay with ocean views`
- Location: Create new location "Villa 12"
- Custom fields:
  - `is_property`: ✓ (checked)
  - `property_code`: `VILLA-12`

6. After creating the asset, add property metadata via SQL:

```sql
INSERT INTO property_metadata (
  asset_id,
  listing_platform,
  bedrooms,
  bathrooms,
  max_guests,
  region,
  avg_rating,
  total_reviews
) VALUES (
  1, -- Replace with actual asset ID
  'airbnb',
  3,
  2.0,
  6,
  'Cape Town',
  4.87,
  143
);
```

### Method 2: Via Atlas API (Recommended)

```bash
# 1. Login to get JWT token
TOKEN=$(curl -X POST http://localhost:8080/auth/signin \
  -H "Content-Type: application/json" \
  -d '{"email":"superadmin@test.com","password":"pls_change_me"}' \
  | jq -r '.accessToken')

# 2. Create location
LOCATION_ID=$(curl -X POST http://localhost:8080/locations \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Villa 12",
    "address": "Camps Bay, Cape Town, South Africa"
  }' | jq -r '.id')

# 3. Create asset (property)
ASSET_ID=$(curl -X POST http://localhost:8080/assets \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Villa 12\",
    \"description\": \"Luxury 3-bedroom villa in Camps Bay\",
    \"locationId\": $LOCATION_ID,
    \"status\": 1
  }" | jq -r '.id')

# 4. Add property metadata via SQL
docker exec atlas_db psql -U rootUser -d atlas -c "
INSERT INTO property_metadata (
  asset_id, listing_platform, bedrooms, bathrooms, max_guests, region
) VALUES (
  $ASSET_ID, 'airbnb', 3, 2.0, 6, 'Cape Town'
);
"

# 5. Mark asset as property
docker exec atlas_db psql -U rootUser -d atlas -c "
UPDATE asset SET is_property = TRUE, property_code = 'VILLA-12' WHERE id = $ASSET_ID;
"
```

## Testing the Schema

### Check Properties

```sql
-- View all properties with metadata
SELECT
  a.id,
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
```

### Check Checklist Templates

```sql
-- View checklist templates
SELECT
  id,
  name,
  appliance_type,
  brand,
  model,
  source,
  estimated_duration_minutes,
  times_used
FROM checklist_template
WHERE deleted_at IS NULL;
```

## Rollback (if needed)

⚠️ **WARNING:** This will delete all STR-specific data!

```sql
-- Drop new tables (in reverse order due to foreign keys)
DROP TABLE IF EXISTS ai_generation_log CASCADE;
DROP TABLE IF EXISTS inventory_usage CASCADE;
DROP TABLE IF EXISTS booking_event CASCADE;
DROP TABLE IF EXISTS task_photo CASCADE;
DROP TABLE IF EXISTS asset_checklist CASCADE;
DROP TABLE IF EXISTS checklist_template CASCADE;
DROP TABLE IF EXISTS property_metadata CASCADE;

-- Drop sequences
DROP SEQUENCE IF EXISTS ai_generation_log_seq;
DROP SEQUENCE IF EXISTS inventory_usage_seq;
DROP SEQUENCE IF EXISTS booking_event_seq;
DROP SEQUENCE IF EXISTS task_photo_seq;
DROP SEQUENCE IF EXISTS asset_checklist_seq;
DROP SEQUENCE IF EXISTS checklist_template_seq;
DROP SEQUENCE IF EXISTS property_metadata_seq;

-- Remove added columns from existing tables
ALTER TABLE asset DROP COLUMN IF EXISTS is_property;
ALTER TABLE asset DROP COLUMN IF EXISTS property_code;
ALTER TABLE asset DROP COLUMN IF EXISTS qr_code_url;

ALTER TABLE work_order DROP COLUMN IF EXISTS task_category;
ALTER TABLE work_order DROP COLUMN IF EXISTS booking_event_id;
ALTER TABLE work_order DROP COLUMN IF EXISTS checklist_template_id;
ALTER TABLE work_order DROP COLUMN IF EXISTS checklist_completion_data;
ALTER TABLE work_order DROP COLUMN IF EXISTS photos_required;
ALTER TABLE work_order DROP COLUMN IF EXISTS photos_uploaded;
ALTER TABLE work_order DROP COLUMN IF EXISTS guest_visible;

ALTER TABLE part DROP COLUMN IF EXISTS part_category;
ALTER TABLE part DROP COLUMN IF EXISTS storage_location;
ALTER TABLE part DROP COLUMN IF EXISTS optimal_stock_level;
ALTER TABLE part DROP COLUMN IF EXISTS reorder_lead_time_days;
ALTER TABLE part DROP COLUMN IF EXISTS seasonal_item;
ALTER TABLE part DROP COLUMN IF EXISTS supplier_name;
ALTER TABLE part DROP COLUMN IF EXISTS supplier_url;
ALTER TABLE part DROP COLUMN IF EXISTS supplier_sku;

ALTER TABLE own_user DROP COLUMN IF EXISTS role_type;
ALTER TABLE own_user DROP COLUMN IF EXISTS assigned_region;
ALTER TABLE own_user DROP COLUMN IF EXISTS phone_number;
ALTER TABLE own_user DROP COLUMN IF EXISTS emergency_contact;
ALTER TABLE own_user DROP COLUMN IF EXISTS mobile_push_token;
ALTER TABLE own_user DROP COLUMN IF EXISTS preferred_language;
```

## Next Steps

1. ✅ Migration 001 applied
2. ⏳ Create 3 test properties via API/UI
3. ⏳ Add property metadata
4. ⏳ Test creating work orders with new fields
5. ⏳ Create Week 2 migration for additional features

---

**Last Updated:** 2025-11-08
**Author:** Colin + Claude
**Status:** Schema extended, ready for data population
