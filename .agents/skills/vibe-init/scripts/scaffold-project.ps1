#!/usr/bin/env pwsh
# 1-Command Project Bootstrapper for Nov-XS Vibe Coding Scaffold (SQLite WAL Edition)
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ProjectName,
    [string]$FirstSlice = 'Workspace',
    [string]$Mission = 'Deliver focused user outcomes with zero architectural bloat.',
    [string]$TargetRoot = '',
    [switch]$InitGit
)
$ErrorActionPreference = 'Stop'

function ConvertTo-PascalIdentifier([string]$Raw, [string]$Fallback) {
    $tokens = ($Raw -split '[^a-zA-Z0-9]+' | Where-Object { $_ })
    if ($tokens.Count -eq 0) { return $Fallback }
    $pascal = ($tokens | ForEach-Object {
        if ($_.Length -eq 1) { $_.ToUpperInvariant() }
        else { $_.Substring(0, 1).ToUpperInvariant() + $_.Substring(1) }
    }) -join ''
    if ($pascal -match '^[0-9]') { $pascal = "App$pascal" }
    return $pascal
}

$ProjectName = ConvertTo-PascalIdentifier $ProjectName 'VibeApp'
$FirstSlice = ConvertTo-PascalIdentifier $FirstSlice 'Workspace'

$templateRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../..')).Path
if ($TargetRoot) {
    if (-not (Test-Path -LiteralPath $TargetRoot -PathType Container)) {
        New-Item -ItemType Directory -Path $TargetRoot -Force | Out-Null
    }
    $repoRoot = (Resolve-Path -LiteralPath $TargetRoot).Path
    if (-not (Test-Path -LiteralPath (Join-Path $repoRoot '.specify') -PathType Container)) {
        foreach ($item in @('AGENTS.md', 'README.md', 'vibe.ps1', '.editorconfig', '.gitignore', '.agents', '.specify', 'docs')) {
            $srcItem = Join-Path $templateRoot $item
            if (Test-Path -LiteralPath $srcItem) {
                Copy-Item -LiteralPath $srcItem -Destination $repoRoot -Recurse -Force
            }
        }
    }
} else {
    $repoRoot = $templateRoot
}

if ($InitGit -and -not (Test-Path -LiteralPath (Join-Path $repoRoot '.git') -PathType Container)) {
    Push-Location $repoRoot
    try { git init -b main | Out-Null } finally { Pop-Location }
}

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$routeSlug = ($FirstSlice -creplace '([a-z0-9])([A-Z])', '$1-$2').ToLowerInvariant()

# 1. Update Constitution placeholders
$constitutionPath = Join-Path $repoRoot '.specify/memory/constitution.md'
if (Test-Path -LiteralPath $constitutionPath -PathType Leaf) {
    $constRaw = [System.IO.File]::ReadAllText($constitutionPath, [System.Text.Encoding]::UTF8)
    $constRaw = $constRaw.Replace('[PROJECT_NAME]', $ProjectName).Replace('[CORE_OUTCOME_METRIC]', $Mission)
    $constRaw = $constRaw.Replace('[TARGET_USER_AND_PROBLEM]', "Users of $ProjectName seeking: $Mission")
    $constRaw = $constRaw.Replace('[EXPLICIT_NON_GOALS]', 'Unrequested CRUD bloat, multi-service microservices, or untested UI.')
    [System.IO.File]::WriteAllText($constitutionPath, $constRaw, $utf8NoBom)
}

# 2. Create .slnx file
$slnxPath = Join-Path $repoRoot "$ProjectName.slnx"
if (-not (Test-Path -LiteralPath $slnxPath -PathType Leaf)) {
    $slnxContent = @"
<Solution>
  <Folder Name="/src/">
    <Project Path="src/$ProjectName/$ProjectName.csproj" />
  </Folder>
  <Folder Name="/tests/">
    <Project Path="tests/$ProjectName.Tests/$ProjectName.Tests.csproj" />
  </Folder>
</Solution>
"@
    [System.IO.File]::WriteAllText($slnxPath, $slnxContent, $utf8NoBom)
}

# 3. Create src/<ProjectName> structure
$appDir = Join-Path $repoRoot "src/$ProjectName"
$infraDir = Join-Path $appDir 'Infrastructure'
$cssDir = Join-Path $appDir 'wwwroot/css'
$compDir = Join-Path $appDir 'wwwroot/components'
$jsDir = Join-Path $appDir 'wwwroot/js'

foreach ($d in @($appDir, $infraDir, $cssDir, $compDir, $jsDir)) {
    New-Item -ItemType Directory -Path $d -Force | Out-Null
}

$csprojPath = Join-Path $appDir "$ProjectName.csproj"
if (-not (Test-Path -LiteralPath $csprojPath -PathType Leaf)) {
    $csprojContent = @"
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.OpenApi" Version="10.0.14" />
    <PackageReference Include="Microsoft.Data.Sqlite" Version="10.0.14" />
    <PackageReference Include="SQLitePCLRaw.bundle_e_sqlite3" Version="2.1.14" />
    <PackageReference Include="Microsoft.Extensions.AI" Version="9.3.0-preview.1.25161.3" />
    <PackageReference Include="Scalar.AspNetCore" Version="2.0.18" />
  </ItemGroup>

</Project>
"@
    [System.IO.File]::WriteAllText($csprojPath, $csprojContent, $utf8NoBom)
}

