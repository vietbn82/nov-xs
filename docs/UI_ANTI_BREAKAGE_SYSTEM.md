# Unbreakable & High-Craft UI System (5 Iron Laws of UI)

> **Why UI Breaks in AI Vibe Coding — And How Nov-XS Permanently Eliminates It:**  
> Industry research on AI coding agents shows that LLMs optimize for *local textual plausibility* over *global layout integrity*. Left unguided, agents invent magic pixel margins, un-wrapped flex rows, global CSS selectors that bleed across components, and monolithic HTML/JS files.  
> **Nov-XS enforces 5 Iron Laws (`<slice-*>` Component Isolation, Anti-Monolith Ceilings, Semantic `oklch()` Tokens, Intrinsic `Every Layout` Primitives, and Top-Layer + Live Bounding-Box Probes) to make UI regressions structurally impossible.**

---

## The 5 Iron Laws of AI-First Unbreakable UI

### Law 1: Strict Slice & Style Isolation (`<slice-*>` + CSS `@scope`)
- `index.html` is a **pure App Shell (`<= 150 lines`)** containing only `<app-header>`, `<main class="app-shell">`, `<app-drawer>`, `<app-cmd-palette>`, `<app-toast>`, and `<slice-*>` custom element tags.
- Every Vertical Slice (`Features/Tasks`) owns its own isolated Web Component (`wwwroot/components/slice-tasks.js`).
- **Scoped Queries Only**: Inside a `<slice-*>` Web Component, `document.getElementById()` and global `document.querySelector()` are **banned**. Always query against `this` (`this.querySelector(...)`).
- **CSS `@scope` Boundary**: Any slice-specific CSS must be wrapped in `@scope (slice-name) { ... }` so selectors can never bleed into sibling components.

### Law 2: Hard Anti-Monolith File Ceilings (Enforced by `audit-dod.ps1`)
[`audit-dod.ps1`](../.agents/skills/ui-dod-audit/scripts/audit-dod.ps1) automatically fails the build if:
- `wwwroot/index.html` exceeds **150 lines**.
- Any `wwwroot/**/*.js` or `wwwroot/**/*.css` file exceeds **300 lines**.
- This forces the AI agent to split new features into clean, isolated Web Components rather than dumping code into existing files.

### Law 3: Token First, Class Later (Studio-Grade Dark Craft)
[`tokens-template.css`](../.specify/templates/tokens-template.css) and [`styles-template.css`](../.specify/templates/web/styles-template.css) bake in Linear/Raycast-grade dark craft by default:
- **Semantic Intent Tokens (`oklch`)**: Deep canvas (`--color-bg-root`) $\rightarrow$ Elevated card (`--color-bg-surface`) $\rightarrow$ Interactive hover (`--color-bg-elevated`) $\rightarrow$ Translucent glass (`--color-bg-glass`).
- **Specular Hairline Borders**: Subtle `1px` borders (`oklch(0.98 0.01 265 / 0.09)`) with inset top-edge specular highlights (`--shadow-card`).
- **Open-Code Primitives**: All shared components (`app-header.js`, `app-dialog.js`, `app-drawer.js`, `app-cmd-palette.js`, `app-toast.js`, `slice-component.js.template`) live transparently inside the repository as `<110-line` vanilla Custom Elements.

### Law 4: Intrinsic Zero-Jank Layouts ("Every Layout" Primitives & 4-State Completeness)
AI agents are **forbidden** from writing fragile `@media` queries or hardcoded pixel margins when the 5 algorithmic primitives in `styles.css` can be composed:
- **`.l-stack`**: Vertical flow (`> * + * { margin-block-start: var(--stack-space, var(--space-4)); }`).
- **`.l-cluster`**: Intrinsic inline wrapping (`display: flex; flex-wrap: wrap; gap: var(--space-3)`).
- **`.l-split`**: Space-between header/action bar with automatic `flex-wrap: wrap`.
- **`.l-grid`**: Auto-responsive grid (`repeat(auto-fit, minmax(min(var(--grid-min, 320px), 100%), 1fr))`).
- **`.l-sidebar`**: Fluid sidebar + main content layout.
- **Zero-Jank Accordions & Wrapping**: `.collapsible` uses `grid-template-rows: 0fr -> 1fr` (banning `max-height` hacks), `.card` and `.item-row` enforce `min-width: 0; overflow-wrap: anywhere;`, and every `<slice-*>` renders **Loading**, **Empty**, **Populated**, and **Error** states.

### Law 5: Top-Layer Exclusivity & Mathematical Bounding-Box Verification (`ui-health-probe.js`)
Every scaffolded project includes [`top-layer.js`](../.specify/templates/web/top-layer.js) and [`ui-health-probe.js`](../.specify/templates/web/ui-health-probe.js) (`window.UiHealthProbe.runAudit()`), which inspects `getBoundingClientRect()` across the live DOM to detect:
1. **Horizontal Viewport Overflow & Off-Screen Clipping** (`scrollWidth > clientWidth` or `rect.right > winWidth`).
2. **Interactive Element Collisions** (two visible buttons/inputs overlapping in 2D space).
3. **Undersized Touch Targets** (`< 44px` interactive controls).
4. **Top-Layer Exclusivity Violations** (simultaneous open `<dialog>` modals).
