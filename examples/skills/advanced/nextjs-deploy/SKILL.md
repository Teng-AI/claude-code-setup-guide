---
name: nextjs-deploy
description: Preview changes locally and deploy Next.js websites to production. Use when the user wants to test changes, preview the site, publish updates, deploy to Vercel or other platforms, or make the site live.
---

# Next.js Preview & Deploy

## Overview

Safely preview changes and deploy Next.js applications to production.

## Quick Commands

```bash
# Development preview (hot reload)
npm run dev

# Production build (catches errors)
npm run build

# Production preview (exactly what will deploy)
npm run build && npm run start
```

## Pre-Deploy Checklist

Always verify before deploying:

- [ ] `npm run build` completes without errors
- [ ] `npm run lint` shows no errors (if configured)
- [ ] Visual check on key pages
- [ ] Test on mobile viewport
- [ ] Links and navigation work
- [ ] Images load correctly
- [ ] Forms function properly (if applicable)

## Local Preview

### Development Mode
```bash
npm run dev
```
- URL: http://localhost:3000
- Hot reload - see changes instantly
- Detailed error messages
- Best for active development

### Production Mode
```bash
npm run build && npm run start
```
- URL: http://localhost:3000
- Optimized build (minified, compressed)
- Shows exactly what will deploy
- Use for final verification

## Deployment Options

### Vercel (Recommended)

**First-time setup:**
```bash
npm install -g vercel
vercel login
```

**Preview deployment:**
```bash
vercel
```
- Creates unique preview URL
- Safe to test before going live

**Production deployment:**
```bash
vercel --prod
```
- Deploys to production domain

### Git-based Auto-Deploy

If connected to GitHub/GitLab with Vercel:

```bash
# Commit changes
git add .
git commit -m "Description of changes"

# Push triggers auto-deploy
git push origin main
```

- Push to `main` → Production deploy
- Push to other branches → Preview deploy

### Other Platforms

**Netlify:**
```bash
npm install -g netlify-cli
netlify login
netlify deploy --prod
```

**Static Export (traditional hosting):**

Add to `next.config.js`:
```js
const nextConfig = {
  output: 'export',
}
```

Then:
```bash
npm run build
# Upload 'out/' folder to hosting
```

## Troubleshooting

### Build Errors

If `npm run build` fails:

1. Read error message carefully
2. Common issues:
   - Missing imports → Add the import
   - TypeScript errors → Fix type issues
   - Missing images → Check file paths
   - Missing env vars → Check `.env.local`

3. Fix and retry: `npm run build`

### Deployment Fails

1. Check platform's deployment logs
2. Verify environment variables are set
3. Ensure dependencies are in `package.json`
4. Try clearing cache:
   ```bash
   rm -rf .next node_modules
   npm install
   npm run build
   ```

### Changes Not Appearing

1. Hard refresh: `Cmd+Shift+R` (Mac) or `Ctrl+Shift+R` (Windows)
2. Clear browser cache
3. Verify deployment completed
4. Check you're on the right URL (preview vs production)

## Environment Variables

- **Local:** `.env.local` (never commit)
- **Production:** Set in hosting platform dashboard
- **Template:** `.env.example` (commit this, shows required vars)

```bash
# .env.example
DATABASE_URL=
API_KEY=
NEXT_PUBLIC_SITE_URL=
```

## Safety Tips

- Always run `npm run build` before deploying
- Use preview deployments to test first
- Keep Git commits for easy rollback
- Never expose secrets in client-side code (`NEXT_PUBLIC_` vars are public)
