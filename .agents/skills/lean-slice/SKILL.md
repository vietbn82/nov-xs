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

Run [new-slice.ps1](./scripts/new-slice.ps1) (or `./vibe.ps1 slice <SliceName>`) to create `specs/###-<slice>/` (`spec.md`, `plan.md`, `tasks.md`), the SQLite WAL Vertical Slice (`Models`, `Service`, `Endpoints`, `Tests`), and the isolated `wwwroot/components/slice-<slice>.js` Web Component:

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

## Stage 2: Design Tokens & Isolated `<slice-*>` Web Component

1. Check `wwwroot/css/tokens.css`. Add any new semantic tokens inside `@layer tokens` using `oklch()` colors and `clamp()` typography.
2. Customize the slice's isolated Native Web Component in `wwwroot/components/slice-<slice>.js` using scoped `this.querySelector()` (never `document.getElementById()`), rendering all 4 states (Loading, Empty, Populated, Error).

## Stage 3: Red-Green-Refactor Vertical Slice TDD

1. **Red**: Expand unit & API integration tests in `tests/<Project>.Tests/Features/<SliceName>Tests.cs` using `xUnit` and `FluentAssertions`.
2. **Green**:
   - Update `<Slice>Models.cs` (immutable `record` DTOs).
   - Update `<Slice>Service.cs` (primary constructor, `ISliceStore<T>` SQLite WAL persistence, `IChatClient` + deterministic fallback if AI-powered).
   - Update `<Slice>Endpoints.cs` (`MapGroup("/api/<slice>")` returning `TypedResults`) and confirm `app.Map<Slice>Endpoints()` is wired in `Program.cs`.
3. **Wire Frontend**: Connect `wwwroot/components/slice-<slice>.js` to `/api/<slice>` with `try/catch` error handling and `window.AppToast` feedback.

## Stage 4: Definition of Done (DoD) Gate

Run the automated DoD & Token Purity auditor ([`ui-dod-audit`](../ui-dod-audit/SKILL.md)):
```powershell
pwsh -NoProfile -File .agents/skills/ui-dod-audit/scripts/audit-dod.ps1
```
