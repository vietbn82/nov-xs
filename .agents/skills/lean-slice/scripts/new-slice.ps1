#!/usr/bin/env pwsh
# Scaffolds a complete Lean SpecKit Vertical Slice backed by SQLite WAL (specs/###-<slice> + Features/<Slice> + <slice-*> Web Component + Program.cs wiring + xUnit Tests)
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$SliceName,
    [string]$Description = '',
    [string]$ProjectName = '',
    [string]$TargetRoot = ''
)
$ErrorActionPreference = 'Stop'

function ConvertTo-PascalIdentifier([string]$Raw, [string]$Fallback) {
    $tokens = ($Raw -split '[^a-zA-Z0-9]+' | Where-Object { $_ })
    if ($tokens.Count -eq 0) { return $Fallback }
    $pascal = ($tokens | ForEach-Object {
        if ($_.Length -eq 1) { $_.ToUpperInvariant() }
        else { $_.Substring(0, 1).ToUpperInvariant() + $_.Substring(1) }
    }) -join ''
    if ($pascal -match '^[0-9]') { $pascal = "Slice$pascal" }
    return $pascal
}

$SliceName = ConvertTo-PascalIdentifier $SliceName 'Feature'
if ($ProjectName) {
    $ProjectName = ConvertTo-PascalIdentifier $ProjectName 'VibeApp'
}

