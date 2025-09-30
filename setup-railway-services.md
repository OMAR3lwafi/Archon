# Setup MCP and Agents Services on Railway

Your main **archon-server** is already deployed successfully! Now let's add the MCP and Agents services to complete the architecture.

## 🎯 Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                   Railway Project: Archon                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ✅ archon-server (Main API)                                │
│     URL: https://archon-production-6a06.up.railway.app      │
│     Port: $PORT (Railway auto-assigns)                      │
│     Status: HEALTHY ✓                                       │
│                                                              │
│  🔄 archon-mcp (MCP Server) - TO BE CREATED                 │
│     Dockerfile: python/Dockerfile-mcp                       │
│     Port: $PORT (Railway auto-assigns)                      │
│                                                              │
│  🤖 archon-agents (AI Agents) - TO BE CREATED               │
│     Dockerfile: python/Dockerfile-agents                    │
│     Port: $PORT (Railway auto-assigns)                      │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Step 1: Create MCP Server Service

1. **Go to Railway Dashboard**: https://railway.com/project/c321c38f-d330-42d2-aebb-69494c80aa26

2. **Click "+ New Service"**

3. **Select "GitHub Repo"** → Choose **OMAR3lwafi/Archon** → Branch: **main**

4. **Configure Service Settings**:
   - **Service Name**: `archon-mcp`
   - Go to **Settings** → **Build** section
   - **Dockerfile Path**: `python/Dockerfile-mcp`

5. **Add Environment Variables** (Settings → Variables):

```bash
# Required - Same as main server
SUPABASE_URL=https://nusznfjetlvuqikgrdss.supabase.co
SUPABASE_SERVICE_KEY=<your-supabase-service-key>

# Service Configuration
SERVICE_DISCOVERY_MODE=railway
TRANSPORT=sse
LOG_LEVEL=INFO

# Port Configuration
ARCHON_MCP_PORT=${{PORT}}
ARCHON_SERVER_PORT=8181

# Service URLs - IMPORTANT: Update after archon-server is deployed
API_SERVICE_URL=https://archon-production-6a06.up.railway.app
AGENTS_ENABLED=false

# Optional
LOGFIRE_TOKEN=<your-logfire-token-if-you-have-one>
```

6. **Deploy**: Railway will automatically build and deploy

7. **Get the MCP URL**: Once deployed, note the URL (something like `https://archon-mcp-production-xxxx.up.railway.app`)

---

## 📋 Step 2: Create Agents Server Service

1. **Click "+ New Service"** again (in the same Railway project)

2. **Select "GitHub Repo"** → Choose **OMAR3lwafi/Archon** → Branch: **main**

3. **Configure Service Settings**:
   - **Service Name**: `archon-agents`
   - Go to **Settings** → **Build** section
   - **Dockerfile Path**: `python/Dockerfile-agents`

4. **Add Environment Variables** (Settings → Variables):

```bash
# Required - Same as others
SUPABASE_URL=https://nusznfjetlvuqikgrdss.supabase.co
SUPABASE_SERVICE_KEY=<your-supabase-service-key>
OPENAI_API_KEY=<your-openai-key>

# Service Configuration
SERVICE_DISCOVERY_MODE=railway
LOG_LEVEL=INFO

# Port Configuration
ARCHON_AGENTS_PORT=${{PORT}}
ARCHON_SERVER_PORT=8181

# Optional
LOGFIRE_TOKEN=<your-logfire-token-if-you-have-one>
```

5. **Deploy**: Railway will automatically build and deploy

6. **Get the Agents URL**: Once deployed, note the URL

---

## 📋 Step 3: Connect Services Together

After both services are deployed, update environment variables to connect them:

### Update archon-server (Main API):

Add these variables to connect to MCP and Agents:

```bash
AGENTS_ENABLED=true
ARCHON_MCP_URL=https://archon-mcp-production-xxxx.up.railway.app
ARCHON_AGENTS_URL=https://archon-agents-production-xxxx.up.railway.app
```

### Update archon-mcp:

```bash
AGENTS_SERVICE_URL=https://archon-agents-production-xxxx.up.railway.app
AGENTS_ENABLED=true
```

---

## ✅ Verification

After all services are deployed, test each health endpoint:

```bash
# Main Server
curl https://archon-production-6a06.up.railway.app/health

# MCP Server
curl https://archon-mcp-production-xxxx.up.railway.app/health

# Agents Server
curl https://archon-agents-production-xxxx.up.railway.app/health
```

All should return a healthy status!

---

## 📝 Quick Reference

### Service URLs to Note:

- **archon-server**: https://archon-production-6a06.up.railway.app ✅
- **archon-mcp**: `<will be generated after creation>`
- **archon-agents**: `<will be generated after creation>`

### Dockerfile Paths:

- **archon-server**: `python/Dockerfile`
- **archon-mcp**: `python/Dockerfile-mcp`
- **archon-agents**: `python/Dockerfile-agents`

### Environment Variables Reference:

All services share these core variables:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_KEY`
- `SERVICE_DISCOVERY_MODE=railway`
- `LOG_LEVEL=INFO`

Service-specific:
- **archon-server**: Needs `OPENAI_API_KEY`, manages core business logic
- **archon-mcp**: Needs `API_SERVICE_URL`, `TRANSPORT=sse`
- **archon-agents**: Needs `OPENAI_API_KEY`, handles AI operations

---

## 🚀 Next: Deploy Frontend to Vercel

Once all three backend services are running, deploy the frontend with:

```bash
VITE_ARCHON_SERVER_URL=https://archon-production-6a06.up.railway.app
VITE_ARCHON_MCP_URL=https://archon-mcp-production-xxxx.up.railway.app
VITE_ARCHON_AGENTS_URL=https://archon-agents-production-xxxx.up.railway.app
```

---

## 💡 Tips

1. **Railway auto-assigns ports** via `$PORT` environment variable
2. **Services communicate via public URLs** (Railway internal networking not needed)
3. **Environment variables can be updated anytime** in Settings → Variables
4. **Check logs** if a service fails: Deployments → Click deployment → View Logs
5. **All services should be in the same Railway project** for easier management

---

## 🆘 Troubleshooting

**Build fails?**
- Check Dockerfile path is correct
- Ensure all `python/` prefixes are in place for file copies

**502 errors?**
- Check deployment logs for Python errors
- Verify all environment variables are set
- Check that PORT is being used correctly in CMD

**Services can't connect?**
- Verify service URLs are correct in environment variables
- Make sure services are using HTTPS URLs
- Check that all services are in "Running" state

---

Ready to proceed? Open the Railway dashboard and follow the steps above!