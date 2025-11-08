## The Anti-Breezeway Platform for Short-Term Rental Operations

**Version:** 1.0  
**Date:** November 8, 2025  
**Owner:** Colin  
**Status:** Planning Phase

---

## 1. Executive Summary

### Vision

Transform the open-source Atlas CMMS into a purpose-built short-term rental property management and maintenance platform that combines the power of industrial CMMS with AI-driven automation, superior mobile UX, and hospitality-focused workflows.

### Mission Statement

Build the operations platform that Breezeway should have been—fast, intelligent, mobile-first, and designed for property managers who run real businesses.

### Target User

Short-term rental operators managing 10-50+ properties who need:

- Dynamic, AI-generated maintenance checklists
- Efficient turnover coordination
- Real-time issue tracking
- Photo-based documentation
- Mobile-first field operations
- Supply inventory management
- Guest experience protection

---

## 2. Problem Statement

### Current Pain Points

**Breezeway Issues:**

- Hidden menus make property editing difficult
- Static checklists require manual creation for every appliance
- No bulk task upload capability
- Mobile app is slow and crashes frequently
- No offline functionality
- Limited AI/automation capabilities
- Expensive for growing portfolios

**Current Colin's Operations:**

- Using Hospitable (property management) + Airtable (operations database)
- Manual coordination between systems
- Response times of 10-17 seconds for morning briefings
- No automated task generation from bookings
- Manual checklist creation for 22 properties

### The Gap

No platform exists that combines:

- Industrial-grade maintenance tracking (Atlas CMMS)
- STR-specific workflows (turnovers, guest issues)
- AI-powered automation (photo → checklist generation)
- Superior mobile UX (offline-capable, photo-heavy)
- Affordable self-hosted option

---

## 3. Goals & Success Metrics

### Business Goals

1. **Operational Efficiency:** Reduce morning briefing time from 10-17s to <0.1s
2. **Task Automation:** Generate 500+ property-specific tasks from CSV in <2 minutes
3. **Mobile Productivity:** Enable housekeepers to complete turnovers 30% faster
4. **Quality Control:** Increase photo documentation compliance to 95%
5. **Scalability:** Support 50+ properties without performance degradation

### Success Metrics

|Metric|Current|Target|Timeline|
|---|---|---|---|
|Morning briefing response time|10-17s|<0.1s|Week 4|
|Task creation time (bulk)|Manual hours|<2 min for 500 tasks|Week 2|
|Mobile app crash rate|Unknown (Breezeway)|<0.5%|Week 3|
|Photo documentation rate|~40%|95%|Week 6|
|Housekeeper task completion time|Baseline|-30%|Week 8|
|System uptime|N/A|99.5%|Week 12|

### User Satisfaction Goals

- Portia (Ops Manager): "Daily briefings are instant and complete"
- Housekeepers: "Mobile app is faster than Breezeway ever was"
- Colin: "I can scale to 50 properties without hiring more coordinators"

---

## 4. User Personas

### Primary Users

**Colin - Portfolio Owner**

- **Role:** Administrator, strategic oversight
- **Properties:** 22 units across Cape Town & Strand
- **Tech Level:** Advanced ("vibe coder")
- **Pain Points:** Manual system coordination, slow reporting, no automation
- **Goals:** Scale portfolio, reduce operational overhead, maintain quality
- **Usage:** Desktop, morning briefings, analytics, bulk operations

**Portia - Operations Manager**

- **Role:** Daily coordinator, task assignment, quality control
- **Properties:** All 22 units
- **Tech Level:** Intermediate
- **Pain Points:** Time-consuming data entry, chasing housekeepers for updates
- **Goals:** Efficient daily operations, proactive issue resolution
- **Usage:** Desktop + mobile, all-day usage, assignment & tracking

**Daniel, Neddy, Sanela - Housekeepers**

