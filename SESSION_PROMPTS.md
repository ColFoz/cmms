# Atlas STR - Session Prompts

Quick-start prompts for resuming work on Atlas STR.

---

## 📋 Checkpoint #2 (Current) - Week 1 Day 5

**Status:** Database schema complete, test data created, ready for UI exploration

### Prompt for Next Session:

```
Continue Atlas STR from Checkpoint #2 - Week 1 Day 5

Last session completed:
✅ Extended database schema (7 new tables, 4 extended tables)
✅ Created 3 test properties with metadata
✅ Committed to GitHub (commit: 09f7da3)

Current status:
- Atlas is [RUNNING / STOPPED]
- Branch: develop
- Location: ~/Downloads/Atlasv2/atlas-str/

Ready for Week 1 Day 5: UI Exploration
Tasks:
1. Verify Atlas UI shows our 3 test properties
2. Explore Assets, Locations, Work Orders pages
3. Check if property_code and metadata display
4. Plan Week 2 UI rebranding

Let's explore the Atlas interface and verify our database changes!
```

---

## 🎯 Alternative Prompts (Choose Based on What You Want)

### Option 1: Just Continue
```
Continue Atlas STR - Week 1 Day 5
```

### Option 2: Specific Task
```
Atlas STR - Show me the 3 properties we created in the Atlas UI at http://localhost:3000
```

### Option 3: Start Week 2
```
Atlas STR - Start Week 2: Backend Models

Skip UI exploration, let's build the Java entities for:
- PropertyMetadata.java
- ChecklistTemplate.java
- AssetChecklist.java

And create the repository/service layers.
```

### Option 4: If Atlas is Stopped
```
Atlas STR - Start services and continue Week 1 Day 5

Atlas is stopped. Please:
1. Start backend: docker-compose up -d
2. Start frontend: cd frontend && npm start
3. Verify http://localhost:3000 works
4. Then continue with UI exploration
```

---

## 📊 Quick Reference

### What We Have Now (Checkpoint #2)

**Database:**
- 7 new STR tables (property_metadata, checklist_template, etc.)
- 4 extended tables (asset, work_order, part, own_user)
- 3 test properties: Villa 12, Newport House, Blouberg Apartment
- 3 test appliances
- 1 checklist template

**Code/Docs:**
- `/docs` - Full project documentation
- `/migrations` - Schema migrations + test data
- Branch: `develop`
- Latest commit: `09f7da3`

**Access:**
- Frontend: http://localhost:3000
- Backend API: http://localhost:8080
- Login: `superadmin@test.com` / `pls_change_me`

### Week 1 Day 5 Goals:
- [ ] Open Atlas UI
- [ ] View properties in Assets page
- [ ] Check data displays correctly
- [ ] Note UI changes needed for Week 2
- [ ] (Optional) Create a work order for testing

### Week 2 Preview:
- Days 1-2: Java backend models (PropertyMetadata, etc.)
- Days 3-4: Frontend UI rebranding (Assets → Properties)
- Day 5: Import all 22 real properties

---

## 🔧 Common Commands

### Start Atlas (if stopped):
```bash
cd ~/Downloads/Atlasv2/atlas-str

# Backend
docker-compose up -d postgres api minio

# Frontend (new terminal)
cd frontend
npm start
```

### Check Status:
```bash
# Is Docker running?
docker ps

# Is frontend running?
lsof -i :3000

# Current branch?
git branch --show-current

# View properties in DB
docker exec atlas_db psql -U rootUser -d atlas -c "
SELECT property_code, name, region FROM asset a
JOIN property_metadata pm ON a.id = pm.asset_id
WHERE is_property = TRUE;"
```

### Stop Atlas:
```bash
# Stop frontend: Ctrl+C in terminal

# Stop backend
docker-compose down
```

---

## 💾 Checkpoints History

### ✅ Checkpoint #1 (Nov 8, 2025 - Session 1)
- Forked Atlas CMMS
- Set up local dev environment
- Got Atlas running (backend + frontend)
- Logged in successfully
- Committed to GitHub

### ✅ Checkpoint #2 (Nov 8, 2025 - Session 2) ← **YOU ARE HERE**
- Extended database schema for STR features
- Created 7 new tables + extended 4 existing tables
- Added 3 test properties with metadata
- Created test appliances and checklist template
- Copied all docs to repo
- Committed and pushed to GitHub

### ⏳ Checkpoint #3 (Next Session)
- Will complete Week 1 Day 5 UI exploration
- Will start Week 2 backend models
- Will begin UI rebranding

---

## 🎯 Roadmap Position

**✅ COMPLETED:**
- Week 1 Days 1-2: Environment Setup
- Week 1 Days 3-4: Database Schema ← Just finished!

**⏳ CURRENT:**
- Week 1 Day 5: Test Data & UI Exploration ← Next session

**🔜 UPCOMING:**
- Week 2 Days 1-2: Backend Models (Java entities)
- Week 2 Days 3-4: Frontend Rebranding
- Week 2 Day 5: Import 22 Properties

**🗓️ TIMELINE:**
- Weeks 3-4: AI Checklist Generation
- Weeks 5-6: Bulk Operations & CSV Import
- Weeks 7-8: Mobile App MVP
- Weeks 9-10: Integrations (Hospitable, Airtable)
- Weeks 11-12: Analytics & Launch 🚀

---

## 📝 Notes for Claude Code

**Context Available:**
- Full docs in `/docs` folder
- Database schema in `/migrations/001_atlas_str_schema_extensions.sql`
- Test data in database ready to view
- Frontend running from source (hot reload enabled)
- Backend in Docker (API working)

**Don't Need to Explain:**
- ✅ Project setup (already done)
- ✅ Database schema (already created)
- ✅ Test data (already inserted)

**Focus On:**
- Exploring the UI
- Verifying data displays
- Planning next steps
- Moving forward with implementation

---

**Last Updated:** 2025-11-08 (Checkpoint #2)
**Next Session:** Week 1 Day 5 - UI Exploration
**Overall Progress:** 2/60 days (3.3% of 12-week plan)

---

## 🚀 Quick Start for Next Session

**Shortest possible prompt:**
```
Continue Atlas STR - Checkpoint #2
```

**That's it!** I'll pick up exactly where we left off. 🎉
