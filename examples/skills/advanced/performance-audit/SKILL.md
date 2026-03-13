---
name: performance-audit
description: Performance analysis for web applications. Checks bundle size, rendering patterns, data fetching, and common bottlenecks. Use when user says "why is this slow", "optimize performance", "check bundle size", "app feels sluggish", or before performance optimization work.
---

# Performance Audit

A practical performance review for web applications. Identifies the most impactful optimizations without premature micro-optimization.

## When to Use

- App feels slow or sluggish
- Before launching to production
- After adding significant features
- When users complain about speed
- Planning optimization work

## The 80/20 Rule

Most performance issues come from a few common causes:
1. **Too much JavaScript** (bundle size)
2. **Too many re-renders** (React)
3. **Slow data fetching** (waterfalls, no caching)
4. **Large images** (unoptimized assets)

Focus on these before anything else.

## The Performance Checklist

### 1. Bundle Size Analysis

**Check JavaScript bundle size:**

```bash
# Build and check output size
npm run build 2>&1 | tail -30

# Check for bundle analyzer (if configured)
grep -E "analyze|bundle-analyzer" package.json

# List largest files in build output
find .next/static dist build -name "*.js" 2>/dev/null | xargs ls -lhS 2>/dev/null | head -10
```

**Evaluate:**
- [ ] Main bundle < 200KB gzipped (ideal < 100KB)
- [ ] No single chunk > 500KB
- [ ] Code splitting is enabled
- [ ] Tree shaking is working

**Common bundle bloaters:**
```bash
# Check for known heavy dependencies
grep -E "moment|lodash[^/]|antd|material-ui" package.json
```

| Library | Size | Alternative |
|---------|------|-------------|
| moment.js | ~300KB | date-fns (~30KB), dayjs (~2KB) |
| lodash (full) | ~70KB | lodash-es + tree shaking |
| Material UI (full) | ~300KB+ | Import specific components |

### 2. React Rendering Performance

**Check for re-render issues:**

```bash
# Find components without memo/useMemo
grep -rL "memo\|useMemo\|useCallback" --include="*.tsx" src/components 2>/dev/null | head -10

# Check for inline object/array props (cause re-renders)
grep -rE "=\{\s*\{" --include="*.tsx" . 2>/dev/null | grep -v node_modules | head -10

# Check for inline function props
grep -rE "onClick=\{.*=>" --include="*.tsx" . 2>/dev/null | grep -v node_modules | head -10
```

**Evaluate:**
- [ ] List components use `key` prop correctly
- [ ] Expensive components are memoized
- [ ] No inline objects/arrays as props in hot paths
- [ ] Context providers are near consumers (not at root)

**Common patterns:**
```typescript
// Bad: New object every render
<Component style={{ color: 'red' }} />

// Good: Stable reference
const style = useMemo(() => ({ color: 'red' }), []);
<Component style={style} />

// Bad: New function every render (in lists)
{items.map(item => <Item onClick={() => handleClick(item.id)} />)}

// Good: Memoized or lifted
const handleClick = useCallback((id) => { ... }, []);
{items.map(item => <Item onClick={handleClick} id={item.id} />)}
```

### 3. Data Fetching Patterns

**Check for fetch waterfalls:**

```bash
# Find data fetching hooks
grep -rE "useEffect.*fetch|useSWR|useQuery|getServerSideProps|getStaticProps" \
  --include="*.tsx" --include="*.ts" . 2>/dev/null | grep -v node_modules | head -15

# Check for sequential fetches in same component
grep -rE "await.*await" --include="*.ts" --include="*.tsx" . 2>/dev/null | grep -v node_modules | head -5
```

**Evaluate:**
- [ ] Parallel fetches where possible (`Promise.all`)
- [ ] Data fetching libraries have caching (SWR, React Query)
- [ ] No fetch waterfalls (child waits for parent)
- [ ] Pagination for large lists

### 4. Image Optimization

**Check image handling:**

```bash
# Find image imports/usage
grep -rE "<img|Image|\.png|\.jpg|\.webp" --include="*.tsx" . 2>/dev/null | grep -v node_modules | head -10

# Check if next/image is used (Next.js)
grep -r "next/image" --include="*.tsx" . 2>/dev/null | wc -l

# Find large images in public folder
find public -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) -size +100k 2>/dev/null
```

