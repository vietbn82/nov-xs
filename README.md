# Nov-XS: AI-Native Vibe Coding Scaffold (XS / Small Projects)

> **Zero Project Bias · Zero Frontend Build Bloat · Vertical Slice .NET 10 · State-of-the-Art AI (`Microsoft.Extensions.AI`)**

`Nov-XS` is a clean, clone-and-go engineering ruleset and spec-driven scaffold for building small-to-medium fullstack applications with AI coding agents (Antigravity, Gemini CLI, Claude Code, Cursor, Copilot).

---

## 🚀 1-Prompt Quickstart (Starting a New Personal Project)

1. Copy or clone `Nov-XS` into your new project directory.
2. Open your AI coding assistant and prompt:
   > **"Initialize a new project called `<ProjectName>` for `<1-sentence idea>`. The primary outcome is `<goal>` and the first MVP slice is `<feature>`."**
3. The agent automatically invokes the [`vibe-init`](.agents/skills/vibe-init/SKILL.md) skill to:
   - Lock your project's Anti-Drift rules in [`.specify/memory/constitution.md`](.specify/memory/constitution.md).
   - Scaffold `<ProjectName>.slnx`, a .NET 10 Minimal API Vertical Slice backend, atomic persistence, and a zero-build Native Web Component frontend with locked `oklch()` design tokens.
   - Generate `specs/001-<first-slice>/spec.md` and run `dotnet test` to verify a 100% green baseline.

---

## 🔄 The 4-Stage Lean SpecKit Loop

Every feature slice follows a fast, deterministic 4-stage loop via [`lean-slice`](.agents/skills/lean-slice/SKILL.md):

```text
[ 1. Lean Spec ] ➔ [ 2. Tokens & Web Components ] ➔ [ 3. Vertical Slice TDD ] ➔ [ 4. 4-Point DoD Gate ]
```

1. **Stage 1 — Spec & Contract (`specs/###-feature/spec.md`)**: Single-page contract locking P1 MVP scenarios, API/AI DTOs, UI Layout Topology, and the Top-Layer Mutual Exclusivity Matrix.
2. **Stage 2 — Tokens & Native Web Components (`wwwroot/`)**: Semantic `oklch()` colors and fluid `clamp()` typography in `tokens.css`; reusable UI encapsulated via `customElements.define` (`<dialog>` & `popover="auto"`).
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
├── AGENTS.md                              # Always-on AI agent rules (under 4KB token budget)
├── .editorconfig                          # Standardized C# 13+ & Web formatting rules
├── .gitignore                             # Clean .NET 10, SQLite WAL & temp-file ignores
├── .agents/                               # Native Antigravity Customizations
│   ├── hooks.json                         # Optional lifecycle hooks (PostToolUse test runner)
│   └── skills/
│       ├── vibe-init/SKILL.md             # 60-second new project bootstrapper
│       ├── lean-slice/SKILL.md            # 4-stage Spec-to-TDD vertical slice builder
│       └── ui-dod-audit/SKILL.md          # Token, Top-Layer & Chrome DevTools DoD auditor
├── .specify/                              # Lean SpecKit Engine
│   ├── memory/constitution.md             # Zero-bias Project Constitution & Anti-Drift Guardrail
│   ├── scripts/powershell/                # Feature & template automation scripts
│   └── templates/                         # Lean Spec, Plan, Tasks, Checklist & Tokens templates
└── docs/                                  # Reference Engineering Blueprints
    ├── LEAN_SPECKIT.md                    # Design Tokens, Web Components & Top-Layer rules
    ├── STANDARDIZED_BLUEPRINT.md          # .NET 10 Minimal APIs, Atomic I/O & SQLite WAL
    └── AI_ENGINEERING_BLUEPRINT.md        # Microsoft.Extensions.AI, Structured Output & SSE
```