- **Role:** Field execution, turnover cleaning, photo documentation
- **Properties:** Regional assignments (Cape Town / Strand)
- **Tech Level:** Basic to intermediate
- **Pain Points:** Slow mobile app, unclear instructions, no offline mode
- **Goals:** Complete tasks quickly, understand requirements, prove completion
- **Usage:** Mobile-only, 4-8 hours/day, photo-heavy

**Simba - Handyman**

- **Role:** Maintenance repairs, appliance service, property improvements
- **Properties:** All 22 units
- **Tech Level:** Intermediate
- **Pain Points:** Unclear task priorities, missing part information, travel inefficiency
- **Goals:** Batch work efficiently, access technical specs, minimize property visits
- **Usage:** Mobile + desktop, route planning, parts inventory

---

## 5. Core Features

### Phase 1: Foundation (Weeks 1-4)

#### 5.1 Property Management (Rebranded Assets)

**Replaces Atlas "Assets" with STR hierarchy:**

```
Portfolio
  └── Region (Cape Town, Strand)
      └── Property (Newport House, Blouberg Beachfront)
          └── Unit (if multi-unit property)
              └── Space (Master Bedroom, Kitchen, Living Area)
                  └── Feature (Samsung TV, Bosch Dishwasher, Door Lock)
```

**Key Fields:**

- Property name, address, coordinates
- Listing platforms (Airbnb, Vrbo, Booking.com) with URLs
- Capacity (bedrooms, bathrooms, max guests)
- Check-in/out times
- Access instructions (lockbox code, wifi)
- Property manager assignment
- Housekeeper assignment
- Star rating average
- Last inspection date

**New Feature: Property Dashboard**

- One-click "Edit Property" (no hidden menus)
- Visual property card with photo
- Quick stats: upcoming bookings, open tasks, recent issues
- Occupancy calendar view

#### 5.2 Task Management (Rebranded Work Orders)

**Task Categories:**

1. **Guest Experience** - Guest-reported issues during stay (HIGH priority)
2. **Turnover Operations** - Pre-arrival prep, cleaning, restocking (TIME-SENSITIVE)
3. **Routine Maintenance** - Scheduled inspections, appliance checks (PREVENTIVE)
4. **Property Improvements** - Upgrades, renovations (PROJECT)
5. **Inventory Replenishment** - Supply restocking (LOGISTICS)

**Task Attributes:**

- Task name & description
- Property + Space + Feature linkage
- Category & priority
- Assigned to (housekeeper/handyman)
- Due date/time
- Estimated duration
- Photo requirements (minimum count)
- Completion checklist
- Parts/supplies needed
- Cost tracking

**Status Flow:**

```
Open → Assigned → In Progress → Review Required → Completed → Verified
```

**New Feature: Booking-Driven Task Generation**

- Webhook from Hospitable on new booking
- Auto-generate turnover checklist
- Assign to appropriate housekeeper
- Set due date = check-in time - 2 hours

#### 5.3 Dynamic AI Checklists

**The Killer Feature:**

**Input Methods:**

1. Upload appliance photo → AI detects model → generates checklist
2. CSV bulk upload with model numbers → AI generates all checklists
3. Manual entry with model number → AI fetches manual → creates checklist

**AI Checklist Generation Process:**

```
1. User uploads: Property, Space, Appliance Type, Photo/Model
2. AI identifies: Make, Model, Serial (from photo OCR)
3. System fetches: User manual PDF from manufacturer database
4. AI extracts: Maintenance schedule, recommended procedures, part numbers
5. System creates: Task template with steps, photos, intervals, parts
6. User reviews: Edit/approve checklist
7. System schedules: Creates recurring tasks at specified intervals
```

**Example Output:**

yaml

