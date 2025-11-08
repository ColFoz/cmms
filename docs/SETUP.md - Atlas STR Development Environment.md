## Quick Start (5 Minutes)

### Prerequisites

bash

```bash
# Check you have these installed:
git --version        # Git 2.30+
docker --version     # Docker 20.10+
node --version       # Node 16+
java --version       # Java 17+
```

### Step 1: Fork & Clone Atlas CMMS

bash

```bash
# Fork on GitHub first: https://github.com/Grashjs/cmms
# Then clone YOUR fork:
git clone https://github.com/YOUR_GITHUB_USERNAME/cmms.git atlas-str
cd atlas-str

# Add upstream for future updates:
git remote add upstream https://github.com/Grashjs/cmms.git
```

### Step 2: Run Atlas Locally (Uses Built-in PostgreSQL)

bash

```bash
# Start all services (backend, frontend, database):
docker-compose up -d

# Check logs:
docker-compose logs -f backend

# Wait for startup message:
# "Started CmmsApplication in X seconds"

# Open browser:
http://localhost:3000

# Default login:
# Email: admin@admin.com
# Password: admin
```

### Step 3: Explore the System

**Test the following:**

1. Create a location (will become "Property" later)
2. Add an asset (will become "Appliance" later)
3. Create a work order (will become "Task" later)
4. Check the mobile-friendly view on your phone

**Important directories:**

```
atlas-str/
├── backend/              # Spring Boot API
│   ├── src/main/java/com/grash/
│   │   ├── controller/  # REST endpoints
│   │   ├── model/       # Database entities
│   │   ├── repository/  # Data access
│   │   └── service/     # Business logic
│   └── src/main/resources/
│       └── application.properties  # Config file
├── frontend/             # React web app
│   ├── src/
│   │   ├── content/     # Main app pages
│   │   ├── models/      # TypeScript types
│   │   └── api/         # API calls
└── docker-compose.yml   # Service orchestration
```

---

## Supabase Setup (Week 2+)

### When to Switch

- After you've built initial features locally
- Before deploying to production
- When you want cloud backups and scaling

### Step 1: Create Supabase Project

1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Click "New Project"
3. Name: `atlas-str-production`
4. Database password: Generate strong password (save it!)
5. Region: Choose closest to Cape Town (e.g., `eu-west-2`)
6. Click "Create new project" (takes ~2 minutes)

### Step 2: Get Connection String

From Supabase dashboard:

1. Go to Project Settings → Database
2. Copy "Connection string" under "Connection Pooling"
3. Example: `postgresql://postgres.xxxxx:[YOUR-PASSWORD]@aws-0-eu-west-2.pooler.supabase.com:5432/postgres`

### Step 3: Configure Atlas to Use Supabase

Edit `backend/src/main/resources/application.properties`:

properties

```properties
# Comment out the old database URL:
# spring.datasource.url=jdbc:postgresql://db:5432/cmms

# Add Supabase connection:
spring.datasource.url=jdbc:postgresql://aws-0-eu-west-2.pooler.supabase.com:5432/postgres
spring.datasource.username=postgres.xxxxx
spring.datasource.password=YOUR-SUPABASE-PASSWORD

# Keep these the same:
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
```

### Step 4: Migrate Existing Data (Optional)

If you already have local data you want to keep:

bash

```bash
# Export from local database:
docker exec -t cmms-db pg_dump -U postgres cmms > local-backup.sql

# Import to Supabase (from Supabase dashboard):
# 1. Go to SQL Editor
# 2. Click "New Query"
# 3. Paste contents of local-backup.sql
# 4. Click "Run"
```

### Step 5: Restart and Test

bash

```bash
# Stop old containers:
docker-compose down

# Start only backend and frontend (database now on Supabase):
docker-compose up -d backend frontend

# Check connection:
docker-compose logs backend | grep "Hibernate"
# Should see: "HHH000400: Using dialect: org.hibernate.dialect.PostgreSQLDialect"

# Test login:
http://localhost:3000
```

---

## Project Structure Explained

### Backend (Java Spring Boot)

**Key Files to Modify:**

```
backend/src/main/java/com/grash/
├── controller/
│   ├── AssetController.java          # ← Will modify for Properties
│   ├── WorkOrderController.java      # ← Will modify for Tasks
│   └── *NEW* ChecklistController.java    # ← Create for AI checklists
├── model/
│   ├── Asset.java                    # ← Extend with property metadata
│   ├── WorkOrder.java                # ← Extend with photo links
│   └── *NEW* ChecklistTemplate.java      # ← Create new model
├── service/
│   ├── AssetService.java             # ← Add property logic
│   └── *NEW* AIChecklistService.java     # ← Create AI integration
└── dto/
    └── *NEW* ChecklistGenerationRequest.java  # ← Request DTOs
```

**Configuration Files:**

```
backend/src/main/resources/
├── application.properties            # Database config, API keys
└── application-dev.properties       # Local development overrides
```

### Frontend (React + TypeScript)

**Key Files to Modify:**

```
frontend/src/
├── content/
│   ├── own/Assets/                   # ← Rename to Properties
│   ├── own/WorkOrders/               # ← Rename to Tasks
│   └── *NEW* own/Checklists/             # ← Create checklist manager
├── models/
│   ├── owns/asset.ts                 # ← Extend Asset type
│   └── *NEW* owns/checklist.ts           # ← Create Checklist type
├── api/
│   ├── asset.ts                      # ← Update API calls
│   └── *NEW* checklist.ts                # ← Create checklist API
└── components/
    └── *NEW* BulkImportDialog.tsx        # ← CSV upload UI
```

---

## Environment Variables

Create `.env` files in each directory:

