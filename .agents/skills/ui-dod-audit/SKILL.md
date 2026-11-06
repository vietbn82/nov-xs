---
name: ui-dod-audit
description: >-
  Audits frontend UI, CSS tokens, Native Web Components, Top-Layer overlay mutual
  exclusivity, accessibility (WCAG 2.2 AA), and backend test health against the
  4-Point Definition of Done (DoD) Gate. Use before marking any feature or UI work complete.
---

# UI & Definition of Done (DoD) Audit

Run this 4-point verification gate before claiming any feature slice or UI change is complete.

## Step 1: Run Automated Static, Security & Test Auditor

Execute [audit-dod.ps1](./scripts/audit-dod.ps1):

```powershell
pwsh -NoProfile -File .agents/skills/ui-dod-audit/scripts/audit-dod.ps1
```

This script automatically verifies:
1. **Token Purity**: Zero hardcoded hex colors (`#[0-9a-fA-F]{3,8}`) or pixel font sizes (`font-size: ...px`) outside `tokens.css`.
2. **Top-Layer Hygiene**: Zero hardcoded `z-index` values outside `tokens.css` variables (`var(--z-*)`).
3. **Secret Hygiene**: Zero leaked API keys (`AIza...`, `sk-...`) in source files.
4. **Automated Test Suite**: Runs `dotnet test --nologo` and verifies exit code `0`.

## Step 2: Responsive Viewport & Occlusion Check (`375px` & `1440px`)

When a browser or Chrome DevTools MCP is available:
1. Inspect the page at **Mobile (`375x812`)** and **Desktop (`1440x900`)**.
2. Verify `document.documentElement.scrollWidth <= document.documentElement.clientWidth` (zero horizontal overflow).
3. Open active `<dialog>` modals and `popover="auto"` surfaces via `window.TopLayer` to confirm primary CTAs are never occluded and `Escape` restores focus to the trigger button.

## Step 3: Accessibility (WCAG 2.2 AA) & Console Cleanliness

1. Verify text contrast against surface backgrounds meets $\ge 4.5:1$ and interactive controls have $\ge 44 \times 44\text{px}$ hit targets (`var(--touch-target-min)`).
2. Confirm the browser DevTools console emits **zero** uncaught errors and **zero** failed network requests (`4xx`/`5xx`).
