---
name: lean-slice
description: >-
  Executes the 4-Stage Lean SpecKit workflow (Spec -> Tokens & Web Components ->
  Vertical Slice TDD -> DoD Gate) for creating or updating a feature. Use when the
  user asks to specify, plan, or implement a new feature or vertical slice.
---

# Lean-Slice: Spec-to-TDD Vertical Slice Workflow

Follow these 4 stages in order whenever adding or modifying a feature.

## Stage 1: Scaffold Slice Spec & Skeleton

Run [new-slice.ps1](./scripts/new-slice.ps1) to create `specs/###-<slice>/` (`spec.md`, `plan.md`, `tasks.md`) and, if `src/` exists, the initial Vertical Slice files (`Models`, `Service`, `Endpoints`, `Tests`):

```powershell
pwsh -NoProfile -File .agents/skills/lean-slice/scripts/new-slice.ps1 `
  -SliceName "<PascalCaseSliceName>" `
  -Description "<Concise feature description>"
```

Then refine `specs/###-<slice>/spec.md` with:
- Prioritized P1 MVP user scenarios (`Given` / `When` / `Then`).
- Exact Minimal API route, Request/Response `record` DTOs, and AI/offline fallback contract.
- UI Layout Topology & **Mutual Exclusivity Matrix** (`<dialog>` vs `popover="auto"` via `window.TopLayer`).
- Visual & Accessibility Contracts (VAC).

## Stage 2: Design Tokens & Native Web Components

1. Check `wwwroot/css/tokens.css`. Add any new semantic tokens inside `@layer tokens` using `oklch()` colors and `clamp()` typography.
2. Apply the **Rule of Two**: if any UI element appears on $\ge 2$ views or encapsulates an overlay (`<dialog>` or `popover="auto"`), create or update a Native Web Component in `wwwroot/components/app-<name>.js`.

## Stage 3: Red-Green-Refactor Vertical Slice TDD

1. **Red**: Expand unit & API integration tests in `tests/<Project>.Tests/Features/<SliceName>Tests.cs` using `xUnit` and `FluentAssertions`.
2. **Green**:
   - Update `<Slice>Models.cs` (immutable `record` DTOs).
   - Update `<Slice>Service.cs` (primary constructor, atomic persistence, `IChatClient` + deterministic fallback if AI-powered).
   - Update `<Slice>Endpoints.cs` (`MapGroup("/api/<slice>")` returning `TypedResults`) and register `app.Map<Slice>Endpoints()` in `Program.cs`.
3. **Wire Frontend**: Connect `wwwroot/components/` and `wwwroot/js/app.js` to the endpoint.

## Stage 4: Definition of Done (DoD) Gate

Run the automated DoD & Token Purity auditor ([`ui-dod-audit`](../ui-dod-audit/SKILL.md)):
```powershell
pwsh -NoProfile -File .agents/skills/ui-dod-audit/scripts/audit-dod.ps1
```
