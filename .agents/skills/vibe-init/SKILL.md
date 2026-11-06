---
name: vibe-init
description: >-
  Bootstraps a new small-to-medium (XS/S) fullstack .NET 10 and Native Web Component
  project from the Nov-XS Vibe Coding Scaffold. Use when the user asks to initialize,
  scaffold, or start a new project in this repository.
---

# Vibe-Init: 60-Second Project Bootstrapper

Use this skill to transform the zero-bias `Nov-XS` rules template into a working, tested .NET 10 Vertical Slice + Native Web Components application tailored to the user's idea.

## Step 1: Auto-Infer Inputs (Zero-Interrogation Vibe Rule)

Do **NOT** interrogate the user for parameters if they already gave you an idea (e.g., *"build me a habit tracker"*). Automatically infer:
1. **ProjectName** (PascalCase, e.g., `HabitTracker`)
2. **FirstSlice** (PascalCase plural noun, e.g., `Habits`)
3. **Mission** (1-sentence outcome inferred from their prompt)

Only ask if the user literally said *"init"* with zero context about what they are building.

## Step 2: Run the 1-Word Bootstrapper

```powershell
pwsh -NoProfile -File ./vibe.ps1 new "<ProjectName>" "<FirstSlice>"
```
*(Or add `-Out` to create a brand-new sibling directory `../<ProjectName>` with a fresh Git repo without touching `Nov-xs`.)*

This script automatically:
- Updates [`.specify/memory/constitution.md`](../../../.specify/memory/constitution.md) with the project name and mission.
- Creates `<ProjectName>.slnx`, `src/<ProjectName>/`, and `tests/<ProjectName>.Tests/`.
- Copies `SqliteDatabase.cs` (`ISqliteConnectionFactory` + `SqliteSliceStore<T>`) and `ResilientAiPipeline.cs` (`DeterministicFallbackChatClient`) from [`.specify/templates/csharp/`](../../../.specify/templates/csharp/).
- Copies `tokens.css`, `styles.css`, `top-layer.js`, `<app-header>`, and `<app-dialog>` from [`.specify/templates/web/`](../../../.specify/templates/web/).
- Invokes `new-slice.ps1` to generate `specs/001-<first-slice>/` (`spec.md`, `plan.md`, `tasks.md`) and the complete `<FirstSlice>` vertical slice + `xUnit` tests.

## Step 3: Customize Domain Logic & Verify DoD Gate

1. Tailor `specs/001-<first-slice>/spec.md` and `src/<ProjectName>/Features/<FirstSlice>/` to the user's specific domain fields.
2. Run the automated DoD gate via [audit-dod.ps1](../ui-dod-audit/scripts/audit-dod.ps1):
   ```powershell
   pwsh -NoProfile -File .agents/skills/ui-dod-audit/scripts/audit-dod.ps1
   ```
