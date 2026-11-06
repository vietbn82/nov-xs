# Lean SpecKit: Standardized Engineering Framework for Small & Medium Projects

> **Mission:** Completely eliminate UI breakage, code duplication, and fragile hotfixes in small-to-medium web projects (Fullstack .NET, Modern Static Frontends, Micro-apps) without the bureaucratic drag of enterprise-heavy processes.

```text
[ Phase 0: Design Tokens ] ➔ [ Phase 1: Shell & Components ] ➔ [ Phase 2: Feature Spec & Contract ] ➔ [ Phase 3: DoD Gate ]
```

---

## 1. The 4 Invariable Core Rules

1. **Token First, Class Later:** Prohibit arbitrary, one-off utility classes (e.g., `text-[11px]`, `px-3.5`, arbitrary hex codes) unless defined in the central Design Tokens. Every font size, spacing interval, border radius, and color tier must stem from design tokens.
2. **Rule of Two (DRY Component Encapsulation):** Whenever a UI construct (Header, Navigation, Modal, Card, Drawer) appears on **two or more pages/views**, it MUST be encapsulated as a reusable **Native Web Component** (`customElements.define`) or a template partial. Copy-pasting HTML blocks between files is strictly forbidden.
3. **Top-Layer & Mutual Exclusivity Architecture:** Floating and overlay elements (Modals, Popovers, Drawers, Floating Docks) must be governed by an explicit mutual exclusivity matrix. Leverage native browser capabilities:
   - Use native `<dialog>` for modal overlays (automatically promoted to the browser's top layer with built-in focus trapping and backdrop management).
   - Use the native HTML **Popover API** (`popover="auto"` or `popover="manual"`) to achieve automatic light-dismiss, zero z-index conflicts, and clean mutual exclusivity.
4. **Visual & Accessibility Acceptance Criteria (VAC):** Every feature must declare measurable visual criteria before implementation: computed typography scale, zero horizontal scrollbar (`overflow-x: hidden` / container constraint), touch targets $\ge 44 \times 44\text{px}$, and WCAG 2.2 AA contrast ($\ge 4.5:1$).

---

## 2. The 4-Stage Implementation Workflow

### Stage 0: Lock Design Tokens (`tokens.css`)

Before writing any page layout or component, establish a single `tokens.css` file as the **Single Source of Truth**. Organize it using CSS `@layer` and modern `oklch()` color gamuts:

```css
@layer tokens {
  :root {
    /* Fluid Typography Scale (Single Source of Truth via clamp) */
    --font-xs: clamp(0.75rem, 0.7rem + 0.25vw, 0.8125rem);   /* 12px - 13px */
    --font-sm: clamp(0.875rem, 0.825rem + 0.25vw, 0.9375rem); /* 14px - 15px */
    --font-base: clamp(1rem, 0.95rem + 0.25vw, 1.0625rem);    /* 16px - 17px */
    --font-lg: clamp(1.125rem, 1.05rem + 0.35vw, 1.25rem);    /* 18px - 20px */
    --font-xl: clamp(1.375rem, 1.25rem + 0.5vw, 1.625rem);    /* 22px - 26px */
    --font-2xl: clamp(1.75rem, 1.5rem + 1vw, 2.25rem);        /* 28px - 36px */

    /* Layout Bounds & Geometry */
    --header-height: 4.0rem;
    --drawer-width: 440px;
    --radius-sm: 0.375rem;
    --radius-md: 0.75rem;
    --radius-lg: 1.0rem;
    --max-content-width: 1280px;

    /* Perceptually Uniform Contrast Palette (OKLCH) */
    --color-bg-root: oklch(0.12 0.02 260);     /* Deep dark slate */
    --color-bg-surface: oklch(0.18 0.03 260);  /* Elevated card background */
    --color-bg-elevated: oklch(0.24 0.04 260); /* Hover / Dropdown background */
    --color-text-main: oklch(0.98 0.01 260);   /* Crisp high-contrast text */
    --color-text-muted: oklch(0.75 0.02 260);  /* Secondary descriptive text */
    --color-border: oklch(0.28 0.03 260);      /* Structural border */
    --color-primary: oklch(0.78 0.16 195);     /* Electric Cyan accent */
    --color-accent: oklch(0.72 0.19 145);      /* Success Green accent */
    --color-warning: oklch(0.80 0.16 80);      /* Amber warning accent */
    --color-danger: oklch(0.65 0.20 25);       /* Crimson danger accent */

    /* Z-Index Hierarchy (when not managed by Native Top-Layer) */
    --z-sticky: 30;
    --z-drawer: 40;
    --z-popover: 50;
  }
}
```

---

### Stage 1: Encapsulate Native Web Components (Zero Build Overhead)

For micro-apps and small-to-medium fullstack systems, do not pull in heavy build tooling (Vite, Webpack, `node_modules`) solely for component reuse. Leverage **HTML5 Native Web Components** (`customElements.define`) and standard ES Modules.

#### Standard Directory Layout:
```text
src/[ProjectName]/wwwroot/
├── components/
│   ├── app-header.js        // <app-header active="home"></app-header>
│   ├── app-ai-drawer.js     // <app-ai-drawer></app-ai-drawer>
│   ├── app-dialog.js        // <app-dialog></app-dialog>
│   └── app-popover.js       // <app-popover></app-popover>
├── css/
│   ├── tokens.css
│   └── styles.css
├── js/
│   └── app.js
└── index.html
```

#### Production-Grade Web Component Pattern (`components/app-header.js`):
```javascript
class AppHeader extends HTMLElement {
  connectedCallback() {
    if (this.hasAttribute('rendered')) return;
    this.setAttribute('rendered', 'true');

    const active = this.getAttribute('active') || 'home';
    const brand = this.getAttribute('brand') || 'MyApp';

    this.innerHTML = `
      <header class="app-header">
        <div class="app-header__inner">
          <a href="/" class="app-header__brand" aria-label="${brand} Home">
            <span>${brand}</span>
          </a>
          <nav class="app-header__nav" aria-label="Primary Navigation">
            <a href="/"
               class="app-header__link ${active === 'home' ? 'is-active' : ''}"
               ${active === 'home' ? 'aria-current="page"' : ''}>
              Workspace
            </a>
            <a href="/insights.html"
               class="app-header__link ${active === 'insights' ? 'is-active' : ''}"
               ${active === 'insights' ? 'aria-current="page"' : ''}>
              Insights
            </a>
          </nav>
        </div>
      </header>
    `;
  }
}

if (!customElements.get('app-header')) {
  customElements.define('app-header', AppHeader);
}
```

> **Benefit:** Modifying navigation links or branding requires editing exactly **one component file**. All consuming pages reflect the change immediately with zero compilation steps.

---

### Stage 2: Lean Feature Mini-Spec (Single-Page Contract)

Before writing feature code, author a brief, single-page specification file (`specs/###-feature/spec.md`) documenting API contracts, UI topologies, state mutual exclusivity, and visual contracts:

```markdown
# FEATURE: AI Copilot Drawer

## 1. Layout Topology & Occlusion Rules
- Anchoring: Fixed right edge (`position: fixed; right: 0; top: 0; bottom: 0;`).
- Geometry: Desktop width = `var(--drawer-width)` (440px); Mobile width = `100vw`.
- Content Shifting: On desktop screens (`>= 1024px`), opening the drawer shifts `<main>` leftward (`margin-right: var(--drawer-width); transition: margin-right 200ms ease;`) to preserve view visibility.
- Occlusion Priority: Managed via native Top-Layer. Fullscreen `<dialog>` modals sit above the drawer.

## 2. State & Mutual Exclusivity Matrix
| Trigger Event | Target Element | Action Taken |
| :--- | :--- | :--- |
| Open Detail Modal | Context Popover | Immediately hide Context Popover (`popover.hidePopover()`). |
| Open AI Drawer | Context Popover | Dismiss Context Popover to prevent overlay occlusion. |
| Press `Escape` | Active Top-Layer | Close topmost modal/popover and restore focus to invoking button. |

## 3. Visual & Accessibility Contracts
- Header Typography: `var(--font-lg)` (bold, line-height: 1.3).
- Conversational Body: `var(--font-sm)` (regular, line-height: 1.6).
- Color Contrast: Text `--color-text-main` against surface `--color-bg-surface` satisfies WCAG 2.2 AA (`>= 4.5:1`).
- Touch Targets: Interactive buttons maintain minimum `44x44px` hit area.
```

---

### Stage 3: Definition of Done (DoD Gate Checklist)

Before creating a commit or marking a feature slice complete, verify against the DoD checklist:

| Verification Domain | Acceptance Criteria |
| :--- | :--- |
| **Viewport Integrity** | Tested across representative viewports: Mobile (`375px`), Tablet (`768px`), Laptop (`1366px`), Desktop (`1920px`). Zero horizontal scrolling (`overflow-x`). |
| **Typography Consistency** | Sibling elements (e.g., cards, list items) strictly share uniform font tokens without random ad-hoc responsive classes. |
| **Occlusion Verification** | Opening drawers, sidebars, or floating docks does not block key action buttons or form controls. |
| **Browser Console Cleanliness** | Browser F12 Developer Console emits **zero** uncaught errors (`ReferenceError`, `Uncaught TypeError`, unhandled promises). |
| **Automated Testing Suite** | All unit and integration tests pass cleanly (`dotnet test` returns exit code `0`). |
