# [PROJECT_NAME] Constitution

> **Purpose**: Supreme product and architectural governance for `[PROJECT_NAME]`.

---

## 1. Product Mission & Anti-Drift Guardrail

- **Project Name**: `[PROJECT_NAME]`
- **Target User & Core Problem**: `[TARGET_USER_AND_PROBLEM]`
- **Primary Outcome (The One Thing)**: `[CORE_OUTCOME_METRIC]`
- **Explicit Non-Goals**: `[EXPLICIT_NON_GOALS]`
- **Anti-Drift Rule**: Every feature, endpoint, AI prompt, or UI component MUST directly serve the Primary Outcome above.

---

## 2. Core Engineering Principles

### Principle I: Vertical Slice Simplicity
- Organize features by vertical slice (`Features/<SliceName>/`) using C# 13+ / .NET 10 Minimal APIs, file-scoped namespaces, primary constructors, `record` DTOs, and `TypedResults`.
- Avoid speculative abstractions (YAGNI); introduce interfaces only at I/O or test boundaries.

### Principle II: Token-First & Native Web Components
- Define all typography (`clamp()`), colors (`oklch()`), and spacing in `tokens.css` (`@layer tokens`).
- Encapsulate reusable UI into HTML5 Native Web Components (`customElements.define`).
- Govern overlays via native `<dialog>` and `popover="auto"` with an explicit Mutual Exclusivity Matrix.

### Principle III: Resilient AI Integration (`Microsoft.Extensions.AI`)
- Route LLM calls through `IChatClient` with structured outputs (`GetResponseAsync<T>`) and SSE streaming (`TypedResults.ServerSentEvents`).
- Always provide a local or deterministic fallback for offline/test resilience.

### Principle IV: Zero-Ops SQLite WAL Hybrid Persistence
- Use embedded SQLite in `WAL` mode (`ISqliteConnectionFactory` + zero-migration `SqliteSliceStore<T>`).

### Principle V: TDD & 4-Point Definition of Done (DoD)
- Verify every vertical slice with `xUnit` + `FluentAssertions` (`dotnet test`), responsive viewports (`375px`–`1440px`), WCAG 2.2 AA accessibility, and zero browser console errors.

---

## 3. Governance

- Amendments require explicit user approval and documentation in `plan.md`.

**Version**: `[CONSTITUTION_VERSION]` | **Ratified**: `[RATIFICATION_DATE]` | **Last Amended**: `[LAST_AMENDED_DATE]`
