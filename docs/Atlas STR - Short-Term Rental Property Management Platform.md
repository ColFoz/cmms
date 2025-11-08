**The Anti-Breezeway: AI-powered, mobile-first property operations for serious hosts**

---

## 🎯 Vision

Transform Atlas CMMS into a purpose-built platform for short-term rental operations with:

- ✨ AI-generated maintenance checklists from appliance photos
- 📱 Mobile-first design that actually works
- 🤖 Automated booking-to-task workflows
- 📊 Real-time operational intelligence
- 💰 Self-hosted affordability

**Current State:** Managing 22 properties, R5M+ annual revenue, manual operations  
**Target State:** Automated operations, scalable to 50+ properties, <2min daily briefings

---

## 📚 Documentation

Start here:

1. **[PRD.md](./PRD.md)** - Complete Product Requirements Document
    - Vision, goals, features
    - User personas
    - Success metrics
    - Technical architecture
2. **[SETUP.md](./SETUP.md)** - Development Environment Setup
    - Fork Atlas CMMS
    - Run locally with Docker
    - Connect to Supabase
    - Daily development workflow
3. **[DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md)** - Database Design
    - New tables for STR features
    - Extensions to Atlas tables
    - Migration scripts
    - Example queries
4. **[AI_INTEGRATION.md](./AI_INTEGRATION.md)** - AI Features
    - Checklist generation from photos
    - Photo quality verification
    - Morning briefing automation
    - Cost management
5. **[API_ENDPOINTS.md](./API_ENDPOINTS.md)** - REST API Reference
    - New STR endpoints
    - Request/response formats
    - Error handling
    - Example cURL commands
6. **[IMPLEMENTATION_ROADMAP.md](./IMPLEMENTATION_ROADMAP.md)** - Build Plan
    - 12-week sprint plan
    - Week-by-week tasks
    - Success criteria
    - Risk mitigation

---

## 🚀 Quick Start

### Prerequisites

bash

```bash
# Required software
git --version        # Git 2.30+
docker --version     # Docker 20.10+
node --version       # Node 16+
java --version       # Java 17+
```

### Setup (5 minutes)

bash

```bash
# 1. Fork and clone Atlas CMMS
git clone https://github.com/YOUR_USERNAME/cmms.git atlas-str
cd atlas-str

# 2. Start local development
docker-compose up -d

# 3. Open in browser
open http://localhost:3000

# 4. Login with default credentials
# Email: admin@admin.com
# Password: admin
```

That's it! You now have Atlas running locally.

---

## 🏗️ Architecture

### Stack

**Backend:**

- Spring Boot (Java) - REST API
- PostgreSQL - Database (via Supabase)
- Anthropic Claude - AI checklist generation

**Frontend:**

- React + TypeScript
- Material-UI components
- Redux for state management

**Mobile:**

- React Native
- Offline-first with Redux Persist
- Vision Camera for photos

**Infrastructure:**

- Supabase - Database + Storage + Auth
- Vercel - Frontend hosting
- Railway - Backend hosting

### Key Technologies

|Component|Technology|Why|
|---|---|---|
|Database|PostgreSQL (Supabase)|Reliable, scalable, great free tier|
|AI|Anthropic Claude|Best vision + instruction following|
|Storage|Supabase Storage|Integrated with database, cost-effective|
|Mobile|React Native|Cross-platform, shared codebase with web|
|API|Spring Boot|Robust, scalable, well-documented|

---

## 🎨 Screenshots

### Before (Breezeway)

❌ Hidden menus  
❌ Static checklists  
❌ Slow mobile app  
❌ No AI features

### After (Atlas STR)

✅ One-click property editing  
✅ AI-generated dynamic checklists  
✅ Fast, offline-capable mobile app  
✅ Photo-based task verification

---

## 🌟 Key Features

### 1. AI Checklist Generation

**The Killer Feature:**

```
Upload photo → AI detects model → Generates maintenance checklist → Schedule across portfolio

Time: 30 seconds vs. hours of manual work
Quality: Manufacturer-backed procedures
Scale: One template for all properties with same appliance
```

### 2. Mobile Excellence

**What housekeepers see:**

- Today's tasks in priority order
- Step-by-step checklists with photos
- Offline support (no wifi? no problem)
- Photo upload with instant sync
- Real-time progress tracking

### 3. Automated Booking Workflows

**When guest books on Airbnb:**

```
Hospitable webhook → Atlas STR
  ↓
Auto-create pre-arrival task (due 2hrs before check-in)
  ↓
Assign to appropriate housekeeper
  ↓
Send push notification
  ↓
Generate turnover checklist
```

### 4. Morning Briefing

**Every day at 6 AM:**

- Check-ins/check-outs across all properties
- Urgent tasks requiring attention
- Team schedule optimization
- Low stock alerts
- Response time: <0.1 seconds

---

## 🎯 Success Metrics

|Metric|Before|After (Target)|Status|
|---|---|---|---|
|Morning briefing time|10-17s|<0.1s|🔄 In Progress|
|Task creation (bulk)|Hours|<2min|🔄 In Progress|
|Mobile app crashes|High|<0.5%|🔄 In Progress|
|Photo documentation|~40%|95%|🔄 In Progress|
|Housekeeper efficiency|Baseline|+30%|🔄 In Progress|
|Cost per property/month|R999+|~R90|🎯 Target Set|

---

## 📱 Mobile App Preview

```
┌─────────────────────┐
│ Today's Tasks       │
│ Nov 8, 2025         │
├─────────────────────┤
│ 🔴 URGENT (2)       │
│  Villa 12           │
│  Guest issue        │
│  Due: 45 min        │
│  [Start Task]       │
│                     │
│ 🟡 SCHEDULED (5)    │
│  Newport House      │
│  Pre-arrival clean  │
│  Due: 5 hrs         │
│  [Start Task]       │
│                     │
│ ✓ COMPLETED (3)     │
└─────────────────────┘
```

