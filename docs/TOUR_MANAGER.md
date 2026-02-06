# Implementation Checklist - Tour Manager Rebuild

**Last Updated**: February 4, 2026
**Duration**: 5 weeks
**Status**: Week 4 - Partial (Marketplace disabled due to API issues)

---

## Overview

This checklist tracks the week-by-week implementation of the Tour Manager rebuild. Check off tasks as they're completed and update the status regularly.

**Progress Tracking**:
- ✅ = Completed
- 🔄 = In Progress
- ⏳ = Not Started
- ⚠️ = Blocked
- ❌ = Skipped/Cancelled

---

## Week 1: Foundation (Days 1-5) ✅

**Goal**: Create all data models, repositories, and services

### Day 1-2: Data Models ✅

#### Data Model Creation
- [x] Create `lib/data/models/pricing_model.dart`
  - [x] Define PricingModel with Freezed
  - [x] Define PricingTier model
  - [x] Add JSON serialization
  - [x] Add Firestore converters
  - [x] Add helper methods (isFree, isPaid, displayPrice)

- [x] Create `lib/data/models/route_model.dart`
  - [x] Define RouteModel with Freezed
  - [x] Define RouteSnapMode enum
  - [x] Add LatLngListConverter
  - [x] Add distance/duration formatters
  - [x] Add Firestore integration

- [x] Create `lib/data/models/waypoint_model.dart`
  - [x] Define WaypointModel with Freezed
  - [x] Define WaypointType enum
  - [x] Add LatLngConverter
  - [x] Add overlap detection methods
  - [x] Add radius color coding logic

- [x] Create `lib/data/models/publishing_submission_model.dart`
  - [x] Define PublishingSubmissionModel with Freezed
  - [x] Define SubmissionStatus enum
  - [x] Add status helper methods
  - [x] Add Firestore integration

- [x] Create `lib/data/models/review_feedback_model.dart`
  - [x] Define ReviewFeedbackModel with Freezed
  - [x] Define FeedbackType enum
  - [x] Add helper methods
  - [x] Add Firestore integration

- [x] Create `lib/data/models/voice_generation_model.dart`
  - [x] Define VoiceGenerationModel with Freezed
  - [x] Define VoiceGenerationStatus enum
  - [x] Define VoiceGenerationHistory model
  - [x] Define VoiceOption class
  - [x] Add VoiceOptions constants (4 voices)
  - [x] Add duration estimation logic

- [x] Create `lib/data/models/collection_model.dart`
  - [x] Define CollectionModel with Freezed
  - [x] Define CollectionType enum
  - [x] Add ParisCollections constants (10 collections)
  - [x] Add Firestore integration

- [x] Create `lib/data/models/tour_analytics_model.dart`
  - [x] Define TourAnalyticsModel with Freezed
  - [x] Define AnalyticsPeriod enum
  - [x] Define PlayMetrics model
  - [x] Define DownloadMetrics model
  - [x] Define FavoriteMetrics model
  - [x] Define RevenueMetrics model
  - [x] Define CompletionMetrics model
  - [x] Define GeographicMetrics model
  - [x] Define TimeSeriesData model
  - [x] Define UserFeedbackMetrics model

#### Code Generation
- [x] Run `dart run build_runner build --delete-conflicting-outputs`
- [x] Fix any code generation errors
- [x] Verify all models compile successfully

#### Unit Tests
- [x] Write tests for PricingModel
- [x] Write tests for RouteModel
- [x] Write tests for WaypointModel
- [x] Write tests for PublishingSubmissionModel
- [x] Write tests for ReviewFeedbackModel
- [x] Write tests for VoiceGenerationModel
- [x] Write tests for CollectionModel
- [x] Write tests for TourAnalyticsModel
- [x] Verify all tests pass (226 model tests passing)

### Day 3-4: Repositories & Services ✅

#### Repository Creation
- [x] Create `lib/data/repositories/pricing_repository.dart`
  - [x] Implement create, read, update, delete
  - [x] Add Firestore queries
  - [x] Add error handling

