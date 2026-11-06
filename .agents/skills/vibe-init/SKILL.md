---
name: vibe-init
description: >-
  Bootstraps a new small-to-medium (XS/S) fullstack .NET 10 and Native Web Component
  project from the Nov-XS Vibe Coding Scaffold. Use when the user asks to initialize,
  scaffold, or start a new project in this repository.
---

# Vibe-Init: 60-Second Project Bootstrapper

Use this skill to transform the zero-bias `Nov-XS` rules template into a working, tested .NET 10 Vertical Slice + Native Web Components application tailored to the user's idea.

## Step 1: Align on the 3 Core Inputs

If the user has not already provided them in their prompt, ask for:
1. **ProjectName** (PascalCase, e.g., `PulseNotes`, `FocusForge`)
2. **Mission** (Primary Outcome — what core problem it solves and for whom)
3. **FirstSlice** (PascalCase name of the first MVP vertical slice, e.g., `Notes`, `Tasks`)

## Step 2: Execute the 1-Command Project Scaffolder

Run the bundled [scaffold-project.ps1](./scripts/scaffold-project.ps1) helper script:

```powershell
pwsh -NoProfile -File .agents/skills/vibe-init/scripts/scaffold-project.ps1 `
  -ProjectName "<ProjectName>" `
  -FirstSlice "<FirstSlice>" `
  -Mission "<Mission>"
```

This script automatically:
- Updates [`.specify/memory/constitution.md`](../../../.specify/memory/constitution.md) with the project name and mission.
- Creates `<ProjectName>.slnx`, `src/<ProjectName>/`, and `tests/<ProjectName>.Tests/`.
- Copies `AtomicJsonStore.cs` and `ResilientAiPipeline.cs` (`DeterministicFallbackChatClient`) from [`.specify/templates/csharp/`](../../../.specify/templates/csharp/).
- Copies `tokens.css`, `styles.css`, `top-layer.js`, `<app-header>`, and `<app-dialog>` from [`.specify/templates/web/`](../../../.specify/templates/web/).
- Invokes `new-slice.ps1` to generate `specs/001-<first-slice>/` (`spec.md`, `plan.md`, `tasks.md`) and the complete `<FirstSlice>` vertical slice + `xUnit` tests.

## Step 3: Customize Domain Logic & Verify DoD Gate

1. Tailor `specs/001-<first-slice>/spec.md` and `src/<ProjectName>/Features/<FirstSlice>/` to the user's specific domain fields.
2. Run the automated DoD gate via [audit-dod.ps1](../ui-dod-audit/scripts/audit-dod.ps1):
   ```powershell
   pwsh -NoProfile -File .agents/skills/ui-dod-audit/scripts/audit-dod.ps1
   ```
