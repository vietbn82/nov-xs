# Project Constitution (Nov-XS Vibe Coding Scaffold)

> **Purpose**: Supreme architectural and product governance for small-to-medium (XS/S) local-first, fullstack, and AI-powered applications. When starting a new project from this template, fill in Section 1 (`Product Mission & Anti-Drift Guardrail`) or run the `vibe-init` skill.

---

## 1. Product Mission & Anti-Drift Guardrail

- **Project Name**: `[PROJECT_NAME]`
- **Target User & Core Problem**: `[TARGET_USER_AND_PROBLEM]`
- **Primary Outcome (The One Thing)**: `[CORE_OUTCOME_METRIC]`
- **Anti-Drift Rule**: Every feature, endpoint, AI prompt, or UI component MUST directly serve the Primary Outcome above. Speculative abstractions, unrequested settings pages, and scope creep outside `[EXPLICIT_NON_GOALS]` are strictly prohibited (YAGNI).

---

## 2. The 5 Invariable Engineering Principles

### Principle I: Vertical Slice Simplicity (Zero Over-Engineering)
- Organize backend code by **feature slice** (`Features/<SliceName>/`) rather than horizontal technical layers (`Controllers/`, `Repositories/`, `Mappers/`).
- Prefer C# 13+ / .NET 10 Minimal APIs, file-scoped namespaces, primary constructors, `record` DTOs, `TypedResults`, and `System.Text.Json` source generation where appropriate.
- Never introduce an interface or abstraction layer unless there are $\ge 2$ concrete implementations or an external I/O boundary (LLM, filesystem, network, clock) that requires test isolation.

### Principle II: Token-First & Zero-Build Native UI
- **Single Source of Truth**: Every color (`oklch()`), font size (`clamp()`), spacing interval, and z-index tier MUST come from `wwwroot/css/tokens.css` (`@layer tokens`). Arbitrary one-off inline values are forbidden.
- **Rule of Two (DRY Encapsulation)**: Any UI construct appearing in $\ge 2$ views or repeated structurally MUST be encapsulated as a zero-dependency **HTML5 Native Web Component** (`customElements.define`) using standard ES Modules.
- **Native Top-Layer Exclusivity**: Use native `<dialog>` for modals and the HTML **Popover API** (`popover="auto"`) for dropdowns, tooltips, and floating panels. Every overlay feature must define its **Mutual Exclusivity Matrix**.

### Principle III: State-of-the-Art AI Engineering (`Microsoft.Extensions.AI`)
- All AI integrations MUST route through unified abstractions (`IChatClient`, `IEmbeddingGenerator`) with DI pipeline middleware (logging, telemetry, caching, rate limiting).
- Use strongly-typed **Structured Outputs** (`GetResponseAsync<T>`) for deterministic data extraction and `TypedResults.ServerSentEvents` (`text/event-stream`) for real-time generative UI streaming.
- **Graceful Degradation**: Every AI feature must define a deterministic fallback (local model via Ollama/ONNX or rule-based heuristic) so the application remains 100% testable and resilient offline or during provider outages.

### Principle IV: Zero-Ops SQLite WAL Hybrid Persistence
- **Single Local-First Engine**: Use embedded **SQLite in `WAL` mode** (`PRAGMA journal_mode = WAL; PRAGMA synchronous = NORMAL; PRAGMA busy_timeout = 5000; PRAGMA foreign_keys = ON;`) via `ISqliteConnectionFactory`.
- **Zero-Migration Slice Store**: Default vertical slices to `ISliceStore<T>` (`SqliteSliceStore<T>`) storing JSON documents in `slice_items(slice, id, payload_json, updated_at_utc)` to eliminate EF Core migration breakage during rapid AI iteration, dropping down to relational tables or `FTS5` via `ISqliteConnectionFactory` only when relational joins or full-text search are needed.

### Principle V: TDD & Definition of Done (DoD) Gate
- Every vertical slice requires automated unit/integration tests (`xUnit` + `FluentAssertions` + `WebApplicationFactory<Program>`) verifying happy paths and validation boundaries.
- No feature is complete until it passes the **4-Point DoD Gate**:
  1. `dotnet test` passes with 0 errors and 0 warnings.
  2. Responsive layout holds across `375px` (Mobile) and `1440px` (Desktop) with zero horizontal scroll (`overflow-x`).
  3. WCAG 2.2 AA contrast ($\ge 4.5:1$), keyboard navigation (`Escape` dismissal, focus return), and $\ge 44 \times 44\text{px}$ touch targets.
  4. Zero uncaught exceptions or failed network requests in the browser DevTools console.

---

## 3. Governance & Amendment

- This Constitution supersedes ad-hoc prompts. Any plan or code change that violates these principles must either be refactored or explicitly justified in the feature's `plan.md` Complexity Tracking table.

**Version**: 2.0.0 | **Template**: Nov-XS Vibe Coding Scaffold | **Status**: Active
