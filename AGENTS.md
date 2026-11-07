# AGENTS.md — Nov-XS Vibe Coding Rules

> Always-on workspace rules for AI coding agents. Zero project bias. Optimized for fast context loading, spec-driven engineering, and **100% unbreakable UI**.

## 1. Core Architecture & Stack Standards

- **Backend (.NET 10 / C# 13+)**:
  - Use **ASP.NET Core Minimal APIs** organized by **Vertical Slice** (`src/<Project>/Features/<SliceName>/`).
  - Co-locate `<Slice>Models.cs` (`record` DTOs), `<Slice>Service.cs` (primary constructors, file-scoped namespaces), and `<Slice>Endpoints.cs` (`MapGroup` + `TypedResults`).
  - Document APIs via `Microsoft.AspNetCore.OpenApi` + `Scalar.AspNetCore` (`/scalar/v1`).
- **Persistence (Zero-Ops SQLite WAL Hybrid Store)**:
  - **Unified Engine**: Embedded **SQLite in `WAL` mode** (`busy_timeout = 5000`, `synchronous = NORMAL`, `foreign_keys = ON`). See [`.specify/templates/csharp/SqliteDatabase.cs.template`](.specify/templates/csharp/SqliteDatabase.cs.template).
  - **Zero-Migration Slice Store (`ISliceStore<T>`)**: Vertical slices default to `SqliteSliceStore<T>` backed by `slice_items(slice, id, payload_json, updated_at_utc)` so C# `record` models evolve with **zero EF Core migration breakage**, retaining ACID transactions and raw SQL/`FTS5` via `ISqliteConnectionFactory`.
- **Frontend (5 Iron Laws of Unbreakable UI — [Full Spec](docs/UI_ANTI_BREAKAGE_SYSTEM.md))**:
  1. **Strict Slice Isolation**: `wwwroot/index.html` is a thin App Shell (`<= 150 lines`). Every feature slice lives in its own Native Web Component (`wwwroot/components/slice-<name>.js`) using scoped `this.querySelector()` (never `document.getElementById()`).
  2. **Anti-Monolith Ceiling**: No `.js` or `.css` file in `wwwroot/` may exceed `300 lines` (enforced by `audit-dod.ps1`).
  3. **Token First, Class Later**: All colors (`oklch()`), fluid font sizes (`clamp()`), shadows, and radii live in `wwwroot/css/tokens.css` (`@layer tokens`). Never hardcode hex colors or pixel font sizes.
  4. **Intrinsic Zero-Jank Layouts**: Compose `.l-stack`, `.l-cluster`, `.l-split`, `.l-grid`, `@container` queries, `tabular-nums`, and `.collapsible` (`grid-template-rows: 0fr/1fr`). Render all 4 states (Loading, Empty, Populated, Error).
  5. **Top-Layer Exclusivity & Geometry Probe**: Use `<dialog>` and `popover="auto"` via `window.TopLayer` ([`.specify/templates/web/top-layer.js`](.specify/templates/web/top-layer.js)) and verify zero overlaps/clipping via `window.UiHealthProbe.runAudit()` ([`.specify/templates/web/ui-health-probe.js`](.specify/templates/web/ui-health-probe.js)).
- **AI Engineering (`Microsoft.Extensions.AI`)**:
  - Route LLM/Embedding calls through `IChatClient` / `IEmbeddingGenerator` (`GetResponseAsync<T>()`, `TypedResults.ServerSentEvents(...)`, `TensorPrimitives.CosineSimilarity`).
  - Always wire a **deterministic fallback** ([`.specify/templates/csharp/ResilientAiPipeline.cs.template`](.specify/templates/csharp/ResilientAiPipeline.cs.template)) supporting both text and structured JSON outputs offline.

## 2. Zero-Friction Vibe Workflow (`./vibe.ps1`)

- **Zero-Interrogation Rule**: When the user asks to build an app or feature in plain English, **never** interrogate them for `ProjectName` or `FirstSlice`—auto-infer them and run [`./vibe.ps1`](vibe.ps1) immediately.
- **4-Stage Execution via [`./vibe.ps1`](vibe.ps1)**:
  1. **Bootstrap App**: `./vibe.ps1 new <AppName> [FirstSlice]` (or `-Out` to create `../<AppName>` with a fresh Git repo).
  2. **Add Feature Slice**: `./vibe.ps1 slice <SliceName>` (scaffolds `specs/###-<slice>/`, SQLite WAL slice, and `<slice-*>` Web Component).
  3. **TDD Implementation**: Customize `src/<App>/Features/<Slice>/`, `wwwroot/components/slice-<name>.js`, and `xUnit` tests.
  4. **Verify Gate**: `./vibe.ps1 check` (`dotnet test -warnaserror` + UI/token/isolation audit) and `./vibe.ps1 run`.

## 3. On-Demand Workspace Skills & References

- **Bootstrapping a project**: [`.agents/skills/vibe-init/SKILL.md`](.agents/skills/vibe-init/SKILL.md)
- **Building a vertical slice**: [`.agents/skills/lean-slice/SKILL.md`](.agents/skills/lean-slice/SKILL.md)
- **Building an AI / Vector slice**: [`.agents/skills/ai-slice/SKILL.md`](.agents/skills/ai-slice/SKILL.md)
- **Auditing UI & DoD compliance**: [`.agents/skills/ui-dod-audit/SKILL.md`](.agents/skills/ui-dod-audit/SKILL.md)
- **Blueprints**: [Constitution](.specify/memory/constitution.md) · [Unbreakable UI](docs/UI_ANTI_BREAKAGE_SYSTEM.md) · [Lean SpecKit](docs/LEAN_SPECKIT.md) · [Standardized Blueprint](docs/STANDARDIZED_BLUEPRINT.md) · [AI Blueprint](docs/AI_ENGINEERING_BLUEPRINT.md)
