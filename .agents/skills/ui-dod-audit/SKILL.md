---
name: ui-dod-audit
description: >-
  Audits frontend UI, Slice Component Isolation, Anti-Monolith file ceilings, CSS tokens,
  Top-Layer overlay mutual exclusivity, bounding-box overlaps (UiHealthProbe), and backend
  test health against the 4-Point Definition of Done (DoD) Gate. Use before marking any
  feature or UI work complete.
---

# UI & Definition of Done (DoD) Audit

Run this verification gate before claiming any feature slice or UI change is complete. Reference [docs/UI_ANTI_BREAKAGE_SYSTEM.md](../../../docs/UI_ANTI_BREAKAGE_SYSTEM.md) for the 5 Iron Laws of Unbreakable UI.

## Step 1: Run Automated Static, Anti-Monolith, Isolation & Test Auditor

Execute [audit-dod.ps1](./scripts/audit-dod.ps1):

```powershell
pwsh -NoProfile -File .agents/skills/ui-dod-audit/scripts/audit-dod.ps1
```

This script automatically enforces:
1. **Anti-Monolith Ceilings**: `index.html <= 150 lines`, all `wwwroot/**/*.{js,css} <= 300 lines`.
2. **Slice Isolation**: Zero `document.getElementById` or global `document.querySelector` inside `wwwroot/components/slice-*.js` (must use scoped `this.querySelector`).
3. **Token & Animation Purity**: Zero hardcoded hex colors (`#[0-9a-fA-F]{3,8}`), pixel font sizes (`font-size: ...px`), raw `z-index`, or `max-height` transitions outside `tokens.css`.
4. **Secret Hygiene & Tests**: Zero leaked API keys and `dotnet test --nologo` exits `0`.

## Step 2: Run Live DOM Bounding-Box & Viewport Probe (`375px` & `1440px`)

When a browser or Chrome DevTools MCP is available:
1. Inspect the page at **Mobile (`375x812`)** and **Desktop (`1440x900`)**.
2. Execute `window.UiHealthProbe.runAudit()` in the browser console (from [ui-health-probe.js](../../../.specify/templates/web/ui-health-probe.js)) and confirm `passed: true`:
   - Zero horizontal overflow (`scrollWidth <= clientWidth`).
   - Zero overlapping interactive controls (`ELEMENT_OVERLAP` bounding-box check).
   - All buttons/inputs meet minimum hit target bounds (`>= 40-44px`).
   - At most 1 `<dialog>` open at a time.
3. Confirm the browser DevTools console emits **zero** uncaught errors and **zero** failed network requests (`4xx`/`5xx`).
