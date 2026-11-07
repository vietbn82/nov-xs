# Technical & Process Blueprint for Small & Medium Projects

> **Philosophy:** *Zero Bloat – Maximum Velocity – Single Source of Truth – Unbreakable UI.*  
> Comprehensive technical standardization covering Tech Stack, Architecture, Tooling, MCP Plugins, and Spec-Driven Engineering for small-to-medium systems (Micro-SaaS, Developer Tools, Internal Portals, Local-First AI applications).

---

## I. Architecture & Technology Stack

```text
┌────────────────────────────────────────────────────────┐
│      Frontend: Native Web Components + Design Tokens   │
└───────────────────────────┬────────────────────────────┘
                            │ JSON / SSE / WebSockets
┌───────────────────────────▼────────────────────────────┐
│      Backend: ASP.NET Core Minimal APIs (.NET 10)      │
│      (Vertical Slice Architecture + M.E.AI)            │
└───────────────────────────┬────────────────────────────┘
                            │ Atomic File I/O / SQLite WAL
┌───────────────────────────▼────────────────────────────┐
│      Persistence: Thread-Safe JSON Store / SQLite      │
└────────────────────────────────────────────────────────┘
```

### 1. Backend: Modern .NET (C# 13+ on .NET 10 LTS)

* **Runtime:** .NET 10 LTS (Ahead-Of-Time / Native AOT friendly).
* **Architectural Style:** Minimal APIs paired with **Vertical Slice Architecture**:
  - **File-scoped namespaces:** Clean, uncluttered files (`namespace MyApp.Features.Workspace;`).
  - **Primary Constructors:** Streamlined dependency injection (`public sealed class WorkspaceService(IOptions<AppConfig> config, ILogger<WorkspaceService> logger)`).
  - **Typed Results (`TypedResults`):** Compile-time verified endpoint return types (e.g., `Results<Ok<ItemDto>, NotFound, ValidationProblem>`), providing native OpenAPI v3.1 metadata generation.
  - **Real-Time SSE Streaming:** Native `TypedResults.ServerSentEvents(...)` for zero-friction AI token and progress streaming.
  - **High-Performance Primitives:** Leverage `ReadOnlySpan<char>`, `SearchValues<char>`, `ValueTask<T>`, and `System.Threading.Lock` (.NET 9+) for low-allocation hot paths.
  - **Zero-Reflection Serialization:** Use `System.Text.Json` Source Generators (`[JsonSerializable]`) for instant startup, reduced memory footprint, and Native AOT compatibility.
  - **Modern API Documentation:** Use Microsoft's native `Microsoft.AspNetCore.OpenApi` paired with **Scalar** (`Scalar.AspNetCore`) for fast, interactive OpenAPI v3.1 exploration.

* **Zero-Ops Persistence (SQLite WAL Hybrid Store):**
  - **Why Not EF Core Migrations for Vibe Coding?** AI coding agents frequently break EF Core migration snapshots during rapid domain iteration. Conversely, flat JSON files lack ACID transactions, concurrent read/write safety, and SQL indexing.
  - **The Optimal Architecture (`SqliteDatabase.cs.template`):** Embedded **SQLite (`Microsoft.Data.Sqlite`) in `WAL` mode** combining a zero-migration JSON document store (`SqliteSliceStore<T>`) with full relational SQL access (`ISqliteConnectionFactory`):
    ```sql
    PRAGMA journal_mode = WAL;
    PRAGMA synchronous = NORMAL;
    PRAGMA busy_timeout = 5000;
    PRAGMA foreign_keys = ON;
    ```
  - **Zero-Migration Vertical Slices (`ISliceStore<T>`):** Each slice immediately gets ACID CRUD over `slice_items (slice, id, payload_json, updated_at_utc)`. Adding or renaming properties on a C# `record` requires **zero schema migrations**.
  - **Relational & FTS5 Escape Hatch:** When a slice requires complex joins, `json_extract()` virtual indexes, or `FTS5` full-text search, inject `ISqliteConnectionFactory` directly without changing database engines.

---

### 2. Frontend: Ultra-Lean & Unbreakable Web Standards

* **Component Model:** **HTML5 Native Web Components** (`customElements.define`) + Standard ES Modules.
  - *Why?* Zero build pipeline dependency (`node_modules`), zero supply-chain vulnerability noise, sub-millisecond cold starts, native browser lifecycle management, and portable UI elements (`<app-header>`, `<app-dialog>`, `<app-drawer>`).
* **Overlay & Top-Layer Architecture:**
  - **Native `<dialog>` Element:** For modals and alert sheets. Automatically placed in the browser's top layer with built-in backdrop management (`::backdrop`), focus containment, and native `Escape` key dismissal.
  - **HTML Popover API:** Use `popover="auto"` or `popover="manual"` for dropdowns, tooltips, and floating docks, eliminating complex custom z-index hierarchies and manual click-outside listeners.
* **CSS & Design System:**
  - **Single Source of Truth:** Centralize tokens in `tokens.css` within `@layer tokens` using `oklch()` color spaces and fluid typography via `clamp()`.
  - **Container Queries (`@container`):** Build responsive components that adapt to parent container widths rather than rigid screen viewports.
  - **Zero-Node CSS Compilation:** Utilize pure modern CSS (`@layer`, CSS nesting, custom properties) or the **Tailwind Standalone CLI** (single self-contained executable) without Node.js dependencies.
* **State Management & Reactivity:**
  - Standard Event-Driven architecture (`window.dispatchEvent(new CustomEvent('app:state-changed', { detail }))`).

---

## II. Standardized Tooling & Ecosystem

