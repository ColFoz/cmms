# 🏠 Atlas STR - Short-Term Rental Property Management

**Version:** 1.0.0
**Date:** November 8, 2025
**Owner:** Colin Forrester
**Status:** ✅ Local Development Environment Working

---

## 🎯 Project Vision

Transform Atlas CMMS into a purpose-built short-term rental property management platform with:
- 🤖 AI-generated maintenance checklists from appliance photos
- 📱 Mobile-first design for housekeepers
- 🔄 Automated booking workflows
- 📊 Real-time operational intelligence
- 💰 Self-hosted affordability

**Managing:** 22 properties | R5M+ annual revenue
**Goal:** Replace Breezeway, automate operations, scale to 50+ properties

---

## 🚀 Quick Start (Current Setup)

### What's Running

```bash
✅ Backend API (Docker)     → http://localhost:8080
✅ PostgreSQL DB (Docker)   → localhost:5432
✅ MinIO Storage (Docker)   → http://localhost:9000
✅ Frontend (From Source)   → http://localhost:3000
```

### Starting the Application

```bash
# 1. Start backend services (from project root)
docker-compose up -d postgres api minio

# 2. Start frontend (in separate terminal)
cd frontend
npm start

# 3. Open browser
open http://localhost:3000
```

### Default Credentials

- **Email:** `superadmin@test.com`
- **Password:** `pls_change_me`

### Stopping the Application

```bash
# Stop frontend: Ctrl+C in the terminal running npm start

# Stop backend:
docker-compose down
```

---

## 📁 Project Structure

```
atlas-str/
├── api/                  # Java Spring Boot backend
├── frontend/            # React + TypeScript UI (running from source)
├── mobile/              # React Native app (future)
├── docs/                # Project documentation
│   ├── PRD.md
│   ├── DATABASE_SCHEMA.md
│   ├── API_ENDPOINTS.md
│   ├── AI_INTEGRATION.md
│   └── IMPLEMENTATION_ROADMAP.md
├── docker-compose.yml   # Backend services
├── .env                 # Environment variables (gitignored)
└── ATLAS_STR_README.md  # This file
```

---

## 🔧 Tech Stack

**Backend:**
- Spring Boot (Java 8) - REST API
- PostgreSQL 16 - Database
- MinIO - S3-compatible file storage

**Frontend:**
- React 18 + TypeScript
- Material-UI components
- Redux Toolkit for state

**Future:**
- React Native mobile app
- Anthropic Claude API (AI checklists)
- Supabase (cloud database)

---

## 📝 Development Workflow

### Git Branching Strategy

```
main (production)
  └── develop (integration)
       ├── feature/database-schema
       ├── feature/property-metadata
       └── feature/ai-checklist
```

### Creating a Feature

```bash
# Always branch from develop
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/your-feature-name

# Make changes, commit often
git add .
git commit -m "Description of changes"

# Push to GitHub (our backup!)
git push origin feature/your-feature-name
```

---

## 🎯 Milestones Achieved

### ✅ Checkpoint #1 (Nov 8, 2025)
- [x] Forked Atlas CMMS → `ColFoz/cmms`
- [x] Created Supabase project: `atlasv2`
- [x] Cloned repo locally
- [x] Set up Git with `develop` branch
- [x] Configured environment variables
- [x] Started backend with Docker (API, DB, MinIO)
- [x] Built and ran frontend from source
- [x] **Logged in successfully!** (User: Mark JoJo)

---

## 🗺️ Roadmap (12 Weeks)

### Phase 1: Foundation (Weeks 1-2) ⏳ CURRENT
- [ ] Extend database schema for STR features
- [ ] Rebrand UI (Assets → Properties)
- [ ] Import 22 properties

### Phase 2: AI Core (Weeks 3-4)
- [ ] AI checklist generation from photos
- [ ] Photo quality verification
- [ ] Template library

### Phase 3: Bulk Operations (Weeks 5-6)
- [ ] CSV import with AI processing
- [ ] Import 300+ appliances

### Phase 4: Mobile App (Weeks 7-8)
- [ ] React Native setup
- [ ] Task list & completion
- [ ] Photo capture
- [ ] Offline sync

### Phase 5: Integrations (Weeks 9-10)
- [ ] Hospitable webhooks
- [ ] Airtable sync
- [ ] Push notifications

### Phase 6: Launch (Weeks 11-12)
- [ ] Morning briefing AI
- [ ] Analytics dashboard
- [ ] User acceptance testing
- [ ] Production deployment 🚀

---

## 🔐 Environment Setup

### Required Software
- ✅ Git 2.50+
- ✅ Docker 28.5+
- ✅ Node 22.19+
- ⚠️ Java (not required - runs in Docker)

### Environment Files

**Root `.env`** (for Docker services)
```bash
POSTGRES_USER=rootUser
POSTGRES_PWD=mypassword
JWT_SECRET_KEY=atlas-str-jwt-secret
MINIO_USER=atlasadmin
MINIO_PASSWORD=AtlasMinIO2025!
PUBLIC_API_URL=http://localhost:8080
PUBLIC_FRONT_URL=http://localhost:3000
```

**Frontend `.env`** (for React app)
```bash
NODE_ENV=development
API_URL=http://localhost:8080
CLOUD_VERSION=false
ENABLE_SSO=false
```

*Note: .env files are gitignored - never commit passwords!*

---

## 📚 Documentation

Full documentation is in the `/docs` folder:
- **PRD.md** - Product Requirements
- **DATABASE_SCHEMA.md** - Schema extensions
- **API_ENDPOINTS.md** - REST API reference
- **AI_INTEGRATION.md** - AI features
- **IMPLEMENTATION_ROADMAP.md** - Week-by-week plan
- **SETUP.md** - Development environment

---

## 🤝 Team

**Colin** - Portfolio Owner & Developer
**Portia** - Operations Manager
**Daniel, Neddy, Sanela** - Housekeepers
**Simba** - Handyman
**Claude Code** - AI Development Assistant

---

## 🎉 Success Metrics

| Metric | Before | Target | Status |
|--------|--------|--------|--------|
| Morning briefing time | 10-17s | <0.1s | 🔄 Planning |
| Task creation (bulk) | Hours | <2min | 🔄 Planning |
| Photo documentation | ~40% | 95% | 🔄 Planning |
| Housekeeper efficiency | Baseline | +30% | 🔄 Planning |
| Cost per property/month | R999+ | ~R90 | 🎯 Target Set |

---

## 🚨 Troubleshooting

### Backend won't start
```bash
# Check logs
docker logs atlas-cmms-backend --tail 50

# Restart with fresh database
docker-compose down -v
docker-compose up -d
```

### Frontend errors
```bash
# Clear cache and reinstall
cd frontend
rm -rf node_modules package-lock.json
npm install
npm start
```

### Port conflicts
```bash
# Check what's using ports
lsof -ti:3000 -ti:8080 | xargs kill -9
```

---

**Last Updated:** November 8, 2025
**Next Checkpoint:** After database schema implementation
**Repository:** https://github.com/ColFoz/cmms

---

🚀 **Let's build the future of STR property management!**
