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
1. **Project Name** (PascalCase, e.g., `PulseNotes`, `FocusForge`)
2. **Primary Outcome (The One Thing)** — what core problem it solves and for whom
3. **First MVP Vertical Slice** — the single highest-value feature to build first

## Step 2: Lock the Project Constitution

Update [`.specify/memory/constitution.md`](../../../.specify/memory/constitution.md) by replacing:
- `[PROJECT_NAME]`
- `[TARGET_USER_AND_PROBLEM]`
- `[CORE_OUTCOME_METRIC]`
- `[EXPLICIT_NON_GOALS]`

## Step 3: Scaffold the Lean .NET 10 Solution

Create the standardized directory structure:
```text
<ProjectName>.slnx
src/<ProjectName>/
├── <ProjectName>.csproj          # net10.0, Nullable=enable, ImplicitUsings=enable
├── Program.cs                    # Minimal API + OpenAPI/Scalar + StaticFiles
├── Infrastructure/
│   └── AtomicJsonStore.cs        # Thread-safe System.Threading.Lock + temp-file swap
├── Features/
│   └── <FirstSlice>/             # Models, Service, Endpoints
└── wwwroot/
    ├── index.html
    ├── css/
    │   ├── tokens.css            # Copy from .specify/templates/tokens-template.css
    │   └── styles.css
    ├── components/
    │   └── app-header.js         # Native Web Component (<app-header>)
    └── js/
        └── app.js
tests/<ProjectName>.Tests/
├── <ProjectName>.Tests.csproj    # xUnit + FluentAssertions + Microsoft.AspNetCore.Mvc.Testing
└── Features/
    └── <FirstSlice>Tests.cs
```

## Step 4: Initialize First Feature Spec & Verify

1. Run `.specify/scripts/powershell/create-new-feature.ps1 -ShortName "<first-slice>" "<First MVP Slice Description>"` to generate `specs/001-<first-slice>/spec.md`.
2. Run `dotnet test` and confirm `0` errors and `0` warnings.
