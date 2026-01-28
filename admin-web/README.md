# AYP Admin Web Panel

A standalone web admin panel for the AYP Tour Guide application, built with Next.js 14 and connecting to the existing Firebase backend.

## Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Next.js 14 (App Router) |
| UI | shadcn/ui + Tailwind CSS |
| State | TanStack Query + Zustand |
| Firebase | Web SDK v10 (Modular) |
| Language | TypeScript |

## Features

- **Dashboard** - Quick stats, pending reviews alert, quick actions
- **Review Queue** - Real-time list of pending tours with approve/reject
- **Tour Management** - Browse all tours, filter by status/category, feature/hide tours
- **User Management** - User list, role changes, ban/unban actions
- **Settings** - Maintenance mode, registration, quotas, app version control
- **Audit Logs** - Filterable admin action history
- **Tour Creator** - Interactive map-based tour creation with:
  - Stop management with drag-and-drop reordering
  - Route editing with custom waypoints
  - Touch/tablet support (44px hit targets, long-press gestures)
  - Snap-to-road toggle for waypoint placement
  - Responsive collapsible sidebar

## Getting Started

### Prerequisites

- Node.js 18+
- Firebase project with Email/Password auth enabled

### Installation

```bash
cd admin-web
npm install
```

### Development

```bash
npm run dev
```

Open http://localhost:3000

### Production Build

```bash
npm run build
npm run start
```

## Creating an Admin Account

### Option 1: Setup Page (Recommended)

1. Enable Email/Password auth in [Firebase Console](https://console.firebase.google.com/project/atyourpace-6a6e5/authentication/providers)
2. Open http://localhost:3000/setup-admin.html
3. Click "Create Admin Account" (creates auth user)
4. Follow the link to Firebase Console to change `role` field to `"admin"`
5. Log in at http://localhost:3000/login

### Option 2: Manual Setup

1. Create user in [Firebase Auth](https://console.firebase.google.com/project/atyourpace-6a6e5/authentication/users)
2. Copy the User UID
3. In [Firestore](https://console.firebase.google.com/project/atyourpace-6a6e5/firestore), create document in `users` collection:
   - Document ID: `<User UID>`
   - Fields:
     - `email` (string): user's email
     - `displayName` (string): display name
     - `role` (string): `"admin"`
     - `createdAt` (timestamp): now
     - `updatedAt` (timestamp): now

## Project Structure

```
admin-web/
├── src/
│   ├── app/
│   │   ├── (auth)/login/         # Login page
│   │   ├── (creator)/            # Tour creator
│   │   │   └── tour/[tourId]/
│   │   │       ├── edit/         # Tour details editor
│   │   │       ├── stops/        # Stop & route map editor
│   │   │       └── preview/      # Tour preview
│   │   └── (admin)/
│   │       ├── dashboard/        # Dashboard with stats
│   │       ├── review-queue/     # Pending tour reviews
│   │       │   └── [tourId]/     # Tour review detail
│   │       ├── tours/            # All tours browser
│   │       ├── users/            # User management
│   │       ├── settings/         # App settings
│   │       └── audit-logs/       # Admin action history
│   ├── components/
│   │   ├── ui/                   # shadcn components
│   │   ├── layout/               # Sidebar, header, admin shell
│   │   └── providers.tsx         # React Query + Auth providers
│   ├── lib/
│   │   ├── firebase/
│   │   │   ├── config.ts         # Firebase initialization
│   │   │   ├── auth.ts           # Auth operations
│   │   │   └── admin.ts          # Admin operations (CRUD)
│   │   └── utils.ts              # Utility functions
│   ├── hooks/                    # TanStack Query hooks
│   │   ├── use-auth.ts
│   │   ├── use-tours.ts
│   │   ├── use-route-calculation.ts  # Route waypoints & ordering
│   │   ├── use-auto-save.ts          # Auto-save functionality
│   │   ├── use-users.ts
│   │   ├── use-settings.ts
│   │   └── use-audit-logs.ts
│   └── types/
│       └── index.ts              # TypeScript models
├── public/
│   └── setup-admin.html          # Admin account setup page
└── scripts/
    └── create-admin.js           # Admin creation script (needs service account)
```

## Firebase Integration

The admin panel connects to the same Firebase backend as the Flutter app:

- **Project ID**: `atyourpace-6a6e5`
- **Collections**: `users`, `tours`, `auditLogs`, `config`

### Admin Operations

All operations are ported from Flutter's `admin_service.dart`:

- `approveTour(tourId, notes)` - Approve pending tour
- `rejectTour(tourId, reason)` - Reject with reason
- `hideTour(tourId, reason)` - Hide from public
- `unhideTour(tourId)` - Restore visibility
- `featureTour(tourId, featured)` - Toggle featured status
- `updateUserRole(userId, role)` - Change user role
- `banUser(userId, reason)` - Ban user
- `unbanUser(userId)` - Unban user
- `getAuditLogs(filters)` - Query audit history

## Tour Creator Features

The Map Editor (`/tour/[tourId]/stops`) provides advanced route editing:

### Route Waypoints
- Click on route line to add waypoints
- Drag waypoints to adjust route path
- Double-click (desktop) or long-press (tablet) to remove waypoints
- Route-aware ordering for curved routes (fixes U-shaped route issues)

### Touch Support (Tablet/iPad)
- 44px touch targets (WCAG accessibility standard)
- Long-press (500ms) with visual feedback to remove waypoints
- Haptic feedback when available
- Responsive sidebar that collapses on tablets (<1024px)

### API Limits
- Mapbox Directions API supports max 25 coordinates
- Automatic Douglas-Peucker simplification when exceeding limit
- Proportional distribution of waypoints across route segments

### Snap-to-Road
- Toggle button in map controls
- Uses Mapbox Map Matching API
- Preference persisted in localStorage

## Deployment

### Firebase Hosting

```bash
npm run build
firebase deploy --only hosting
```

### Vercel

Connect your repository to Vercel for automatic deployments.

## Default Credentials

For development/testing:

- **Email**: admin@test.com
- **Password**: admin123

(Must be created using setup steps above)