```yaml
Appliance: Bosch Dishwasher SMS88TW06G
Location: Villa 12 - Kitchen
Generated: 2025-11-08

Deep Clean Checklist (Every 6 months):
  1. Remove and clean lower spray arm
     - Photo guide: [link to manual page 23]
     - Tools: Screwdriver, soft brush
     - Time: 5 minutes
  
  2. Clean filter assembly
     - Photo guide: [link]
     - Tools: None (hand removal)
     - Parts: Replace if damaged (Part #00427903)
     - Time: 10 minutes
  
  3. Wipe door seals
     - Photo guide: [link]
     - Products: Mild detergent, soft cloth
     - Time: 5 minutes
  
  4. Run cleaning cycle
     - Product: Finish Dishwasher Cleaner or citric acid
     - Parts: Item in inventory (SKU: CLEAN-DISH-01)
     - Time: 90 minutes (unattended)
  
  5. Check drain hose connection
     - Photo guide: [link]
     - Tools: Flashlight
     - Time: 3 minutes
  
  6. Photo documentation
     - Required: Filter (clean), spray arm, door seals, cycle completion
     - Upload: 4 photos minimum

Total time: 2 hours (including cycle)
Next due: 2026-05-08
Assigned to: Daniel (Cape Town housekeeping)
```

**Checklist Template Storage:**

- Reusable across properties with same appliance
- Version control (track changes)
- Share library with other users (future marketplace)

#### 5.4 Bulk Operations

**CSV Bulk Import:**

**Use Case:** Colin has 22 properties with ~300 appliances. Manually creating checklists would take weeks.

**Solution:** Upload CSV → AI processes all → creates 500+ tasks in <2 minutes

**CSV Format:**

csv

```csv
property_name,space,appliance_type,brand,model,photo_url,serial_number
Villa 12,Kitchen,Dishwasher,Bosch,SMS88TW06G,https://storage.com/v12-dishwasher.jpg,FD9234567890
Villa 12,Kitchen,Coffee Machine,Nespresso,Vertuo Plus,https://storage.com/v12-coffee.jpg,
Villa 12,Living Room,Air Conditioner,Daikin,FTXS35K,https://storage.com/v12-ac.jpg,
Newport House,Master Bedroom,Smart TV,Samsung,QN65Q80C,https://storage.com/np-tv.jpg,
```

**Processing Flow:**

1. Upload CSV file
2. System validates: property exists, required fields present
3. For each row:
    - AI identifies appliance from photo (if provided)
    - Fetches manual based on model
    - Generates maintenance checklist
    - Creates recurring task schedule
    - Links to property → space
4. User reviews summary
5. Confirm to create all tasks

**Success Message:**

```
✓ Processed 47 appliances across 12 properties
✓ Created 283 scheduled tasks
✓ Generated 47 maintenance checklists
✓ Estimated annual maintenance hours: 156

View tasks: [Dashboard Link]
```

#### 5.5 Supply Inventory Management

**Replaces Atlas "Parts" with STR supplies:**

**Categories:**

1. **Guest Consumables** - Coffee, tea, toiletries, welcome packs
2. **Linen & Soft Goods** - Sheets, towels, blankets
3. **Appliance Parts** - Filters, bulbs, remote controls
4. **Cleaning Supplies** - Detergents, disinfectants, tools
5. **Fixtures & Hardware** - Locks, keys, shower heads
6. **Kitchen Equipment** - Dishes, cookware, glassware

**Inventory Tracking:**

- Item name, SKU, category
- Quantity on hand (by storage location)
- Minimum quantity threshold
- Cost per unit
- Supplier information
- Preferred vendor
- Lead time
- Photos of item
- Usage rate (auto-calculated)

**Smart Reorder Alerts:**

- Low stock notifications
- Predictive reordering based on usage patterns
- Batch orders across properties
- Seasonal adjustments (more beach towels in summer)

**Inventory Usage Tracking:**

- Link items to tasks (e.g., coffee used in turnover)
- Auto-decrement on task completion
- Cost allocation to properties
- Monthly consumption reports

---

### Phase 2: Mobile Excellence (Weeks 5-8)

#### 5.6 Mobile App (React Native)

**Design Principles:**

- Mobile-first (design for phone, adapt to desktop)
- Offline-capable (sync when connected)
- Photo-heavy (visual task verification)
- One-handed operation (thumbs reach everything)
- Fast loading (<1s per screen)

**Housekeeper Workflow:**

**Morning View:**

