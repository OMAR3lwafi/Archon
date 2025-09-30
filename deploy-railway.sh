#!/bin/bash

# Archon Railway Deployment Script
# This script helps deploy Archon services to Railway

set -e

echo "🚀 Archon Railway Deployment Helper"
echo "===================================="
echo ""

# Check if railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI is not installed. Install it with: brew install railway"
    exit 1
fi

echo "⚠️  IMPORTANT: Railway doesn't support Docker Compose directly."
echo "You need to create separate services in the Railway dashboard."
echo ""
echo "📋 Manual Steps Required:"
echo ""
echo "1. Go to: https://railway.com/project/c321c38f-d330-42d2-aebb-69494c80aa26"
echo ""
echo "2. Create SERVICE #1 - archon-server:"
echo "   - Click '+ New Service'"
echo "   - Select your GitHub repo"
echo "   - Service Name: archon-server"
echo "   - Dockerfile Path: python/Dockerfile.server"
echo "   - Add environment variables (see .env file)"
echo ""
echo "3. Create SERVICE #2 - archon-mcp:"
echo "   - Click '+ New Service' again"
echo "   - Same GitHub repo"
echo "   - Service Name: archon-mcp"
echo "   - Dockerfile Path: python/Dockerfile.mcp"
echo "   - Add environment variables"
echo ""
echo "4. (Optional) Create SERVICE #3 - archon-agents:"
echo "   - Service Name: archon-agents"
echo "   - Dockerfile Path: python/Dockerfile.agents"
echo ""
echo "📝 Required Environment Variables for ALL services:"
echo "   SUPABASE_URL (from your .env)"
echo "   SUPABASE_SERVICE_KEY (from your .env)"
echo "   OPENAI_API_KEY (from your .env)"
echo "   SERVICE_DISCOVERY_MODE=railway"
echo ""
echo "For detailed instructions, check the Railway documentation:"
echo "https://docs.railway.app/guides/dockerfiles"
echo ""
read -p "Press Enter to open Railway dashboard in your browser..."
open "https://railway.com/project/c321c38f-d330-42d2-aebb-69494c80aa26"