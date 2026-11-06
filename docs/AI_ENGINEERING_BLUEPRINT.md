# State-of-the-Art AI Engineering Blueprint (.NET 10 + Native Web)

> **Philosophy:** *Provider-Agnostic Abstractions – Deterministic Structured Outputs – Real-Time SSE Streaming – 100% Offline/Test Resilience.*  
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
│ Cloud Provider│          │ Local Runtime │          │ In-Memory     │
│ (Gemini /     │          │ (Ollama /     │          │ Heuristic /   │
│  OpenAI)      │          │  ONNX)        │          │ Test Fake     │
└───────────────┘          └───────────────┘          └───────────────┘
```

---

## 2. Core Pattern 1: Unified `IChatClient` Pipeline (`Microsoft.Extensions.AI`)

Never couple domain services to a specific SDK or spawn external CLI processes for LLM inference. Register `IChatClient` using `ChatClientBuilder` middleware in `Program.cs`:

```csharp
using Microsoft.Extensions.AI;

// Program.cs — Composable AI Pipeline Registration
builder.Services.AddDistributedMemoryCache();

// Register provider-agnostic IChatClient (Cloud, Ollama local, or Fallback)
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

public sealed class AnalysisService(
    IChatClient chatClient,
    ILogger<AnalysisService> logger)
{
    public async Task<AnalysisResult> AnalyzeAsync(AnalysisRequest request, CancellationToken ct = default)
    {
        try
        {
            var prompt = $"""
                Analyze the following input toward the goal: "{request.Goal}".
                Input: {request.Content}
                """;

            var response = await chatClient.GetResponseAsync<AnalysisResult>(
                prompt,
                cancellationToken: ct);

            if (response.Result is { } typedResult)
            {
                return typedResult;
            }
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "Primary IChatClient failed; executing deterministic fallback.");
        }

        return BuildDeterministicFallback(request);
    }

    private static AnalysisResult BuildDeterministicFallback(AnalysisRequest request) =>
        new(
            Summary: $"Offline summary for '{request.Goal}' ({request.Content.Length} chars).",
            ClarityScore: 80,
            NextActions: [new ActionItem("Review core requirements", "High", 15)],
            UsedFallback: true);
}
```

---

## 4. Core Pattern 3: Real-Time Generative Streaming (.NET 10 Native SSE)

For long-form generation or interactive coaching/chat, stream tokens immediately using .NET 10's built-in `TypedResults.ServerSentEvents`:

### Backend Minimal API Endpoint:
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

### Frontend Native Consumption (`fetch` + `ReadableStream`):
```javascript
export async function streamAiResponse(prompt, onChunk) {
  const response = await fetch('/api/ai/stream', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ prompt })
  });

  if (!response.ok || !response.body) {
    throw new Error(`Stream failed: ${response.status}`);
  }

  const reader = response.body.pipeThrough(new TextDecoderStream()).getReader();
  while (true) {
    const { value, done } = await reader.read();
    if (done) break;
    for (const line of value.split('\n')) {
      if (line.startsWith('data: ')) {
        onChunk(line.slice(6));
      }
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

## 6. AI Verification & Testing Checklist

1. **Zero Live-Key Test Dependency:** Unit and integration tests (`dotnet test`) MUST pass with zero external API keys configured by injecting an in-memory `IChatClient` fake or verifying the deterministic fallback path.
2. **Bounded Latency & Cancellation:** Always forward `CancellationToken ct` from Minimal API endpoints into `IChatClient` calls and configure a sensible timeout (`TimeSpan.FromSeconds(15)`).
3. **Prompt Hygiene:** Keep system prompts concise, versioned inside the Vertical Slice service, and grounded in user-supplied context.