```
Today's Tasks - November 8, 2025

URGENT (2)
  🔴 Villa 12 - Guest reported no hot water
      Due: 9:00 AM (in 45 min)
      [Start Task]
  
  🔴 Newport House - Check-in prep
      Due: 2:00 PM (in 5 hrs)
      [Start Task]

SCHEDULED (5)
  🟡 Blouberg Apt - Turnover clean
      Due: 4:00 PM
      [Start Task]
  
  ... see all
```

**Task Detail View:**

```
Villa 12 - Kitchen
Deep Clean Dishwasher

Status: In Progress (Started 9:23 AM)

Checklist (4/6 complete):
  ✓ Remove spray arm (photo uploaded)
  ✓ Clean filter assembly (photo uploaded)
  ✓ Wipe door seals (photo uploaded)
  ✓ Run cleaning cycle (photo uploaded)
  ○ Check drain hose
  ○ Final documentation

Photos required: 2 more

[📷 Take Photo]
[Add Note]
[Report Issue]
[Complete Task]
```

**Photo Capture:**

- Inline camera (no app switching)
- Auto-compress for bandwidth
- Geolocation tagging
- Before/after mode
- Draw markup on photos (circle damage)
- Voice-to-text notes

**Offline Mode:**

- Download today's tasks on wifi
- Complete tasks offline
- Queue photos for upload
- Sync automatically when connected
- Show pending upload count

**Push Notifications:**

- New task assigned
- Due date approaching (1 hour before)
- Priority changed
- Message from Portia
- Low supplies at property

#### 5.7 Photo Documentation System

**Requirements:**

- Minimum photos per task type
- Before/after comparison views
- Damage documentation workflow
- Guest-visible proof (for disputes)
- AI quality check (is photo clear/relevant?)

**Photo Storage:**

- Supabase Storage
- Organized: `{property_id}/{task_id}/{timestamp}_{photo_number}.jpg`
- Auto-resize: thumbnail (200px), display (800px), full (original)
- Retention: 90 days for routine tasks, 2 years for damage reports

**AI Photo Analysis (Future):**

- Detect common issues (e.g., water stains, broken items)
- Verify task completion (e.g., did they actually clean the filter?)
- Auto-fill damage reports

---

### Phase 3: Intelligence & Integration (Weeks 9-12)

#### 5.8 Hospitable Integration

**Webhook Listeners:**

**On New Booking:**

json

```json
{
  "event": "reservation.created",
  "property_id": "villa_12_id",
  "check_in": "2025-11-15T15:00:00Z",
  "check_out": "2025-11-18T11:00:00Z",
  "guest_name": "John Smith",
  "guest_count": 4
}
```

**Atlas Actions:**

1. Create turnover task (due = check-in - 2 hours)
2. Assign to property housekeeper (Daniel)
3. Generate pre-arrival checklist:
    - Deep clean all rooms
    - Restock consumables (coffee for 4 guests × 3 days)
    - Test all appliances
    - Check wifi, locks, amenities
    - Upload 10 photos minimum
4. Create post-checkout task (due = check-out + 4 hours)
5. Block calendar for turnover window

**On Booking Cancelled:**

- Cancel related tasks
- Free up housekeeper schedule
- Return supplies to inventory

**On Guest Message:**

- Create urgent task if issue reported
- Notify Portia immediately
- Escalate if response required <1 hour

#### 5.9 Airtable Sync (Transition Phase)

**Purpose:** Gradual migration from Airtable to Atlas

**Sync Strategy:**

- One-way sync: Atlas → Airtable (during transition)
- Two-way sync: Airtable ← → Atlas (for reports Colin already built)
- Phase out: Eventually replace Airtable with Atlas analytics

**Data to Sync:**

- Tasks created/completed
- Property data changes
- Inventory levels
- Team assignments

#### 5.10 AI-Powered Features

**Morning Briefing Generator:**

- Query all properties for today's activity
- Generate natural language summary
- Highlight risks/conflicts
- Send to Portia via email/Slack
- Response time: <0.1s (cached overnight)

**Smart Task Assignment:**

