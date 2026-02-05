# Project Status Summary

**Last Updated**: February 5, 2026
**Project**: AYP Tour Guide - Mobile App
**Status**: ~85% Complete — Core UX functional, polish remaining

---

## Current State

The mobile app core experience is working: maps render, audio plays, tours load from Firestore, and the playback flow is functional end-to-end.

### Recently Fixed (Session 6 — Feb 5, 2026)

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
| **RenderFlex overflow** | Low | 8px/22px overflow on home screen (skeleton_loader.dart:59 area) |
| **Reviews PERMISSION_DENIED** | Low | Firestore rules rejecting reviews query |
| **GoogleApiManager DEVELOPER_ERROR** | Low | SHA-1 fingerprint not registered in Firebase console |
| **Content editor placeholders** | N/A | Stop editor (map picker, record audio, file upload) — legitimately "coming soon" |

---

## What Works

- Core navigation and architecture
- Authentication (login/logout)
- Tour list with cover images on Home and Discover tabs
- Map rendering with stop markers and trigger radius circles
- Audio playback with auto-trigger on geofence entry
- Playback bottom sheet with stop list, play/pause, expanded content
- Center-on-user button with fallback
- Begin Tour choice dialog (Browse Map / Start Tour)
- Browse mode with tappable stop markers showing info sheets
- Preview mode (explore map without audio/tracking)
- Tour completion overlay

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
| `playback_provider.dart` | Audio playback, geofence triggers, proximity checks |
| `tour_map_widget.dart` | Map rendering, stop markers, center button |
| `tour_playback_screen.dart` | Playback UI, stop info sheet (browse), end tour |
| `tour_details_screen.dart` | Tour info, begin tour dialog |
| `playback_bottom_sheet.dart` | Stop list, play/pause controls, expanded content |

---

## Documentation

- [Tour Manager](./TOUR_MANAGER.md) - Tour Manager rebuild tasks
- [Architecture](./ARCHITECTURE.md) - System design
