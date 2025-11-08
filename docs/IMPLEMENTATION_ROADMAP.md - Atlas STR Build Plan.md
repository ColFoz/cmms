## Project Vision

Transform Atlas CMMS into a purpose-built short-term rental property management platform with AI-powered automation, mobile-first design, and hospitality-focused workflows.

**Target:** Production-ready in 12 weeks for 22 properties generating R5M+ annual revenue.

---

## Phase 1: Foundation (Weeks 1-2)

### Week 1: Setup & Database

**Goal:** Get Atlas running locally and connected to Supabase

- [ ]  **Day 1-2: Environment Setup**
    - [ ]  Fork Atlas CMMS repo
    - [ ]  Clone locally and run `docker-compose up`
    - [ ]  Verify login works ([admin@admin.com](mailto:admin@admin.com) / admin)
    - [ ]  Create Supabase account and new project
    - [ ]  Configure Supabase connection in `application.properties`
    - [ ]  Test database connection
- [ ]  **Day 3-4: Database Schema**
    - [ ]  Run `DATABASE_SCHEMA.md` migrations
    - [ ]  Create new tables: `property_metadata`, `checklist_template`, etc.
    - [ ]  Add columns to existing tables (Asset, WorkOrder, Part, Users)
    - [ ]  Create views for reporting
    - [ ]  Verify all migrations successful
- [ ]  **Day 5: Test Data**
    - [ ]  Create 3 test properties (Villa 12, Newport House, Blouberg Apt)
    - [ ]  Add property metadata for each
    - [ ]  Create 5 test appliances
    - [ ]  Verify relationships work

**Success Criteria:**

- ✓ Atlas runs locally with Supabase
- ✓ All new tables created successfully
- ✓ Can CRUD test properties
- ✓ No database errors in logs

---

### Week 2: UI Rebranding & Basic Property Management

**Goal:** Rebrand Assets → Properties with STR-specific fields

- [ ]  **Day 1-2: Backend Models**
    - [ ]  Create `PropertyMetadata.java` entity
    - [ ]  Create `PropertyMetadataRepository.java`
    - [ ]  Create `PropertyService.java` with CRUD methods
    - [ ]  Update `AssetController.java` to include property metadata
    - [ ]  Test with Postman
- [ ]  **Day 3-4: Frontend Property Dashboard**
    - [ ]  Rename `Assets` folder to `Properties`
    - [ ]  Update navigation labels (Asset → Property)
    - [ ]  Add property metadata form fields:
        - [ ]  Listing platform dropdown
        - [ ]  Check-in/out times
        - [ ]  Wifi/lockbox fields
        - [ ]  Housekeeper assignment
        - [ ]  Bedrooms/bathrooms/guests
    - [ ]  Add property card view with thumbnail
- [ ]  **Day 5: Testing & Refinement**
    - [ ]  Import Colin's 22 properties via UI
    - [ ]  Verify all metadata saves correctly
    - [ ]  Test property search and filtering
    - [ ]  Fix any bugs

**Success Criteria:**

- ✓ Can create/edit properties with all STR fields
- ✓ Property list shows 22 properties correctly
- ✓ Terminology changed throughout UI
- ✓ No console errors

---

## Phase 2: AI Checklist Generation (Weeks 3-4)

### Week 3: AI Integration Core

**Goal:** Generate first AI checklist from appliance photo

- [ ]  **Day 1-2: Setup AI Service**
    - [ ]  Add Anthropic API key to `.env`
    - [ ]  Create `AIChecklistService.java`
    - [ ]  Implement `identifyAppliance()` method
    - [ ]  Test with sample dishwasher photo
    - [ ]  Verify brand/model detection works
- [ ]  **Day 3-4: Checklist Generation**
    - [ ]  Create `ChecklistTemplate.java` entity
    - [ ]  Create `ChecklistTemplateRepository.java`
    - [ ]  Implement `generateChecklist()` method
    - [ ]  Create PDF manual fetching service (mock for now)
    - [ ]  Test full generation pipeline
    - [ ]  Save template to database
