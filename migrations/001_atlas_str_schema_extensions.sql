-- ============================================================================
-- Atlas STR Schema Extensions - Migration 001
-- ============================================================================
-- Purpose: Extend Atlas CMMS database schema for short-term rental management
-- Date: 2025-11-08
-- Author: Colin + Claude
--
-- IMPORTANT: This migration extends Atlas CMMS, it does not replace it!
-- All original Atlas tables remain intact.
-- ============================================================================

-- ============================================================================
-- 1. ENABLE REQUIRED EXTENSIONS
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For similarity search

-- ============================================================================
-- 2. CREATE SEQUENCE GENERATORS (Atlas uses bigint, not UUIDs)
-- ============================================================================

CREATE SEQUENCE IF NOT EXISTS property_metadata_seq START 1;
CREATE SEQUENCE IF NOT EXISTS checklist_template_seq START 1;
CREATE SEQUENCE IF NOT EXISTS asset_checklist_seq START 1;
CREATE SEQUENCE IF NOT EXISTS task_photo_seq START 1;
CREATE SEQUENCE IF NOT EXISTS booking_event_seq START 1;
CREATE SEQUENCE IF NOT EXISTS inventory_usage_seq START 1;
CREATE SEQUENCE IF NOT EXISTS ai_generation_log_seq START 1;

-- ============================================================================
-- 3. EXTEND EXISTING ATLAS TABLES
-- ============================================================================

-- -----------------------------
-- Asset Table Extensions
-- -----------------------------
ALTER TABLE asset ADD COLUMN IF NOT EXISTS is_property BOOLEAN DEFAULT FALSE;
ALTER TABLE asset ADD COLUMN IF NOT EXISTS property_code VARCHAR(20);
ALTER TABLE asset ADD COLUMN IF NOT EXISTS qr_code_url TEXT;

CREATE INDEX IF NOT EXISTS idx_asset_is_property ON asset(is_property) WHERE is_property = TRUE;
CREATE INDEX IF NOT EXISTS idx_asset_property_code ON asset(property_code) WHERE property_code IS NOT NULL;

COMMENT ON COLUMN asset.is_property IS 'True if this asset represents a property/listing';
COMMENT ON COLUMN asset.property_code IS 'Short code for property (e.g., VILLA-12, NPH)';
COMMENT ON COLUMN asset.qr_code_url IS 'QR code link for mobile access';

-- -----------------------------
-- Work Order Table Extensions
-- -----------------------------
ALTER TABLE work_order ADD COLUMN IF NOT EXISTS task_category VARCHAR(50);
ALTER TABLE work_order ADD COLUMN IF NOT EXISTS booking_event_id BIGINT;
ALTER TABLE work_order ADD COLUMN IF NOT EXISTS checklist_template_id BIGINT;
ALTER TABLE work_order ADD COLUMN IF NOT EXISTS checklist_completion_data JSONB;
ALTER TABLE work_order ADD COLUMN IF NOT EXISTS photos_required INTEGER DEFAULT 0;
ALTER TABLE work_order ADD COLUMN IF NOT EXISTS photos_uploaded INTEGER DEFAULT 0;
ALTER TABLE work_order ADD COLUMN IF NOT EXISTS guest_visible BOOLEAN DEFAULT FALSE;

CREATE INDEX IF NOT EXISTS idx_work_order_category ON work_order(task_category);
CREATE INDEX IF NOT EXISTS idx_work_order_booking ON work_order(booking_event_id);
CREATE INDEX IF NOT EXISTS idx_work_order_checklist ON work_order(checklist_template_id);

COMMENT ON COLUMN work_order.task_category IS 'Task type: guest_experience, turnover, routine_maintenance, improvement, inventory';
COMMENT ON COLUMN work_order.booking_event_id IS 'Link to booking that triggered this task';
COMMENT ON COLUMN work_order.checklist_template_id IS 'Template used for this task';
COMMENT ON COLUMN work_order.checklist_completion_data IS 'JSON tracking checklist step completion';
COMMENT ON COLUMN work_order.guest_visible IS 'Can guest see this task status?';

