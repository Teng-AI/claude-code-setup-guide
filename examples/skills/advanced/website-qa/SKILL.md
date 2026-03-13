---
name: website-qa
description: Check any website for bugs, broken links, typos, spelling errors, responsive design issues, accessibility problems, and build errors. Use when the user wants to verify a site is working properly, run a health check, find issues, or test before deploying.
---

# Website QA / Health Check

## Overview

Run quality assurance checks on websites to catch issues before they affect visitors. Works with any web project.

## Quick Checks

First, identify the project type and run appropriate commands:

```bash
# Next.js / React
npm run build && npm run lint

# Generic Node.js
npm run build
npm run lint

# Static sites
# Just check files directly
```

## Comprehensive Checklist

### 1. Build & Code Errors

- Run the build command - check for compilation errors
- Run linting - check for code quality issues
- Look for TypeScript/type errors
- Check for missing imports or dependencies

### 2. Link Verification

Scan all pages and components for links:

**Internal Links:**
- Verify each linked page/route exists
- Check for typos in paths (e.g., `/abut` vs `/about`)
- Ensure case sensitivity is correct

**External Links:**
- Verify URLs are properly formatted
- Check that external sites are accessible
- Look for outdated links (404s)

**Image Sources:**
- Verify all images exist in the expected location
- Check for missing or broken image paths

### 3. Content Review

Scan for common issues:
- Typos and spelling errors
- Inconsistent capitalization
- Placeholder text (Lorem ipsum, TODO, FIXME, TBD)
- Outdated dates, statistics, or information
- Missing alt text on images
- Broken or malformed HTML entities

### 4. Responsive Design Check

Start the dev server and test each page at:

| Device | Width |
|--------|-------|
| Mobile | 375px |
| Tablet | 768px |
| Desktop | 1280px |
| Wide | 1920px |

Look for:
- Text overflow or cutoff
- Images stretching or distorting
- Navigation issues on mobile
- Touch targets too small (< 44px)
- Horizontal scrolling (usually a bug)
- Elements overlapping

### 5. Accessibility Basics (WCAG)

Check for:
- All images have descriptive `alt` text
- Links have clear, descriptive text (not "click here")
- Sufficient color contrast (4.5:1 for normal text)
- Page headings follow hierarchy (h1 > h2 > h3)
- Form inputs have labels
- Interactive elements are keyboard accessible
- Focus states are visible

### 6. Performance Red Flags

Look for:
- Very large images (> 500KB)
- Missing image optimization (no width/height, no lazy loading)
- Too many external scripts
- Render-blocking resources

## Reporting Format

```markdown
## QA Report: [Project Name]

**Date:** [Date]
**Pages Checked:** [List]

### Critical (Must Fix Before Deploy)
- [ ] Issue description - Location

### High Priority
- [ ] Issue description - Location

### Medium Priority
- [ ] Issue description - Location

### Low Priority / Suggestions
- [ ] Issue description - Location

### Passed Checks
- Build completes successfully
- No linting errors
- [Other passing items]
```

## Instructions

1. Identify the project type (Next.js, React, static, etc.)
2. Run build and lint commands
3. If build passes, start dev server
4. Systematically check each page
5. Document all findings with locations
6. Prioritize issues by severity
7. Present report to user