$repoRoot = if ($TargetRoot) {
    (Resolve-Path -LiteralPath $TargetRoot).Path
} else {
    (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../..')).Path
}

if ([string]::IsNullOrWhiteSpace($Description)) {
    $Description = "$SliceName vertical slice"
}

$shortName = ($SliceName -creplace '([a-z0-9])([A-Z])', '$1-$2').ToLowerInvariant()
$routeSlug = $shortName

# 1. Generate Lean SpecKit artifacts (spec.md, plan.md, tasks.md) without leaking env vars
$prevInitDir = $env:SPECIFY_INIT_DIR
$prevFeatDir = $env:SPECIFY_FEATURE_DIRECTORY
$prevFeat = $env:SPECIFY_FEATURE
try {
    $env:SPECIFY_INIT_DIR = $repoRoot
    $specJson = & (Join-Path $repoRoot '.specify/scripts/powershell/create-new-feature.ps1') -Json -AllowExistingBranch -ShortName $shortName $Description | ConvertFrom-Json
    $featureDir = Split-Path -Parent $specJson.SPEC_FILE
    $env:SPECIFY_FEATURE_DIRECTORY = $featureDir
    & (Join-Path $repoRoot '.specify/scripts/powershell/setup-plan.ps1') -Json | Out-Null
    & (Join-Path $repoRoot '.specify/scripts/powershell/setup-tasks.ps1') -Json | Out-Null
} finally {
    $env:SPECIFY_INIT_DIR = $prevInitDir
    $env:SPECIFY_FEATURE_DIRECTORY = $prevFeatDir
    $env:SPECIFY_FEATURE = $prevFeat
}

# 2. Auto-detect ProjectName if src/ exists
$srcRoot = Join-Path $repoRoot 'src'
if ([string]::IsNullOrWhiteSpace($ProjectName) -and (Test-Path -LiteralPath $srcRoot -PathType Container)) {
    $firstProj = Get-ChildItem -LiteralPath $srcRoot -Directory | Select-Object -First 1
    if ($firstProj) { $ProjectName = $firstProj.Name }
}

if (-not [string]::IsNullOrWhiteSpace($ProjectName)) {
    foreach ($docFile in @(
        (Join-Path $featureDir 'plan.md'),
        (Join-Path $featureDir 'tasks.md')
    )) {
        if (Test-Path -LiteralPath $docFile -PathType Leaf) {
            $raw = [System.IO.File]::ReadAllText($docFile, [System.Text.Encoding]::UTF8)
            $raw = $raw.Replace('[ProjectName]', $ProjectName).Replace('[SliceName]', $SliceName).Replace('[Slice]', $SliceName).Replace('[slice]', $routeSlug).Replace('[FEATURE NAME]', $Description)
            [System.IO.File]::WriteAllText($docFile, $raw, [System.Text.UTF8Encoding]::new($false))
        }
    }

    $projectDir = Join-Path $srcRoot $ProjectName
    if (Test-Path -LiteralPath $projectDir -PathType Container) {
        $sliceDir = Join-Path $projectDir "Features/$SliceName"
        New-Item -ItemType Directory -Path $sliceDir -Force | Out-Null
        $utf8NoBom = [System.Text.UTF8Encoding]::new($false)

        $modelsPath = Join-Path $sliceDir "${SliceName}Models.cs"
        if (-not (Test-Path -LiteralPath $modelsPath -PathType Leaf)) {
            $modelsCode = @"
namespace $ProjectName.Features.$SliceName;

public sealed record ${SliceName}Item(string Id, string Title, string Notes, DateTimeOffset CreatedAtUtc);

public sealed record Create${SliceName}Request(string Title, string? Notes = null);
"@
            [System.IO.File]::WriteAllText($modelsPath, $modelsCode, $utf8NoBom)
        }

        $servicePath = Join-Path $sliceDir "${SliceName}Service.cs"
        if (-not (Test-Path -LiteralPath $servicePath -PathType Leaf)) {
            $serviceCode = @"
using $ProjectName.Infrastructure;

namespace $ProjectName.Features.$SliceName;

public sealed class ${SliceName}Service(ISliceStore<${SliceName}Item> store)
{
    public Task<IReadOnlyList<${SliceName}Item>> GetAllAsync(CancellationToken ct = default) =>
        store.GetAllAsync(ct);

    public async Task<${SliceName}Item> CreateAsync(Create${SliceName}Request request, CancellationToken ct = default)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(request.Title);

        var item = new ${SliceName}Item(
            Id: Guid.CreateVersion7().ToString("N"),
            Title: request.Title.Trim(),
            Notes: request.Notes?.Trim() ?? string.Empty,
            CreatedAtUtc: DateTimeOffset.UtcNow);

        return await store.UpsertAsync(item.Id, item, ct);
    }

    public Task<bool> DeleteAsync(string id, CancellationToken ct = default) =>
        store.DeleteAsync(id, ct);
}
"@
            [System.IO.File]::WriteAllText($servicePath, $serviceCode, $utf8NoBom)
        }

        $endpointsPath = Join-Path $sliceDir "${SliceName}Endpoints.cs"
        if (-not (Test-Path -LiteralPath $endpointsPath -PathType Leaf)) {
            $endpointsCode = @"
using Microsoft.AspNetCore.Http.HttpResults;

namespace $ProjectName.Features.$SliceName;

public static class ${SliceName}Endpoints
{
    public static IEndpointRouteBuilder Map${SliceName}Endpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/$routeSlug").WithTags("$SliceName");

        group.MapGet("/", async (${SliceName}Service service, CancellationToken ct) =>
            TypedResults.Ok(await service.GetAllAsync(ct)));

        group.MapPost("/", async Task<Results<Created<${SliceName}Item>, ValidationProblem>> (
            Create${SliceName}Request request,
            ${SliceName}Service service,
            CancellationToken ct) =>
        {
            if (string.IsNullOrWhiteSpace(request.Title))
            {
                return TypedResults.ValidationProblem(new Dictionary<string, string[]>
                {
                    [nameof(request.Title)] = ["Title is required."]
                });
            }

            var created = await service.CreateAsync(request, ct);
            return TypedResults.Created("/api/$routeSlug/" + created.Id, created);
        });

        group.MapDelete("/{id}", async Task<Results<NoContent, NotFound>> (
            string id,
            ${SliceName}Service service,
            CancellationToken ct) =>
        {
            var deleted = await service.DeleteAsync(id, ct);
            return deleted ? TypedResults.NoContent() : TypedResults.NotFound();
        });

        return app;
    }
}
"@
            [System.IO.File]::WriteAllText($endpointsPath, $endpointsCode, $utf8NoBom)
        }

        # 3. Scaffold Isolated Native Web Component (wwwroot/components/slice-<routeSlug>.js)
        $compDir = Join-Path $projectDir 'wwwroot/components'
        $sliceTplPath = Join-Path $repoRoot '.specify/templates/web/slice-component.js.template'
        if ((Test-Path -LiteralPath $compDir -PathType Container) -and (Test-Path -LiteralPath $sliceTplPath -PathType Leaf)) {
            $compFile = Join-Path $compDir "slice-$routeSlug.js"
            if (-not (Test-Path -LiteralPath $compFile -PathType Leaf)) {
                $safeDesc = $Description.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;').Replace("'", '&#39;').Replace('`', '').Replace('$', '')
                $compJs = [System.IO.File]::ReadAllText($sliceTplPath, [System.Text.Encoding]::UTF8)
                $compJs = $compJs.Replace('__SLICE_NAME__', $SliceName).Replace('__ROUTE_SLUG__', $routeSlug).Replace('__SLICE_DESCRIPTION__', $safeDesc)
                [System.IO.File]::WriteAllText($compFile, $compJs, $utf8NoBom)
            }

            $indexPath = Join-Path $projectDir 'wwwroot/index.html'
            if (Test-Path -LiteralPath $indexPath -PathType Leaf) {
                $indexRaw = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)
                $scriptTag = "<script type=`"module`" src=`"/components/slice-$routeSlug.js`"></script>"
                $elementTag = "<slice-$routeSlug></slice-$routeSlug>"
                if ($indexRaw -notmatch "slice-$routeSlug\.js") {
                    $indexRaw = $indexRaw.Replace('</head>', "  $scriptTag`n</head>")
                }
                if ($indexRaw -notmatch "<slice-$routeSlug>") {
                    $indexRaw = $indexRaw.Replace('</main>', "    $elementTag`n  </main>")
                }
                [System.IO.File]::WriteAllText($indexPath, $indexRaw, $utf8NoBom)
            }
        }

        # 4. Auto-register SQLite SliceStore & Service in Program.cs
        $programPath = Join-Path $projectDir 'Program.cs'
        if (Test-Path -LiteralPath $programPath -PathType Leaf) {
            $progRaw = [System.IO.File]::ReadAllText($programPath, [System.Text.Encoding]::UTF8)
            if ($progRaw -notmatch "Map${SliceName}Endpoints") {
                $usingLine = "using $ProjectName.Features.$SliceName;`n"
                $diBlock = @"
builder.Services.AddSingleton<ISliceStore<${SliceName}Item>>(sp =>
    new SqliteSliceStore<${SliceName}Item>(sp.GetRequiredService<ISqliteConnectionFactory>(), "$routeSlug"));
builder.Services.AddSingleton<${SliceName}Service>();

var app = builder.Build();
"@
                $progRaw = $usingLine + $progRaw
                $progRaw = $progRaw.Replace('var app = builder.Build();', $diBlock)
                $progRaw = $progRaw.Replace('app.Run();', "app.Map${SliceName}Endpoints();`n`napp.Run();")
                [System.IO.File]::WriteAllText($programPath, $progRaw, $utf8NoBom)
            }
        }

        # 5. Scaffold xUnit + FluentAssertions Test Suite (Testing SQLite WAL + Minimal API Endpoints + OpenAPI)
        $testDir = Join-Path $repoRoot "tests/$ProjectName.Tests/Features"
        if (Test-Path -LiteralPath (Join-Path $repoRoot "tests/$ProjectName.Tests") -PathType Container) {
            New-Item -ItemType Directory -Path $testDir -Force | Out-Null
            $testPath = Join-Path $testDir "${SliceName}Tests.cs"
            if (-not (Test-Path -LiteralPath $testPath -PathType Leaf)) {
                $testCode = @"
using System.Net;
using System.Net.Http.Json;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Data.Sqlite;
using Microsoft.Extensions.AI;
using $ProjectName.Features.$SliceName;
using $ProjectName.Infrastructure;
using Xunit;

namespace $ProjectName.Tests.Features;

public sealed class ${SliceName}Tests : IDisposable
{
    private readonly string _tempDb = Path.Combine(Path.GetTempPath(), $"test-$routeSlug-{Guid.NewGuid():N}.db");

    [Fact]
    public async Task Service_CreateGetAndDelete_PersistsInSqliteWal()
    {
        using var factory = new SqliteConnectionFactory(_tempDb);
        var store = new SqliteSliceStore<${SliceName}Item>(factory, "$routeSlug");
        var service = new ${SliceName}Service(store);

        var created = await service.CreateAsync(new Create${SliceName}Request("SQLite WAL Item", "Verified via TDD"));

        created.Id.Should().HaveLength(32);
        (await service.GetAllAsync()).Should().ContainSingle(x => x.Title == "SQLite WAL Item");

        var deleted = await service.DeleteAsync(created.Id);
        deleted.Should().BeTrue();
        (await service.GetAllAsync()).Should().BeEmpty();
    }

    [Fact]
    public async Task Endpoint_ValidationAndOpenApi_WorkCorrectly()
    {
        await using var appFactory = new WebApplicationFactory<Program>()
            .WithWebHostBuilder(b => b.UseSetting("DatabasePath", _tempDb));
        using var client = appFactory.CreateClient();

        var badResponse = await client.PostAsJsonAsync("/api/$routeSlug", new Create${SliceName}Request("   "));
        badResponse.StatusCode.Should().Be(HttpStatusCode.BadRequest);

        var openApiResponse = await client.GetAsync("/openapi/v1.json");
        openApiResponse.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    [Fact]
    public async Task FallbackChatClient_StructuredOutput_DeserializesCleanly()
    {
        using var chatClient = new DeterministicFallbackChatClient();
        var response = await chatClient.GetResponseAsync<Create${SliceName}Request>("Test structured output");

        response.Result.Should().NotBeNull();
        response.Result.Title.Should().Contain("Fallback");
    }

    public void Dispose()
    {
        SqliteConnection.ClearAllPools();
        foreach (var suffix in new[] { "", "-wal", "-shm" })
        {
            var p = _tempDb + suffix;
            if (File.Exists(p)) File.Delete(p);
        }
    }
}
"@
                [System.IO.File]::WriteAllText($testPath, $testCode, $utf8NoBom)
            }
        }
    }
}

[PSCustomObject]@{
    Branch      = $specJson.BRANCH_NAME
    SpecFile    = $specJson.SPEC_FILE
    SliceName   = $SliceName
    ProjectName = $ProjectName
} | ConvertTo-Json -Compress
