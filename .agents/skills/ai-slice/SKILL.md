---
name: ai-slice
description: >-
  Implements or upgrades an AI-powered vertical slice using Microsoft.Extensions.AI
  (IChatClient, Structured Outputs via GetResponseAsync<T>, .NET 10 ServerSentEvents
  streaming, AIFunction tool calling, or SIMD CosineSimilarity local vector search)
  with 100% deterministic offline fallback. Use when building LLM, chat, extraction,
  or semantic search features.
---

# AI-Slice: State-of-the-Art .NET 10 AI Feature Builder

Follow this workflow whenever adding AI capabilities to a Vertical Slice. Reference [docs/AI_ENGINEERING_BLUEPRINT.md](../../../docs/AI_ENGINEERING_BLUEPRINT.md) for code patterns.

## 1. Choose the Right AI Primitive

| Use Case | Required Pattern |
| :--- | :--- |
| **Classification, Scoring, Extraction** | `await chatClient.GetResponseAsync<TResponse>(prompt, ct)` with immutable `record` DTOs |
| **Interactive Chat / Long-Form Generation** | `TypedResults.ServerSentEvents(StreamAsync(...), eventType: "token")` |
| **Querying Local App State from LLM** | `ChatOptions { Tools = [AIFunctionFactory.Create(...)] }` + `.UseFunctionInvocation()` |
| **Semantic Search (< 50K records)** | `IEmbeddingGenerator<string, Embedding<float>>` + `TensorPrimitives.CosineSimilarity` |

## 2. Enforce the 3 Non-Negotiable AI Guardrails

1. **Zero CLI Spawning**: Never call `Process.Start` to invoke external CLI tools for AI inference; always inject `IChatClient` or `IEmbeddingGenerator`.
2. **Mandatory Offline/Test Fallback**: Catch provider exceptions (`try`/`catch`) and return a deterministic heuristic response (or use `DeterministicFallbackChatClient` from [`.specify/templates/csharp/ResilientAiPipeline.cs.template`](../../../.specify/templates/csharp/ResilientAiPipeline.cs.template)) so `dotnet test` and offline development never fail.
3. **Cancellation & Timeout Hygiene**: Forward `CancellationToken ct` from every Minimal API endpoint to `IChatClient`.

## 3. Write Deterministic xUnit Tests

In `tests/<Project>.Tests/Features/<Slice>Tests.cs`:
- Test the structured output path using `DeterministicFallbackChatClient` or a canned `IChatClient` test double.
- Test the fallback path when the primary `IChatClient` throws an `HttpRequestException` or returns empty output.
