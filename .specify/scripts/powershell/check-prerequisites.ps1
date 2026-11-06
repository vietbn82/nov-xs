#!/usr/bin/env pwsh
# Consolidated prerequisite check for Lean SpecKit workflow
[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$RequireSpec,
    [switch]$RequireTasks,
    [switch]$IncludeTasks,
    [switch]$PathsOnly,
    [string]$Template,
    [switch]$Help
)
$ErrorActionPreference = 'Stop'

if ($Help) {
    Write-Output "Usage: ./check-prerequisites.ps1 [-Json] [-RequireSpec] [-RequireTasks] [-IncludeTasks] [-PathsOnly] [-Template <name>]"
    exit 0
}

. "$PSScriptRoot/common.ps1"
$paths = if ($PathsOnly) { Get-FeaturePathsEnv -NoPersist } else { Get-FeaturePathsEnv }

if ($PathsOnly) {
    if ($Json) {
        [PSCustomObject]@{
            REPO_ROOT    = $paths.REPO_ROOT
            BRANCH       = $paths.CURRENT_BRANCH
            FEATURE_DIR  = $paths.FEATURE_DIR
            FEATURE_SPEC = $paths.FEATURE_SPEC
            IMPL_PLAN    = $paths.IMPL_PLAN
            TASKS        = $paths.TASKS
        } | ConvertTo-Json -Compress
    } else {
        Write-Output "REPO_ROOT: $($paths.REPO_ROOT)"
        Write-Output "BRANCH: $($paths.CURRENT_BRANCH)"
        Write-Output "FEATURE_DIR: $($paths.FEATURE_DIR)"
        Write-Output "FEATURE_SPEC: $($paths.FEATURE_SPEC)"
        Write-Output "IMPL_PLAN: $($paths.IMPL_PLAN)"
        Write-Output "TASKS: $($paths.TASKS)"
    }
    exit 0
}

if (-not (Test-Path -LiteralPath $paths.FEATURE_DIR -PathType Container)) {
    [Console]::Error.WriteLine("ERROR: Feature directory not found: $($paths.FEATURE_DIR)")
    exit 1
}
if ($RequireSpec -and -not (Test-Path -LiteralPath $paths.FEATURE_SPEC -PathType Leaf)) {
    [Console]::Error.WriteLine("ERROR: spec.md not found in $($paths.FEATURE_DIR)")
    exit 1
}
if (-not (Test-Path -LiteralPath $paths.IMPL_PLAN -PathType Leaf)) {
    [Console]::Error.WriteLine("ERROR: plan.md not found in $($paths.FEATURE_DIR)")
    exit 1
}
if ($RequireTasks -and -not (Test-Path -LiteralPath $paths.TASKS -PathType Leaf)) {
    [Console]::Error.WriteLine("ERROR: tasks.md not found in $($paths.FEATURE_DIR)")
    exit 1
}

$docs = @()
if (Test-Path -LiteralPath $paths.FEATURE_SPEC -PathType Leaf) { $docs += 'spec.md' }
if (Test-Path -LiteralPath $paths.IMPL_PLAN -PathType Leaf) { $docs += 'plan.md' }
if ($IncludeTasks -and (Test-Path -LiteralPath $paths.TASKS -PathType Leaf)) { $docs += 'tasks.md' }
if (Test-Path -LiteralPath $paths.CHECKLIST -PathType Leaf) { $docs += 'checklist.md' }

$result = [PSCustomObject]@{
    FEATURE_DIR    = $paths.FEATURE_DIR
    AVAILABLE_DOCS = $docs
}

if ($Template) {
    $tplContent = Resolve-TemplateContent -TemplateName $Template -RepoRoot $paths.REPO_ROOT
    $result | Add-Member -NotePropertyName 'TEMPLATE_CONTENT' -NotePropertyValue $tplContent
}

if ($Json) {
    $result | ConvertTo-Json -Compress
} else {
    Write-Output "FEATURE_DIR: $($paths.FEATURE_DIR)"
    Write-Output "AVAILABLE_DOCS: $($docs -join ', ')"
}
