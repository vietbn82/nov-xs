# Quality & Definition of Done Checklist: [FEATURE NAME]

**Feature**: `[###-feature-name]` | **Created**: `[DATE]` | **Spec**: `./spec.md`

> **Usage**: Used by `/speckit.checklist`, `/speckit.analyze`, or the `ui-dod-audit` skill to verify spec completeness and implementation quality before completion.

---

## 1. Spec & Architecture Alignment

- [ ] CHK001 **Scope Guardrail**: Feature directly supports the Primary Outcome in `.specify/memory/constitution.md` with zero speculative bloat.
- [ ] CHK002 **Contracts Locked**: Every route, request/response `record` DTO, validation rule, and error status is explicitly defined in `spec.md`.
- [ ] CHK003 **AI & I/O Resilience**: Any LLM (`IChatClient`) or external call defines structured output schemas and a deterministic offline fallback; file writes use atomic temp-swap or SQLite `WAL`.

## 2. UI, Tokens & Top-Layer Hygiene

- [ ] CHK004 **Token-First CSS**: All colors (`oklch()`), fluid font sizes (`clamp()`), and spacing intervals use `tokens.css` variables (`@layer tokens`).
- [ ] CHK005 **Rule of Two (DRY)**: Any UI structure repeated across $\ge 2$ views is encapsulated in `wwwroot/components/` as a Native Web Component.
- [ ] CHK006 **Mutual Exclusivity**: Floating elements use native `<dialog>` or `popover="auto"` and never occlude active CTAs.

## 3. Verification & Definition of Done (DoD)

- [ ] CHK007 **Automated Tests**: `xUnit` + `FluentAssertions` unit and integration tests cover happy paths, edge cases, and fallbacks (`dotnet test` passes 100%).
- [ ] CHK008 **Responsive & A11y**: Zero horizontal overflow at `375px` and `1440px`; WCAG 2.2 AA contrast ($\ge 4.5:1$); touch targets $\ge 44 \times 44\text{px}$; zero console errors.