-- -----------------------------
-- Part Table Extensions
-- -----------------------------
ALTER TABLE part ADD COLUMN IF NOT EXISTS part_category VARCHAR(50);
ALTER TABLE part ADD COLUMN IF NOT EXISTS storage_location VARCHAR(100);
ALTER TABLE part ADD COLUMN IF NOT EXISTS optimal_stock_level INTEGER;
ALTER TABLE part ADD COLUMN IF NOT EXISTS reorder_lead_time_days INTEGER;
ALTER TABLE part ADD COLUMN IF NOT EXISTS seasonal_item BOOLEAN DEFAULT FALSE;
ALTER TABLE part ADD COLUMN IF NOT EXISTS supplier_name VARCHAR(200);
ALTER TABLE part ADD COLUMN IF NOT EXISTS supplier_url TEXT;
ALTER TABLE part ADD COLUMN IF NOT EXISTS supplier_sku VARCHAR(100);

CREATE INDEX IF NOT EXISTS idx_part_category ON part(part_category);
CREATE INDEX IF NOT EXISTS idx_part_storage ON part(storage_location);

COMMENT ON COLUMN part.part_category IS 'Category: guest_consumables, linen, appliance_parts, cleaning_supplies, fixtures, kitchen';
COMMENT ON COLUMN part.storage_location IS 'Physical location of stored inventory';

-- -----------------------------
-- Users Table Extensions
-- -----------------------------
ALTER TABLE own_user ADD COLUMN IF NOT EXISTS role_type VARCHAR(50);
ALTER TABLE own_user ADD COLUMN IF NOT EXISTS assigned_region VARCHAR(50);
ALTER TABLE own_user ADD COLUMN IF NOT EXISTS phone_number VARCHAR(50);
ALTER TABLE own_user ADD COLUMN IF NOT EXISTS emergency_contact TEXT;
ALTER TABLE own_user ADD COLUMN IF NOT EXISTS mobile_push_token TEXT;
ALTER TABLE own_user ADD COLUMN IF NOT EXISTS preferred_language VARCHAR(10) DEFAULT 'en';

CREATE INDEX IF NOT EXISTS idx_users_role ON own_user(role_type);
CREATE INDEX IF NOT EXISTS idx_users_region ON own_user(assigned_region);

COMMENT ON COLUMN own_user.role_type IS 'Role: portfolio_owner, operations_manager, housekeeper, handyman, admin';
COMMENT ON COLUMN own_user.assigned_region IS 'Geographic region assigned (e.g., Cape Town, Strand)';

-- ============================================================================
-- 4. CREATE NEW STR-SPECIFIC TABLES
-- ============================================================================

-- -----------------------------
-- Property Metadata Table
-- -----------------------------
CREATE TABLE IF NOT EXISTS property_metadata (
  id BIGINT PRIMARY KEY DEFAULT nextval('property_metadata_seq'),
  asset_id BIGINT NOT NULL REFERENCES asset(id) ON DELETE CASCADE,

  -- Listing Information
  listing_platform VARCHAR(50), -- 'airbnb', 'vrbo', 'booking', 'direct'
  listing_url TEXT,
  listing_id VARCHAR(100), -- External platform ID

  -- Access Details
  check_in_time TIME DEFAULT '15:00:00',
  check_out_time TIME DEFAULT '11:00:00',
  wifi_ssid VARCHAR(100),
  wifi_password VARCHAR(100),
  lockbox_code VARCHAR(20),
  access_instructions TEXT,
  parking_instructions TEXT,

  -- Property Details
  property_type VARCHAR(50), -- 'apartment', 'house', 'villa', 'cottage'
  bedrooms INTEGER,
  bathrooms DECIMAL(3,1), -- 2.5 for 2 full + 1 half bath
  max_guests INTEGER,
  square_meters INTEGER,

  -- Performance Tracking
  avg_rating DECIMAL(3,2), -- 4.87
  total_reviews INTEGER DEFAULT 0,
  total_bookings INTEGER DEFAULT 0,

  -- Maintenance Tracking
  last_deep_clean DATE,
  last_safety_inspection DATE,
  last_appliance_service DATE,
  next_scheduled_maintenance DATE,

  -- Regional Assignment
  region VARCHAR(50), -- 'Cape Town', 'Strand'
  primary_housekeeper_id BIGINT REFERENCES own_user(id),
  backup_housekeeper_id BIGINT REFERENCES own_user(id),
  handyman_id BIGINT REFERENCES own_user(id),

  -- Flags
  guest_favorite BOOLEAN DEFAULT FALSE,
  requires_special_attention BOOLEAN DEFAULT FALSE,
  pet_friendly BOOLEAN DEFAULT FALSE,

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  -- Constraints
  CONSTRAINT unique_asset_property UNIQUE(asset_id),
  CONSTRAINT check_rating CHECK (avg_rating >= 0 AND avg_rating <= 5)
);

