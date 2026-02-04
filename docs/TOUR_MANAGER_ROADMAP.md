# Tour Manager Rebuild - Complete Roadmap

**Status**: Planning Complete - Ready for Implementation  
**Last Updated**: January 30, 2026  
**Target Completion**: 5 weeks from start  
**Migration Strategy**: Big Bang (nuke old system, deploy new)

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Problem Statement](#problem-statement)
3. [Solution Overview](#solution-overview)
4. [Architecture](#architecture)
5. [Key Principles](#key-principles)
6. [What Gets Nuked](#what-gets-nuked)
7. [New Module Structure](#new-module-structure)
8. [Implementation Phases](#implementation-phases)
9. [Success Criteria](#success-criteria)

---

## Executive Summary

The current tour management system is difficult to maintain, has poor UX, and lacks critical features for route creation, publishing workflow, and analytics. We're rebuilding the entire system with a modular architecture that separates concerns and provides a superior experience for creators, admins, and tourists.

### Core Improvements
- **Modular architecture** with clearly defined boundaries
- **Advanced route editor** with Mapbox integration and auto-snap
- **Integrated voice generation** with ElevenLabs (4 regional voices)
- **Publishing workflow** with admin review and feedback system
- **Enhanced marketplace** with location search and Paris collections
- **Comprehensive analytics** with CSV export and caching
- **Unified tour details** optimized for mobile

---

## Problem Statement

### Current Issues
1. **Tightly coupled code** - Hard to make changes without breaking things
2. **Poor UX** - Confusing navigation, unclear workflows
3. **Missing critical features**:
   - No route creation tools
   - No route snapping to roads
   - No waypoint reorganization
   - No trigger radius visualization
   - No voice generation integration
   - No publishing workflow
   - No advanced analytics
   - No pricing system
   - No collections/curation

### Impact
- Creators struggle to build quality tours
- Admins can't efficiently review submissions
- Tourists have limited discovery options
- No monetization infrastructure
- Poor data insights

---

## Solution Overview

### New Capabilities

**For Creators:**
- Visual route editor with map-based waypoint placement
- Auto-snap to roads with manual override option
- Integrated voice generation (no external tools needed)
- Clear publishing workflow with feedback
- Comprehensive analytics dashboard

**For Admins:**
- Unified tour management interface
- Efficient review queue with preview/edit modes
- Feedback system for tour improvements
- Collection curation tools
- Full analytics access

**For Tourists:**
- Better discovery with location-based search
- Curated collections (Paris-focused)
- Map view with clustering
- Enhanced tour details page
- Improved filtering and sorting

---

## Architecture

### New Folder Structure

```
lib/presentation/screens/
├── auth/                          # Authentication (unchanged)
├── tourist/                       # Tourist/Consumer Experience
│   ├── home_screen.dart
│   ├── profile/
│   └── my_tours/
├── creator/                       # Creator Studio (minimal)
│   └── creator_dashboard_screen.dart
├── admin/                         # Admin Panel (minimal)
│   ├── admin_dashboard_screen.dart
│   └── user_management_screen.dart
└── modules/                       # NEW: Shared Functional Modules
    ├── marketplace/               # Tour Discovery
    │   ├── marketplace_screen.dart
    │   ├── widgets/
    │   └── providers/
    ├── tour_details/              # Unified Tour Info
    │   ├── tour_details_screen.dart
    │   ├── widgets/
    │   └── providers/
    ├── tour_playback/             # Active Tour Experience (existing)
    ├── tour_manager/              # Tour Management (Creator + Admin)
    │   ├── tour_manager_screen.dart
    │   ├── views/
    │   │   ├── list_view_tab.dart
    │   │   ├── grid_view_tab.dart
    │   │   ├── analytics_view_tab.dart
    │   │   └── calendar_view_tab.dart
    │   ├── widgets/
    │   └── providers/
    ├── route_editor/              # Route Creation & Editing
    │   ├── route_editor_screen.dart
    │   ├── widgets/
    │   │   ├── interactive_map.dart
    │   │   ├── waypoint_list.dart
    │   │   ├── route_tools_panel.dart
    │   │   └── trigger_radius_editor.dart
    │   ├── services/
    │   │   └── route_snapping_service.dart
    │   └── providers/
    ├── content_editor/            # Tour Content Creation
    │   ├── tour_editor_screen.dart
    │   ├── stop_editor_screen.dart
    │   ├── modules/
    │   │   ├── basic_info_module.dart
    │   │   ├── route_module.dart
    │   │   ├── stops_module.dart
    │   │   ├── media_module.dart
    │   │   ├── pricing_module.dart
    │   │   ├── preview_module.dart
    │   │   └── publish_module.dart
    │   ├── widgets/
    │   │   ├── voice_generator_panel.dart
    │   │   ├── script_editor.dart
    │   │   └── audio_recorder.dart
    │   ├── services/
    │   │   └── voice_generation_service.dart
    │   └── providers/
    ├── publishing/                # Publishing Workflow
    │   ├── submission_screen.dart
    │   ├── review_queue_screen.dart
    │   ├── tour_review_screen.dart
    │   ├── feedback_screen.dart
    │   ├── widgets/
    │   └── providers/
    └── analytics/                 # Modular Analytics
        ├── analytics_dashboard_screen.dart
        ├── modules/
        │   ├── plays_analytics_module.dart
        │   ├── downloads_analytics_module.dart
        │   ├── favorites_analytics_module.dart
        │   ├── revenue_analytics_module.dart
        │   ├── completion_analytics_module.dart
        │   ├── geographic_analytics_module.dart
        │   └── user_feedback_analytics_module.dart
        ├── widgets/
        ├── services/
        │   └── analytics_service.dart
        └── providers/
```

### Data Layer Updates

```
lib/data/
├── models/
│   ├── pricing_model.dart              # NEW
│   ├── route_model.dart                # NEW
│   ├── waypoint_model.dart             # NEW
│   ├── publishing_submission_model.dart # NEW
│   ├── review_feedback_model.dart      # NEW
│   ├── voice_generation_model.dart     # NEW
│   ├── collection_model.dart           # NEW
│   └── analytics_model.dart            # NEW
└── repositories/
    ├── pricing_repository.dart         # NEW
    ├── route_repository.dart           # NEW
    ├── publishing_repository.dart      # NEW
    ├── collection_repository.dart      # NEW
    └── analytics_repository.dart       # NEW
```

---

## Key Principles

### 1. Modular Design
- Each module is self-contained
- Clear boundaries and responsibilities
- Easy to add/remove features
- Reusable components

### 2. Web-First for Creator Tools
- Tour Manager optimized for web
- Route Editor designed for desktop
- Content Editor works best on large screens
- Mobile support as secondary

### 3. Mobile-First for Tourist Experience
- Tour Details optimized for mobile
- Marketplace designed for touch
- Playback experience mobile-native

### 4. Optimistic UI Updates
- Immediate feedback on actions
- Assume success, handle failures gracefully
- Fast, responsive feel
- Pagination for large datasets

### 5. Role-Based Access
- Creators see their tours
- Admins see all tours
- Same UI, conditional features
- Clear permission boundaries

### 6. Data-Driven Decisions
- Comprehensive analytics
- CSV export for external analysis
- Cached for performance
- Batch-processed aggregation

---

## What Gets Nuked

### Files to Delete
```
lib/presentation/screens/creator/
├── creator_dashboard_screen.dart      # Replaced by Tour Manager
├── tour_editor_screen.dart            # Replaced by Content Editor
└── stop_editor_screen.dart            # Replaced by new Stop Editor

lib/presentation/screens/admin/
├── all_tours_screen.dart              # Replaced by Tour Manager
└── review_queue_screen.dart           # Replaced by Publishing module

lib/presentation/screens/user/
└── discover_screen.dart               # Replaced by Marketplace
```

### What Stays (Modified)
- `tour_details_screen.dart` - Rebuilt as unified module
- `tour_playback_screen.dart` - Enhanced with new route data
- Authentication screens - Unchanged
- Profile screens - Unchanged

---

## New Module Structure

### 1. Tour Manager
**Purpose**: Unified tour management for creators and admins

**Features**:
- List/Grid/Analytics/Calendar views
- Advanced filtering (status, category, date, performance)
- Search by title, location, creator
- Pagination (20 tours per page)
- Quick actions (edit, delete, duplicate, feature)
- Stats summary

**Access**:
- Creators: See only their tours
- Admins: See all tours with additional actions

### 2. Route Editor
**Purpose**: Advanced route creation and editing

**Features**:
- Click-to-add waypoints on map
- Drag-and-drop waypoint reordering
- Drag waypoints on map to adjust position
- Auto-snap to roads (Mapbox Directions API)
- Manual override for off-path routes
- Trigger radius visualization (color-coded circles)
- Overlap/proximity warnings
- Min/max radius limits (10m - 500m)
- Route statistics (distance, duration)

**Technology**: Mapbox GL JS, Mapbox Directions API

### 3. Content Editor
**Purpose**: All-in-one tour content creation

**Tabs**:
1. Basic Info - Title, description, category, type
2. Route - Opens Route Editor
3. Stops - List with inline editing
4. Media - Cover image, gallery
5. Pricing - Free/paid placeholder
6. Preview - Tourist view
7. Publish - Submission checklist

**Voice Generation**:
- 4 regional voices (French, British, American)
- Script text area (1000 char limit)
- Duration preview before generation
- Preview generated audio
- Regenerate option
- Stores script + audio URL

### 4. Publishing Workflow
**Purpose**: Structured submission and review process

**Creator Side**:
- Pre-submission checklist (enforced)
- Dashboard shows submission status
- View feedback from admin
- Resubmit with justification
- Option to ignore suggestions

**Admin Side**:
- Review queue (pending submissions)
- Preview mode (tourist view)
- Edit mode (make changes)
- Leave feedback (stop-specific or general)
- Actions: Approve, Approve with changes, Request changes, Reject

### 5. Marketplace
**Purpose**: Enhanced tour discovery

**Features**:
- Search by location, tags (on-submit)
- "Near me" using device location
- Search by city/starting point
- Map view with clustering
- Advanced filters (type, category, duration, distance, price, rating)
- Sort options (popular, newest, highest rated, nearest, price, duration)
- Paris Collections (10 curated collections)
- Featured tours section
- Editor's picks

### 6. Tour Details
**Purpose**: Unified tour information page

**Layout Priority** (Mobile-optimized):
1. Hero image + title + rating
2. Quick stats (duration, distance, stops, price)
3. Action buttons (Download, Start, Favorite, Share)
4. Overview/description
5. Stops preview (list or map)
6. Creator info
7. Reviews
8. Similar tours

**Admin Actions**: Feature, Hide, Delete, View Analytics

### 7. Analytics Dashboard
**Purpose**: Comprehensive tour performance metrics

**Metrics**:
- Plays (total, unique, avg duration, completions, completion rate)
- Downloads (total, unique, storage used)
- Favorites (total, trend)
- Revenue (total, transactions, average) - placeholder
- Completion (rate, drop-off points, avg time)
- Geographic (distribution by city/country)
- Time Series (plays per day/week/month)
- User Feedback (ratings, reviews)

**Features**:
- Date range picker
- Metric cards with trends
- Charts (line, bar, pie)
- CSV export
- 5-minute caching
- Optimistic UI updates

---

## Implementation Phases

### Phase 1: Foundation (Week 1)
**Goal**: Create all data models, repositories, and services

**Tasks**:
- Create 7 new Freezed models
- Run code generation
- Create repositories for new models
- Create services (route snapping, voice generation, analytics)
- Update Firestore schema
- Update security rules
- Create Cloud Functions for analytics
- Write unit tests

**Deliverables**:
- All models with JSON serialization
- All repositories with CRUD operations
- All services with API integrations
- Firestore collections created
- Tests passing

### Phase 2: Route Editor (Week 2, Days 1-3)
**Goal**: Build visual route creation tool

**Tasks**:
- Create Route Editor screen structure
- Integrate Mapbox GL JS
- Implement waypoint click-to-add
- Implement drag-and-drop reordering
- Implement drag-on-map positioning
- Integrate Mapbox Directions API for snapping
- Build trigger radius visualization
- Add overlap/proximity warnings
- Create route statistics display
- Write integration tests

**Deliverables**:
- Fully functional Route Editor
- Auto-snap working with manual override
- Visual trigger radius with warnings
- Route statistics calculation

### Phase 3: Content Editor (Week 2-3)
**Goal**: Build all-in-one tour creation interface

**Tasks**:
- Create tab-based layout
- Implement Basic Info tab
- Integrate Route Editor in Route tab
- Build Stops list tab
- Create Stop Editor screen
- Integrate voice generation (ElevenLabs)
- Build voice generator panel
- Implement script editor with char count
- Add duration preview
- Build Media tab with image upload
- Create Pricing tab (placeholder)
- Build Preview tab
- Create Publish tab with checklist
- Write integration tests

**Deliverables**:
- Complete Content Editor with all tabs
- Stop Editor with voice generation
- ElevenLabs integration working
- Script + audio storage to Firestore

### Phase 4: Tour Manager (Week 3, Days 1-3)
**Goal**: Build unified tour management interface

**Tasks**:
- Create Tour Manager screen structure
- Implement List view
- Implement Grid view
- Implement Analytics view
- Implement Calendar view
- Build filters panel
- Add search functionality
- Implement pagination
- Create quick actions menu
- Add stats summary
- Build role-based access control
- Write integration tests

**Deliverables**:
- Tour Manager with 4 views
- Filters and search working
- Pagination implemented
- Role-based access working

### Phase 5: Publishing Workflow (Week 3, Days 4-5)
**Goal**: Build submission and review system

**Tasks**:
- Create submission screen with checklist
- Build review queue screen
- Create tour review screen
- Implement preview/edit mode toggle
- Build feedback system
- Add stop-specific comments
- Implement approval actions
- Create feedback screen for creators
- Add resubmission with justification
- Write integration tests

**Deliverables**:
- Complete publishing workflow
- Submission checklist enforced
- Review queue functional
- Feedback system working
- Resubmission logic implemented

### Phase 6: Marketplace (Week 4, Days 1-3)
**Goal**: Rebuild tour discovery experience

**Tasks**:
- Create Marketplace screen
- Implement search functionality
- Add location-based search
- Build map view with clustering
- Create filters panel
- Implement sort options
- Build collections system
- Create 10 Paris collections
- Add featured tours section
- Implement editor's picks
- Write integration tests

**Deliverables**:
- Marketplace with search and filters
- Map view with clustering
- Collections system working
- Paris collections created

### Phase 7: Tour Details (Week 4, Days 4-5)
**Goal**: Create unified tour information page

**Tasks**:
- Rebuild Tour Details screen
- Implement mobile-optimized layout
- Add action buttons (Download, Start, Favorite, Share)
- Build stops preview section
- Add creator info section
- Implement reviews section
- Add similar tours section
- Create admin actions menu
- Write integration tests

**Deliverables**:
- Unified Tour Details page
- Mobile-optimized layout
- All sections implemented
- Admin actions working

### Phase 8: Analytics Dashboard (Week 5, Days 1-2)
**Goal**: Build comprehensive analytics system

**Tasks**:
- Create Analytics Dashboard screen
- Implement modular metric cards
- Build plays analytics module
- Build downloads analytics module
- Build favorites analytics module
- Build revenue analytics module (placeholder)
- Build completion analytics module
- Build geographic analytics module
- Build time series charts
- Build user feedback module
- Implement CSV export
- Add caching layer
- Write integration tests

**Deliverables**:
- Analytics Dashboard with all metrics
- CSV export working
- Caching implemented
- All charts rendering

### Phase 9: Integration & Cleanup (Week 5, Days 3-5)
**Goal**: Connect everything and clean up old code

**Tasks**:
- Update app routing (GoRouter)
- Connect Tour Manager to Content Editor
- Connect Content Editor to Route Editor
- Connect Publishing to Tour Manager
- Connect Marketplace to Tour Details
- Connect Tour Details to Analytics
- Delete old screens
- Update navigation flows
- Test all user journeys
- Fix bugs
- Performance optimization
- Write end-to-end tests

**Deliverables**:
- All modules connected
- Old code removed
- Navigation updated
- All tests passing
- Performance optimized

---

## Success Criteria

### Functional Requirements
- ✅ Creators can visually create routes with auto-snap
- ✅ Creators can generate voice narration in-app
- ✅ Creators can submit tours for review
- ✅ Admins can review and provide feedback
- ✅ Tourists can discover tours by location
- ✅ Tourists can browse curated collections
- ✅ Analytics dashboard shows comprehensive metrics
- ✅ CSV export works for all metrics

### Technical Requirements
- ✅ All modules are self-contained
- ✅ Code uses Riverpod code generation
- ✅ Optimistic UI updates implemented
- ✅ Pagination working for large datasets
- ✅ Analytics cached for performance
- ✅ All tests passing (unit, integration, e2e)

### UX Requirements
- ✅ Route Editor is intuitive and visual
- ✅ Voice generation is seamless
- ✅ Publishing workflow is clear
- ✅ Marketplace is easy to navigate
- ✅ Tour Details is mobile-optimized
- ✅ Analytics are easy to understand

### Performance Requirements
- ✅ Tour Manager loads < 2 seconds
- ✅ Route Editor responds instantly to interactions
- ✅ Voice generation completes < 30 seconds
- ✅ Marketplace search returns < 1 second
- ✅ Analytics dashboard loads < 3 seconds

---

## Risk Mitigation

### Technical Risks
1. **Mapbox API limits** - Monitor usage, implement caching
2. **ElevenLabs API costs** - Set character limits, track usage
3. **Large dataset performance** - Pagination, caching, indexing
4. **Complex state management** - Use Riverpod code generation

### UX Risks
1. **Route Editor learning curve** - Provide tutorial, tooltips
2. **Voice generation confusion** - Clear instructions, examples
3. **Publishing workflow complexity** - Step-by-step checklist

### Migration Risks
1. **Data loss** - Backup before migration
2. **Downtime** - Deploy during low-traffic hours
3. **User confusion** - Provide migration guide, announcements

---

## Post-Launch

### Monitoring
- Track API usage (Mapbox, ElevenLabs)
- Monitor performance metrics
- Watch error rates
- Collect user feedback

### Iteration
- Add bulk actions to Tour Manager
- Enhance analytics with more metrics
- Add email notifications for publishing
- Implement Stripe integration
- Add more voice options
- Create more collections

---

## References

- [Data Models Documentation](./DATA_MODELS.md)
- [API Integrations](./API_INTEGRATIONS.md)
- [Implementation Checklist](./IMPLEMENTATION_CHECKLIST.md)
- [Architecture Documentation](./ARCHITECTURE.md)
