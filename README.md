# Nov-XS: AI-Native Vibe Coding Scaffold (XS / Small Projects)

> **Zero Project Bias · Zero Frontend Build Bloat · Vertical Slice .NET 10 · State-of-the-Art AI (`Microsoft.Extensions.AI`)**

`Nov-XS` is a clean, clone-and-go engineering ruleset, executable scaffolding engine, and spec-driven toolkit for building small-to-medium fullstack applications with AI coding agents (Antigravity, Gemini CLI, Claude Code, Cursor, Copilot).

---

## 🚀 1-Prompt Quickstart (Starting a New Personal Project)

1. Copy or clone `Nov-XS` into your new project directory.
2. Open your AI coding assistant and prompt:
   > **"Initialize a new project called `<ProjectName>` for `<1-sentence idea>`. The primary outcome is `<goal>` and the first MVP slice is `<SliceName>`."**
3. The agent automatically invokes [`vibe-init`](.agents/skills/vibe-init/SKILL.md) ([`scaffold-project.ps1`](.agents/skills/vibe-init/scripts/scaffold-project.ps1)) to:
   - Lock your project's Anti-Drift rules in [`.specify/memory/constitution.md`](.specify/memory/constitution.md).
   - Scaffold `<ProjectName>.slnx`, a .NET 10 Minimal API Vertical Slice backend, `AtomicJsonStore`, `DeterministicFallbackChatClient`, and a zero-build Native Web Component frontend with locked `oklch()` design tokens.
   - Generate `specs/001-<first-slice>/` (`spec.md`, `plan.md`, `tasks.md`) and run [`audit-dod.ps1`](.agents/skills/ui-dod-audit/scripts/audit-dod.ps1) (`dotnet test` + static token/security audit) to verify a 100% green baseline in seconds.

---

## ⚡ One-Command Automation Scripts

| Task | Command |
| :--- | :--- |
| **Bootstrap Full Project** | `pwsh -NoProfile -File .agents/skills/vibe-init/scripts/scaffold-project.ps1 -ProjectName "PulseApp" -FirstSlice "Tasks" -Mission "Zero-friction task flow"` |
| **Scaffold New Vertical Slice** | `pwsh -NoProfile -File .agents/skills/lean-slice/scripts/new-slice.ps1 -SliceName "Bookmarks" -Description "Save and tag links"` |
| **Run 4-Point DoD & Token Audit** | `pwsh -NoProfile -File .agents/skills/ui-dod-audit/scripts/audit-dod.ps1` |

---

## 🔄 The 4-Stage Lean SpecKit Loop

Every feature slice follows a deterministic 4-stage loop via [`lean-slice`](.agents/skills/lean-slice/SKILL.md) and [`ai-slice`](.agents/skills/ai-slice/SKILL.md):

```text
[ 1. Lean Spec ] ➔ [ 2. Tokens & Web Components ] ➔ [ 3. Vertical Slice TDD ] ➔ [ 4. 4-Point DoD Gate ]
```

1. **Stage 1 — Spec & Contract (`specs/###-feature/spec.md`)**: Single-page contract locking P1 MVP scenarios, API/AI DTOs, UI Layout Topology, and the Top-Layer Mutual Exclusivity Matrix.
2. **Stage 2 — Tokens & Native Web Components (`wwwroot/`)**: Semantic `oklch()` colors and fluid `clamp()` typography in `tokens.css`; reusable UI encapsulated via `customElements.define` (`<dialog>` & `popover="auto"` coordinated by `window.TopLayer`).
3. **Stage 3 — Red-Green-Refactor TDD (`Features/<Slice>/`)**: Write failing `xUnit` + `FluentAssertions` tests first, then implement the Service (`IChatClient` + deterministic fallback) and Minimal API `TypedResults` / SSE endpoint.
4. **Stage 4 — 4-Point DoD Gate ([`ui-dod-audit`](.agents/skills/ui-dod-audit/SKILL.md))**:
   - `dotnet test` passes with `0` errors and `0` warnings.
   - Zero horizontal overflow (`overflow-x`) at `375px` (Mobile) and `1440px` (Desktop).
   - WCAG 2.2 AA contrast ($\ge 4.5:1$), $\ge 44 \times 44\text{px}$ touch targets, and `Escape` key overlay dismissal.
   - Zero uncaught errors or failed network requests in the browser DevTools console.

---

## 🗂️ Scaffold Architecture Map

```text
Nov-xs/
├── AGENTS.md                              # Always-on AI agent rules (<4KB token budget)
├── .editorconfig                          # Standardized C# 13+ & Web formatting rules
├── .gitignore                             # Clean .NET 10, SQLite WAL & temp-file ignores
├── .agents/                               # Native Antigravity Customizations
│   ├── hooks.json                         # Protocol-compliant SessionStart & PostToolUse hooks
│   └── skills/
│       ├── vibe-init/                     # 1-command project bootstrapper (SKILL.md + scaffold-project.ps1)
│       ├── lean-slice/                    # Spec-to-TDD vertical slice builder (SKILL.md + new-slice.ps1)
│       ├── ai-slice/                      # Microsoft.Extensions.AI & SIMD vector search workflow
│       └── ui-dod-audit/                  # Token, Top-Layer & DoD auditor (SKILL.md + audit-dod.ps1)
├── .specify/                              # Lean SpecKit Engine & Reference Templates
│   ├── memory/constitution.md             # Zero-bias Project Constitution & Anti-Drift Guardrail
│   ├── scripts/powershell/                # De-bloated SpecKit & Hook PowerShell scripts
│   └── templates/
│       ├── csharp/                        # AtomicJsonStore, SqliteWalFactory, ResilientAiPipeline
│       ├── web/                           # top-layer.js, app-header.js, app-dialog.js, styles-template.css
│       ├── tokens-template.css            # WCAG 2.2 AA OKLCH + fluid clamp() design tokens
│       └── *.md                           # Lean Spec, Plan, Tasks, Checklist & Constitution templates
└── docs/                                  # Reference Engineering Blueprints
    ├── LEAN_SPECKIT.md                    # Design Tokens, Web Components & Top-Layer rules
    ├── STANDARDIZED_BLUEPRINT.md          # .NET 10 Minimal APIs, Atomic I/O & SQLite WAL
    └── AI_ENGINEERING_BLUEPRINT.md        # Microsoft.Extensions.AI, Structured Output, SSE & Vector SIMD
```