**Evaluate:**
- [ ] Using Next.js Image or similar optimization
- [ ] Images are appropriately sized (not 4K for thumbnails)
- [ ] WebP format where supported
- [ ] Lazy loading for below-fold images

### 5. Network Performance

**Check API response sizes:**

```bash
# Find API routes
find . -path "*/api/*" -name "*.ts" 2>/dev/null | grep -v node_modules | head -10

# Check for pagination in APIs
grep -rE "limit|offset|cursor|page" --include="*.ts" . 2>/dev/null | grep -v node_modules | head -10
```

**Evaluate:**
- [ ] API responses are paginated
- [ ] No over-fetching (returning unused fields)
- [ ] Compression enabled (gzip/brotli)
- [ ] CDN for static assets

### 6. Core Web Vitals

**Quick local check:**

```bash
# Check if Lighthouse CI is configured
ls lighthouse* .lighthouserc* 2>/dev/null

# Check for web-vitals package
grep "web-vitals" package.json
```

**Target metrics:**
| Metric | Good | Needs Work | Poor |
|--------|------|------------|------|
| LCP (Largest Contentful Paint) | < 2.5s | 2.5-4s | > 4s |
| FID (First Input Delay) | < 100ms | 100-300ms | > 300ms |
| CLS (Cumulative Layout Shift) | < 0.1 | 0.1-0.25 | > 0.25 |

**To measure:** Run Lighthouse in Chrome DevTools or use PageSpeed Insights.

## Output Format

```markdown
## Performance Audit: [Project Name]

**Audit Date**: YYYY-MM-DD
**Overall Score**: Good / Needs Work / Poor

### Summary

| Category | Status | Impact |
|----------|--------|--------|
| Bundle Size | ✅/⚠️/❌ | [X KB] |
| React Rendering | ✅/⚠️/❌ | [notes] |
| Data Fetching | ✅/⚠️/❌ | [notes] |
| Images | ✅/⚠️/❌ | [notes] |
| Core Web Vitals | ✅/⚠️/❌ | LCP: X, FID: X, CLS: X |

### High Impact Fixes

1. **[Issue]**: [Description]
   - **Impact**: High/Medium/Low
   - **Effort**: Easy/Medium/Hard
   - **Fix**: [How to fix]

### Optimization Opportunities

| Opportunity | Impact | Effort |
|-------------|--------|--------|
| [Description] | High | Easy |

### Not Worth Optimizing (Yet)

- [Things that seem slow but don't matter for your scale]
```

## Quick Performance Check

```bash
# One-liner: Check obvious issues
npm run build 2>&1 | grep -E "size|KB|MB"; \
grep -r "moment\|lodash[^/]" package.json 2>/dev/null; \
find public -name "*.png" -size +500k 2>/dev/null
```

## Common Quick Wins

### 1. Replace moment.js
```bash
npm uninstall moment
npm install date-fns
```

### 2. Dynamic imports for heavy components
```typescript
// Before
import HeavyChart from './HeavyChart';

// After
const HeavyChart = dynamic(() => import('./HeavyChart'), {
  loading: () => <Skeleton />,
});
```

### 3. Image optimization (Next.js)
```typescript
// Before
<img src="/hero.png" />

// After
import Image from 'next/image';
<Image src="/hero.png" width={800} height={600} priority />
```

## When to Stop Optimizing

Don't optimize if:
- The app already feels fast to users
- You have < 1000 users
- The optimization adds significant complexity
- You haven't measured the actual impact

**Measure first, optimize second.**

## Tools for Deeper Analysis

- **Lighthouse**: Built into Chrome DevTools
- **Bundle Analyzer**: `@next/bundle-analyzer` or `webpack-bundle-analyzer`
- **React DevTools Profiler**: For component render times
- **Chrome DevTools Performance tab**: For runtime profiling

## Maintenance

Run this skill:
- Before major launches
- After adding significant features
- When users report slowness
- Quarterly as a health check
