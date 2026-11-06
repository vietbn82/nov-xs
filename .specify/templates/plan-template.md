# Implementation Plan: [FEATURE NAME]

**Feature ID**: `[###-feature-name]` | **Date**: `[DATE]` | **Spec**: `./spec.md`

---

## 1. Summary & Technical Context

- **Goal**: [1-sentence summary of the vertical slice outcome and technical approach]
- **Backend Stack**: .NET 10 Minimal APIs, C# 13+, Vertical Slice (`Features/[SliceName]/`), `TypedResults`
- **AI Stack (if applicable)**: `Microsoft.Extensions.AI` (`IChatClient`), Structured Output / SSE Streaming, Deterministic Fallback
- **Persistence**: [Atomic JSON Document Store (`System.Threading.Lock` + temp-file swap) / SQLite `WAL`]
- **Frontend Stack**: HTML5 Native Web Components (`customElements.define`), `tokens.css` (`@layer tokens`, `oklch()`, `clamp()`), native `<dialog>` & Popover API
- **Verification**: `xUnit` + `FluentAssertions` + `WebApplicationFactory<Program>` + Chrome DevTools MCP

---

## 2. Constitution & Lean SpecKit Gate

- [ ] **Anti-Drift**: Directly serves the project's Primary Outcome in `.specify/memory/constitution.md`.
- [ ] **Zero Over-Engineering**: Single vertical slice; no unnecessary repositories, mappers, or pass-through interfaces.
- [ ] **Rule of Two (DRY UI)**: Shared UI elements extracted to `wwwroot/components/<name>.js`.
- [ ] **Top-Layer Exclusivity**: Overlays use `<dialog>` or `popover="auto"` matching the spec's Mutual Exclusivity Matrix.
- [ ] **Resilient AI/I/O**: Includes deterministic fallback and atomic persistence writes.

---

## 3. Vertical Slice File Map

```text
specs/[###-feature-name]/
├── spec.md                  # Lean Feature Specification & Contracts
├── plan.md                  # This Vertical Slice Implementation Plan
└── tasks.md                 # TDD & DoD Execution Checklist

src/[ProjectName]/
├── Program.cs               # Register slice services & Map[Slice]Endpoints()
├── Features/
│   └── [SliceName]/
│       ├── [Slice]Models.cs     # Request/Response records & validation
│       ├── [Slice]Service.cs    # Core domain/AI logic + fallback
│       └── [Slice]Endpoints.cs  # Minimal API route group (TypedResults / SSE)
├── Infrastructure/          # Shared AtomicJsonStore / SqliteDb / AiClient
└── wwwroot/
    ├── css/tokens.css       # Design token additions (if any)
    └── components/
        └── app-[slice].js   # Encapsulated Native Web Component

tests/[ProjectName].Tests/
└── Features/
    └── [SliceName]Tests.cs  # xUnit + FluentAssertions unit & API integration tests
```

---

## 4. Complexity Exceptions (Fill ONLY if a Constitution Rule is Waived)

| Rule Waived | Why Required | Simpler Alternative Rejected Because |
| :--- | :--- | :--- |
| None | N/A | N/A |