- [x] Create `lib/data/repositories/route_repository.dart`
  - [x] Implement CRUD operations
  - [x] Add waypoint management
  - [x] Add route versioning

- [x] Create `lib/data/repositories/publishing_repository.dart`
  - [x] Implement submission CRUD
  - [x] Add feedback management
  - [x] Add status update methods
  - [x] Add query methods (pending, approved, etc.)

- [x] Create `lib/data/repositories/collection_repository.dart`
  - [x] Implement CRUD operations
  - [x] Add tour management (add/remove tours)
  - [x] Add featured collections query

- [x] Create `lib/data/repositories/analytics_repository.dart`
  - [x] Implement analytics retrieval
  - [x] Add aggregation methods
  - [x] Add CSV export logic
  - [x] Add caching layer

#### Service Creation
- [x] Create `lib/services/route_snapping_service.dart`
  - [x] Implement Mapbox Directions API integration
  - [x] Add snapToRoads method
  - [x] Add distance calculation
  - [x] Add duration estimation
  - [x] Add error handling and fallbacks

- [x] Create `lib/services/voice_generation_service.dart`
  - [x] Implement ElevenLabs API integration
  - [x] Add generateVoice method
  - [x] Add Firebase Storage upload
  - [x] Add duration estimation
  - [x] Add error handling

- [x] Create `lib/services/analytics_aggregation_service.dart`
  - [x] Implement analytics aggregation
  - [x] Add CSV export functionality
  - [x] Add caching logic (5-minute cache)
  - [x] Add batch processing

#### Unit Tests
- [x] Write tests for all repositories
- [x] Write tests for all services
- [x] Mock external API calls
- [x] Verify all tests pass

### Day 5: Firestore Schema & Cloud Functions ✅

#### Firestore Setup
- [x] Create `pricing` subcollection structure
- [x] Create `routes` subcollection structure
- [x] Create `waypoints` subcollection structure
- [x] Create `publishing_submissions` collection
- [x] Create `review_feedback` subcollection structure
- [x] Create `voice_generations` subcollection structure
- [x] Create `collections` collection
- [x] Create `analytics` collection structure

#### Security Rules
- [x] Update Firestore security rules for new collections
- [x] Add role-based access rules
- [x] Deploy security rules

#### Indexes
- [x] Create index for publishing_submissions (status, submittedAt)
- [x] Create index for collections (isFeatured, sortOrder)
- [x] Create index for analytics (tourId, period, startDate)
- [x] Deploy 16 composite indexes

#### Cloud Functions
- [x] Create `aggregateTourAnalytics` function (scheduled hourly)
- [x] Create `triggerTourAnalytics` function (HTTP callable)
- [x] Create `onTourProgressCreated` function (real-time)
- [x] Create `onTourProgressUpdated` function (real-time)
- [x] Create `onSubmissionCreated` function
- [x] Create `onSubmissionUpdated` function
- [x] Create `onFeedbackCreated` function
- [x] Deploy Cloud Functions (8 functions deployed)

---

## Week 2: Route Editor & Content Editor (Days 1-5)

**Goal**: Build visual route creation and content editing tools

### Day 1-3: Route Editor ✅

#### Screen Structure
- [x] Create `lib/presentation/screens/modules/route_editor/` folder
- [x] Create `route_editor_screen.dart` (main screen)
- [x] Create `widgets/` subfolder
- [x] Create `providers/` subfolder
- [x] Create `route_editor.dart` (exports)

#### Map Integration
- [x] Create `widgets/interactive_route_map.dart`
  - [x] Integrate Mapbox GL
  - [x] Add click-to-add waypoint
  - [x] Add waypoint markers (PointAnnotationManager)
  - [x] Add route polyline rendering (PolylineAnnotationManager)
  - [x] Add trigger radius circles (CircleAnnotationManager)

