# Railway Deployment Guide for Archon

## Overview

Railway doesn't support Docker Compose with multiple services in a single deployment. We need to create **3 separate Railway services**:

1. **archon-server** - Main API backend (Port: 8181)
2. **archon-mcp** - MCP server for AI clients (Port: 8051)  
3. **archon-agents** - AI/ML operations (Port: 8052) - Optional

## Prerequisites

- Railway account with a project created
- Supabase project set up with migrations applied
- OpenAI API key (or other LLM provider)
- Your `.env` file configured

## Step-by-Step Deployment

### Service 1: archon-server (Main Backend)

1. **Go to Railway Dashboard**: https://railway.com/project/c321c38f-d330-42d2-aebb-69494c80aa26

2. **Create New Service**:
   - Click `+ New Service`
   - Select `GitHub Repo`
   - Choose your Archon repository
   - Select the `main` or `stable` branch

3. **Configure Build Settings**:
   - **Service Name**: `archon-server`
   - **Root Directory**: `/` (leave empty for root)
   - **Dockerfile Path**: `python/Dockerfile.server`
   - Railway will auto-detect the port from the Dockerfile

4. **Add Environment Variables**:
   ```bash
   # Required - From your .env file
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_SERVICE_KEY=your-service-key-here
   OPENAI_API_KEY=your-openai-key-here
   
   # Service Configuration
   SERVICE_DISCOVERY_MODE=railway
   LOG_LEVEL=INFO
   ARCHON_SERVER_PORT=${{PORT}}
   ARCHON_MCP_PORT=8051
   ARCHON_AGENTS_PORT=8052
   AGENTS_ENABLED=false
   
   # Optional
   LOGFIRE_TOKEN=your-logfire-token
   ```

5. **Deploy**: Click `Deploy` and wait for the build to complete

6. **Get the URL**: Once deployed, Railway will provide a public URL like:
   ```
   https://archon-server-production-xxxx.up.railway.app
   ```

### Service 2: archon-mcp (MCP Server)

1. **Create Another Service**:
   - In the same Railway project, click `+ New Service`
   - Select the same GitHub repo

2. **Configure Build Settings**:
   - **Service Name**: `archon-mcp`
   - **Dockerfile Path**: `python/Dockerfile.mcp`

3. **Add Environment Variables**:
   ```bash
   # Required
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_SERVICE_KEY=your-service-key-here
   
   # Service Configuration
   SERVICE_DISCOVERY_MODE=railway
   TRANSPORT=sse
   LOG_LEVEL=INFO
   ARCHON_MCP_PORT=${{PORT}}
   ARCHON_SERVER_PORT=8181
   
   # Service URLs - Use the Railway internal URL for archon-server
   API_SERVICE_URL=https://archon-server-production-xxxx.up.railway.app
   AGENTS_ENABLED=false
   
   # Optional
   LOGFIRE_TOKEN=your-logfire-token
   ```

4. **Important**: After `archon-server` is deployed, update `API_SERVICE_URL` with its Railway URL

5. **Deploy**: Click `Deploy`

### Service 3: archon-agents (Optional - AI/ML Operations)

Only needed if you want advanced AI features like reranking.

1. **Create Service**:
   - Click `+ New Service`
   - Same GitHub repo

2. **Configure Build Settings**:
   - **Service Name**: `archon-agents`
   - **Dockerfile Path**: `python/Dockerfile.agents`

3. **Add Environment Variables**:
   ```bash
   # Required
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_SERVICE_KEY=your-service-key-here
   OPENAI_API_KEY=your-openai-key-here
   
   # Service Configuration
   SERVICE_DISCOVERY_MODE=railway
   LOG_LEVEL=INFO
   ARCHON_AGENTS_PORT=${{PORT}}
   ARCHON_SERVER_PORT=8181
   
   # Optional
   LOGFIRE_TOKEN=your-logfire-token
   ```

4. **Deploy**: Click `Deploy`

## Connecting Services

After all services are deployed, update the environment variables to use Railway's service discovery:

### In archon-mcp:
```bash
API_SERVICE_URL=https://archon-server-production-xxxx.up.railway.app
AGENTS_SERVICE_URL=https://archon-agents-production-xxxx.up.railway.app
```

### In archon-server:
If you enabled agents, add:
```bash
AGENTS_ENABLED=true
```

## Verifying Deployment

1. **Check archon-server health**:
   ```bash
   curl https://archon-server-production-xxxx.up.railway.app/health
   ```

2. **Check archon-mcp health**:
   ```bash
   curl https://archon-mcp-production-xxxx.up.railway.app/health
   ```

3. **Check logs** in Railway dashboard for any errors

## Next Steps: Deploy Frontend to Vercel

Once your backend services are running on Railway:

1. Go to Vercel and create a new project
2. Connect your GitHub repository
3. Set root directory to: `archon-ui-main`
4. Framework: `Vite`
5. Add environment variables:
   ```bash
   VITE_ARCHON_SERVER_URL=https://archon-server-production-xxxx.up.railway.app
   VITE_ARCHON_MCP_URL=https://archon-mcp-production-xxxx.up.railway.app
   VITE_ARCHON_AGENTS_URL=https://archon-agents-production-xxxx.up.railway.app
   ```
6. Deploy!

## Troubleshooting

### Build Fails
- Check that Dockerfile paths are correct: `python/Dockerfile.server`, `python/Dockerfile.mcp`, etc.
- Ensure all required environment variables are set
- Check Railway build logs for specific errors

### Services Can't Connect
- Verify `API_SERVICE_URL` in archon-mcp points to the correct archon-server URL
- Use Railway's public URLs (not internal Docker network names)
- Check that all services are in the "Running" state

### Database Connection Issues
- Verify `SUPABASE_URL` and `SUPABASE_SERVICE_KEY` are correct
- Make sure you're using the legacy Supabase service key (the longer one)
- Check that migrations have been applied to your Supabase database

## Cost Considerations

Railway charges per service:
- **Hobby Plan**: $5/month + usage-based pricing
- Each service consumes resources separately
- Monitor your usage in Railway dashboard

Consider:
- Start with just `archon-server` and `archon-mcp`
- Add `archon-agents` only if needed for advanced features
- Use Railway's sleep mode for development environments

## Support

- Railway Docs: https://docs.railway.app
- Archon Discord: https://github.com/coleam00/Archon/discussions
- Railway Discord: https://discord.gg/railway