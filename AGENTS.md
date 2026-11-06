# AGENTS.md — Nov-XS Vibe Coding Rules

> Always-on workspace rules for AI coding agents. Zero project bias. Optimized for fast context loading and high-velocity spec-driven engineering.

## 1. Core Architecture & Stack Standards

- **Backend (.NET 10 / C# 13+)**:
  - Use **ASP.NET Core Minimal APIs** organized by **Vertical Slice** (`src/<Project>/Features/<SliceName>/`).
  - Each slice co-locates `<Slice>Models.cs` (`record` DTOs), `<Slice>Service.cs` (primary constructors, file-scoped namespaces), and `<Slice>Endpoints.cs` (`MapGroup` + `TypedResults`).
  - Use high-performance primitives (`ReadOnlySpan<char>`, `ValueTask<T>`, `System.Threading.Lock`) and `System.Text.Json` source generation where applicable.
  - Document APIs via `Microsoft.AspNetCore.OpenApi` + `Scalar.AspNetCore`.
- **Persistence (Zero-Ops Local-First)**:
  - **Micro (< 100K items)**: Thread-safe JSON store using `System.Threading.Lock` + **atomic temp-file swap** (`File.Move(tmpPath, targetPath, overwrite: true)`). See [`.specify/templates/csharp/AtomicJsonStore.cs.template`](.specify/templates/csharp/AtomicJsonStore.cs.template).
  - **Medium (< 10M items)**: SQLite in `WAL` mode (`PRAGMA journal_mode = WAL; PRAGMA synchronous = NORMAL; PRAGMA busy_timeout = 5000;`). See [`.specify/templates/csharp/SqliteWalFactory.cs.template`](.specify/templates/csharp/SqliteWalFactory.cs.template).
- **Frontend (Zero-Build Web Standards)**:
  - **Token First, Class Later**: All colors (`oklch()`), fluid font sizes (`clamp()`), radii, and layout bounds MUST live in `wwwroot/css/tokens.css` (`@layer tokens`). Never hardcode arbitrary hex colors or pixel font sizes.
  - **Rule of Two (DRY)**: Any UI structure appearing in $\ge 2$ views MUST be encapsulated as an **HTML5 Native Web Component** (`customElements.define`) in `wwwroot/components/`.
  - **Top-Layer Exclusivity**: Use native `<dialog>` for modals and `popover="auto"` for floating popovers/drawers coordinated via `window.TopLayer` ([`.specify/templates/web/top-layer.js`](.specify/templates/web/top-layer.js)).
- **AI Engineering (`Microsoft.Extensions.AI`)**:
  - Route all LLM/Embedding calls through `IChatClient` / `IEmbeddingGenerator` pipelines (never shell out to CLI processes for inference).
  - Use `GetResponseAsync<T>()` for structured JSON outputs, `TypedResults.ServerSentEvents(...)` for real-time streaming, and `TensorPrimitives.CosineSimilarity` for local vector search (< 50K items).
  - Always implement a **deterministic fallback** ([`.specify/templates/csharp/ResilientAiPipeline.cs.template`](.specify/templates/csharp/ResilientAiPipeline.cs.template)) so tests and offline dev work 100% reliably without external API keys.

## 2. The 4-Stage Lean SpecKit Workflow

1. **Stage 1 — Spec & Contract**: Scaffold via `.agents/skills/lean-slice/scripts/new-slice.ps1` and lock `specs/###-<feature>/spec.md`.
2. **Stage 2 — Tokens & Shells**: Update `tokens.css` and scaffold reusable Web Components in `wwwroot/components/`.
3. **Stage 3 — Red-Green-Refactor TDD**: Write failing `xUnit` + `FluentAssertions` tests first (`tests/<Project>.Tests/`), then implement the Vertical Slice and wire the frontend.
4. **Stage 4 — 4-Point Definition of Done (DoD) Gate**: Run `.agents/skills/ui-dod-audit/scripts/audit-dod.ps1` and verify `375px`/`1440px` viewports, WCAG 2.2 AA contrast ($\ge 4.5:1$), and zero console errors.

## 3. On-Demand Workspace Skills & References

- **Bootstrapping a new project**: [`.agents/skills/vibe-init/SKILL.md`](.agents/skills/vibe-init/SKILL.md)
- **Building a feature vertical slice**: [`.agents/skills/lean-slice/SKILL.md`](.agents/skills/lean-slice/SKILL.md)
- **Building an AI / LLM / Vector slice**: [`.agents/skills/ai-slice/SKILL.md`](.agents/skills/ai-slice/SKILL.md)
- **Auditing UI, tokens & DoD compliance**: [`.agents/skills/ui-dod-audit/SKILL.md`](.agents/skills/ui-dod-audit/SKILL.md)
- **Blueprints**: [Constitution](.specify/memory/constitution.md) · [Lean SpecKit](docs/LEAN_SPECKIT.md) · [Standardized Blueprint](docs/STANDARDIZED_BLUEPRINT.md) · [AI Engineering Blueprint](docs/AI_ENGINEERING_BLUEPRINT.md)