- [x] Create `widgets/waypoint_list.dart`
  - [x] Implement draggable list (ReorderableListView)
  - [x] Add reorder functionality
  - [x] Add waypoint details (type, radius, linked stop)
  - [x] Add delete functionality
  - [x] Add overlap warning indicators

- [x] Create `widgets/route_tools_panel.dart`
  - [x] Add snap mode selector (dropdown)
  - [x] Add clear route button
  - [x] Add undo/redo buttons
  - [x] Add route statistics display (distance, duration, stops)
  - [x] Add save button with loading state

- [x] Create `widgets/trigger_radius_editor.dart`
  - [x] Add radius slider (10-100m)
  - [x] Add radius presets (15, 25, 35, 50, 75m)
  - [x] Add waypoint name input
  - [x] Add waypoint type selector
  - [x] Add overlap warnings
  - [x] Add coordinates display
  - [x] Add bottom sheet variant for mobile

#### Route Logic
- [x] Create `providers/route_editor_provider.dart`
  - [x] Implement RouteEditorState (immutable)
  - [x] Implement RouteEditorNotifier (StateNotifier)
  - [x] Implement addWaypoint
  - [x] Implement removeWaypoint
  - [x] Implement reorderWaypoints
  - [x] Implement moveWaypoint
  - [x] Implement updateTriggerRadius
  - [x] Implement updateWaypointName
  - [x] Implement updateWaypointType
  - [x] Implement setSnapMode
  - [x] Implement selectWaypoint
  - [x] Implement undo/redo (50 action limit)
  - [x] Implement clearRoute
  - [x] Implement save
  - [x] Implement initialize (load existing route)

- [x] Integrate RouteSnappingService
- [x] Add auto-snap functionality
- [x] Add manual override functionality (RouteSnapMode.none)
- [x] Add route statistics calculation
- [x] Add overlap detection (overlappingWaypointIndices)

#### Testing
- [x] Write unit tests for RouteEditorProvider (25 tests)
  - [x] State tests (formatting, computed properties)
  - [x] Waypoint operations tests
  - [x] Undo/redo tests
  - [x] Snap mode tests
  - [x] Save tests
  - [x] Overlap detection tests
- [ ] Write widget tests for all components
- [ ] Write integration tests for route creation
- [ ] Test auto-snap vs manual mode
- [ ] Test trigger radius visualization
- [ ] Test waypoint drag-and-drop

### Day 4-5: Content Editor - Basic Structure ✅

#### Screen Structure
- [x] Create `lib/presentation/screens/modules/content_editor/` folder
- [x] Create `tour_editor_screen.dart` (tab-based layout)
- [x] Create `modules/` subfolder for tabs
- [x] Create `providers/` subfolder
- [x] Create `content_editor.dart` (exports)

#### Tab Modules
- [x] Create `modules/basic_info_module.dart`
  - [x] Title input
  - [x] Description textarea
  - [x] Category dropdown
  - [x] Tour type selector (SegmentedButton)
  - [x] Difficulty selector (SegmentedButton)
  - [x] City/region/country inputs
  - [x] Tags placeholder

- [x] Create `modules/route_module.dart`
  - [x] Route Editor integration (embedded mode)
  - [x] Route summary display (stops, distance, duration)
  - [x] Full screen button
  - [x] Empty state for no route

- [x] Create `modules/stops_module.dart`
  - [x] Stops list with ReorderableListView
  - [x] Inline editing (title, description)
  - [x] Expandable stop cards
  - [x] Audio status indicators
  - [x] Audio section with record/generate options
  - [x] Delete confirmation dialog

- [x] Create `modules/media_module.dart`
  - [x] Cover image upload/preview
  - [x] Image guidelines card
  - [x] Stop images gallery preview
  - [x] Image placeholder picker

- [x] Create `modules/pricing_module.dart`
  - [x] Free/Paid toggle cards
  - [x] Price input with currency symbol
  - [x] Quick price buttons
  - [x] Currency selector (EUR, USD, GBP)
  - [x] Pricing guidelines
  - [x] Revenue breakdown display

