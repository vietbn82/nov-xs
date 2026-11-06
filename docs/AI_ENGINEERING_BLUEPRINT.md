# State-of-the-Art AI Engineering Blueprint (.NET 10 + Native Web)

> **Philosophy:** *Provider-Agnostic Abstractions – Deterministic Structured Outputs – Real-Time SSE Streaming – SIMD Local Vector Search – 100% Offline/Test Resilience.*  
> Standardized blueprint for building production-grade AI capabilities inside small-to-medium .NET 10 applications without vendor lock-in or brittle prompt parsing.

---

## 1. Reference AI Architecture

```text
┌──────────────────────────────────────────────────────────────────────┐
│  Frontend: Native Web Components (<app-ai-stream>, EventSource/SSE)  │
└──────────────────────────────────┬───────────────────────────────────┘
                                   │ POST /api/ai/* (JSON or text/event-stream)
┌──────────────────────────────────▼───────────────────────────────────┐
│  Minimal API Endpoint: TypedResults.Ok<T> | ServerSentEvents<T>      │
└──────────────────────────────────┬───────────────────────────────────┘
                                   │
┌──────────────────────────────────▼───────────────────────────────────┐
│  Resilient AI Service (Primary IChatClient ➔ Deterministic Fallback) │
└──────────────────────────────────┬───────────────────────────────────┘
                                   │ Microsoft.Extensions.AI Pipeline
        ┌──────────────────────────┼──────────────────────────┐
        ▼                          ▼                          ▼
┌───────────────┐          ┌───────────────┐          ┌───────────────┐
│ Cloud Provider│          │ Local Runtime │          │ Deterministic │
│ (Gemini /     │          │ (Ollama /     │          │ Fallback /    │
│  OpenAI)      │          │  ONNX)        │          │ Test Fake     │
└───────────────┘          └───────────────┘          └───────────────┘
```

---

## 2. Core Pattern 1: Unified `IChatClient` Pipeline (`Microsoft.Extensions.AI`)

Never couple domain services to a specific SDK or spawn external CLI processes for LLM inference. Register `IChatClient` using `ChatClientBuilder` middleware in `Program.cs`:

```csharp
using Microsoft.Extensions.AI;

builder.Services.AddDistributedMemoryCache();

builder.Services.AddChatClient(sp =>
{
    IChatClient innerClient = ResolveConfiguredProvider(builder.Configuration);
    return new ChatClientBuilder(innerClient)
        .UseDistributedCache()          // Zero-cost instant replay for identical prompts
        .UseFunctionInvocation()        // Automatic AIFunction tool-calling loop
        .UseOpenTelemetry()             // Built-in token usage & latency spans
        .UseLogging()
        .Build(sp);
});
```

---

## 3. Core Pattern 2: Deterministic Structured Outputs (`GetResponseAsync<T>`)

Prohibit fragile regex or substring extraction on raw LLM markdown. Always request strongly-typed C# `record` schemas via `GetResponseAsync<T>`:

```csharp
namespace MyApp.Features.Analysis;

public sealed record AnalysisRequest(string Content, string Goal);
public sealed record ActionItem(string Title, string Priority, int EstimatedMinutes);
public sealed record AnalysisResult(
    string Summary,
    int ClarityScore,
    IReadOnlyList<ActionItem> NextActions,
    bool UsedFallback = false);

public sealed class AnalysisService(IChatClient chatClient, ILogger<AnalysisService> logger)
{
    public async Task<AnalysisResult> AnalyzeAsync(AnalysisRequest request, CancellationToken ct = default)
    {
        try
        {
            var prompt = $"""
                Analyze the following input toward the goal: "{request.Goal}".
                Input: {request.Content}
                """;

            var response = await chatClient.GetResponseAsync<AnalysisResult>(prompt, cancellationToken: ct);
            if (response.Result is { } typedResult)
            {
                return typedResult;
            }
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "Primary IChatClient failed; executing deterministic fallback.");
        }

        return new AnalysisResult(
            Summary: $"Offline summary for '{request.Goal}' ({request.Content.Length} chars).",
            ClarityScore: 80,
            NextActions: [new ActionItem("Review core requirements", "High", 15)],
            UsedFallback: true);
    }
}
```