CREATE INDEX IF NOT EXISTS idx_property_region ON property_metadata(region);
CREATE INDEX IF NOT EXISTS idx_property_housekeeper ON property_metadata(primary_housekeeper_id);
CREATE INDEX IF NOT EXISTS idx_property_listing_platform ON property_metadata(listing_platform);

COMMENT ON TABLE property_metadata IS 'STR-specific metadata for property assets';

-- -----------------------------
-- Checklist Template Table
-- -----------------------------
CREATE TABLE IF NOT EXISTS checklist_template (
  id BIGINT PRIMARY KEY DEFAULT nextval('checklist_template_seq'),

  -- Identification
  name VARCHAR(200) NOT NULL,
  description TEXT,
  appliance_type VARCHAR(100), -- 'dishwasher', 'coffee_machine', 'air_conditioner'
  brand VARCHAR(50),
  model VARCHAR(100),

  -- Source Tracking
  source VARCHAR(20) NOT NULL, -- 'ai_generated', 'manual', 'imported', 'community'
  manual_pdf_url TEXT, -- Link to manufacturer manual

  -- Checklist Steps (JSONB for flexibility)
  steps JSONB NOT NULL,
  -- Example structure:
  -- [
  --   {
  --     "order": 1,
  --     "title": "Remove spray arm",
  --     "description": "Twist counterclockwise to remove",
  --     "photo_guide_url": "https://...",
  --     "video_url": "https://...",
  --     "estimated_minutes": 5,
  --     "tools_required": ["screwdriver"],
  --     "requires_photo": true,
  --     "safety_warning": "Turn off power first"
  --   }
  -- ]

  -- Requirements
  photos_required INTEGER DEFAULT 0,
  min_photos_per_step INTEGER DEFAULT 0,
  estimated_duration_minutes INTEGER,

  -- Scheduling
  frequency_type VARCHAR(20), -- 'days', 'weeks', 'months', 'years', 'usage_based'
  frequency_value INTEGER, -- e.g., 6 for "every 6 months"
  seasonal_only BOOLEAN DEFAULT FALSE, -- e.g., AC service in summer

  -- Parts & Supplies
  parts_needed JSONB, -- [{"part_id": 123, "quantity": 1, "optional": false}]
  supplies_needed JSONB, -- [{"name": "Citric acid", "quantity": "100g"}]

  -- Difficulty & Skills
  difficulty_level VARCHAR(20), -- 'easy', 'medium', 'hard', 'professional'
  required_skills TEXT[], -- {'basic_plumbing', 'electrical_knowledge'}
  requires_two_people BOOLEAN DEFAULT FALSE,

  -- AI Metadata (if AI-generated)
  ai_confidence_score DECIMAL(3,2), -- 0.95 = 95% confidence
  ai_model VARCHAR(50), -- 'claude-3-sonnet-20240229'
  ai_generation_date TIMESTAMP,

  -- Usage Tracking
  times_used INTEGER DEFAULT 0,
  avg_completion_time_minutes INTEGER,
  success_rate DECIMAL(5,2), -- % of times completed without issues

  -- Versioning
  version INTEGER DEFAULT 1,
  previous_version_id BIGINT REFERENCES checklist_template(id),

  -- Ownership
  created_by BIGINT REFERENCES own_user(id),
  is_public BOOLEAN DEFAULT FALSE, -- Share with other users?
  company_id BIGINT REFERENCES company(id),

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  deleted_at TIMESTAMP, -- Soft delete

  -- Constraints
  CONSTRAINT check_frequency CHECK (frequency_value > 0 OR frequency_value IS NULL),
  CONSTRAINT check_confidence CHECK (ai_confidence_score >= 0 AND ai_confidence_score <= 1 OR ai_confidence_score IS NULL)
);

CREATE INDEX IF NOT EXISTS idx_checklist_appliance ON checklist_template(appliance_type);
CREATE INDEX IF NOT EXISTS idx_checklist_brand_model ON checklist_template(brand, model);
CREATE INDEX IF NOT EXISTS idx_checklist_company ON checklist_template(company_id);
CREATE INDEX IF NOT EXISTS idx_checklist_public ON checklist_template(is_public) WHERE is_public = TRUE;
CREATE INDEX IF NOT EXISTS idx_checklist_active ON checklist_template(deleted_at) WHERE deleted_at IS NULL;

