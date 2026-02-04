# Project Status Summary

**Last Updated**: February 4, 2026
**Project**: AYP Tour Guide - Mobile App
**Status**: Mobile App Has Critical Issues Blocking Usability

---

## Current State - HONEST ASSESSMENT

The mobile app has several critical issues that make it unusable for real testing:

### Blocking Issues (Must Fix)

| Issue | Status | Notes |
|-------|--------|-------|
| **Map tiles not rendering** | 3 fixes applied, untested | Grey/blank maps on both tour details header and playback screen |
| **Audio not playing** | Data issue | All Firestore stops have `audioUrl: null` - need real audio files |
| **Tour cover images not loading** | Not investigated | Featured tours and "Recommended for you" show no images |
| **Center-on-user button broken** | Not investigated | Button exists but doesn't work |
| **Dead-end buttons everywhere** | Not fixed | Many buttons lead nowhere or show placeholder content |
| **Manual/auto trigger toggle** | Confusing UX | Toggle at top of playback screen - unclear purpose |

### Map Tile Fixes Applied (Untested)

Three fixes were applied on Feb 4, 2026 but not deployed:

1. **Disabled Impeller** - Added `EnableImpeller=false` meta-data in AndroidManifest.xml
2. **Changed androidHostingMode** - Set to `TLHC_HC` instead of default `VD` in TourMapWidget
3. **Added Android string resource** - Created `mapbox_config.xml` with access token

To test: `flutter run -d R5CY503JQTT --no-enable-impeller`

---

## What Works

- Core navigation and architecture
- Authentication (login/logout)
- Tour list displays (with placeholder images)
- Tour playback screen structure (minus map tiles)
- Bottom sheet with stops list
- Trigger radius circles on map (when tiles load)

---

## Recent UI Changes (Feb 4, 2026)

### Session 2 (Afternoon)
- Removed search & settings buttons from playback map overlay
- Converted playback bottom sheet from tabbed StatefulWidget to clean StatelessWidget
- Added play button per stop in bottom sheet
- Added status labels (Completed/Now Playing/Audio/No audio)
- Changed status bar text from version title to tour city
- Switched tour details "Begin Tour" from bottomSheet to bottomNavigationBar
- Added category-specific gradient placeholders for tour cards
- Restored trigger radius circles (user preference)

### Session 1 (Morning)
- Removed "Download Complete" checkmark and text
- Removed "Read before you go" section
- Removed "Meet the Creators" section
- Removed in-app Write Review buttons
- Added preview mode to TourPlaybackScreen

---

## Tour Manager Rebuild Status

The Tour Manager rebuild (creator/admin tools) is separate from mobile user experience:

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

## Next Session Priority

1. **Deploy and test map tile fixes** - Run with `--no-enable-impeller`
2. **Debug cover images** - Are URLs null in Firestore or is it a code issue?
3. **Test center-on-user button** - Check location permissions and userPosition state
4. **Audit dead-end buttons** - Find all `onPressed: () {}` and remove or implement
5. **Consider removing manual/auto toggle** - Confusing UX element
6. **Add real audio files to Firestore** - Current test data has null audioUrls

---

## Files to Check

| File | Issue |
|------|-------|
| `tour_map_widget.dart` | Map tile rendering |
| `tour_card.dart` | Cover image loading |
| `tour_playback_screen.dart` | Center button, trigger mode toggle |
| `playback_bottom_sheet.dart` | Stop list and audio controls |
| `playback_provider.dart` | Audio playback logic |

---

## Documentation

- [Memory File](../../../.claude/projects/C--Users-Benjamin-Desktop-Projects-AYP/memory/MEMORY.md) - Session notes and priority issues
- [Implementation Checklist](./IMPLEMENTATION_CHECKLIST.md) - Tour Manager rebuild tasks
- [Architecture](./ARCHITECTURE.md) - System design

---

**Bottom Line**: The mobile app needs the map tiles working and dead-end buttons cleaned up before it's usable for real testing.