---

## 4. Core Pattern 3: Real-Time Generative Streaming (.NET 10 Native SSE)

For long-form generation or interactive chat, stream tokens immediately using .NET 10's built-in `TypedResults.ServerSentEvents`:

```csharp
using System.Net.ServerSentEvents;
using System.Runtime.CompilerServices;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.Extensions.AI;

app.MapPost("/api/ai/stream", (
    StreamPromptRequest request,
    IChatClient chatClient,
    CancellationToken ct) =>
{
    return TypedResults.ServerSentEvents(
        StreamTokensAsync(request.Prompt, chatClient, ct),
        eventType: "token");
});

static async IAsyncEnumerable<string> StreamTokensAsync(
    string prompt,
    IChatClient chatClient,
    [EnumeratorCancellation] CancellationToken ct)
{
    await foreach (var update in chatClient.GetStreamingResponseAsync(prompt, cancellationToken: ct))
    {
        if (!string.IsNullOrEmpty(update.Text))
        {
            yield return update.Text;
        }
    }
}
```

---

## 5. Core Pattern 4: Tool Calling & Model Context Protocol (MCP)

Expose deterministic C# domain methods as AI tools using `AIFunctionFactory.Create` so the model can query local state safely:

```csharp
var chatOptions = new ChatOptions
{
    Tools =
    [
        AIFunctionFactory.Create(
            (string tag) => workspaceService.SearchItemsByTag(tag),
            name: "search_workspace_items",
            description: "Searches local workspace items by tag name.")
    ]
};

var response = await chatClient.GetResponseAsync(userMessage, chatOptions, ct);
```

---

## 6. Core Pattern 5: Zero-Ops Local Vector Search (`TensorPrimitives.CosineSimilarity`)

For small-to-medium apps (`< 50,000` documents), do **not** deploy an external vector database (Pinecone, Qdrant, pgvector). Store `float[]` embeddings in your local JSON/SQLite store and rank in-memory using hardware-accelerated SIMD `TensorPrimitives.CosineSimilarity` (`System.Numerics.Tensors`):

```csharp
using System.Numerics.Tensors;
using Microsoft.Extensions.AI;

public sealed record EmbeddedRecord<T>(T Item, float[] Vector);

public static IReadOnlyList<T> TopKSimilar<T>(
    ReadOnlySpan<float> queryVector,
    IEnumerable<EmbeddedRecord<T>> corpus,
    int k = 5)
{
    var scored = new List<(T Item, float Score)>();
    foreach (var entry in corpus)
    {
        float score = TensorPrimitives.CosineSimilarity(queryVector, entry.Vector);
        scored.Add((entry.Item, score));
    }

    return scored
        .OrderByDescending(x => x.Score)
        .Take(k)
        .Select(x => x.Item)
        .ToList();
}
```

---

## 7. Core Pattern 6: Deterministic AI Unit Testing

Use [`.specify/templates/csharp/ResilientAiPipeline.cs.template`](../.specify/templates/csharp/ResilientAiPipeline.cs.template) (`DeterministicFallbackChatClient`) or a canned `IChatClient` stub in `xUnit` so `dotnet test` runs in `< 100ms` with zero network calls or API keys:

```csharp
[Fact]
public async Task AnalyzeAsync_WhenFallbackActive_ReturnsDeterministicResult()
{
    var chatClient = new DeterministicFallbackChatClient();
    var service = new AnalysisService(chatClient, NullLogger<AnalysisService>.Instance);

    var result = await service.AnalyzeAsync(new AnalysisRequest("Draft spec", "Ship MVP"));

    result.Summary.Should().NotBeNullOrWhiteSpace();
    result.ClarityScore.Should().BeInRange(0, 100);
}
```