- [ ]  **Day 5: API Endpoint**
    - [ ]  Create `ChecklistController.java`
    - [ ]  Implement `POST /checklists/generate` endpoint
    - [ ]  Add photo upload to Supabase Storage
    - [ ]  Add error handling
    - [ ]  Test with Postman
    - [ ]  Add logging for costs/tokens

**Success Criteria:**

- ✓ Can upload Bosch dishwasher photo
- ✓ AI identifies make/model correctly
- ✓ Generates realistic 6-step checklist
- ✓ Template saved to database
- ✓ Response time <10 seconds

---

### Week 4: Checklist UI & Assignment

**Goal:** View and assign checklists to properties

- [ ]  **Day 1-2: Checklist UI**
    - [ ]  Create `Checklists` folder in frontend
    - [ ]  Create checklist generation page
    - [ ]  Add photo upload component
    - [ ]  Display generated checklist preview
    - [ ]  Add manual fields (brand, model) as fallback
- [ ]  **Day 3-4: Checklist Library**
    - [ ]  Create checklist list page
    - [ ]  Add search/filter by appliance type
    - [ ]  Show times used, success rate
    - [ ]  Allow editing checklist steps
    - [ ]  Add delete functionality (soft delete)
- [ ]  **Day 5: Assignment to Assets**
    - [ ]  Create `AssetChecklist.java` entity
    - [ ]  Add "Assign Checklist" button on property page
    - [ ]  Create assignment form (next due date, assigned to)
    - [ ]  Link checklist to specific appliances
    - [ ]  Test full flow: generate → assign → schedule

**Success Criteria:**

- ✓ Can generate checklist from UI
- ✓ Can view checklist library
- ✓ Can assign checklist to Villa 12 dishwasher
- ✓ Assignment creates scheduled task
- ✓ UI is intuitive

---

## Phase 3: Bulk Operations (Weeks 5-6)

### Week 5: CSV Bulk Import

**Goal:** Import 300 appliances from CSV in <2 minutes

- [ ]  **Day 1-2: CSV Parser**
    - [ ]  Create `ImportService.java`
    - [ ]  Implement CSV parser with validation
    - [ ]  Add dry-run mode (validate without creating)
    - [ ]  Test with sample 10-row CSV
    - [ ]  Add error collection and reporting
- [ ]  **Day 3-4: Bulk AI Processing**
    - [ ]  Implement async processing with job queue
    - [ ]  Add progress tracking to database
    - [ ]  Create batch AI calls (5 at a time)
    - [ ]  Implement retry logic for failures
    - [ ]  Add cost calculation
- [ ]  **Day 5: Import API & UI**
    - [ ]  Create `POST /import/csv` endpoint
    - [ ]  Create `GET /import/jobs/{id}` progress endpoint
    - [ ]  Build upload UI with drag-drop
    - [ ]  Show real-time progress bar
    - [ ]  Display summary report on completion

**Success Criteria:**

- ✓ Can upload 47-row CSV
- ✓ Dry-run validates correctly
- ✓ Full import completes in <2 minutes
- ✓ Creates 31 templates, 283 tasks
- ✓ Error handling works gracefully

---

### Week 6: Data Migration & Testing

**Goal:** Import all of Colin's real data

- [ ]  **Day 1-2: Prepare Production Data**
    - [ ]  Create CSV with all 22 properties
    - [ ]  List top 10 appliances per property
    - [ ]  Gather photos for major appliances
    - [ ]  Test CSV with dry-run
    - [ ]  Fix any validation errors
- [ ]  **Day 3: Full Import**
    - [ ]  Run full import (dry-run first)
    - [ ]  Monitor progress and errors
    - [ ]  Review generated checklists
    - [ ]  Adjust any low-confidence templates
    - [ ]  Verify task scheduling
- [ ]  **Day 4-5: Quality Check**
    - [ ]  Review all 22 properties
    - [ ]  Check property metadata accuracy
    - [ ]  Verify housekeeper assignments
    - [ ]  Test checklist assignments
    - [ ]  Have Portia review on staging

**Success Criteria:**

