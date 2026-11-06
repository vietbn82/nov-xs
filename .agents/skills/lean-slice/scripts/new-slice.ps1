#!/usr/bin/env pwsh
# Scaffolds a complete Lean SpecKit Vertical Slice (specs/###-<slice> + Features/<Slice> + Isolated <slice-*> Web Component + Program.cs wiring + xUnit Tests)
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$SliceName,
    [string]$Description = '',
    [string]$ProjectName = '',
    [string]$TargetRoot = ''
)
$ErrorActionPreference = 'Stop'

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

# 1. Generate Lean SpecKit artifacts (spec.md, plan.md, tasks.md)
$env:SPECIFY_INIT_DIR = $repoRoot
$specJson = & (Join-Path $repoRoot '.specify/scripts/powershell/create-new-feature.ps1') -Json -AllowExistingBranch -ShortName $shortName $Description | ConvertFrom-Json
$env:SPECIFY_FEATURE_DIRECTORY = Split-Path -Parent $specJson.SPEC_FILE
& (Join-Path $repoRoot '.specify/scripts/powershell/setup-plan.ps1') -Json | Out-Null
& (Join-Path $repoRoot '.specify/scripts/powershell/setup-tasks.ps1') -Json | Out-Null

# 2. Auto-detect ProjectName if src/ exists
$srcRoot = Join-Path $repoRoot 'src'
if ([string]::IsNullOrWhiteSpace($ProjectName) -and (Test-Path -LiteralPath $srcRoot -PathType Container)) {
    $firstProj = Get-ChildItem -LiteralPath $srcRoot -Directory | Select-Object -First 1
    if ($firstProj) { $ProjectName = $firstProj.Name }
}

if (-not [string]::IsNullOrWhiteSpace($ProjectName)) {
    foreach ($docFile in @(
        (Join-Path $env:SPECIFY_FEATURE_DIRECTORY 'plan.md'),
        (Join-Path $env:SPECIFY_FEATURE_DIRECTORY 'tasks.md')
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

public sealed record ${SliceName}State(IReadOnlyList<${SliceName}Item> Items);
"@
            [System.IO.File]::WriteAllText($modelsPath, $modelsCode, $utf8NoBom)
        }

        $servicePath = Join-Path $sliceDir "${SliceName}Service.cs"
        if (-not (Test-Path -LiteralPath $servicePath -PathType Leaf)) {
            $serviceCode = @"
using $ProjectName.Infrastructure;

namespace $ProjectName.Features.$SliceName;

public sealed class ${SliceName}Service(IJsonStore<${SliceName}State> store)
{
    public IReadOnlyList<${SliceName}Item> GetAll() => store.Read().Items;

    public ${SliceName}Item Create(Create${SliceName}Request request)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(request.Title);

        var item = new ${SliceName}Item(
            Id: Guid.NewGuid().ToString("N")[..8],
            Title: request.Title.Trim(),
            Notes: request.Notes?.Trim() ?? string.Empty,
            CreatedAtUtc: DateTimeOffset.UtcNow);

        store.Update(state => new ${SliceName}State([.. state.Items, item]));
        return item;
    }
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

        group.MapGet("/", (${SliceName}Service service) =>
            TypedResults.Ok(service.GetAll()));

        group.MapPost("/", Results<Created<${SliceName}Item>, ValidationProblem> (
            Create${SliceName}Request request,
            ${SliceName}Service service) =>
        {
            if (string.IsNullOrWhiteSpace(request.Title))
            {
                return TypedResults.ValidationProblem(new Dictionary<string, string[]>
                {
                    [nameof(request.Title)] = ["Title is required."]
                });
            }

            var created = service.Create(request);
            return TypedResults.Created("/api/$routeSlug/" + created.Id, created);
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
                $compJs = [System.IO.File]::ReadAllText($sliceTplPath, [System.Text.Encoding]::UTF8)
                $compJs = $compJs.Replace('__SLICE_NAME__', $SliceName).Replace('__ROUTE_SLUG__', $routeSlug).Replace('__SLICE_DESCRIPTION__', $Description)
                [System.IO.File]::WriteAllText($compFile, $compJs, $utf8NoBom)
            }

            # Mount <slice-*> tag and script import into index.html if not already present
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

        # 4. Auto-register slice in Program.cs if Program.cs exists and doesn't already wire it
        $programPath = Join-Path $projectDir 'Program.cs'
        if (Test-Path -LiteralPath $programPath -PathType Leaf) {
            $progRaw = [System.IO.File]::ReadAllText($programPath, [System.Text.Encoding]::UTF8)
            if ($progRaw -notmatch "Map${SliceName}Endpoints") {
                $usingLine = "using $ProjectName.Features.$SliceName;`n"
                $diBlock = @"
builder.Services.AddSingleton<IJsonStore<${SliceName}State>>(_ =>
    new AtomicJsonStore<${SliceName}State>(Path.Combine(builder.Environment.ContentRootPath, "Data", "$routeSlug.json"), () => new ${SliceName}State([])));
builder.Services.AddSingleton<${SliceName}Service>();

var app = builder.Build();
"@
                $progRaw = $usingLine + $progRaw
                $progRaw = $progRaw.Replace('var app = builder.Build();', $diBlock)
                $progRaw = $progRaw.Replace('app.Run();', "app.Map${SliceName}Endpoints();`n`napp.Run();")
                [System.IO.File]::WriteAllText($programPath, $progRaw, $utf8NoBom)
            }
        }

        # 5. Scaffold xUnit + FluentAssertions Test Suite
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
using $ProjectName.Features.$SliceName;
using $ProjectName.Infrastructure;
using Xunit;

namespace $ProjectName.Tests.Features;

public sealed class ${SliceName}Tests : IDisposable
{
    private readonly string _tempFile = Path.Combine(Path.GetTempPath(), $"test-$routeSlug-{Guid.NewGuid():N}.json");

    [Fact]
    public void Service_CreateAndGetAll_PersistsAtomically()
    {
        var store = new AtomicJsonStore<${SliceName}State>(_tempFile, () => new ${SliceName}State([]));
        var service = new ${SliceName}Service(store);

        var created = service.Create(new Create${SliceName}Request("First Slice Item", "Verified via TDD"));

        created.Id.Should().NotBeNullOrWhiteSpace();
        service.GetAll().Should().ContainSingle(x => x.Title == "First Slice Item");
    }

    [Fact]
    public async Task Endpoint_PostEmptyTitle_ReturnsBadRequest()
    {
        await using var factory = new WebApplicationFactory<Program>();
        using var client = factory.CreateClient();

        var response = await client.PostAsJsonAsync("/api/$routeSlug", new Create${SliceName}Request("   "));

        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    public void Dispose()
    {
        if (File.Exists(_tempFile))
        {
            File.Delete(_tempFile);
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
