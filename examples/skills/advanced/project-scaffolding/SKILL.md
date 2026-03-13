---
name: project-scaffolding
description: Set up new projects with proper structure, configuration, and boilerplate. Use when the user wants to start a new project, initialize a codebase, or scaffold an application.
---

# Project Scaffolding

Help set up new projects with sensible defaults and structure.

## Before Starting

Ask the user:
1. **Framework/Language**: What tech stack?
2. **Purpose**: What will this project do?
3. **Scale**: Personal project, team, or production?

## Common Project Structures

### Next.js / React
```
project/
├── src/
│   ├── app/              # App router pages
│   ├── components/       # Reusable UI components
│   │   ├── ui/          # Base components (Button, Input)
│   │   └── features/    # Feature-specific components
│   ├── lib/             # Utilities, helpers
│   ├── hooks/           # Custom React hooks
│   ├── types/           # TypeScript types
│   └── styles/          # Global styles
├── public/              # Static assets
├── tests/               # Test files
└── .env.example         # Environment template
```

### Node.js API
```
project/
├── src/
│   ├── routes/          # API route handlers
│   ├── controllers/     # Business logic
│   ├── models/          # Data models
│   ├── middleware/      # Express middleware
│   ├── services/        # External service integrations
│   ├── utils/           # Helpers
│   └── types/           # TypeScript types
├── tests/
├── config/              # Environment configs
└── scripts/             # Build/deploy scripts
```

### Python
```
project/
├── src/
│   └── package_name/
│       ├── __init__.py
│       ├── main.py
│       └── utils/
├── tests/
├── pyproject.toml
├── requirements.txt
└── .env.example
```

## Essential Config Files

### TypeScript (tsconfig.json)
```json
{
  "compilerOptions": {
    "strict": true,
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "paths": { "@/*": ["./src/*"] }
  }
}
```

### ESLint (.eslintrc.json)
```json
{
  "extends": ["next/core-web-vitals", "prettier"],
  "rules": {
    "no-unused-vars": "error",
    "no-console": "warn"
  }
}
```

### Prettier (.prettierrc)
```json
{
  "semi": false,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5"
}
```

## Checklist

- [ ] Initialize git repository
- [ ] Create .gitignore (use gitignore.io)
- [ ] Set up .env.example with required variables
- [ ] Add README with setup instructions
- [ ] Configure linting and formatting
- [ ] Set up pre-commit hooks (optional)
- [ ] Create initial folder structure
- [ ] Add TypeScript/type checking if applicable

## Guidelines
- Start minimal, add complexity as needed
- Document setup steps in README
- Use .env.example to show required environment variables (never commit actual .env)
- Configure editor settings (.editorconfig) for consistency