- ✓ All 22 properties imported
- ✓ ~300 appliances documented
- ✓ ~500 scheduled tasks created
- ✓ Data accuracy >95%
- ✓ Portia approves data quality

---

## Phase 4: Mobile App MVP (Weeks 7-8)

### Week 7: React Native Setup

**Goal:** Basic mobile app with task list

- [ ]  **Day 1-2: Project Setup**
    - [ ]  Create React Native project (`npx react-native init AtlasSTRMobile`)
    - [ ]  Setup navigation (React Navigation)
    - [ ]  Configure Redux for state management
    - [ ]  Add API service layer
    - [ ]  Test on iOS/Android emulator
- [ ]  **Day 3-4: Authentication**
    - [ ]  Create login screen
    - [ ]  Implement JWT token storage (AsyncStorage)
    - [ ]  Add auto-refresh logic
    - [ ]  Create "Remember Me" functionality
    - [ ]  Test login flow
- [ ]  **Day 5: Task List Screen**
    - [ ]  Fetch today's tasks from API
    - [ ]  Display in categorized list (Urgent, Scheduled)
    - [ ]  Add pull-to-refresh
    - [ ]  Show task status indicators
    - [ ]  Add search/filter

**Success Criteria:**

- ✓ App runs on test device
- ✓ Can login as Daniel
- ✓ Shows today's tasks correctly
- ✓ Pull-to-refresh works
- ✓ Performance <1s load time

---

### Week 8: Task Detail & Photo Upload

**Goal:** Complete tasks and upload photos

- [ ]  **Day 1-2: Task Detail Screen**
    - [ ]  Show full task information
    - [ ]  Display checklist steps
    - [ ]  Add step completion checkboxes
    - [ ]  Show progress bar
    - [ ]  Add "Start Task" button
- [ ]  **Day 3-4: Photo Capture**
    - [ ]  Integrate react-native-vision-camera
    - [ ]  Create camera screen
    - [ ]  Add photo preview
    - [ ]  Implement compression
    - [ ]  Test upload to Supabase Storage
- [ ]  **Day 5: Offline Support**
    - [ ]  Implement Redux Persist
    - [ ]  Queue photos for upload when offline
    - [ ]  Show pending upload indicator
    - [ ]  Sync when connection restored
    - [ ]  Test offline/online transitions

**Success Criteria:**

- ✓ Can complete task steps
- ✓ Can take and upload photos
- ✓ Photos appear in web dashboard
- ✓ Offline mode works
- ✓ Daniel approves UX

---

## Phase 5: Integrations (Weeks 9-10)

### Week 9: Hospitable Webhook Integration

**Goal:** Auto-create tasks from bookings

- [ ]  **Day 1-2: Webhook Receiver**
    - [ ]  Create `BookingEvent.java` entity
    - [ ]  Create `WebhookController.java`
    - [ ]  Implement signature verification
    - [ ]  Parse Hospitable webhook payload
    - [ ]  Map external property IDs to internal IDs
- [ ]  **Day 3-4: Task Generation Logic**
    - [ ]  Create `BookingService.java`
    - [ ]  Implement pre-arrival task generation
    - [ ]  Implement post-checkout task generation
    - [ ]  Assign to appropriate housekeeper
    - [ ]  Calculate due dates automatically
- [ ]  **Day 5: Testing & Monitoring**
    - [ ]  Setup webhook endpoint in Hospitable
    - [ ]  Test with real booking
    - [ ]  Verify tasks created correctly
    - [ ]  Add webhook logging
    - [ ]  Setup alerting for failures

**Success Criteria:**

- ✓ Webhook receives booking events
- ✓ Creates 2 tasks per booking
- ✓ Tasks assigned correctly
- ✓ Due dates calculated properly
- ✓ No webhook errors

---

### Week 10: Airtable Sync & Notifications

**Goal:** Sync data to Airtable and send notifications

- [ ]  **Day 1-2: Airtable Integration**
    - [ ]  Create Airtable API service
    - [ ]  Implement one-way sync (Atlas → Airtable)
    - [ ]  Sync tasks on creation/completion
    - [ ]  Sync property data changes
    - [ ]  Test sync reliability
