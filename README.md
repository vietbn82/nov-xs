# Nov-XS: AI-Native Vibe Coding Scaffold (XS / Small Projects)

> **Zero Project Bias · Unbreakable Slice-Isolated UI · Vertical Slice .NET 10 · State-of-the-Art AI (`Microsoft.Extensions.AI`)**

`Nov-XS` is a clean, clone-and-go engineering ruleset, executable scaffolding engine, and spec-driven toolkit for building small-to-medium fullstack applications with AI coding agents (Antigravity, Gemini CLI, Claude Code, Cursor, Copilot).

---

## 🛡️ How Nov-XS Permanently Prevents UI Breakage & Regression

See [docs/UI_ANTI_BREAKAGE_SYSTEM.md](docs/UI_ANTI_BREAKAGE_SYSTEM.md) for full details:
1. **Zero Shared DOM/JS State (`<slice-*>` Web Components)**: `index.html` is a thin `<30 line` App Shell. Every vertical slice generates its own isolated `wwwroot/components/slice-<name>.js` using scoped `this.querySelector()`. Fixing Slice B can **never** break Slice A.
2. **Hard Anti-Monolith Ceilings (Enforced by `audit-dod.ps1`)**: Build fails automatically if `index.html > 150 lines` or any `.js`/`.css` file exceeds `300 lines`.
3. **Studio-Grade Dark Craft Out of the Box**: Pre-configured 4-tier `oklch()` surface hierarchy, `1px` specular borders, radial ambient glow, `@container` responsive cards, `.empty-state`, and zero-jank CSS Grid `0fr/1fr` accordions.
4. **Live Bounding-Box Collision Probe (`ui-health-probe.js`)**: `window.UiHealthProbe.runAudit()` mathematically verifies zero overlapping buttons/inputs, zero horizontal overflow, and valid touch targets across viewports.

---

## 🚀 1-Prompt Quickstart (Starting a New Personal Project)

1. Copy or clone `Nov-XS` into your new project directory.
2. Open your AI coding assistant and prompt:
   > **"Initialize a new project called `<ProjectName>` for `<1-sentence idea>`. The primary outcome is `<goal>` and the first MVP slice is `<SliceName>`."**
3. The agent automatically invokes [`vibe-init`](.agents/skills/vibe-init/SKILL.md) ([`scaffold-project.ps1`](.agents/skills/vibe-init/scripts/scaffold-project.ps1)) to:
   - Lock your project's Anti-Drift rules in [`.specify/memory/constitution.md`](.specify/memory/constitution.md).
   - Scaffold `<ProjectName>.slnx`, a .NET 10 Minimal API Vertical Slice backend, `SqliteDatabase` (SQLite `WAL` Hybrid Document/Relational Store), `DeterministicFallbackChatClient`, and an isolated `<slice-*>` Web Component frontend.
   - Generate `specs/001-<first-slice>/` (`spec.md`, `plan.md`, `tasks.md`) and run [`audit-dod.ps1`](.agents/skills/ui-dod-audit/scripts/audit-dod.ps1) (`dotnet test` + anti-monolith/isolation/token audit) to verify a 100% green baseline in seconds.

---

## ⚡ One-Command Automation Scripts

| Task | Command |
| :--- | :--- |
| **Bootstrap Full Project** | `pwsh -NoProfile -File .agents/skills/vibe-init/scripts/scaffold-project.ps1 -ProjectName "PulseApp" -FirstSlice "Tasks" -Mission "Zero-friction task flow"` |
| **Scaffold New Vertical Slice** | `pwsh -NoProfile -File .agents/skills/lean-slice/scripts/new-slice.ps1 -SliceName "Bookmarks" -Description "Save and tag links"` |
| **Run 4-Point DoD & UI Audit** | `pwsh -NoProfile -File .agents/skills/ui-dod-audit/scripts/audit-dod.ps1` |

---

## 🗂️ Scaffold Architecture Map

```text
Nov-xs/
├── AGENTS.md                              # Always-on AI agent rules (<4.6KB token budget)
├── .editorconfig                          # Standardized C# 13+ & Web formatting rules
├── .gitignore                             # Clean .NET 10, SQLite WAL & temp-file ignores
├── .agents/                               # Native Antigravity Customizations
│   ├── hooks.json                         # Protocol-compliant SessionStart & PostToolUse hooks
│   └── skills/
│       ├── vibe-init/                     # 1-command project bootstrapper (SKILL.md + scaffold-project.ps1)
│       ├── lean-slice/                    # Spec-to-TDD vertical slice builder (SKILL.md + new-slice.ps1)
│       ├── ai-slice/                      # Microsoft.Extensions.AI & SIMD vector search workflow
│       └── ui-dod-audit/                  # Anti-monolith, Isolation & DoD auditor (SKILL.md + audit-dod.ps1)
├── .specify/                              # Lean SpecKit Engine & Reference Templates
│   ├── memory/constitution.md             # Zero-bias Project Constitution & Anti-Drift Guardrail
│   ├── scripts/powershell/                # De-bloated SpecKit & Hook PowerShell scripts
│   └── templates/
│       ├── csharp/                        # SqliteDatabase (WAL Hybrid Store), ResilientAiPipeline
│       ├── web/                           # top-layer.js, ui-health-probe.js, slice-component.js.template, etc.
│       ├── tokens-template.css            # Studio-grade OKLCH + fluid clamp() design tokens
│       └── *.md                           # Lean Spec, Plan, Tasks, Checklist & Constitution templates
└── docs/                                  # Reference Engineering Blueprints
    ├── UI_ANTI_BREAKAGE_SYSTEM.md         # 5 Iron Laws of Unbreakable & High-Craft UI
    ├── LEAN_SPECKIT.md                    # Design Tokens, Web Components & Top-Layer rules
    ├── STANDARDIZED_BLUEPRINT.md          # .NET 10 Minimal APIs & SQLite WAL Hybrid Store
    └── AI_ENGINEERING_BLUEPRINT.md        # Microsoft.Extensions.AI, Structured Output, SSE & Vector SIMD
```
