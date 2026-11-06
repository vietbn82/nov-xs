# Unbreakable & High-Craft UI System (Anti-Regression Architecture)

> **Why UI Breaks in AI Vibe Coding — And How Nov-XS Permanently Eliminates It:**  
> Industry research on AI coding agents shows that LLMs optimize for *local textual plausibility* over *global layout integrity*. Left unguided, agents invent magic pixel margins, un-wrapped flex rows, global CSS selectors that bleed across components, and monolithic HTML/JS files.  
> **Nov-XS combines 6 state-of-the-art frontend constraints (`Every Layout` primitives, `@scope` / Custom Element isolation, Open-Code `shadcn`-style primitives, Semantic `oklch()` Tokens, Anti-Monolith Linters, and Live Bounding-Box Probes) to make UI regressions structurally impossible.**

---

## 1. The 6 Pillars of AI-First Unbreakable UI

### Pillar 1: "Every Layout" Algorithmic CSS Primitives (Zero `@media` Breakage)
AI agents notoriously break responsive layouts when writing custom `@media` queries or hardcoded margins. In `Nov-XS`, agents are **forbidden** from writing raw structural margins or custom flex/grid wrappers when the 5 algorithmic primitives in `styles.css` can be composed:
- **`.l-stack`**: Vertical flow (`> * + * { margin-block-start: var(--stack-space, var(--space-4)); }`). Eliminates margin collapse and uneven vertical spacing.
- **`.l-cluster`**: Intrinsic inline wrapping (`display: flex; flex-wrap: wrap; gap: var(--space-3)`). Guarantees toolbars, pill lists, and button groups wrap cleanly on `375px` mobile screens without overflowing.
- **`.l-split`**: Space-between header/action bar with automatic `flex-wrap: wrap`.
- **`.l-grid`**: Auto-responsive grid (`repeat(auto-fit, minmax(min(var(--grid-min, 320px), 100%), 1fr))`). Adapts from 1 to 3+ columns purely by math—zero media queries required.
- **`.l-sidebar`**: Fluid sidebar + main content layout that automatically stacks when container width narrows.

### Pillar 2: Strict Slice & Style Isolation (`<slice-*>` + CSS `@scope`)
- `index.html` is a **pure App Shell (`<= 150 lines`)** containing only `<app-header>`, `<main class="app-shell">`, and `<slice-*>` custom element tags.
- Every Vertical Slice (`Features/Tasks`) owns its own isolated Web Component (`wwwroot/components/slice-tasks.js`).
- **Scoped Queries Only**: Inside a Web Component, `document.getElementById()` and global `document.querySelector()` are **banned**. Always query against `this` (`this.querySelector(...)`).
- **CSS `@scope` Boundary**: Any slice-specific CSS must be wrapped in `@scope (slice-name) { ... }` so selectors can never bleed into sibling components.

### Pillar 3: Hard Anti-Monolith File Ceilings (Enforced by `audit-dod.ps1`)
`audit-dod.ps1` automatically fails the build if:
- `wwwroot/index.html` exceeds **150 lines**.
- Any `wwwroot/**/*.js` or `wwwroot/**/*.css` file exceeds **300 lines**.
- This forces the AI agent to split new features into clean, isolated Web Components rather than dumping code into existing files.

### Pillar 4: Open-Code Primitives (`shadcn/ui` Philosophy for Native Web)
Instead of black-box npm UI frameworks where AI agents hallucinate non-existent props, all primitives (`app-header.js`, `app-dialog.js`, `slice-component.js.template`, `top-layer.js`) live transparently inside the repository as <100-line vanilla Custom Elements that the LLM can inspect and compose deterministically.

### Pillar 5: Studio-Grade Dark Craft & 4-State Completeness
`tokens-template.css` and `styles-template.css` bake in Linear/Raycast-grade dark craft by default:
- **Semantic Intent Tokens (`oklch`)**: Deep canvas (`--color-bg-root`) $\rightarrow$ Elevated card (`--color-bg-surface`) $\rightarrow$ Interactive hover (`--color-bg-elevated`) $\rightarrow$ Translucent glass (`--color-bg-glass`).
- **Specular Hairline Borders**: Subtle `1px` borders (`oklch(0.98 0.01 265 / 0.09)`) with inset top-edge specular highlights (`--shadow-card`).
- **Zero-Jank Accordions & Tabular Numerals**: `.collapsible` uses `grid-template-rows: 0fr -> 1fr` (banning `max-height` hacks), and badges/counters use `font-variant-numeric: tabular-nums`.
- **Mandatory 4-State Rendering**: Every `<slice-*>` component must handle **Loading**, **Empty** (`.empty-state`), **Populated**, and **Error/Offline** states.

### Pillar 6: Mathematical Bounding-Box Verification (`ui-health-probe.js`)
Every scaffolded project includes `/js/ui-health-probe.js` (`window.UiHealthProbe.runAudit()`), which inspects `getBoundingClientRect()` across the live DOM to detect:
1. **Horizontal Viewport Overflow** (`scrollWidth > clientWidth`).
2. **Interactive Element Collisions** (two visible buttons/inputs overlapping in 2D space).
3. **Undersized Touch Targets** (`< 40-44px` interactive controls).
4. **Top-Layer Exclusivity Violations** (simultaneous open `<dialog>` modals).