-- Full-text search on name and description
CREATE INDEX IF NOT EXISTS idx_checklist_search ON checklist_template
  USING gin(to_tsvector('english', name || ' ' || COALESCE(description, '')));

COMMENT ON TABLE checklist_template IS 'Reusable maintenance checklists (AI-generated or manual)';

-- -----------------------------
-- Asset Checklist Assignment Table
-- -----------------------------
CREATE TABLE IF NOT EXISTS asset_checklist (
  id BIGINT PRIMARY KEY DEFAULT nextval('asset_checklist_seq'),

  -- Links
  asset_id BIGINT NOT NULL REFERENCES asset(id) ON DELETE CASCADE,
  template_id BIGINT NOT NULL REFERENCES checklist_template(id) ON DELETE CASCADE,

  -- Scheduling
  next_due_date DATE NOT NULL,
  last_completed_date DATE,
  last_completed_work_order_id BIGINT REFERENCES work_order(id),

  -- Assignment
  assigned_to BIGINT REFERENCES own_user(id),
  assigned_team_id BIGINT REFERENCES team(id),

  -- Status
  recurring BOOLEAN DEFAULT TRUE,
  active BOOLEAN DEFAULT TRUE,
  auto_create_work_order BOOLEAN DEFAULT TRUE, -- Auto-create task when due?

  -- Customization (override template defaults)
  custom_frequency_days INTEGER, -- Override template frequency
  custom_estimated_minutes INTEGER,
  notes TEXT,

  -- Performance Tracking
  times_completed INTEGER DEFAULT 0,
  avg_actual_duration_minutes INTEGER,
  avg_compliance_score DECIMAL(3,2), -- How well steps were followed

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  -- Constraints
  CONSTRAINT unique_asset_template UNIQUE(asset_id, template_id)
);

CREATE INDEX IF NOT EXISTS idx_asset_checklist_asset ON asset_checklist(asset_id);
CREATE INDEX IF NOT EXISTS idx_asset_checklist_due_date ON asset_checklist(next_due_date) WHERE active = TRUE;
CREATE INDEX IF NOT EXISTS idx_asset_checklist_assigned ON asset_checklist(assigned_to);
CREATE INDEX IF NOT EXISTS idx_asset_checklist_active ON asset_checklist(active) WHERE active = TRUE;

COMMENT ON TABLE asset_checklist IS 'Links checklists to specific assets and tracks scheduling';

-- -----------------------------
-- Task Photo Table
-- -----------------------------
CREATE TABLE IF NOT EXISTS task_photo (
  id BIGINT PRIMARY KEY DEFAULT nextval('task_photo_seq'),

  -- Links
  work_order_id BIGINT NOT NULL REFERENCES work_order(id) ON DELETE CASCADE,
  checklist_step_order INTEGER, -- Which step this photo is for (null = general)

  -- File Storage (MinIO/Supabase Storage)
  file_path TEXT NOT NULL, -- e.g., "properties/villa-12/tasks/task-id/photo1.jpg"
  thumbnail_path TEXT,
  file_size_bytes INTEGER,
  mime_type VARCHAR(50) DEFAULT 'image/jpeg',

  -- Photo Metadata
  is_before BOOLEAN DEFAULT FALSE, -- Before/after comparison
  is_damage_report BOOLEAN DEFAULT FALSE,
  photo_type VARCHAR(50), -- 'completion_proof', 'damage', 'before', 'after', 'general'

  -- Geolocation
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  location_accuracy_meters DECIMAL(6,2),

  -- AI Analysis (optional)
  ai_analysis JSONB,
  -- Example:
  -- {
  --   "detected_objects": ["dishwasher", "spray_arm"],
  --   "quality_score": 0.87,
  --   "is_blurry": false,
  --   "damage_detected": false,
  --   "confidence": 0.92
  -- }

  -- User Data
  uploaded_by BIGINT NOT NULL REFERENCES own_user(id),
  caption TEXT,
  notes TEXT,

  -- Approval (for quality control)
  requires_approval BOOLEAN DEFAULT FALSE,
  approved_by BIGINT REFERENCES own_user(id),
  approved_at TIMESTAMP,
  rejected_reason TEXT,

  -- Metadata
  uploaded_at TIMESTAMP DEFAULT NOW(),
  deleted_at TIMESTAMP, -- Soft delete

  -- Constraints
  CONSTRAINT check_geo_lat CHECK (latitude >= -90 AND latitude <= 90 OR latitude IS NULL),
  CONSTRAINT check_geo_lon CHECK (longitude >= -180 AND longitude <= 180 OR longitude IS NULL)
);

