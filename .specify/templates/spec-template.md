# Feature Specification: [FEATURE NAME]

**Feature ID**: `[###-feature-name]` | **Created**: `[DATE]` | **Status**: Draft  
**Input**: "$ARGUMENTS"

---

## 1. User Scenarios & Independent Acceptance (MVP First)

### User Story 1 - [Primary Slice Title] (Priority: P1 — MVP)
[1–2 sentences describing what the user accomplishes and why it matters.]

- **Independent Test**: [How to verify this slice end-to-end on its own]
- **Acceptance Scenarios**:
  1. **Given** [initial state], **When** [user/system action], **Then** [deterministic outcome].
  2. **Given** [invalid/edge input], **When** [action], **Then** [graceful validation or fallback].

### User Story 2 - [Secondary Enhancement] (Priority: P2 — Optional)
[1–2 sentences describing the secondary flow, if applicable.]

- **Independent Test**: [How to verify independently]
- **Acceptance Scenarios**:
  1. **Given** [initial state], **When** [action], **Then** [expected outcome].

---

## 2. API, AI & Data Contracts

| Method & Route | Request DTO / Params | Response (`TypedResults` / SSE) | Error / Fallback Behavior |
| :--- | :--- | :--- | :--- |
| `POST /api/[slice]` | `[RequestRecord]` | `Ok<[ResponseRecord]>` / `ValidationProblem` | [Deterministic fallback / 400 problem details] |

- **Persistence Entity**: `[EntityName]` stored via [Atomic JSON Store / SQLite WAL].
- **AI Contract (if applicable)**: `IChatClient` prompt goal, structured output schema `[SchemaRecord]`, and offline/heuristic fallback.

---

## 3. UI Layout Topology & Mutual Exclusivity Matrix

- **Surface & Anchoring**: [e.g., Main grid card / Right `<dialog>` drawer (`--drawer-width`) / Native `popover="auto"`]
- **Reusable Web Component**: [`<app-component-name>` in `wwwroot/components/`]

| Trigger Event | Active Overlay / Target | Action Taken (Top-Layer Rule) |
| :--- | :--- | :--- |
| Open `[Modal/Drawer A]` | `[Popover/Tooltip B]` | Immediately dismiss `B` (`hidePopover()`) before `showModal()` |
| Press `Escape` | Active `<dialog>` / `popover` | Close active top-layer surface and restore focus to trigger button |

---

## 4. Visual, Performance & Accessibility Contracts (VAC)

- [ ] **Token Compliance**: Uses only `tokens.css` variables (`var(--font-*)`, `var(--color-*)` in `oklch()`, `var(--radius-*)`). Zero ad-hoc hex codes or arbitrary pixel font sizes.
- [ ] **Viewport Integrity**: Zero horizontal overflow (`overflow-x: hidden`) at `375px` (Mobile), `768px` (Tablet), and `1440px` (Desktop).
- [ ] **Accessibility (WCAG 2.2 AA)**: Contrast $\ge 4.5:1$, touch targets $\ge 44 \times 44\text{px}$, full keyboard navigation (`Tab`, `Enter`, `Escape`).
- [ ] **Performance & Resilience**: API p95 `< 200ms` (non-AI) or immediate SSE first-token feedback (AI); 100% functional when offline/fallback mode is active.
