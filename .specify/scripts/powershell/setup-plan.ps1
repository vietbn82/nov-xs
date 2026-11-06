#!/usr/bin/env pwsh
# Setup implementation plan (plan.md) for the active feature slice
[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$Help
)
$ErrorActionPreference = 'Stop'

if ($Help) {
    Write-Output "Usage: ./setup-plan.ps1 [-Json] [-Help]"
    exit 0
}

. "$PSScriptRoot/common.ps1"
$paths = Get-FeaturePathsEnv -ReturnNullOnError
if (-not $paths) {
    [Console]::Error.WriteLine("ERROR: Failed to resolve feature paths.")
    exit 1
}

New-Item -ItemType Directory -Path $paths.FEATURE_DIR -Force | Out-Null

if (-not (Test-Path -LiteralPath $paths.IMPL_PLAN -PathType Leaf)) {
    $content = Resolve-TemplateContent -TemplateName 'plan-template' -RepoRoot $paths.REPO_ROOT
    if ([string]::IsNullOrEmpty($content)) {
        [Console]::Error.WriteLine("ERROR: valid plan-template.md not found.")
        exit 1
    }
    $today = (Get-Date).ToString('yyyy-MM-dd')
    $content = $content.Replace('[###-feature-name]', $paths.CURRENT_BRANCH).Replace('[DATE]', $today)
    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($paths.IMPL_PLAN, $content, $utf8NoBom)
}

if ($Json) {
    [PSCustomObject]@{
        FEATURE_SPEC = $paths.FEATURE_SPEC
        IMPL_PLAN    = $paths.IMPL_PLAN
        FEATURE_DIR  = $paths.FEATURE_DIR
        BRANCH       = $paths.CURRENT_BRANCH
    } | ConvertTo-Json -Compress
} else {
    Write-Output "FEATURE_SPEC: $($paths.FEATURE_SPEC)"
    Write-Output "IMPL_PLAN: $($paths.IMPL_PLAN)"
    Write-Output "FEATURE_DIR: $($paths.FEATURE_DIR)"
    Write-Output "BRANCH: $($paths.CURRENT_BRANCH)"
}