- Learn housekeeper strengths (e.g., Daniel is great with appliance repairs)
- Optimize routes (batch nearby properties)
- Balance workloads
- Predict completion times based on history

**Predictive Maintenance:**

- Analyze task history to predict failures
- "Dishwasher at Villa 12 is due for service based on age and usage"
- Auto-schedule preventive tasks

**Supply Consumption Forecasting:**

- "Based on bookings, you'll need 45 coffee pods this week"
- Seasonal patterns (more beach towels in summer)

---

## 6. Technical Architecture

### 6.1 Stack

**Backend:**

- **Framework:** Spring Boot (Java) - Atlas CMMS base
- **Database:** PostgreSQL via Supabase
- **API:** REST + GraphQL for complex queries
- **Auth:** Supabase Auth (JWT-based)
- **Storage:** Supabase Storage (photos, documents)
- **AI:** Claude API for checklist generation, image analysis

**Frontend (Admin/Desktop):**

- **Framework:** React (Atlas CMMS base)
- **State:** Redux Toolkit
- **UI:** Material-UI + custom components
- **Charts:** Recharts for analytics

**Mobile:**

- **Framework:** React Native
- **State:** Redux Toolkit (shared with web)
- **UI:** React Native Paper
- **Offline:** Redux Persist + AsyncStorage
- **Camera:** react-native-vision-camera
- **Maps:** react-native-maps (route optimization)

**AI Services:**

- **LLM:** Anthropic Claude (checklist generation)
- **OCR:** Google Cloud Vision API (serial number extraction from photos)
- **PDF Parsing:** PDF.js (manual extraction)
- **Image Analysis:** Claude Vision (damage detection)

**Integrations:**

- **Hospitable:** Webhooks for booking events
- **Airtable:** REST API (transition sync)
- **Email:** SendGrid (notifications, reports)
- **SMS:** Twilio (urgent alerts)

### 6.2 Database Schema Extensions

**New Tables (add to Atlas CMMS):**

sql

```sql
-- Property-specific metadata (extends Asset)
CREATE TABLE property_metadata (
  id UUID PRIMARY KEY,
  asset_id UUID REFERENCES asset(id),
  listing_platform VARCHAR(50), -- 'airbnb', 'vrbo', 'booking'
  listing_url TEXT,
  listing_id VARCHAR(100),
  check_in_time TIME,
  check_out_time TIME,
  wifi_ssid VARCHAR(100),
  wifi_password VARCHAR(100),
  lockbox_code VARCHAR(20),
  avg_rating DECIMAL(3,2),
  last_deep_clean DATE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Dynamic checklists (AI-generated)
CREATE TABLE checklist_template (
  id UUID PRIMARY KEY,
  appliance_type VARCHAR(100), -- 'dishwasher', 'coffee_machine'
  brand VARCHAR(50),
  model VARCHAR(100),
  source VARCHAR(20), -- 'ai_generated', 'manual', 'imported'
  steps JSONB, -- array of step objects
  photos_required INTEGER,
  estimated_duration_minutes INTEGER,
  frequency_days INTEGER,
  parts_needed JSONB, -- array of part IDs
  created_by UUID REFERENCES user(id),
  created_at TIMESTAMP DEFAULT NOW(),
  version INTEGER DEFAULT 1
);

-- Link templates to assets
CREATE TABLE asset_checklist (
  id UUID PRIMARY KEY,
  asset_id UUID REFERENCES asset(id),
  template_id UUID REFERENCES checklist_template(id),
  next_due_date DATE,
  last_completed_date DATE,
  assigned_to UUID REFERENCES user(id),
  recurring BOOLEAN DEFAULT TRUE,
  active BOOLEAN DEFAULT TRUE
);

-- Photo documentation
CREATE TABLE task_photo (
  id UUID PRIMARY KEY,
  work_order_id UUID REFERENCES work_order(id),
  file_path TEXT, -- Supabase storage path
  thumbnail_path TEXT,
  uploaded_by UUID REFERENCES user(id),
  uploaded_at TIMESTAMP DEFAULT NOW(),
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  is_before BOOLEAN,
  ai_analysis JSONB, -- damage detection, quality check
  notes TEXT
);

-- Booking integration
CREATE TABLE booking_event (
  id UUID PRIMARY KEY,
  property_id UUID REFERENCES asset(id),
  external_id VARCHAR(100), -- Hospitable reservation ID
  platform VARCHAR(50),
  check_in TIMESTAMP,
  check_out TIMESTAMP,
  guest_name VARCHAR(200),
  guest_count INTEGER,
  status VARCHAR(50), -- 'confirmed', 'cancelled', 'completed'
  tasks_generated JSONB, -- array of work_order IDs created
  received_at TIMESTAMP DEFAULT NOW()
);

-- Supply consumption tracking
CREATE TABLE inventory_usage (
  id UUID PRIMARY KEY,
  part_id UUID REFERENCES part(id),
  work_order_id UUID REFERENCES work_order(id),
  quantity_used INTEGER,
  cost DECIMAL(10,2),
  used_by UUID REFERENCES user(id),
  used_at TIMESTAMP DEFAULT NOW()
);
```