- [ ]  **Day 3-4: Email Notifications**
    - [ ]  Setup SendGrid account
    - [ ]  Create email templates
    - [ ]  Send task assignment emails
    - [ ]  Send morning briefing to Portia
    - [ ]  Test email delivery
- [ ]  **Day 5: Push Notifications**
    - [ ]  Setup Firebase Cloud Messaging
    - [ ]  Implement push notification sending
    - [ ]  Send on task assignment
    - [ ]  Send on urgent issues
    - [ ]  Test on mobile devices

**Success Criteria:**

- ✓ Airtable stays in sync
- ✓ Portia receives morning briefing
- ✓ Housekeepers receive task notifications
- ✓ Push notifications work on iOS/Android
- ✓ No notification failures

---

## Phase 6: Analytics & Polish (Weeks 11-12)

### Week 11: Morning Briefing & Analytics

**Goal:** Automated daily briefing and reporting

- [ ]  **Day 1-2: Morning Briefing Generator**
    - [ ]  Create `BriefingService.java`
    - [ ]  Fetch all data for today
    - [ ]  Use Claude API to generate natural language summary
    - [ ]  Cache briefing (generated at 5:30 AM)
    - [ ]  Test briefing quality
- [ ]  **Day 3-4: Analytics Endpoints**
    - [ ]  Implement task completion stats API
    - [ ]  Implement property performance API
    - [ ]  Add date range filtering
    - [ ]  Create dashboard queries
    - [ ]  Optimize query performance
- [ ]  **Day 5: Analytics UI**
    - [ ]  Create analytics dashboard page
    - [ ]  Add charts (Recharts)
    - [ ]  Show KPIs (completion rate, avg time, etc.)
    - [ ]  Add export to PDF functionality
    - [ ]  Test with real data

**Success Criteria:**

- ✓ Morning briefing generated automatically
- ✓ Briefing is accurate and actionable
- ✓ Analytics show meaningful insights
- ✓ Dashboard loads in <2 seconds
- ✓ Portia finds it useful

---

### Week 12: UAT, Bug Fixes & Deployment

**Goal:** Production-ready system

- [ ]  **Day 1: User Acceptance Testing**
    - [ ]  Portia tests full workflow
    - [ ]  Daniel tests mobile app (Cape Town)
    - [ ]  Neddy tests mobile app (Strand)
    - [ ]  Simba tests maintenance workflows
    - [ ]  Colin tests admin features
    - [ ]  Collect feedback
- [ ]  **Day 2-3: Bug Fixes**
    - [ ]  Fix all critical bugs
    - [ ]  Address usability issues
    - [ ]  Optimize slow queries
    - [ ]  Improve error messages
    - [ ]  Polish UI/UX
- [ ]  **Day 4: Production Deployment**
    - [ ]  Setup production Supabase project
    - [ ]  Deploy backend to Vercel/Railway
    - [ ]  Deploy frontend to Vercel
    - [ ]  Setup custom domain
    - [ ]  Configure environment variables
    - [ ]  Setup monitoring (Sentry)
    - [ ]  Setup backups
- [ ]  **Day 5: Training & Launch**
    - [ ]  Train Portia on all features
    - [ ]  Train housekeepers on mobile app
    - [ ]  Train Simba on maintenance workflows
    - [ ]  Create user documentation
    - [ ]  Go live! 🚀

**Success Criteria:**

- ✓ Zero critical bugs
- ✓ All users trained
- ✓ System deployed to production
- ✓ Monitoring in place
- ✓ Team successfully using system

---

## Post-Launch (Week 13+)

### Immediate Priorities

1. **Monitor & Support (Week 13)**
    - Watch for issues closely
    - Respond to user feedback quickly
    - Optimize performance bottlenecks
    - Fix bugs as they arise
2. **Smart Features (Weeks 14-16)**
    - Implement smart task assignment
    - Add predictive maintenance
    - Build supply forecasting
    - Optimize routes for housekeepers
3. **Advanced Analytics (Weeks 17-20)**
    - Guest satisfaction correlation
    - Revenue per property analysis
    - Maintenance cost optimization
    - Housekeeper productivity insights