CREATE INDEX IF NOT EXISTS idx_task_photo_work_order ON task_photo(work_order_id);
CREATE INDEX IF NOT EXISTS idx_task_photo_uploaded_by ON task_photo(uploaded_by);
CREATE INDEX IF NOT EXISTS idx_task_photo_type ON task_photo(photo_type);
CREATE INDEX IF NOT EXISTS idx_task_photo_approval ON task_photo(requires_approval, approved_at)
  WHERE requires_approval = TRUE;

COMMENT ON TABLE task_photo IS 'Photos attached to work orders/tasks';

-- -----------------------------
-- Booking Event Table
-- -----------------------------
CREATE TABLE IF NOT EXISTS booking_event (
  id BIGINT PRIMARY KEY DEFAULT nextval('booking_event_seq'),

  -- External IDs
  external_id VARCHAR(100) NOT NULL, -- Hospitable reservation ID
  platform VARCHAR(50) NOT NULL, -- 'airbnb', 'vrbo', 'booking', 'direct'
  external_url TEXT, -- Link to booking on platform

  -- Property Link
  property_id BIGINT NOT NULL REFERENCES asset(id),

  -- Dates
  check_in TIMESTAMP NOT NULL,
  check_out TIMESTAMP NOT NULL,
  booking_created_at TIMESTAMP,

  -- Guest Information
  guest_name VARCHAR(200),
  guest_email VARCHAR(255),
  guest_phone VARCHAR(50),
  guest_count INTEGER NOT NULL,

  -- Booking Details
  status VARCHAR(50) NOT NULL, -- 'confirmed', 'cancelled', 'modified', 'completed', 'no_show'
  previous_status VARCHAR(50), -- For tracking status changes
  confirmation_code VARCHAR(50),

  -- Pricing (optional)
  total_price_cents INTEGER,
  currency VARCHAR(3) DEFAULT 'ZAR',

  -- Special Requests
  special_requests TEXT,
  has_pets BOOLEAN DEFAULT FALSE,
  early_check_in BOOLEAN DEFAULT FALSE,
  late_check_out BOOLEAN DEFAULT FALSE,

  -- Task Generation
  tasks_generated JSONB, -- Array of work_order IDs created: [123, 124]
  pre_arrival_task_id BIGINT REFERENCES work_order(id),
  post_checkout_task_id BIGINT REFERENCES work_order(id),
  tasks_generated_at TIMESTAMP,

  -- Webhook Metadata
  webhook_payload JSONB, -- Store full webhook for debugging
  received_at TIMESTAMP DEFAULT NOW(),
  processed BOOLEAN DEFAULT FALSE,
  processed_at TIMESTAMP,
  processing_errors TEXT,

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  -- Constraints
  CONSTRAINT unique_external_booking UNIQUE(external_id, platform),
  CONSTRAINT check_dates CHECK (check_out > check_in)
);

CREATE INDEX IF NOT EXISTS idx_booking_property ON booking_event(property_id);
CREATE INDEX IF NOT EXISTS idx_booking_status ON booking_event(status);
CREATE INDEX IF NOT EXISTS idx_booking_check_in ON booking_event(check_in);
CREATE INDEX IF NOT EXISTS idx_booking_external ON booking_event(external_id, platform);
CREATE INDEX IF NOT EXISTS idx_booking_unprocessed ON booking_event(processed) WHERE processed = FALSE;

COMMENT ON TABLE booking_event IS 'Booking webhooks from Hospitable and other platforms';

