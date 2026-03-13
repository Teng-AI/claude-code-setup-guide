---
name: security-check
description: Security vulnerability scanner for web applications. Checks for common vulnerabilities, exposed secrets, and insecure patterns. Use when user says "is this secure", "check for vulnerabilities", "security audit", "am I exposing secrets", or before deploying to production.
---

# Security Check

A practical security audit for web applications. Focuses on the vulnerabilities most likely to affect solo developers and small teams.

## When to Use

- Before deploying to production
- After adding authentication/authorization
- When handling user input or payments
- During code review
- After adding new dependencies

## The Security Checklist

### 1. Secrets & Credentials

**Check for exposed secrets:**

```bash
# Search for common secret patterns
grep -rE "(API_KEY|SECRET|PASSWORD|TOKEN|PRIVATE_KEY)\s*=\s*['\"][^'\"]+['\"]" \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.json" \
  . 2>/dev/null | grep -v node_modules

# Check for .env files that shouldn't be committed
git ls-files | grep -E "\.env$|\.env\.local$|\.env\.production$"

# Check .gitignore includes sensitive files
grep -E "\.env|\.pem|credentials" .gitignore 2>/dev/null || echo "⚠️ Check .gitignore for sensitive patterns"
```

**Evaluate:**
- [ ] No hardcoded secrets in source code
- [ ] `.env` files are gitignored
- [ ] No API keys in client-side code
- [ ] Secrets use environment variables

### 2. Dependencies

**Check for vulnerable packages:**

```bash
# npm audit for vulnerabilities
npm audit 2>/dev/null

# Check for outdated packages with known issues
npm outdated 2>/dev/null | head -20
```

**Evaluate:**
- [ ] No critical vulnerabilities
- [ ] No high-severity vulnerabilities in production deps
- [ ] Dependencies are reasonably up-to-date

### 3. Input Validation (OWASP Top 10)

**Search for risky patterns:**

```bash
# SQL injection risk (raw queries)
grep -rE "(query|exec|execute)\s*\(" --include="*.ts" --include="*.js" . 2>/dev/null | grep -v node_modules | head -10

# XSS risk (dangerouslySetInnerHTML in React)
grep -r "dangerouslySetInnerHTML" --include="*.tsx" --include="*.jsx" . 2>/dev/null | grep -v node_modules

# Command injection risk (exec, spawn with user input)
grep -rE "(exec|spawn|execSync)\s*\(" --include="*.ts" --include="*.js" . 2>/dev/null | grep -v node_modules

# Eval usage (almost always bad)
grep -rE "eval\s*\(" --include="*.ts" --include="*.js" . 2>/dev/null | grep -v node_modules
```

**Evaluate:**
- [ ] No raw SQL queries with string concatenation
- [ ] No `dangerouslySetInnerHTML` with user content
- [ ] No `eval()` usage
- [ ] User input is validated/sanitized

### 4. Authentication & Authorization

**Check auth patterns:**

```bash
# Find auth-related files
find . -type f \( -name "*auth*" -o -name "*login*" -o -name "*session*" \) | grep -v node_modules | head -10

# Check for JWT handling
grep -r "jwt\|JWT\|jsonwebtoken" --include="*.ts" --include="*.js" . 2>/dev/null | grep -v node_modules | head -5

# Check for password handling
grep -r "password\|Password" --include="*.ts" --include="*.js" . 2>/dev/null | grep -v node_modules | head -10
```

**Evaluate:**
- [ ] Passwords are hashed (bcrypt, argon2), not stored plaintext
- [ ] JWT secrets are in environment variables
- [ ] Session tokens have expiration
- [ ] Auth checks on protected routes

### 5. Data Exposure

**Check for data leaks:**

```bash
# Console.log with potentially sensitive data
grep -rE "console\.(log|info|debug).*\b(password|token|secret|key|user)\b" \
  --include="*.ts" --include="*.js" . 2>/dev/null | grep -v node_modules

# Check API responses for over-exposure
grep -rE "res\.(json|send)\s*\(" --include="*.ts" --include="*.js" . 2>/dev/null | grep -v node_modules | head -10
```

**Evaluate:**
- [ ] No sensitive data in console.log
- [ ] API responses don't expose internal fields
- [ ] Error messages don't leak system details

### 6. Firebase-Specific (if applicable)

```bash
# Check for Firebase security rules
cat firebase.json 2>/dev/null | grep -A5 "database\|firestore\|storage"

# Check if rules files exist
ls -la *rules* 2>/dev/null || ls -la firestore.rules database.rules.json 2>/dev/null

# Check for overly permissive rules
grep -E '".read":\s*true|".write":\s*true|allow read|allow write' *.rules* 2>/dev/null
```

**Evaluate:**
- [ ] Security rules exist and are deployed
- [ ] No `".read": true, ".write": true` on root
- [ ] Rules validate user authentication
- [ ] Rules validate data structure

### 7. HTTPS & Headers

**Check security headers (if applicable):**

```bash
# Check for security header configuration
grep -rE "helmet|Content-Security-Policy|X-Frame-Options|HSTS" \
  --include="*.ts" --include="*.js" . 2>/dev/null | grep -v node_modules

# Check for CORS configuration
grep -r "cors\|CORS\|Access-Control" --include="*.ts" --include="*.js" . 2>/dev/null | grep -v node_modules | head -5
```

**Evaluate:**
- [ ] HTTPS enforced in production
- [ ] Security headers configured (CSP, HSTS, X-Frame-Options)
- [ ] CORS properly restricted

## Output Format

```markdown
## Security Check: [Project Name]

**Check Date**: YYYY-MM-DD
**Risk Level**: Low / Medium / High / Critical

### Summary

| Category | Status | Issues |
|----------|--------|--------|
| Secrets | ✅/⚠️/❌ | [count] |
| Dependencies | ✅/⚠️/❌ | [count] |
| Input Validation | ✅/⚠️/❌ | [count] |
| Auth | ✅/⚠️/❌ | [count] |
| Data Exposure | ✅/⚠️/❌ | [count] |

### Critical Issues (Fix Now)

1. **[Issue]**: [Description]
   - **File**: `path/to/file.ts:line`
   - **Fix**: [How to fix]

### High Priority (Fix This Week)

1. [Issue]

### Medium Priority (Fix Soon)

1. [Issue]

### Recommendations

- [General security improvements]
```

## Quick Check Mode

For a fast security scan:

```bash
# One-liner: Check for obvious issues
npm audit --audit-level=high 2>/dev/null; \
grep -rE "(API_KEY|SECRET|PASSWORD).*=" --include="*.ts" . 2>/dev/null | grep -v node_modules | head -5; \
grep -r "dangerouslySetInnerHTML\|eval(" --include="*.tsx" --include="*.ts" . 2>/dev/null | grep -v node_modules
```

## Common Fixes

### Exposed Secret
```typescript
// Bad
const API_KEY = "sk-1234567890abcdef";

// Good
const API_KEY = process.env.API_KEY;
```

### XSS Risk
```typescript
// Bad
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// Good
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userInput) }} />
```

### SQL Injection
```typescript
// Bad
db.query(`SELECT * FROM users WHERE id = ${userId}`);

// Good
db.query('SELECT * FROM users WHERE id = $1', [userId]);
```

## When to Get Professional Help

Consider a professional security audit if:
- Handling payments or financial data
- Storing sensitive personal information (PII)
- Healthcare or legal compliance requirements
- Large user base (>10k users)
- B2B with enterprise customers

## Maintenance

Run this skill:
- Before every production deploy
- After adding auth features
- After adding new dependencies
- Monthly as a health check
