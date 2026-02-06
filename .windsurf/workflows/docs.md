---
description: Documentation procedures for session start/end
---

## Usage

- /docs start - Begin a session (reads current status)
- /docs end - End a session (updates PROJECT_STATUS.md)
- /docs status - Quick view of current state (read-only)

---

## Start Procedure

When user runs /docs start:

1. Read docs/PROJECT_STATUS.md
2. Summarize to user:
   - Current blocking issues (table format)
   - What currently works
   - Next session priorities
3. Ask: **What is the goal for this session?**

---

## End Procedure

When user runs /docs end:

1. Ask: **What was accomplished this session?**
2. Propose updates to docs/PROJECT_STATUS.md:
   - Update Last Updated to today date
   - Move resolved issues from Blocking Issues to What Works
   - Add any new issues discovered to Blocking Issues
   - Update Next Session Priority based on remaining work
   - Add session notes to Recent UI Changes section if UI changed
3. **Show proposed changes and confirm before saving**
4. If architecture changed, remind to update docs/ARCHITECTURE.md

---

## Status Procedure

When user runs /docs status:

1. Read docs/PROJECT_STATUS.md
2. Display current state (read-only, no changes)

---

## Files This Workflow Touches

| File | When |
|------|------|
| docs/PROJECT_STATUS.md | Always on /docs end |
| docs/ARCHITECTURE.md | Only if architecture changed |
| docs/TOUR_MANAGER.md | Only if Tour Manager tasks completed |