-- -----------------------------
-- Inventory Usage Table
-- -----------------------------
CREATE TABLE IF NOT EXISTS inventory_usage (
  id BIGINT PRIMARY KEY DEFAULT nextval('inventory_usage_seq'),

  -- Links
  part_id BIGINT NOT NULL REFERENCES part(id) ON DELETE CASCADE,
  work_order_id BIGINT REFERENCES work_order(id),
  asset_id BIGINT REFERENCES asset(id), -- Property where used

  -- Usage Details
  quantity_used DECIMAL(10,2) NOT NULL,
  unit VARCHAR(20), -- 'units', 'kg', 'liters', 'pods'

  -- Cost Tracking
  unit_cost_cents INTEGER,
  total_cost_cents INTEGER,
  currency VARCHAR(3) DEFAULT 'ZAR',

  -- Context
  usage_type VARCHAR(50), -- 'task_completion', 'restocking', 'waste', 'guest_complaint'
  notes TEXT,

  -- User Tracking
  used_by BIGINT REFERENCES own_user(id),
  used_at TIMESTAMP DEFAULT NOW(),

  -- Approval (for expensive items)
  requires_approval BOOLEAN DEFAULT FALSE,
  approved_by BIGINT REFERENCES own_user(id),
  approved_at TIMESTAMP,

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_inventory_usage_part ON inventory_usage(part_id);
CREATE INDEX IF NOT EXISTS idx_inventory_usage_work_order ON inventory_usage(work_order_id);
CREATE INDEX IF NOT EXISTS idx_inventory_usage_asset ON inventory_usage(asset_id);
CREATE INDEX IF NOT EXISTS idx_inventory_usage_date ON inventory_usage(used_at);

COMMENT ON TABLE inventory_usage IS 'Tracks supply consumption per task/property';

-- -----------------------------
-- AI Generation Log Table
-- -----------------------------
CREATE TABLE IF NOT EXISTS ai_generation_log (
  id BIGINT PRIMARY KEY DEFAULT nextval('ai_generation_log_seq'),

  -- Request Details
  request_type VARCHAR(50) NOT NULL, -- 'checklist_generation', 'photo_analysis', 'damage_detection'
  model VARCHAR(50) NOT NULL, -- 'claude-3-sonnet-20240229'

  -- Input
  input_data JSONB NOT NULL,
  -- Example for checklist:
  -- {
  --   "appliance_type": "dishwasher",
  --   "brand": "Bosch",
  --   "model": "SMS88TW06G",
  --   "photo_url": "https://..."
  -- }

  -- Output
  output_data JSONB,
  success BOOLEAN DEFAULT FALSE,
  error_message TEXT,

  -- Performance
  response_time_ms INTEGER,
  tokens_used INTEGER,
  estimated_cost_cents INTEGER,

  -- Links
  checklist_template_id BIGINT REFERENCES checklist_template(id),
  work_order_id BIGINT REFERENCES work_order(id),
  photo_id BIGINT REFERENCES task_photo(id),

  -- User
  requested_by BIGINT REFERENCES own_user(id),

  -- Metadata
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_log_type ON ai_generation_log(request_type);
CREATE INDEX IF NOT EXISTS idx_ai_log_date ON ai_generation_log(created_at);
CREATE INDEX IF NOT EXISTS idx_ai_log_user ON ai_generation_log(requested_by);
CREATE INDEX IF NOT EXISTS idx_ai_log_success ON ai_generation_log(success);

COMMENT ON TABLE ai_generation_log IS 'Tracks AI API calls for debugging and cost monitoring';

-- ============================================================================
-- 5. CREATE TRIGGERS FOR AUTO-UPDATING TIMESTAMPS
-- ============================================================================

-- Updated timestamp trigger function
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers
CREATE TRIGGER property_metadata_updated
BEFORE UPDATE ON property_metadata
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER checklist_template_updated
BEFORE UPDATE ON checklist_template
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER asset_checklist_updated
BEFORE UPDATE ON asset_checklist
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER booking_event_updated
BEFORE UPDATE ON booking_event
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- ============================================================================
-- 6. ADD FOREIGN KEY CONSTRAINTS TO WORK_ORDER (deferred from section 3)
-- ============================================================================

ALTER TABLE work_order
  ADD CONSTRAINT IF NOT EXISTS fk_work_order_booking
  FOREIGN KEY (booking_event_id) REFERENCES booking_event(id) ON DELETE SET NULL;

ALTER TABLE work_order
  ADD CONSTRAINT IF NOT EXISTS fk_work_order_checklist_template
  FOREIGN KEY (checklist_template_id) REFERENCES checklist_template(id) ON DELETE SET NULL;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

-- Log migration completion
DO $$
BEGIN
  RAISE NOTICE 'Atlas STR Migration 001 completed successfully!';
  RAISE NOTICE 'Created 7 new tables:';
  RAISE NOTICE '  - property_metadata';
  RAISE NOTICE '  - checklist_template';
  RAISE NOTICE '  - asset_checklist';
  RAISE NOTICE '  - task_photo';
  RAISE NOTICE '  - booking_event';
  RAISE NOTICE '  - inventory_usage';
  RAISE NOTICE '  - ai_generation_log';
  RAISE NOTICE 'Extended 4 existing Atlas tables with STR-specific columns';
END $$;
