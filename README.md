# OpenClaw Admin Panel

Web-based admin dashboard for OpenClaw AI agents with granular permission management.

## Getting Started

### Prerequisites

- Node.js 18+ installed
- OpenClaw Gateway running on port 18789

### Installation

```bash
npm install
```

### Development

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

### Build

```bash
npm run build
npm run start
```

## Project Structure

```
src/
├── app/           # Next.js app directory
│   ├── layout.tsx # Root layout
│   ├── page.tsx   # Home page
│   └── globals.css
├── components/    # React components
├── lib/          # Utility functions
└── types/        # TypeScript type definitions
```

## Tech Stack

- **Framework**: Next.js 15 with App Router
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Linting**: ESLint

## Best Practices

This project follows Vercel's React Best Practices:
- Server-side rendering for better performance
- Code splitting and lazy loading for heavy components
- Proper TypeScript typing
- ESLint for code quality

## License

MIT