| Layer | Standardized Technology | Selection Rationale |
| :--- | :--- | :--- |
| **Backend Framework** | ASP.NET Core Minimal APIs (.NET 10) | Sub-0.2s cold start, `<30MB` RAM baseline, idiomatic C# syntax. |
| **AI Abstraction** | `Microsoft.Extensions.AI` (`IChatClient`) | Unified provider-agnostic LLM/embedding pipeline with structured outputs & tool calling. |
| **OpenAPI & Docs** | `Microsoft.AspNetCore.OpenApi` + `Scalar` | Replaces deprecated Swashbuckle; native OpenAPI v3.1, AOT-compliant. |
| **Validation** | Record validation / `FluentValidation` | Clean separation of validation rules from endpoint logic. |
| **Testing Engine** | `xUnit` + `FluentAssertions` | Expressive `result.Should().Be(...)` assertions + `WebApplicationFactory<Program>`. |
| **Mocking / Fakes** | `NSubstitute` or In-Memory Fakes | Concise, fast test doubles without reflection/telemetry overhead. |
| **CSS Architecture** | Native CSS `@layer` + `tokens.css` (`oklch`) | Zero npm/node dependencies required; instant browser reload. |
| **Code Formatting** | `.editorconfig` + `dotnet format` | Enforces uniform formatting, file-scoped namespaces, and clean usings. |
| **Browser Verification** | Chrome DevTools MCP / Playwright | Automated inspection for layout overflow, a11y contrast, and console cleanliness. |

---

## III. Antigravity & AI Agent Integration

When collaborating with AI Coding Assistants:

1. **Workspace Customization (`AGENTS.md` & `.agents/`):**
   - Root `AGENTS.md` provides always-on architectural guardrails within the token budget.
   - `.agents/skills/` provides progressive-disclosure workflows (`vibe-init`, `lean-slice`, `ui-dod-audit`) loaded only when relevant.
2. **Chrome DevTools MCP Plugin:**
   - Automate layout inspection, capture screenshots across `375px` and `1440px` viewports, verify WCAG 2.2 AA contrast, and monitor browser console output for unhandled exceptions during UI validation.
3. **Subagent Delegation:**
   - Offload independent vertical slices or deep research spikes to focused subagents to maintain a clean, high-signal parent context.

---

## IV. The 4-Stage Spec-Driven Workflow

```text
[ STAGE 1: SPEC-FIRST ] ➔ [ STAGE 2: TOKENS & COMPONENTS ] ➔ [ STAGE 3: TDD CODE ] ➔ [ STAGE 4: DoD GATE ]
```

### Stage 1: Spec-First (Lean RFC)
Before writing implementation code, author a single-page `specs/###-feature/spec.md` including:
1. **API & AI Contracts:** Route, Request DTO, Response DTO (`TypedResults` / SSE), fallback behavior.
2. **Layout Topology:** Anchoring, geometry (desktop vs mobile), layer priority.
3. **Mutual Exclusivity Matrix:** Explicitly declare state interactions (e.g., opening Modal A automatically closes Popover B).

### Stage 2: Lock Tokens & Component Shells
- Register all required colors, font sizes, and layout bounds in `tokens.css`.
- Encapsulate reusable UI fragments into `wwwroot/components/` as Custom Elements.

### Stage 3: TDD Implementation
- Write unit/integration tests for the vertical slice first using `xUnit` and `FluentAssertions`.
- Implement the Service and Minimal API Endpoint and verify test green state.
- Wire Frontend Custom Elements to endpoints via native `fetch()` or `EventSource`.

### Stage 4: Definition of Done (DoD) Gate
A task is only marked complete when it passes all criteria:
- [x] **Backend:** 100% test pass rate (`dotnet test`).
- [x] **Responsive Layout:** Zero horizontal overflow on `375px` mobile and `1440px` desktop viewports.
- [x] **Typography Hygiene:** All text and colors use `tokens.css` variables.
- [x] **Browser Console:** Zero uncaught exceptions or failed network requests in browser console.

---

## V. Reference Repository Template Structure

The standard, battle-tested layout for small-to-medium fullstack .NET applications initialized from this scaffold:

```text
my-project/
├── AGENTS.md                     # Always-on AI agent architectural rules
├── .editorconfig                 # Standardized C# & web formatting rules
├── .agents/                      # Progressive-disclosure AI skills & hooks
│   ├── hooks.json
│   └── skills/
├── .specify/                     # Lean SpecKit templates, scripts & constitution
├── docs/                         # Engineering & AI blueprints
├── MyProject.slnx                # Modern XML-based solution format
├── src/
│   └── MyProject/
│       ├── Program.cs            # Minimal API Bootstrap (routes, OpenAPI, DI)
│       ├── Features/             # Vertical Slices (Models + Service + Endpoints)
│       │   └── [SliceName]/
│       ├── Infrastructure/       # SqliteDatabase.cs & ResilientAiPipeline.cs
│       ├── Data/                 # Local SQLite WAL database (app.db)
│       └── wwwroot/              # Static frontend (Zero build pipeline)
│           ├── index.html        # Thin App Shell (<= 150 lines)
│           ├── css/
│           │   ├── tokens.css    # Single Source of Truth for Design Tokens
│           │   └── styles.css    # Every Layout primitives & component styles
│           ├── components/       # Isolated <slice-*> & <app-*> Web Components
│           └── js/
│               ├── top-layer.js        # Modal/Popover exclusivity coordinator
│               └── ui-health-probe.js  # Live bounding-box & overflow auditor
└── tests/
    └── MyProject.Tests/          # xUnit + FluentAssertions test suite
```
