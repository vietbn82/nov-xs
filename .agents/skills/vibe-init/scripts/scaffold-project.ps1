#!/usr/bin/env pwsh
# 1-Command Project Bootstrapper for Nov-XS Vibe Coding Scaffold
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ProjectName,
    [string]$FirstSlice = 'Workspace',
    [string]$Mission = 'Deliver focused user outcomes with zero architectural bloat.',
    [string]$TargetRoot = ''
)
$ErrorActionPreference = 'Stop'

$repoRoot = if ($TargetRoot) {
    (Resolve-Path -LiteralPath $TargetRoot).Path
} else {
    (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../..')).Path
}

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$routeSlug = ($FirstSlice -creplace '([a-z0-9])([A-Z])', '$1-$2').ToLowerInvariant()

# 1. Update Constitution if placeholders exist
$constitutionPath = Join-Path $repoRoot '.specify/memory/constitution.md'
if (Test-Path -LiteralPath $constitutionPath -PathType Leaf) {
    $constRaw = [System.IO.File]::ReadAllText($constitutionPath, [System.Text.Encoding]::UTF8)
    $constRaw = $constRaw.Replace('[PROJECT_NAME]', $ProjectName).Replace('[CORE_OUTCOME_METRIC]', $Mission)
    [System.IO.File]::WriteAllText($constitutionPath, $constRaw, $utf8NoBom)
}

# 2. Create .slnx file
$slnxPath = Join-Path $repoRoot "$ProjectName.slnx"
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

# 3. Create src/<ProjectName> structure
$appDir = Join-Path $repoRoot "src/$ProjectName"
$infraDir = Join-Path $appDir 'Infrastructure'
$cssDir = Join-Path $appDir 'wwwroot/css'
$compDir = Join-Path $appDir 'wwwroot/components'
$jsDir = Join-Path $appDir 'wwwroot/js'

foreach ($d in @($appDir, $infraDir, $cssDir, $compDir, $jsDir)) {
    New-Item -ItemType Directory -Path $d -Force | Out-Null
}

$csprojContent = @"
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.Extensions.AI" Version="9.3.0-preview.1.25161.3" />
    <PackageReference Include="Scalar.AspNetCore" Version="2.0.18" />
  </ItemGroup>

</Project>
"@
[System.IO.File]::WriteAllText((Join-Path $appDir "$ProjectName.csproj"), $csprojContent, $utf8NoBom)

# 4. Copy C# Infrastructure templates
$csharpTplDir = Join-Path $repoRoot '.specify/templates/csharp'
foreach ($tpl in @('AtomicJsonStore.cs.template', 'ResilientAiPipeline.cs.template')) {
    $srcTpl = Join-Path $csharpTplDir $tpl
    $dstName = $tpl.Replace('.template', '')
    $content = [System.IO.File]::ReadAllText($srcTpl, [System.Text.Encoding]::UTF8).Replace('__PROJECT_NAME__', $ProjectName)
    [System.IO.File]::WriteAllText((Join-Path $infraDir $dstName), $content, $utf8NoBom)
}

# 5. Copy Web Tokens & Component templates
[System.IO.File]::Copy((Join-Path $repoRoot '.specify/templates/tokens-template.css'), (Join-Path $cssDir 'tokens.css'), $true)
[System.IO.File]::Copy((Join-Path $repoRoot '.specify/templates/web/styles-template.css'), (Join-Path $cssDir 'styles.css'), $true)
[System.IO.File]::Copy((Join-Path $repoRoot '.specify/templates/web/top-layer.js'), (Join-Path $jsDir 'top-layer.js'), $true)
[System.IO.File]::Copy((Join-Path $repoRoot '.specify/templates/web/app-header.js'), (Join-Path $compDir 'app-header.js'), $true)
[System.IO.File]::Copy((Join-Path $repoRoot '.specify/templates/web/app-dialog.js'), (Join-Path $compDir 'app-dialog.js'), $true)

# 6. Create index.html & app.js
$indexHtml = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>$ProjectName</title>
  <link rel="stylesheet" href="/css/styles.css" />
  <script type="module" src="/js/top-layer.js"></script>
  <script type="module" src="/components/app-header.js"></script>
  <script type="module" src="/components/app-dialog.js"></script>
  <script type="module" src="/js/app.js"></script>
</head>
<body>
  <app-header brand="$ProjectName" active="home"></app-header>

  <main class="app-shell">
    <section class="card" aria-labelledby="slice-heading">
      <h1 id="slice-heading" class="card__title">$FirstSlice</h1>
      <p class="card__subtitle">$Mission</p>
      <form id="create-form" class="input-group">
        <input id="item-title" class="input-field" type="text" placeholder="Enter title..." required aria-label="Item title" />
        <button type="submit" class="btn">Add</button>
      </form>
      <ul id="items-list" aria-live="polite"></ul>
    </section>
  </main>
</body>
</html>
"@
[System.IO.File]::WriteAllText((Join-Path $appDir 'wwwroot/index.html'), $indexHtml, $utf8NoBom)

$appJs = @"
const API_BASE = '/api/$routeSlug';

async function loadItems() {
  const listEl = document.getElementById('items-list');
  if (!listEl) return;
  const res = await fetch(API_BASE);
  if (!res.ok) return;
  const items = await res.json();
  listEl.innerHTML = items.map((i) => '<li><strong>' + i.title + '</strong></li>').join('');
}

document.addEventListener('DOMContentLoaded', () => {
  loadItems();
  const form = document.getElementById('create-form');
  form?.addEventListener('submit', async (e) => {
    e.preventDefault();
    const input = document.getElementById('item-title');
    if (!input || !input.value.trim()) return;
    await fetch(API_BASE, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title: input.value.trim() })
    });
    input.value = '';
    await loadItems();
  });
});
"@
[System.IO.File]::WriteAllText((Join-Path $jsDir 'app.js'), $appJs, $utf8NoBom)