#### Providers
- [x] Create `providers/tour_editor_provider.dart`
  - [x] TourEditorState with all tour fields
  - [x] TourEditorNotifier with full CRUD
  - [x] Load existing tour or create new
  - [x] Update title, description, basic info
  - [x] Update cover image
  - [x] Update pricing (free/paid/currency)
  - [x] Manage stops (add/remove/reorder)
  - [x] Save tour to Firestore
  - [x] Validation errors getter
  - [x] Completion progress tracking

#### Route Editor Updates
- [x] Added `embedded` parameter for integration
- [x] Made tourId/versionId optional for new tours
- [x] Updated all internal widget references

#### Testing
- [x] Write unit tests for TourEditorProvider (24 tests)
  - [x] State tests (defaults, getters)
  - [x] Title/description update tests
  - [x] Pricing tests (free/paid)
  - [x] Stops management tests
  - [x] Reorder tests
  - [x] Tab navigation tests
- [ ] Write widget tests for all tabs
- [ ] Write integration tests for tour creation
- [ ] Test tab navigation
- [ ] Test data persistence

---

## Week 3: Content Editor Voice + Tour Manager + Publishing ✅

**Goal**: Complete content editor with voice generation, build tour manager, implement publishing workflow

### Day 1-2: Content Editor - Voice Generation ✅

#### Stop Editor
- [x] Create `stop_editor_screen.dart`
  - [x] Name input
  - [x] Description textarea
  - [x] Location picker (map)
  - [x] Trigger radius slider
  - [x] Audio options (Record, Upload, Generate) - tabbed interface
  - [x] Image gallery management

#### Voice Generation
- [x] Create `widgets/voice_generator_panel.dart`
  - [x] Script textarea with character count
  - [x] Voice selector dropdown (4 voices)
  - [x] Duration preview
  - [x] Generate button with loading state
  - [x] Audio preview player
  - [x] Regenerate button
  - [x] Generation history list

- [x] Create `widgets/script_editor.dart`
  - [x] Text area with formatting
  - [x] Character counter (5000 limit)
  - [x] Duration estimation (words/150 per minute)
  - [x] Progress bar with color warnings
  - [x] ScriptEditorDialog for modal editing

- [x] Create `providers/voice_generation_provider.dart`
  - [x] Integrate VoiceGenerationService
  - [x] Handle generation states (loading, success, error)
  - [x] Store script + audio URL
  - [x] Handle regeneration
  - [x] Generation history tracking

#### Testing
- [ ] Write tests for voice generation flow
- [ ] Mock ElevenLabs API
- [ ] Test error handling
- [ ] Test regeneration

### Day 3: Tour Manager ✅

#### Screen Structure
- [x] Create `lib/presentation/screens/modules/tour_manager/` folder
- [x] Create `tour_manager_screen.dart` (main screen with tabs)
- [x] Create `views/` subfolder
- [x] Create `widgets/` subfolder
- [x] Create `providers/` subfolder
- [x] Create `tour_manager.dart` (exports)

#### Views
- [x] Create `views/list_view_tab.dart`
  - [x] Compact tour rows using TourCardCompact
  - [x] Status badges
  - [x] Quick stats (stops, plays)
  - [x] Actions menu

- [x] Create `views/grid_view_tab.dart`
  - [x] Card-based layout using TourCardGrid
  - [x] Cover images
  - [x] Status badges

- [x] Create `views/analytics_view_tab.dart`
  - [x] Performance metrics table
  - [x] Sortable columns (plays, downloads, favorites, rating)
  - [x] Trend indicators

- [x] Create `views/calendar_view_tab.dart`
  - [x] Month/week/day views using table_calendar
  - [x] Color-coded by status
  - [x] Tour details on date click

#### Widgets
- [x] Create `widgets/tour_manager_filters.dart`
  - [x] Status filter dropdown
  - [x] Category filter dropdown
  - [x] Date range picker
  - [x] Search input

