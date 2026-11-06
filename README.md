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

## 🚀 How to Use (Zero Friction)

### Option A: Pure AI Chat (0 Commands to Remember)
Just open your AI assistant in this folder and type what you want in plain English:
> **"Build me a habit tracker app"**

The AI automatically infers the project name, scaffolds the `.NET 10` + SQLite `WAL` backend and `<slice-*>` UI, writes the tests, and verifies everything passes.

### Option B: 1-Word Terminal CLI (`./vibe.ps1`)
If you prefer running commands yourself, use [`vibe.ps1`](vibe.ps1):

| What you want | Command |
| :--- | :--- |
| **Start app in this folder** | `./vibe.ps1 new MyApp` |
| **Start app in a new `../MyApp` folder + fresh Git** | `./vibe.ps1 new MyApp -Out` |
| **Add a new feature slice** | `./vibe.ps1 slice Bookmarks` |
| **Run the web app** | `./vibe.ps1 run` |
| **Run tests + UI health check** | `./vibe.ps1 check` |

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
