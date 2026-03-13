---
name: doc-write
description: Write NEW documentation from scratch. Use when creating a README, API docs, or adding code comments. For syncing existing docs with code changes, use /docs instead.
---

# Write Documentation

Write documentation that helps future readers (including yourself) understand and use code.

## Documentation Types

### README.md (Project root)
```markdown
# Project Name

Brief description of what this project does.

## Quick Start

\`\`\`bash
# Install dependencies
npm install

# Set up environment
cp .env.example .env

# Run development server
npm run dev
\`\`\`

## Features

- Feature 1
- Feature 2

## Project Structure

\`\`\`
src/
├── components/   # React components
├── lib/          # Utilities
└── app/          # Pages
\`\`\`

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| DATABASE_URL | PostgreSQL connection string | Yes |
| API_KEY | External API key | Yes |

## Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run test` - Run tests

## Contributing

[How to contribute]

## License

MIT
```

### Function/Method Documentation

```typescript
/**
 * Calculates the total price including tax and discounts.
 *
 * @param items - Array of cart items with price and quantity
 * @param taxRate - Tax rate as decimal (e.g., 0.08 for 8%)
 * @param discountCode - Optional discount code to apply
 * @returns Total price in cents, or null if calculation fails
 *
 * @example
 * const total = calculateTotal(
 *   [{ price: 1000, quantity: 2 }],
 *   0.08,
 *   'SAVE10'
 * )
 */
function calculateTotal(
  items: CartItem[],
  taxRate: number,
  discountCode?: string
): number | null
```

### API Documentation

```markdown
## POST /api/users

Create a new user account.

### Request

\`\`\`json
{
  "email": "user@example.com",
  "password": "securepassword",
  "name": "John Doe"
}
\`\`\`

### Response

**201 Created**
\`\`\`json
{
  "id": "usr_123",
  "email": "user@example.com",
  "name": "John Doe",
  "createdAt": "2024-01-15T10:30:00Z"
}
\`\`\`

**400 Bad Request**
\`\`\`json
{
  "error": "validation_error",
  "message": "Email already exists"
}
\`\`\`
```

## When to Add Comments

**Do comment:**
- Why something is done (not obvious from code)
- Complex algorithms or business logic
- Workarounds for bugs/limitations
- TODO/FIXME with context

**Don't comment:**
- What code does (should be clear from code itself)
- Obvious operations
- Every function (only complex ones need docs)

### Good vs Bad Comments

```typescript
// Bad: describes what code does
// Loop through users and check if active
users.forEach(user => { if (user.active) ... })

// Good: explains why
// Filter inactive users first to avoid sending emails
// to accounts pending deletion (see JIRA-1234)
const activeUsers = users.filter(user => user.active)
```

## Guidelines

1. **Write for the reader** - Assume they're smart but lack context
2. **Keep it current** - Outdated docs are worse than none
3. **Show, don't tell** - Use examples
4. **Be concise** - Respect reader's time
5. **Document decisions** - ADRs for architectural choices