### Backend `.env`

bash

```bash
# backend/.env
DATABASE_URL=postgresql://postgres.xxxxx:[PASSWORD]@aws-0-eu-west-2.pooler.supabase.com:5432/postgres
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
ANTHROPIC_API_KEY=sk-ant-api03-...
GOOGLE_CLOUD_VISION_API_KEY=AIzaSy...
SENDGRID_API_KEY=SG.xxx...
JWT_SECRET=your-secret-key-here
```

### Frontend `.env`

bash

```bash
# frontend/.env
REACT_APP_API_URL=http://localhost:8080/api/v1
REACT_APP_SUPABASE_URL=https://xxxxx.supabase.co
REACT_APP_SUPABASE_ANON_KEY=eyJhbGc...
```

---

## Development Workflow

### Day-to-Day Development

bash

```bash
# Start services:
docker-compose up -d

# Watch backend logs:
docker-compose logs -f backend

# Frontend already has hot-reload at http://localhost:3000

# Make changes to code...

# Restart backend if you change Java code:
docker-compose restart backend

# Run tests:
docker-compose exec backend ./mvnw test
```

### Create a New Feature Branch

bash

```bash
# Always work on feature branches:
git checkout -b feature/ai-checklist-generation

# Make changes...

# Commit frequently:
git add .
git commit -m "Add AI checklist generation endpoint"

# Push to YOUR fork:
git push origin feature/ai-checklist-generation
```

### Merge Upstream Updates (Monthly)

bash

```bash
# Fetch latest from original Atlas repo:
git fetch upstream

# Merge into your main branch:
git checkout main
git merge upstream/main

# Resolve any conflicts...

# Push to your fork:
git push origin main
```

---

## Common Issues & Solutions

### Issue: "Port 8080 already in use"

bash

```bash
# Find and kill the process:
lsof -ti:8080 | xargs kill -9

# Or change Atlas port in docker-compose.yml:
# ports:
#   - "8081:8080"  # Use 8081 instead
```

### Issue: "Database connection refused"

bash

```bash
# Check database is running:
docker ps | grep postgres

# Check connection string is correct:
docker-compose logs backend | grep "datasource"

# Restart database:
docker-compose restart db
```

### Issue: Frontend won't compile

bash

```bash
# Clear cache and reinstall:
cd frontend
rm -rf node_modules package-lock.json
npm install
```

### Issue: Changes not appearing

bash

```bash
# Backend: Restart container
docker-compose restart backend

# Frontend: Hard refresh browser
# Chrome/Firefox: Ctrl+Shift+R (Cmd+Shift+R on Mac)
```

---

## Testing Strategy

### Test Locally First

1. Create test property "Test Villa"
2. Add test appliance "Test Dishwasher"
3. Generate checklist with AI
4. Complete a task with photos
5. Check data in Supabase dashboard

### Test with Real Data (Controlled)

1. Import 1 real property (Villa 12)
2. Add 5 real appliances with photos
3. Generate checklists
4. Have Daniel test on mobile
5. Iterate based on feedback

### Full Rollout

1. Import all 22 properties
2. Generate all checklists (bulk CSV)
3. Train Portia and housekeepers
4. Monitor first week closely
5. Collect feedback and iterate

---

## Backup & Disaster Recovery

### Automated Backups (Supabase)

- Supabase Pro includes daily backups (7 days retention)
- Enable Point-in-Time Recovery (PITR) for production

### Manual Backup

bash

```bash
# Export entire database:
pg_dump -h aws-0-eu-west-2.pooler.supabase.com \
        -U postgres.xxxxx \
        -d postgres \
        > backup-$(date +%Y%m%d).sql

# Store backups:
# 1. Local: ~/backups/atlas-str/
# 2. Cloud: Google Drive (automatic)
```

### Restore from Backup

bash

```bash
# From Supabase dashboard:
# 1. Go to Database → Backups
# 2. Select backup date
# 3. Click "Restore"

# Or from SQL file:
psql -h aws-0-eu-west-2.pooler.supabase.com \
     -U postgres.xxxxx \
     -d postgres \
     < backup-20251108.sql
```

---

## Next Steps

Once you have Atlas running locally:

1. ✓ Read [ARCHITECTURE.md](./ARCHITECTURE.md) - Understand codebase structure
2. ✓ Read [FEATURES.md](./FEATURES.md) - Detailed feature specifications
3. ✓ Read [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md) - Schema changes needed
4. ✓ Create first feature: Property metadata table
5. ✓ Test AI checklist generation with 1 appliance

---

## Help & Resources

**Official Atlas CMMS:**

- GitHub: [https://github.com/Grashjs/cmms](https://github.com/Grashjs/cmms)
- Docs: [https://docs.atlas-cmms.com/](https://docs.atlas-cmms.com/)
- Discord: [https://discord.gg/grash](https://discord.gg/grash)

**Our Custom Docs:**

- Architecture: [ARCHITECTURE.md](./ARCHITECTURE.md)
- Features: [FEATURES.md](./FEATURES.md)
- API: [API_ENDPOINTS.md](./API_ENDPOINTS.md)
- Mobile: [MOBILE_APP.md](./MOBILE_APP.md)
- AI: [AI_INTEGRATION.md](./AI_INTEGRATION.md)

**External Resources:**

- Spring Boot: [https://spring.io/guides](https://spring.io/guides)
- React: [https://react.dev/learn](https://react.dev/learn)
- Supabase: [https://supabase.com/docs](https://supabase.com/docs)
- React Native: [https://reactnative.dev/](https://reactnative.dev/)

---

**Last Updated:** 2025-11-08  
**Author:** Colin  
**Status:** Active Development