- [x] Create `widgets/tour_card_compact.dart` (list view)
- [x] Create `widgets/tour_card_grid.dart` (grid view)
- [x] Create `widgets/tour_stats_summary.dart` (top stats bar)
- [x] Create `widgets/quick_actions_menu.dart` (per-tour actions)

#### Providers
- [x] Create `providers/tour_manager_provider.dart`
  - [x] TourManagerState with tours, filters, pagination
  - [x] TourManagerFilters for status, category, search, date range
  - [x] TourManagerNotifier with full CRUD
  - [x] Fetch tours with filters
  - [x] Implement pagination (20 per page)
  - [x] Duplicate tour functionality
  - [x] Delete tour functionality

#### Testing
- [ ] Write tests for all views
- [ ] Test filters and search
- [ ] Test pagination
- [ ] Test role-based access

### Day 4-5: Publishing Workflow ✅

#### Screens
- [x] Create `lib/presentation/screens/modules/publishing/` folder
- [x] Create `submission_screen.dart`
  - [x] Pre-submission checklist with validation
  - [x] Submit button
  - [x] Status display section
  - [x] Feedback section
  - [x] Withdraw submission option
  - [x] Resubmit functionality

- [x] Create `review_queue_screen.dart` (Admin)
  - [x] List of pending submissions
  - [x] Filter tabs by status
  - [x] Stats header (pending, in review, total)
  - [x] Submission cards with status badges
  - [x] Pagination support

- [x] Create `tour_review_screen.dart` (Admin)
  - [x] Preview/Edit mode toggle
  - [x] Tour content display
  - [x] Feedback panel with form
  - [x] Action buttons (Approve, Reject, Request Changes)
  - [x] Confirmation dialogs

#### Widgets
- [x] Create `widgets/submission_checklist.dart`
  - [x] SubmissionChecklist component
  - [x] DetailedChecklist with progress bar
- [x] Create `widgets/feedback_widgets.dart`
  - [x] FeedbackList
  - [x] FeedbackCard with type indicators
  - [x] FeedbackForm with type selector
- [x] Create `publishing.dart` (exports)

#### Providers
- [x] Create `providers/publishing_provider.dart`
  - [x] PublishingState/PublishingNotifier - creator submission workflow
  - [x] ReviewQueueState/ReviewQueueNotifier - admin queue management
  - [x] TourReviewState/TourReviewNotifier - reviewing specific submissions
  - [x] Submit for review with validation
  - [x] Withdraw submission
  - [x] Resubmit with justification
  - [x] Add feedback (type, message, stop reference)
  - [x] Approve/reject/request changes actions

#### Testing
- [ ] Write tests for submission flow
- [ ] Write tests for review flow
- [ ] Test feedback system
- [ ] Test resubmission logic

---

## Week 4: Marketplace & Tour Details

**Goal**: Rebuild tour discovery and unified tour details page

### Day 1-3: Marketplace - PARTIALLY COMPLETE (DISABLED)

**Status**: Implemented but disabled due to Mapbox API compatibility issues on mobile.

#### Screen Structure
- [x] Create `lib/presentation/screens/modules/marketplace/` folder
- [x] Create `marketplace_screen.dart` (main screen)
- [x] Create `widgets/` subfolder
- [x] Create `providers/` subfolder

#### Search & Filters
- [x] Search bar with real-time filtering
- [x] Category filter pills
- [x] View mode toggle (List/Map)

#### Views
- [x] List view with tour cards
- [x] Map view with clustering (Mapbox)
- ⚠️ **DISABLED**: Renamed to `marketplace.disabled` due to API compat errors

#### Collections
- [x] Collection cards
- [x] Collection details screen
- [x] 10 Paris collections (mocked)

#### Providers
- [x] Marketplace provider with filters
- [x] Collections provider

#### Issues
- Mapbox API incompatibility (`resourceOptions`, `.geometry` not available)
- Freezed code generation failures
- Router falls back to `DiscoverScreen`