### 6.3 API Endpoints (New)

**AI Checklist Generation:**

```
POST /api/checklist/generate
Body: {
  "appliance_type": "dishwasher",
  "brand": "Bosch",
  "model": "SMS88TW06G",
  "photo_base64": "data:image/jpeg;base64,..."
}
Response: {
  "template_id": "uuid",
  "steps": [...],
  "estimated_duration": 120,
  "parts_needed": [...]
}
```

**Bulk Import:**

```
POST /api/import/csv
Body: multipart/form-data (CSV file)
Response: {
  "processed": 47,
  "tasks_created": 283,
  "templates_created": 31,
  "errors": []
}
```

**Morning Briefing:**

```
GET /api/briefing/today
Query: ?date=2025-11-08
Response: {
  "summary": "8 check-ins, 5 check-outs, 2 urgent tasks...",
  "check_ins": [...],
  "check_outs": [...],
  "urgent_tasks": [...],
  "team_schedule": {...},
  "supply_alerts": [...]
}
```

**Mobile Sync:**

```
POST /api/mobile/sync
Body: {
  "last_sync": "2025-11-08T09:00:00Z",
  "pending_tasks": [...],
  "pending_photos": [...]
}
Response: {
  "new_tasks": [...],
  "updated_tasks": [...],
  "server_time": "2025-11-08T11:30:00Z"
}
```

---

## 7. Roadmap

### Week 1-2: Foundation

- ✓ Fork Atlas CMMS
- ✓ Setup local development environment
- ✓ Connect to Supabase
- □ Rebrand UI terminology (Asset → Property, Work Order → Task)
- □ Add property metadata schema
- □ Basic property dashboard

### Week 3-4: AI Core

- □ Implement photo upload endpoint
- □ Integrate Claude API for checklist generation
- □ Build checklist template system
- □ Test with 5 real appliances

### Week 5-6: Bulk Operations

- □ CSV parser and validator
- □ Bulk AI generation pipeline
- □ Progress tracking UI
- □ Test with full 22-property inventory

### Week 7-8: Mobile App (MVP)

- □ React Native project setup
- □ Task list view
- □ Task detail with checklist
- □ Photo capture and upload
- □ Offline sync

### Week 9-10: Integrations

- □ Hospitable webhook receiver
- □ Booking → Task automation
- □ Airtable sync (one-way)
- □ Email notifications

### Week 11-12: Analytics & Polish

- □ Morning briefing generator
- □ Mobile analytics dashboard
- □ Performance optimization
- □ User acceptance testing with Portia & housekeepers
- □ Production deployment

### Week 13+: Advanced Features

- □ Smart task assignment
- □ Predictive maintenance
- □ Supply forecasting
- □ Guest-facing status updates
- □ Marketplace for checklist templates

---

## 8. Success Criteria

### Must-Have (Launch Blockers)

