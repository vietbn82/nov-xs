---
name: lean-slice
description: >-
  Executes the 4-Stage Lean SpecKit workflow (Spec -> Tokens & Web Components ->
  Vertical Slice TDD -> DoD Gate) for creating or updating a feature. Use when the
  user asks to specify, plan, or implement a new feature or vertical slice.
---

# Lean-Slice: Spec-to-TDD Vertical Slice Workflow

Follow these 4 stages in order whenever adding or modifying a feature.

## Stage 1: Lean Spec & Contract (`specs/###-feature/`)

1. Scaffold the feature directory:
   ```powershell
   pwsh -NoProfile -File .specify/scripts/powershell/create-new-feature.ps1 -Json -ShortName "<short-name>" "<feature description>"
   ```
2. Fill out `specs/###-<short-name>/spec.md` using [`.specify/templates/spec-template.md`](../../../.specify/templates/spec-template.md):
   - Prioritized P1 MVP user scenarios (`Given` / `When` / `Then`).
   - Exact Minimal API route, Request/Response `record` DTOs, and AI/offline fallback contract.
   - UI Layout Topology & **Mutual Exclusivity Matrix** (`<dialog>` vs `popover="auto"`).
   - Visual & Accessibility Contracts (VAC).
3. Generate `plan.md` via `.specify/scripts/powershell/setup-plan.ps1` and map the vertical slice files under `src/<Project>/Features/<SliceName>/`.

## Stage 2: Design Tokens & Native Web Components

1. Check `wwwroot/css/tokens.css`. Add any new semantic tokens inside `@layer tokens` using `oklch()` colors and `clamp()` typography.
2. Apply the **Rule of Two**: if any UI element appears on $\ge 2$ views or encapsulates an overlay (`<dialog>` or `popover="auto"`), create or update a Native Web Component in `wwwroot/components/app-<name>.js`.

## Stage 3: Red-Green-Refactor Vertical Slice TDD

1. **Red**: Write failing unit & API integration tests in `tests/<Project>.Tests/Features/<SliceName>Tests.cs` using `xUnit` and `FluentAssertions`.
2. **Green**:
   - Create `<Slice>Models.cs` (immutable `record` DTOs).
   - Create `<Slice>Service.cs` (primary constructor, atomic persistence, `IChatClient` + deterministic fallback if AI-powered).
   - Create `<Slice>Endpoints.cs` (`MapGroup("/api/<slice>")` returning `TypedResults` or `TypedResults.ServerSentEvents`).
3. **Verify Backend**: Run `dotnet test` until 100% green.
4. **Wire Frontend**: Connect `wwwroot/components/` and `wwwroot/js/app.js` to the endpoint.

## Stage 4: Definition of Done (DoD) Gate

Invoke the `ui-dod-audit` skill (`.agents/skills/ui-dod-audit/SKILL.md`) to validate tests, responsive viewports (`375px` & `1440px`), WCAG 2.2 AA contrast, and browser console cleanliness.
