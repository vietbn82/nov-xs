---
description: "Lean Vertical-Slice TDD & DoD Task List"
---

# Tasks: [FEATURE NAME]

**Input**: `./spec.md` and `./plan.md` in `specs/[###-feature-name]/`  
**Format**: `- [ ] [TaskID] [P?] [Slice] Description with exact file path` (`[P]` = safe to run in parallel)

---

## Phase 1: Design Tokens & Contracts Setup

- [ ] T001 [P] [Tokens] Verify or add required CSS variables (`oklch()` colors, `clamp()` typography, layout bounds) in `src/[ProjectName]/wwwroot/css/tokens.css`
- [ ] T002 [P] [Contracts] Define immutable request/response `record` DTOs and domain models in `src/[ProjectName]/Features/[SliceName]/[Slice]Models.cs`

---

## Phase 2: Backend Vertical Slice (Red-Green-Refactor TDD)

> **Rule**: Write failing `xUnit` + `FluentAssertions` tests BEFORE implementing service or endpoint logic.

- [ ] T003 [US1] Write unit & integration tests (happy path, validation errors, offline/AI fallback) in `tests/[ProjectName].Tests/Features/[SliceName]Tests.cs`
- [ ] T004 [US1] Implement service logic (with atomic persistence and `IChatClient` + deterministic fallback if AI-enabled) in `src/[ProjectName]/Features/[SliceName]/[Slice]Service.cs`
- [ ] T005 [US1] Map Minimal API endpoints using `TypedResults` (or `TypedResults.ServerSentEvents`) in `src/[ProjectName]/Features/[SliceName]/[Slice]Endpoints.cs` and wire into `src/[ProjectName]/Program.cs`
- [ ] T006 [US1] Run `dotnet test` and confirm all Phase 2 tests pass (`Green`)

---

## Phase 3: Native Web Components & Top-Layer UI

- [ ] T007 [P] [US1] Build or update encapsulated Native Web Component (`customElements.define`) using `<dialog>` / `popover="auto"` in `src/[ProjectName]/wwwroot/components/app-[slice].js`
- [ ] T008 [US1] Wire frontend API calls (`fetch` / `EventSource`) and enforce the Mutual Exclusivity Matrix in `src/[ProjectName]/wwwroot/js/app.js` and `src/[ProjectName]/wwwroot/index.html`

---

## Phase 4: 4-Point Definition of Done (DoD) Gate

- [ ] T009 [DoD] **Automated Suite**: `dotnet test` exits `0` with zero warnings
- [ ] T010 [DoD] **Viewport Integrity**: Verify `375px` (Mobile) and `1440px` (Desktop) layouts have zero horizontal scrollbar (`overflow-x`)
- [ ] T011 [DoD] **Visual & A11y (VAC)**: Verify token-only typography/colors, WCAG 2.2 AA contrast ($\ge 4.5:1$), $\ge 44 \times 44\text{px}$ touch targets, and `Escape` key overlay dismissal
- [ ] T012 [DoD] **Console Cleanliness**: Verify zero uncaught JS errors or failed network requests in browser DevTools console
