# AGENTS.md — Nov-XS Vibe Coding Rules

> Always-on workspace rules for AI coding agents. Zero project bias. Optimized for fast context loading, high-velocity spec-driven engineering, and **100% unbreakable UI**.

## 1. Core Architecture & Stack Standards

- **Backend (.NET 10 / C# 13+)**:
  - Use **ASP.NET Core Minimal APIs** organized by **Vertical Slice** (`src/<Project>/Features/<SliceName>/`).
  - Each slice co-locates `<Slice>Models.cs` (`record` DTOs), `<Slice>Service.cs` (primary constructors, file-scoped namespaces), and `<Slice>Endpoints.cs` (`MapGroup` + `TypedResults`).
  - Use high-performance primitives (`ReadOnlySpan<char>`, `ValueTask<T>`, `System.Threading.Lock`) and `System.Text.Json` source generation where applicable.
  - Document APIs via `Scalar.AspNetCore`.
- **Persistence (Zero-Ops SQLite WAL Hybrid Store)**:
  - **Single Unified Engine**: Embedded **SQLite in `WAL` mode** (`PRAGMA journal_mode = WAL; PRAGMA synchronous = NORMAL; PRAGMA busy_timeout = 5000; PRAGMA foreign_keys = ON;`). See [`.specify/templates/csharp/SqliteDatabase.cs.template`](.specify/templates/csharp/SqliteDatabase.cs.template).
  - **Zero-Migration Slice Store (`ISliceStore<T>`)**: Vertical slices default to `SqliteSliceStore<T>` backed by `slice_items(slice, id, payload_json, updated_at_utc)` so AI agents can add/evolve C# `record` properties with **zero EF Core migration breakage**, while retaining ACID transactions, `json_extract()` indexing, and raw relational/FTS5 SQL via `ISqliteConnectionFactory`.
- **Frontend (5 Iron Laws of Unbreakable UI — [Full Spec](docs/UI_ANTI_BREAKAGE_SYSTEM.md))**:
  1. **Strict Slice Isolation**: `wwwroot/index.html` is a thin App Shell (`<= 150 lines`). Every feature slice MUST live in its own isolated Native Web Component (`wwwroot/components/slice-<name>.js`). Never use `document.getElementById()` inside a slice component—always use scoped `this.querySelector()`.
  2. **Anti-Monolith Ceiling**: No `.js` or `.css` file in `wwwroot/` may exceed `300 lines` (enforced by `audit-dod.ps1`).
  3. **Token First, Class Later**: All colors (`oklch()`), fluid font sizes (`clamp()`), shadows, and radii MUST live in `wwwroot/css/tokens.css` (`@layer tokens`). Never hardcode hex colors or pixel font sizes.
  4. **Intrinsic Zero-Jank Layouts**: Use `@container` queries, `tabular-nums`, and `.collapsible` (`grid-template-rows: 0fr/1fr`) instead of `max-height` transition hacks. Render all 4 states (Loading, Empty, Populated, Error).
  5. **Top-Layer Exclusivity & Geometry Probe**: Use `<dialog>` and `popover="auto"` via `window.TopLayer` ([`.specify/templates/web/top-layer.js`](.specify/templates/web/top-layer.js)) and verify zero overlapping controls via `window.UiHealthProbe.runAudit()` ([`.specify/templates/web/ui-health-probe.js`](.specify/templates/web/ui-health-probe.js)).
- **AI Engineering (`Microsoft.Extensions.AI`)**:
  - Route all LLM/Embedding calls through `IChatClient` / `IEmbeddingGenerator` pipelines (never shell out to CLI processes for inference).
  - Use `GetResponseAsync<T>()` for structured JSON outputs, `TypedResults.ServerSentEvents(...)` for real-time streaming, and `TensorPrimitives.CosineSimilarity` for local vector search (< 50K items).
  - Always implement a **deterministic fallback** ([`.specify/templates/csharp/ResilientAiPipeline.cs.template`](.specify/templates/csharp/ResilientAiPipeline.cs.template)) so tests and offline dev work 100% reliably without external API keys.

## 2. The 4-Stage Lean SpecKit Workflow

1. **Stage 1 — Spec & Contract**: Scaffold via `.agents/skills/lean-slice/scripts/new-slice.ps1` and lock `specs/###-<feature>/spec.md`.
2. **Stage 2 — Tokens & Isolated Web Component**: Update `tokens.css` and customize `wwwroot/components/slice-<name>.js`.
3. **Stage 3 — Red-Green-Refactor TDD**: Write failing `xUnit` + `FluentAssertions` tests first (`tests/<Project>.Tests/`), then implement the Vertical Slice.
4. **Stage 4 — 4-Point Definition of Done (DoD) Gate**: Run `.agents/skills/ui-dod-audit/scripts/audit-dod.ps1` and `window.UiHealthProbe.runAudit()` across `375px`/`1440px` viewports.

## 3. On-Demand Workspace Skills & References

- **Bootstrapping a new project**: [`.agents/skills/vibe-init/SKILL.md`](.agents/skills/vibe-init/SKILL.md)
- **Building a feature vertical slice**: [`.agents/skills/lean-slice/SKILL.md`](.agents/skills/lean-slice/SKILL.md)
- **Building an AI / LLM / Vector slice**: [`.agents/skills/ai-slice/SKILL.md`](.agents/skills/ai-slice/SKILL.md)
- **Auditing UI, tokens & DoD compliance**: [`.agents/skills/ui-dod-audit/SKILL.md`](.agents/skills/ui-dod-audit/SKILL.md)
- **Blueprints**: [Constitution](.specify/memory/constitution.md) · [Unbreakable UI System](docs/UI_ANTI_BREAKAGE_SYSTEM.md) · [Lean SpecKit](docs/LEAN_SPECKIT.md) · [Standardized Blueprint](docs/STANDARDIZED_BLUEPRINT.md) · [AI Engineering Blueprint](docs/AI_ENGINEERING_BLUEPRINT.md)
