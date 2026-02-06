# Project Status Summary

**Last Updated**: February 6, 2026
**Project**: AYP Tour Guide - Mobile App
**Status**: ~90% Complete — Core UX functional, design system overhauled

---

## Current State

The mobile app core experience is working: maps render, audio plays, tours load from Firestore, and the playback flow is functional end-to-end.

### Recently Fixed (Session 10 — Feb 6, 2026)

| Issue | Fix |
|-------|-----|
| **Reviews hidden** | Commented out `TourReviewsSection` in tour details + "My Reviews" nav in profile (code preserved for re-enable) |
| **Tour not starting at first stop** | Added `_initialProximityCheck()` after geofence setup — triggers stop if user already inside radius |
| **Navigate-to-first-stop prompt** | New `_NavigateToFirstStopCard` widget shows distance + "Show" button when user hasn't reached stop 1 |
| **Playback screen overlaps** | Disabled Mapbox scale bar, repositioned compass/logo/attribution ornaments; added `SafeArea` to bottom sheet status bar |
| **Profile photo upload failing** | Storage path mismatch: `users/$userId/avatar` → `users/$userId/profile/avatar` to match Firebase Storage rules |
| **Tour download button added** | `TourDownloadButton` in tour details app bar + bottom bar (download infrastructure already existed) |
| **Download GeoPoint/Timestamp crash** | `toJson()` converters now return plain maps/ISO strings instead of Firestore objects (Hive can't serialize GeoPoint/Timestamp) |
| **Download error visibility** | Added `debugPrint` logging + snackbar with error message on failed downloads |

### Previously Fixed (Session 7 — Feb 6, 2026)

| Issue | Fix |
|-------|-----|
| **Boutique Editorial redesign** | Complete design system overhaul — serif typography (Playfair Display, Libre Baskerville, EB Garamond), warm gold/parchment/sepia palette, glassmorphic UI replacing neumorphic |
| **Neumorphic system removed** | Deleted `neumorphic.dart`, updated all 3 marketplace files that imported it, `neumorphic_card.dart` now uses glassmorphic internally |
| **Gate circles not scaling with zoom** | Circles now redraw on every camera change with pixel radius recalculated for current zoom level (both tour map and route editor) |
| **New widgets created** | `GlassPanel`, `ParchmentScaffold`, `VintageLoader` (compass spinner, ink progress, quill dots) |
| **Motion design system** | `editorial_transitions.dart` — paper-flip page transitions, glass pane modals, micro-interaction presets |
| **google_fonts dependency** | Added `google_fonts: ^6.2.1` to pubspec.yaml |

### Previously Fixed (Session 6 — Feb 5, 2026)

| Issue | Fix |
|-------|-----|
| **Audio auto-play not triggering** | Added same-stop guard, continuous proximity checks, removed duplicate location tracking |
| **Center-on-user button silent fail** | Falls back to `Geolocator.getCurrentPosition()` when streamed position is null |
| **Begin Tour had no options** | Now shows bottom sheet with "Browse Tour Map" and "Start Tour Now" choices |
| **Browse mode markers not tappable** | Tapping a stop in preview mode now shows info sheet (name, images, description) |

### Previously Fixed (Sessions 1–5) 

| Issue | Session |
|-------|---------|
| Map tiles not rendering (Mapbox token, Impeller, hosting mode) | 3 |
| Audio not playing (null audioUrls patched) | 3–4 |
| Cover images not loading on Home tab (AsyncValue pattern) | 4–5 |
| Dead-end buttons removed/implemented | 4 |
| Seed tours cleaned up, admin tours patched | 5 |

### Remaining Issues

| Issue | Severity | Notes |
|-------|----------|-------|
| **Tour download not yet verified** | Medium | GeoPoint/Timestamp serialization fixed but download not re-tested end-to-end |
| **RenderFlex overflow** | Low | 8px overflow on home screen `_FeaturedTourCard` — pre-existing |
| **GoogleApiManager DEVELOPER_ERROR** | Low | SHA-1 fingerprint not registered in Firebase console |
| **~258 hardcoded color refs** | Low | In 43 admin/creator/module files — deferred to follow-up |
| **Dark theme** | Low | Not updated for botanical design system |
| **Content editor placeholders** | N/A | Stop editor (map picker, record audio, file upload) — legitimately "coming soon" |

---

## What Works

- Core navigation and architecture
- Authentication (login/logout)
- Tour list with cover images on Home and Discover tabs
- Map rendering with stop markers and trigger radius circles
- **Gate circles scale correctly with map zoom** (redraw on camera change)
- Audio playback with auto-trigger on geofence entry
- Playback bottom sheet with stop list, play/pause, expanded content
- Center-on-user button with fallback
- Begin Tour choice dialog (Browse Map / Start Tour)
- Browse mode with tappable stop markers showing info sheets
- Preview mode (explore map without audio/tracking)
- Tour completion overlay
- **Botanical design system** (glassmorphic, serif typography, garden-green/ivory-cream palette)
- **Reusable widgets**: GlassPanel, ParchmentScaffold, VintageLoader
- **Motion design**: editorial transitions, glass pane modals, micro-interactions
- Navigate-to-first-stop prompt when user isn't at stop 1
- Initial proximity check auto-triggers stop if already inside geofence
- Profile photo upload (Firebase Storage)
- Tour download button on tour details screen (downloads data, audio, images, map tiles)

---

## Tour Manager Rebuild Status

| Module | Status |
|--------|--------|
| Route Editor | Complete |
| Content Editor | Complete |
| Voice Generation | Complete |
| Tour Manager | Complete |
| Publishing Workflow | Complete |
| Marketplace | Disabled (Mapbox API compat issues) |
| Analytics Dashboard | Not started |

---

## Key Files

| File | Purpose |
|------|---------|
| `glassmorphic.dart` | Glassmorphic panel decorations (heavy/medium/light/whisper) |
| `layering.dart` | 5-plane Z-index architecture for visual depth |
| `editorial_transitions.dart` | Page transitions, modal animations, micro-interaction presets |
| `glass_panel.dart` | Reusable frosted glass container widget |
| `parchment_scaffold.dart` | Scaffold with parchment gradient background |
| `vintage_loader.dart` | Compass spinner, ink progress bar, quill dots loaders |
| `playback_provider.dart` | Audio playback, geofence triggers, proximity checks |
| `tour_map_widget.dart` | Map rendering, stop markers, center button |
| `tour_playback_screen.dart` | Playback UI, stop info sheet (browse), end tour |
| `tour_details_screen.dart` | Tour info, begin tour dialog |
| `playback_bottom_sheet.dart` | Stop list, play/pause controls, expanded content |

---

## Documentation

- [Tour Manager](./TOUR_MANAGER.md) - Tour Manager rebuild tasks
- [Architecture](./ARCHITECTURE.md) - System design
