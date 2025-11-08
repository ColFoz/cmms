# 📝 Atlas STR Setup Notes

**Date:** November 8, 2025
**Setup Time:** ~1 hour
**Status:** ✅ SUCCESS

---

## 🎉 What We Accomplished

### ✅ Infrastructure Setup
1. **Forked Atlas CMMS** from `Grashjs/cmms` → `ColFoz/cmms`
2. **Created Supabase project** named `atlasv2` (for future use)
3. **Cloned repository** locally to `~/Downloads/Atlasv2/atlas-str/`
4. **Set up Git branching**:
   - `main` branch (production)
   - `develop` branch (integration)
   - Added upstream remote to pull Atlas updates

### ✅ Development Environment
1. **Backend (Docker)**:
   - PostgreSQL 16 database (port 5432)
   - Spring Boot API (port 8080)
   - MinIO S3 storage (ports 9000-9001)

2. **Frontend (From Source)**:
   - React + TypeScript
   - Running on port 3000
   - 2614 npm packages installed
   - Development server with hot reload

### ✅ Configuration
- Root `.env` for Docker services
- Frontend `.env` for React app
- Both properly gitignored

### ✅ Verification
- **Backend API working:** Successfully authenticated via curl
- **Frontend working:** Logged in as Mark JoJo
- **Database working:** Tables created, user exists
- **No licensing issues!** (Running from source)

---

## 🔍 Issues Encountered & Solutions

### Issue #1: Default Login Credentials
**Problem:** Tried `admin@admin.com` / `admin` - didn't work
**Solution:** Found docs showing correct credentials: `superadmin@test.com` / `pls_change_me`
**Location:** `dev-docs/SuperAdmin password update guide.md`

### Issue #2: License Error in Docker Frontend
**Problem:** Pre-built Docker frontend image had "License is invalid" errors
**Console errors:**
```
License is invalid
Failed to load resources
port disconnected, reconnecting
```
**Root cause:** Atlas CMMS Docker images have licensing restrictions
**Solution:**
- Stopped using Docker frontend image
- Built and ran frontend from source code
- Backend still runs in Docker (works fine)

### Issue #3: Database Authentication
**Problem:** Backend couldn't connect - password mismatch
**Error:** `FATAL: password authentication failed for user "atlas_admin"`
**Solution:** Used default credentials from `.env.example`:
- `POSTGRES_USER=rootUser`
- `POSTGRES_PWD=mypassword`

---

## 📋 Current Architecture

```
┌─────────────────────────────────────────┐
│         User's Browser                   │
│     http://localhost:3000                │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│    Frontend (Running from Source)       │
│    - React Dev Server                    │
│    - Port 3000                           │
│    - Hot reload enabled                  │
└─────────────────┬───────────────────────┘
                  │ HTTP API calls
                  ▼
┌─────────────────────────────────────────┐
│    Docker Container: atlas-cmms-backend  │
│    - Spring Boot API                     │
│    - Port 8080                           │
└─────────────────┬───────────────────────┘
                  │
        ┌─────────┴────────┐
        ▼                  ▼
┌─────────────────┐ ┌──────────────────┐
│  atlas_db       │ │  atlas_minio     │
│  PostgreSQL 16  │ │  S3 Storage      │
│  Port 5432      │ │  Ports 9000-9001 │
└─────────────────┘ └──────────────────┘
```

---

## 🎯 Why This Setup Works

### Benefits of Running Frontend from Source:
1. **No licensing restrictions** ✅
2. **Full source code access** for customization
3. **Hot reload** for faster development
4. **Easy debugging** with React DevTools
5. **Can modify anything** we want

### Why Backend in Docker is Fine:
1. **No licensing issues** with backend image
2. **Easier database management**
3. **Consistent Java environment** (no local Java install needed)
4. **MinIO storage** included
5. **Quick to reset** with `docker-compose down -v`

---

## 🔐 Security Notes

### Credentials Created
- **Superadmin:** `superadmin@test.com` / `pls_change_me`
- **Test User:** Mark JoJo (whatever password was set)
- **Database:** `rootUser` / `mypassword`
- **MinIO:** `atlasadmin` / `AtlasMinIO2025!`

**⚠️ IMPORTANT:** These are development credentials only!
- Change all passwords before production
- Never commit `.env` files to git
- Use strong passwords in production

---

## 📝 Next Steps (Week 1)

### Immediate (Today/Tomorrow):
1. ✅ Create this checkpoint commit
2. ✅ Push to GitHub
3. [ ] Explore Atlas interface (Locations, Assets, Work Orders)
4. [ ] Review database schema in Supabase
5. [ ] Copy docs folder to repository

### This Week:
1. [ ] Create database schema extensions (STR tables)
2. [ ] Add property metadata table
3. [ ] Rebrand UI terminology (Assets → Properties)
4. [ ] Import first 3 test properties

---

## 🛠️ Useful Commands

### Start Everything
```bash
# From project root
docker-compose up -d postgres api minio

# In separate terminal
cd frontend && npm start
```

### Stop Everything
```bash
# Ctrl+C in frontend terminal

# Stop Docker
docker-compose down
```

### View Logs
```bash
# Backend logs
docker logs atlas-cmms-backend --tail 50 -f

# Database logs
docker logs atlas_db --tail 50 -f
```

### Reset Database (Fresh Start)
```bash
docker-compose down -v
docker-compose up -d
```

### Check What's Running
```bash
docker ps
lsof -i :3000 -i :8080
```

---

## 📚 Resources

### Documentation
- Project docs: `/docs` folder
- Atlas CMMS: https://github.com/Grashjs/cmms
- Atlas Docs: https://docs.atlas-cmms.com/

### API Testing
- Backend API: http://localhost:8080
- Swagger docs: http://localhost:8080/swagger-ui.html
- MinIO console: http://localhost:9001

---

## 🎓 Lessons Learned

1. **Always read the docs first!** The password was in `dev-docs/`
2. **Pre-built Docker images may have restrictions** - source is better for customization
3. **Gitignore `.env` files** from the start - never commit secrets
4. **Test backend API directly** (curl) to isolate frontend issues
5. **Commit early, commit often** - we lost 2 weeks of work before!

---

## ⏱️ Time Breakdown

- Fork & clone: 5 min
- Environment setup: 10 min
- First Docker attempt: 15 min
- Troubleshooting login: 10 min
- Fixing licensing issue: 20 min
- Frontend from source: 15 min (npm install + compile)
- Documentation: 15 min
- **Total: ~1.5 hours**

---

## 🎯 Success Criteria Met

✅ Local development environment running
✅ Can login and access Atlas UI
✅ Backend API responding
✅ Database initialized with tables
✅ Frontend compiling without errors
✅ No licensing restrictions
✅ Git repository set up properly
✅ Ready to start customization!

---

**Setup by:** Colin + Claude Code
**Last updated:** November 8, 2025, 7:35 PM
**Next checkpoint:** After database schema implementation