### Future Roadmap

**Q1 2026:**

- Damage detection AI
- Guest communication portal
- Multi-property batch operations
- Template marketplace (share/sell checklists)

**Q2 2026:**

- White-label for other property managers
- Accounting integration (Xero/QuickBooks)
- Dynamic pricing suggestions
- Automated review responses

**Q3 2026:**

- Multi-language support (Afrikaans, Xhosa)
- IoT integration (smart locks, thermostats)
- Predictive analytics dashboard
- Mobile app v2 (React Native → Flutter?)

---

## Critical Success Factors

### Technical

- [ ]  Response times <1s for most operations
- [ ]  Mobile app doesn't crash
- [ ]  Data integrity maintained (no data loss)
- [ ]  Backups working correctly
- [ ]  Security best practices followed

### User Experience

- [ ]  Intuitive UI (minimal training needed)
- [ ]  Mobile app faster than Breezeway
- [ ]  Photos upload reliably
- [ ]  Offline mode works seamlessly
- [ ]  Notifications timely and relevant

### Business Impact

- [ ]  Morning briefing time: <0.1s (vs 10-17s)
- [ ]  Task creation: <2min for 500 tasks (vs hours)
- [ ]  Housekeeper efficiency: +30%
- [ ]  Photo documentation: 95% compliance
- [ ]  System uptime: 99.5%

---

## Team Responsibilities

**Colin (Portfolio Owner & Developer):**

- Overall project management
- Backend development (Java/Spring Boot)
- AI integration
- Database design
- Deployment

**Claude Code (AI Assistant):**

- Code generation
- Bug fixing
- Documentation
- Testing support
- Architecture guidance

**Portia (Operations Manager & Tester):**

- Requirements validation
- User acceptance testing
- Training materials
- Daily operations feedback

**Daniel, Neddy, Sanela (Housekeepers):**

- Mobile app testing
- Photo workflow testing
- Usability feedback

**Simba (Handyman):**

- Maintenance workflow testing
- Parts inventory validation

---

## Risk Mitigation

|Risk|Mitigation|
|---|---|
|AI generates poor checklists|Human review before first use; feedback loop|
|Mobile app performance issues|Offline-first design; optimize images; profile performance|
|Hospitable API changes|Version API; monitor deprecations; manual fallback|
|Data loss during migration|Full backups; test on staging; rollback plan|
|Team adoption resistance|Involve in testing; gradual rollout; training|
|Budget overruns|Track costs daily; optimize AI usage; scale gradually|

---

## Tools & Resources

### Development

- **IDE:** IntelliJ IDEA / VS Code
- **API Testing:** Postman
- **Database:** Supabase (PostgreSQL)
- **Version Control:** Git + GitHub
- **CI/CD:** GitHub Actions

### AI & Services

- **LLM:** Anthropic Claude
- **OCR:** Google Cloud Vision
- **Email:** SendGrid
- **SMS:** Twilio
- **Push:** Firebase Cloud Messaging
- **Monitoring:** Sentry

### Documentation

- **API Docs:** Swagger/OpenAPI
- **User Docs:** GitBook or Notion
- **Team Comms:** Slack or WhatsApp

---

## Daily Standup Questions

**What did I accomplish yesterday?** **What will I work on today?** **Any blockers?**

Example:

```
Yesterday: ✓ Created property metadata table, ✓ Added backend API
Today: Build property UI, add metadata form fields
Blockers: None
```

---

## Definition of Done

A feature is "done" when:

- [ ]  Code written and tested
- [ ]  Unit tests pass (>80% coverage)
- [ ]  Integration tests pass
- [ ]  UI works on desktop and mobile
- [ ]  API documented
- [ ]  User documentation written
- [ ]  Code reviewed (by Claude or Colin)
- [ ]  Deployed to staging
- [ ]  Tested by relevant user (Portia/Daniel/etc.)
- [ ]  Merged to main branch

---

**This is your roadmap to build Atlas STR. Let's make it happen!** 🚀

**Last Updated:** 2025-11-08  
**Author:** Colin + Claude  
**Status:** Ready to Execute