---

## 🗓️ Roadmap

### Phase 1: Foundation (Weeks 1-2) ⏳ Current

- [ ]  Fork Atlas CMMS
- [ ]  Setup Supabase
- [ ]  Extend database schema
- [ ]  Rebrand UI (Assets → Properties)

### Phase 2: AI Core (Weeks 3-4)

- [ ]  AI checklist generation
- [ ]  Photo upload & analysis
- [ ]  Template library

### Phase 3: Bulk Operations (Weeks 5-6)

- [ ]  CSV import with AI
- [ ]  Import Colin's 22 properties
- [ ]  500+ tasks in <2 minutes

### Phase 4: Mobile App (Weeks 7-8)

- [ ]  React Native app
- [ ]  Task completion
- [ ]  Photo capture
- [ ]  Offline sync

### Phase 5: Integrations (Weeks 9-10)

- [ ]  Hospitable webhooks
- [ ]  Airtable sync
- [ ]  Email notifications
- [ ]  Push notifications

### Phase 6: Launch (Weeks 11-12)

- [ ]  Morning briefing AI
- [ ]  Analytics dashboard
- [ ]  User acceptance testing
- [ ]  Production deployment 🚀

---

## 💰 Cost Structure

### Development (One-Time)

- Colin's time: 240-360 hours over 12 weeks
- Claude Code: Included with Claude Pro ($20/month)
- **Total:** Sweat equity + $240 for Claude access

### Monthly Operations

- Supabase Pro: $25/month
- Anthropic API (AI): ~$50/month
- Google Cloud Vision: ~$20/month
- Hosting (Vercel): $0 (hobby tier)
- **Total: ~$95/month** (~R1,800/month)

### ROI

- **Current tools:** Breezeway or similar: ~R999/property/month × 22 = **R21,978/month**
- **Atlas STR:** R1,800/month
- **Savings:** R20,178/month = **R242,136/year**

Plus: Improved efficiency, better data, scalable to 50+ properties.

---

## 🤝 Team

**Colin** - Portfolio Owner & Lead Developer  
22 properties, 10+ years STR experience, technical expertise

**Portia** - Operations Manager  
Daily coordinator, quality control, team management

**Daniel** - Housekeeper (Cape Town)  
Mobile app power user, quality standards

**Neddy & Sanela** - Housekeepers (Strand)  
Regional operations, mobile app testing

**Simba** - Handyman  
Maintenance expert, parts inventory manager

**Claude Code** - AI Development Assistant  
Code generation, testing, documentation

---

## 🛠️ Development Workflow

### Daily Development

bash

```bash
# Start services
docker-compose up -d

# Watch logs
docker-compose logs -f backend

# Make changes to code...

# Restart backend (if Java changes)
docker-compose restart backend

# Frontend auto-reloads at http://localhost:3000
```

### Create Feature Branch

bash

```bash
git checkout -b feature/ai-checklist-generation
# ... make changes ...
git add .
git commit -m "Add AI checklist generation"
git push origin feature/ai-checklist-generation
```

### Test Before Committing

bash

```bash
# Backend tests
docker-compose exec backend ./mvnw test

# Frontend tests
cd frontend
npm test
```

---

## 📖 Learning Resources

### Atlas CMMS

- GitHub: [https://github.com/Grashjs/cmms](https://github.com/Grashjs/cmms)
- Docs: [https://docs.atlas-cmms.com/](https://docs.atlas-cmms.com/)

### Technologies

- Spring Boot: [https://spring.io/guides](https://spring.io/guides)
- React: [https://react.dev/learn](https://react.dev/learn)
- React Native: [https://reactnative.dev/](https://reactnative.dev/)
- Supabase: [https://supabase.com/docs](https://supabase.com/docs)
- Anthropic: [https://docs.anthropic.com/](https://docs.anthropic.com/)

---

## 🐛 Troubleshooting

### "Port 8080 already in use"

bash

```bash
lsof -ti:8080 | xargs kill -9
```

### "Database connection refused"

bash

```bash
docker-compose restart db
docker-compose logs backend | grep datasource
```

### "Frontend won't compile"

bash

```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
```

See [SETUP.md](./SETUP.md) for more solutions.

---

## 🎓 Next Steps

1. **Read the PRD** - Understand the full vision: [PRD.md](./PRD.md)
2. **Setup Environment** - Get it running: [SETUP.md](./SETUP.md)
3. **Review Database Schema** - Understand data model: [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md)
4. **Start Week 1** - Follow roadmap: [IMPLEMENTATION_ROADMAP.md](./IMPLEMENTATION_ROADMAP.md)

---

## 📞 Support

**Questions?** Open an issue on GitHub  
**Bugs?** Create a bug report with details  
**Ideas?** Start a discussion

---

## 📄 License

Based on Atlas CMMS (Apache 2.0 License)  
Atlas STR customizations © 2025 Colin

---

## 🎉 Let's Build This!

This is more than just a fork of Atlas CMMS - it's a complete reimagining of what property management software should be for serious short-term rental operators.

No hidden menus. No static checklists. No slow mobile apps.

Just fast, intelligent, mobile-first operations that scale with your business.

**Ready to replace Breezeway forever?**

bash

```bash
git clone https://github.com/YOUR_USERNAME/cmms.git atlas-str
cd atlas-str
docker-compose up -d
```

Let's go! 🚀

---

**Last Updated:** 2025-11-08  
**Version:** 1.0.0  
**Status:** Active Development