- ✓ Property management with 22 properties configured
- ✓ Task creation and assignment
- ✓ AI checklist generation (80%+ accuracy)
- ✓ Bulk CSV import (<2 min for 500 tasks)
- ✓ Mobile app (task list, checklist, photo upload)
- ✓ Hospitable booking integration
- ✓ Photo storage and viewing

### Should-Have (Post-Launch Priority)

- Morning briefing automation
- Offline mobile sync
- Supply inventory tracking
- Route optimization for housekeepers
- Airtable two-way sync

### Nice-to-Have (Future)

- AI damage detection
- Guest communication portal
- Template marketplace
- Multi-language support
- White-label for other property managers

---

## 9. Risks & Mitigations

|Risk|Impact|Probability|Mitigation|
|---|---|---|---|
|AI generates inaccurate checklists|High|Medium|Human review before first use, feedback loop for improvements|
|Mobile app performance issues|High|Low|Offline-first design, optimize image compression, use React Native performance tools|
|Hospitable API changes|Medium|Low|Version API calls, monitor deprecation notices, maintain fallback to manual entry|
|Database migration data loss|High|Low|Full backup before migration, test on staging environment, rollback plan|
|Team adoption resistance|Medium|Medium|Involve Portia and housekeepers in testing, provide training, gradual rollout|
|Photo storage costs|Low|Medium|Implement auto-deletion policy (90 days), image compression, monitor usage|

---

## 10. Budget & Resources

### Development Time

- **Colin (vibe coding):** 20-30 hours/week × 12 weeks = 240-360 hours
- **Claude Code (AI assist):** Reduce development time by ~40%

### Infrastructure Costs (Monthly)

- **Supabase Pro:** $25/month (includes 8GB database, 100GB storage)
- **Anthropic API:** ~$50/month (1M tokens for checklist generation)
- **Google Cloud Vision:** ~$20/month (OCR for serial numbers)
- **Vercel/Netlify:** $0 (hobby tier sufficient)
- **SendGrid:** $0 (free tier 100 emails/day)
- **Total:** ~$95/month (~R1,800/month)

### Potential Revenue

- **Internal use:** R5M annual revenue ÷ improved efficiency = ~R500K+ value/year
- **Future SaaS:** R999/month × 50 property managers = R50K/month

---

## 11. Next Steps

### Immediate Actions

1. **Fork Atlas CMMS** - Get code running locally
2. **Create Supabase project** - Setup database and storage
3. **Document 5 test appliances** - Real data from Villa 12, Newport House
4. **Define first CSV import** - 22 properties, top 10 appliances each
5. **Sketch mobile UI** - Wireframes for housekeeper workflows

### Week 1 Deliverables

- Running Atlas locally with Supabase connection
- Property table with 22 properties imported
- First AI-generated checklist (Bosch dishwasher)
- Mobile app repository created
- This PRD reviewed by Portia

---

## 12. Appendix

### Terminology Map (Atlas → Atlas STR)

- Asset → Property/Feature
- Location → Property/Unit
- Work Order → Task
- PM Task → Routine Inspection
- Part → Supply Item
- Technician → Service Team Member
- Downtime → Property Unavailable

### Key Competitors

- **Breezeway:** $0.50-1.00/unit/day, clunky UX, no AI
- **Properly:** $3-5/unit/day, expensive, less customizable
- **Operto:** $2-4/unit/day, focused on access control
- **Atlas STR:** $0.10/unit/day self-hosted, unlimited customization, AI-powered

### References

- Atlas CMMS GitHub: [https://github.com/Grashjs/cmms](https://github.com/Grashjs/cmms)
- Atlas Docs: [https://docs.atlas-cmms.com/](https://docs.atlas-cmms.com/)
- Supabase Docs: [https://supabase.com/docs](https://supabase.com/docs)
- React Native Docs: [https://reactnative.dev/](https://reactnative.dev/)
- Anthropic API: [https://docs.anthropic.com/](https://docs.anthropic.com/)

---

**Document Version History:**

- v1.0 (2025-11-08): Initial PRD created with Colin