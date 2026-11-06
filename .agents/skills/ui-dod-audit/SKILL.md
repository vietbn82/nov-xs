---
name: ui-dod-audit
description: >-
  Audits frontend UI, CSS tokens, Native Web Components, Top-Layer overlay mutual
  exclusivity, accessibility (WCAG 2.2 AA), and backend test health against the
  4-Point Definition of Done (DoD) Gate. Use before marking any feature or UI work complete.
---

# UI & Definition of Done (DoD) Audit

Run this 4-point verification gate before claiming any feature slice or UI change is complete.

## 1. Static Token & Component Audit

- **Token Purity**: Grep modified HTML/CSS/JS files to ensure zero hardcoded hex colors (`#[0-9a-fA-F]{3,8}`) or arbitrary pixel font sizes (`text-\[\d+px\]`, `font-size:\s*\d+px`). All styling must reference `tokens.css` custom properties (`var(--font-*)`, `var(--color-*)`, `var(--radius-*)`).
- **Rule of Two (DRY)**: Confirm no duplicated header, modal, card, or drawer HTML exists across multiple `.html` files; shared constructs must use `customElements.define` in `wwwroot/components/`.
- **Top-Layer Hygiene**: Confirm modals use native `<dialog>` (`showModal()` / `close()`) and floating popovers/tooltips use `popover="auto"`, enforcing the feature's Mutual Exclusivity Matrix without z-index wars.

## 2. Automated Backend & Integration Suite

Run the full test suite and verify exit code `0`:
```powershell
dotnet test --nologo
```

## 3. Responsive Viewport & Occlusion Check (`375px` & `1440px`)

When a browser or Chrome DevTools MCP is available:
1. Inspect the page at **Mobile (`375x812`)** and **Desktop (`1440x900`)**.
2. Verify `document.documentElement.scrollWidth <= document.documentElement.clientWidth` (zero horizontal overflow).
3. Open active drawers/modals/popovers and verify primary CTA buttons are never occluded and `Escape` cleanly dismisses the active overlay while restoring focus.

## 4. Accessibility (WCAG 2.2 AA) & Console Cleanliness

1. Verify text contrast against surface backgrounds meets $\ge 4.5:1$ and interactive controls have $\ge 44 \times 44\text{px}$ hit targets.
2. Confirm the browser console emits **zero** uncaught errors (`ReferenceError`, `TypeError`, unhandled promise rejections) and **zero** failed network requests (`4xx`/`5xx`).
