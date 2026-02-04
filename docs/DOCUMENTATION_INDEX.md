# Documentation Index - Context Loading Guide

**Purpose**: This is the master index for all AYP Tour Guide documentation. Read this first, then follow the recommended reading order based on your role or task.

**Last Updated**: February 4, 2026

---

## Current Project State

### Mobile App: CRITICAL ISSUES

The mobile app has blocking issues that must be fixed before real testing:

| Issue | Status |
|-------|--------|
| Map tiles not rendering | 3 fixes applied, untested |
| Audio not playing | Data issue - Firestore has null audioUrls |
| Tour cover images not loading | Not investigated |
| Center-on-user button broken | Not investigated |
| Dead-end buttons everywhere | Not fixed |

**See [PROJECT_STATUS.md](./PROJECT_STATUS.md) for full details.**

### Tour Manager Rebuild: ~65%

Creator/admin tools rebuild is separate from mobile issues:
- Route Editor: Complete
- Content Editor: Complete
- Voice Generation: Complete
- Tour Manager: Complete
- Publishing Workflow: Complete
- Marketplace: Disabled (API compat issues)
- Analytics Dashboard: Not started

---

## Quick Start - Context Loading Order

### For AI Assistants (Claude/Cascade)

**Read these files in this exact order:**

1. **START HERE** → `DOCUMENTATION_INDEX.md` (this file)
2. **Current Issues** → `PROJECT_STATUS.md` (blocking mobile issues)
3. **Session History** → `SESSION_LOG.md` (recent changes)
4. **Memory** → `.claude/projects/.../memory/MEMORY.md` (priority issues)
5. **Architecture** → `ARCHITECTURE.md` (system design)

### For Developers

#### Fixing Mobile Issues
1. `PROJECT_STATUS.md` - List of blocking issues
2. `SESSION_LOG.md` - What was tried
3. `MEMORY.md` - Priority fixes

#### Working on Tour Manager Rebuild
1. `TOUR_MANAGER_ROADMAP.md` - Complete rebuild plan
2. `DATA_MODELS.md` - All new data models
3. `IMPLEMENTATION_CHECKLIST.md` - Week-by-week tasks

---

## Documentation Files

### Core Documentation

| File | Purpose | Status |
|------|---------|--------|
| `README.md` (Root) | Project overview, tech stack | Needs update |
| `PROJECT_STATUS.md` | Current issues, honest assessment | Updated |
| `SESSION_LOG.md` | Recent changes, decisions | Updated |
| `ARCHITECTURE.md` | System design, patterns | Needs update |
| `SETUP.md` | Development environment | Up to date |
| `TESTING.md` | Testing strategy | Up to date |

### Tour Manager Rebuild Documentation

| File | Purpose | Status |
|------|---------|--------|
| `TOUR_MANAGER_ROADMAP.md` | Master plan for rebuild | Complete |
| `DATA_MODELS.md` | 8 new Freezed models | Complete |
| `API_INTEGRATIONS.md` | Mapbox, ElevenLabs, Stripe | In progress |
| `IMPLEMENTATION_CHECKLIST.md` | Week-by-week tasks | In progress |

### Legacy Documentation

| File | Purpose | Status |
|------|---------|--------|
| `COMPLETION_PLAN.md` | Original completion plan | Outdated - see PROJECT_STATUS |

---

## Navigation Guide

### "I want to fix the mobile app"
1. Read `PROJECT_STATUS.md` for the issue list
2. Read `SESSION_LOG.md` for what was tried
3. Check `MEMORY.md` for priority fixes

### "I'm implementing the Tour Manager rebuild"
1. Read `TOUR_MANAGER_ROADMAP.md` (full read)
2. Read `DATA_MODELS.md`
3. Check `IMPLEMENTATION_CHECKLIST.md` for current tasks

### "I'm debugging a specific issue"
1. Check `SESSION_LOG.md` for recent changes
2. Check `MEMORY.md` for known issues
3. Review relevant code files

---

## Quick Links

### Essential Files
- [Project Status](./PROJECT_STATUS.md) - Current blocking issues
- [Session Log](./SESSION_LOG.md) - Recent changes
- [Architecture](./ARCHITECTURE.md) - System design
- [Tour Manager Roadmap](./TOUR_MANAGER_ROADMAP.md) - Rebuild plan

### Setup & Development
- [Setup Guide](./SETUP.md)
- [Testing Guide](./TESTING.md)

---

## Priority Fixes for Next Session

1. **Deploy and test map tile fixes** - `flutter run -d R5CY503JQTT --no-enable-impeller`
2. **Debug cover images** - Check if URLs are null in Firestore
3. **Test center-on-user button** - Check location permissions
4. **Audit dead-end buttons** - Find all `onPressed: () {}`
5. **Add real audio files** - Current test data has null audioUrls

---

**Remember**: The mobile app is not usable until the map tiles work and dead-end buttons are cleaned up.