#### Testing
- [ ] Write tests for search
- [ ] Write tests for filters
- [ ] Write tests for map view
- [ ] Write tests for collections

### Day 4-5: Tour Details ⏳

#### Screen
- [ ] Create `lib/presentation/screens/modules/tour_details/` folder
- [ ] Create `tour_details_screen.dart` (mobile-optimized)

#### Sections
- [ ] Create `widgets/tour_hero_section.dart`
  - [ ] Hero image
  - [ ] Title
  - [ ] Creator name
  - [ ] Rating

- [ ] Create `widgets/tour_stats_section.dart`
  - [ ] Duration, distance, stops, price

- [ ] Create `widgets/tour_actions_bar.dart`
  - [ ] Download button
  - [ ] Start Tour button
  - [ ] Favorite button
  - [ ] Share button

- [ ] Create `widgets/tour_overview_section.dart`
  - [ ] Description

- [ ] Create `widgets/stops_preview_section.dart`
  - [ ] Stops list
  - [ ] Map toggle

- [ ] Create `widgets/creator_profile_section.dart`
  - [ ] Creator info
  - [ ] View profile button

- [ ] Create `widgets/reviews_section.dart`
  - [ ] Reviews list
  - [ ] See all button

- [ ] Create `widgets/similar_tours_section.dart`
  - [ ] Horizontal tour cards

- [ ] Create `widgets/admin_actions_panel.dart` (Admin only)
  - [ ] Feature/Unfeature
  - [ ] Hide/Unhide
  - [ ] Delete
  - [ ] View Analytics

#### Providers
- [ ] Create `providers/tour_details_provider.dart`
  - [ ] Fetch tour details

- [ ] Create `providers/similar_tours_provider.dart`
  - [ ] Fetch similar tours

#### Testing
- [ ] Write tests for all sections
- [ ] Test role-based actions
- [ ] Test mobile layout

---

## Week 5: Analytics & Integration

**Goal**: Build analytics dashboard and integrate all modules

### Day 1-2: Analytics Dashboard ⏳

#### Screen Structure
- [ ] Create `lib/presentation/screens/modules/analytics/` folder
- [ ] Create `analytics_dashboard_screen.dart`
- [ ] Create `modules/` subfolder
- [ ] Create `widgets/` subfolder
- [ ] Create `providers/` subfolder

#### Metric Modules
- [ ] Create `modules/plays_analytics_module.dart`
  - [ ] Metric card
  - [ ] Chart
  - [ ] Trend indicator

- [ ] Create `modules/downloads_analytics_module.dart`
- [ ] Create `modules/favorites_analytics_module.dart`
- [ ] Create `modules/revenue_analytics_module.dart`
- [ ] Create `modules/completion_analytics_module.dart`
- [ ] Create `modules/geographic_analytics_module.dart`
- [ ] Create `modules/time_series_analytics_module.dart`
- [ ] Create `modules/user_feedback_analytics_module.dart`

#### Widgets
- [ ] Create `widgets/metric_card.dart`
- [ ] Create `widgets/date_range_picker.dart`
- [ ] Create `widgets/analytics_chart.dart`
- [ ] Create `widgets/csv_export_button.dart`

#### Providers
- [ ] Create `providers/tour_analytics_provider.dart`
  - [ ] Fetch analytics with caching
  - [ ] Export to CSV
  - [ ] Handle date ranges

#### CSV Export
- [ ] Implement CSV generation
- [ ] Add download functionality
- [ ] Test export

#### Testing
- [ ] Write tests for all modules
- [ ] Test caching
- [ ] Test CSV export

### Day 3-5: Integration & Cleanup ⏳

#### Routing
- [ ] Update `lib/presentation/router/app_router.dart`
  - [ ] Add Tour Manager route
  - [ ] Add Route Editor route
  - [ ] Add Content Editor route
  - [ ] Add Publishing routes
  - [ ] Add Marketplace route
  - [ ] Add Tour Details route
  - [ ] Add Analytics route