# 4. Copy C# Infrastructure templates (SqliteDatabase + ResilientAiPipeline)
$csharpTplDir = Join-Path $repoRoot '.specify/templates/csharp'
foreach ($tpl in @('SqliteDatabase.cs.template', 'ResilientAiPipeline.cs.template')) {
    $srcTpl = Join-Path $csharpTplDir $tpl
    $dstPath = Join-Path $infraDir ($tpl.Replace('.template', ''))
    if (-not (Test-Path -LiteralPath $dstPath -PathType Leaf)) {
        $content = [System.IO.File]::ReadAllText($srcTpl, [System.Text.Encoding]::UTF8).Replace('__PROJECT_NAME__', $ProjectName)
        [System.IO.File]::WriteAllText($dstPath, $content, $utf8NoBom)
    }
}

# 5. Copy Studio-Grade Web Tokens, Top-Layer, Health Probe & Open-Code Component Kit
foreach ($pair in @(
    @{ Src = '.specify/templates/tokens-template.css'; Dst = (Join-Path $cssDir 'tokens.css') },
    @{ Src = '.specify/templates/web/styles-template.css'; Dst = (Join-Path $cssDir 'styles.css') },
    @{ Src = '.specify/templates/web/top-layer.js'; Dst = (Join-Path $jsDir 'top-layer.js') },
    @{ Src = '.specify/templates/web/ui-health-probe.js'; Dst = (Join-Path $jsDir 'ui-health-probe.js') }
)) {
    if (-not (Test-Path -LiteralPath $pair.Dst -PathType Leaf)) {
        [System.IO.File]::Copy((Join-Path $repoRoot $pair.Src), $pair.Dst, $true)
    }
}

foreach ($webComp in @('app-header.js', 'app-dialog.js', 'app-drawer.js', 'app-toast.js', 'app-cmd-palette.js')) {
    $dstComp = Join-Path $compDir $webComp
    if (-not (Test-Path -LiteralPath $dstComp -PathType Leaf)) {
        [System.IO.File]::Copy((Join-Path $repoRoot ".specify/templates/web/$webComp"), $dstComp, $true)
    }
}

# 6. Create thin App Shell index.html (idempotent: preserve existing index.html if present)
$indexPath = Join-Path $appDir 'wwwroot/index.html'
if (-not (Test-Path -LiteralPath $indexPath -PathType Leaf)) {
    $indexHtml = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>$ProjectName</title>
  <link rel="stylesheet" href="/css/styles.css" />
  <script type="module" src="/js/top-layer.js"></script>
  <script type="module" src="/js/ui-health-probe.js"></script>
  <script type="module" src="/components/app-header.js"></script>
  <script type="module" src="/components/app-dialog.js"></script>
  <script type="module" src="/components/app-drawer.js"></script>
  <script type="module" src="/components/app-toast.js"></script>
  <script type="module" src="/components/app-cmd-palette.js"></script>
</head>
<body>
  <app-header brand="$ProjectName" active="home"></app-header>
  <main class="app-shell">
  </main>
  <app-drawer drawer-id="app-inspector-drawer" title="System & AI Inspector">
    <p class="card__subtitle">Press Ctrl+K anywhere to launch the Command Palette or run a live UI geometry audit.</p>
  </app-drawer>
  <app-cmd-palette></app-cmd-palette>
  <app-toast></app-toast>
</body>
</html>
"@
    [System.IO.File]::WriteAllText($indexPath, $indexHtml, $utf8NoBom)
}

# 7. Create tests/<ProjectName>.Tests project
$testProjDir = Join-Path $repoRoot "tests/$ProjectName.Tests"
New-Item -ItemType Directory -Path $testProjDir -Force | Out-Null

$testCsprojPath = Join-Path $testProjDir "$ProjectName.Tests.csproj"
if (-not (Test-Path -LiteralPath $testCsprojPath -PathType Leaf)) {
    $testCsproj = @"
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <IsPackable>false</IsPackable>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="FluentAssertions" Version="6.12.2" />
    <PackageReference Include="Microsoft.AspNetCore.Mvc.Testing" Version="10.0.14" />
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.12.0" />
    <PackageReference Include="xunit" Version="2.9.2" />
    <PackageReference Include="xunit.runner.visualstudio" Version="2.8.2" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\..\src\$ProjectName\$ProjectName.csproj" />
  </ItemGroup>

</Project>
"@
    [System.IO.File]::WriteAllText($testCsprojPath, $testCsproj, $utf8NoBom)
}

# 8. Write base Program.cs wiring SQLite WAL Engine, OpenAPI + Scalar, and IChatClient fallback (idempotent)
$programPath = Join-Path $appDir 'Program.cs'
if (-not (Test-Path -LiteralPath $programPath -PathType Leaf)) {
    $programCs = @"
using Microsoft.Extensions.AI;
using Scalar.AspNetCore;
using $ProjectName.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

var dbPath = builder.Configuration["DatabasePath"]
    ?? Path.Combine(builder.Environment.ContentRootPath, "Data", "app.db");
builder.Services.AddOpenApi();
builder.Services.AddSingleton<ISqliteConnectionFactory>(_ => new SqliteConnectionFactory(dbPath));
builder.Services.AddSingleton<IChatClient, DeterministicFallbackChatClient>();

var app = builder.Build();

app.MapOpenApi();
app.MapScalarApiReference();
app.UseDefaultFiles();
app.UseStaticFiles();

app.Run();

public partial class Program;
"@
    [System.IO.File]::WriteAllText($programPath, $programCs, $utf8NoBom)
}

# 9. Generate First Vertical Slice, Isolated Web Component & Spec via new-slice.ps1
& (Join-Path $repoRoot '.agents/skills/lean-slice/scripts/new-slice.ps1') `
    -SliceName $FirstSlice `
    -Description $Mission `
    -ProjectName $ProjectName `
    -TargetRoot $repoRoot | Out-Null

Write-Output "Scaffolded $ProjectName (SQLite WAL) with isolated slice '<slice-$routeSlug>' at $repoRoot"