# 7. Create tests/<ProjectName>.Tests project
$testProjDir = Join-Path $repoRoot "tests/$ProjectName.Tests"
New-Item -ItemType Directory -Path $testProjDir -Force | Out-Null

$testCsproj = @"
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <IsPackable>false</IsPackable>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="FluentAssertions" Version="6.12.2" />
    <PackageReference Include="Microsoft.AspNetCore.Mvc.Testing" Version="10.0.0-*" />
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.12.0" />
    <PackageReference Include="xunit" Version="2.9.2" />
    <PackageReference Include="xunit.runner.visualstudio" Version="2.8.2" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\..\src\$ProjectName\$ProjectName.csproj" />
  </ItemGroup>

</Project>
"@
[System.IO.File]::WriteAllText((Join-Path $testProjDir "$ProjectName.Tests.csproj"), $testCsproj, $utf8NoBom)

# 8. Generate First Vertical Slice & Spec via new-slice.ps1
& (Join-Path $repoRoot '.agents/skills/lean-slice/scripts/new-slice.ps1') `
    -SliceName $FirstSlice `
    -Description "$FirstSlice MVP vertical slice" `
    -ProjectName $ProjectName `
    -TargetRoot $repoRoot | Out-Null

# 9. Write Program.cs wiring Scalar, IChatClient fallback, and the First Slice
$programCs = @"
using Microsoft.Extensions.AI;
using Scalar.AspNetCore;
using $ProjectName.Features.$FirstSlice;
using $ProjectName.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSingleton<IChatClient, DeterministicFallbackChatClient>();

var dataFile = Path.Combine(builder.Environment.ContentRootPath, "Data", "$routeSlug.json");
builder.Services.AddSingleton<IJsonStore<${FirstSlice}State>>(_ =>
    new AtomicJsonStore<${FirstSlice}State>(dataFile, () => new ${FirstSlice}State([])));
builder.Services.AddSingleton<${FirstSlice}Service>();

var app = builder.Build();

app.MapScalarApiReference();
app.UseDefaultFiles();
app.UseStaticFiles();

app.Map${FirstSlice}Endpoints();

app.Run();

public partial class Program;
"@
[System.IO.File]::WriteAllText((Join-Path $appDir 'Program.cs'), $programCs, $utf8NoBom)

Write-Output "Scaffolded $ProjectName with slice '$FirstSlice' at $repoRoot"