- [ ] Update navigation flows
  - [ ] Tour Manager → Content Editor
  - [ ] Content Editor → Route Editor
  - [ ] Publishing → Tour Manager
  - [ ] Marketplace → Tour Details
  - [ ] Tour Details → Analytics

#### Module Connections
- [ ] Connect Tour Manager to Content Editor
- [ ] Connect Content Editor to Route Editor
- [ ] Connect Publishing to Tour Manager
- [ ] Connect Marketplace to Tour Details
- [ ] Connect Tour Details to Analytics

#### Cleanup
- [ ] Delete `lib/presentation/screens/creator/creator_dashboard_screen.dart`
- [ ] Delete `lib/presentation/screens/creator/tour_editor_screen.dart`
- [ ] Delete `lib/presentation/screens/creator/stop_editor_screen.dart`
- [ ] Delete `lib/presentation/screens/admin/all_tours_screen.dart`
- [ ] Delete `lib/presentation/screens/admin/review_queue_screen.dart`
- [ ] Delete `lib/presentation/screens/user/discover_screen.dart`

#### Testing
- [ ] Run all unit tests
- [ ] Run all widget tests
- [ ] Run all integration tests
- [ ] Write end-to-end tests for key user journeys:
  - [ ] Creator: Create tour → Submit → Receive feedback → Resubmit → Approved
  - [ ] Admin: Review queue → Review tour → Provide feedback → Approve
  - [ ] Tourist: Marketplace → Search → View details → Download → Start tour

#### Performance
- [ ] Profile Tour Manager performance
- [ ] Profile Route Editor performance
- [ ] Profile Marketplace performance
- [ ] Optimize slow operations
- [ ] Add loading states
- [ ] Add error boundaries

#### Bug Fixes
- [ ] Fix any discovered bugs
- [ ] Address edge cases
- [ ] Handle error scenarios

#### Documentation
- [ ] Update code comments
- [ ] Update README if needed
- [ ] Update SESSION_LOG with final status

---

## Post-Implementation Checklist

### Deployment Preparation
- [ ] Run full test suite
- [ ] Fix all failing tests
- [ ] Code review
- [ ] Performance audit
- [ ] Security audit
- [ ] Backup Firestore data
- [ ] Prepare rollback plan

### Deployment
- [ ] Deploy Cloud Functions
- [ ] Update Firestore security rules
- [ ] Deploy web app
- [ ] Deploy mobile app (if applicable)
- [ ] Monitor for errors
- [ ] Verify all features working

### Post-Deployment
- [ ] Monitor API usage (Mapbox, ElevenLabs)
- [ ] Monitor performance metrics
- [ ] Collect user feedback
- [ ] Address critical bugs
- [ ] Plan iteration improvements

---

## Notes & Blockers

### Current Blockers
- None

### Decisions Made
- Using Riverpod code generation for all new providers
- Using Freezed for all new models
- Web-first for Tour Manager and Route Editor
- Mobile-first for Tour Details and Marketplace
- Big Bang migration strategy
- 5-minute analytics caching

### Future Enhancements
- Bulk actions for Tour Manager
- Email notifications for publishing
- Stripe integration for payments
- Route validation
- Real-time analytics
- Offline support for Tour Manager
- More voice options
- More collections

---

## Progress Summary

**Overall Progress**: 65% (Week 1-3 complete, Week 4 partial)

**Week 1**: ✅ Complete (Foundation - Data Models, Repositories, Services, Cloud Functions)
**Week 2**: ✅ Complete (Route Editor + Content Editor Basic Structure)
**Week 3**: ✅ Complete (Voice Generation + Tour Manager + Publishing Workflow)
**Week 4**: ⚠️ Partial (Marketplace implemented but disabled due to API issues)
**Week 5**: ⏳ Not Started

**Last Updated**: February 4, 2026
**Current Blocker**: Mobile app has critical issues (map tiles, audio, dead-end buttons)
**Next Milestone**: Fix mobile app issues before continuing Tour Manager rebuild
