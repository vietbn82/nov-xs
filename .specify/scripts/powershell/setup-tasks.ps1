#!/usr/bin/env pwsh
# Setup tasks.md for the active feature slice
[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$Help
)
$ErrorActionPreference = 'Stop'

if ($Help) {
    Write-Output "Usage: ./setup-tasks.ps1 [-Json] [-Help]"
    exit 0
}

. "$PSScriptRoot/common.ps1"
$paths = Get-FeaturePathsEnv -ReturnNullOnError
if (-not $paths) { exit 1 }

if (-not (Test-Path -LiteralPath $paths.FEATURE_SPEC -PathType Leaf)) {
    [Console]::Error.WriteLine("ERROR: spec.md not found in $($paths.FEATURE_DIR)")
    exit 1
}
if (-not (Test-Path -LiteralPath $paths.IMPL_PLAN -PathType Leaf)) {
    [Console]::Error.WriteLine("ERROR: plan.md not found in $($paths.FEATURE_DIR)")
    exit 1
}

$tasksTemplate = Resolve-Template -TemplateName 'tasks-template' -RepoRoot $paths.REPO_ROOT
$tasksTemplateContent = Resolve-TemplateContent -TemplateName 'tasks-template' -RepoRoot $paths.REPO_ROOT
if ([string]::IsNullOrEmpty($tasksTemplateContent)) {
    [Console]::Error.WriteLine("ERROR: tasks-template.md not found.")
    exit 1
}

if (-not (Test-Path -LiteralPath $paths.TASKS -PathType Leaf)) {
    $content = $tasksTemplateContent.Replace('[###-feature-name]', $paths.CURRENT_BRANCH)
    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($paths.TASKS, $content, $utf8NoBom)
}

$docs = @('spec.md', 'plan.md')
if (Test-Path -LiteralPath $paths.TASKS -PathType Leaf) { $docs += 'tasks.md' }
if (Test-Path -LiteralPath $paths.CHECKLIST -PathType Leaf) { $docs += 'checklist.md' }

if ($Json) {
    [PSCustomObject]@{
        FEATURE_DIR            = $paths.FEATURE_DIR
        AVAILABLE_DOCS         = $docs
        TASKS_TEMPLATE         = $tasksTemplate
        TASKS_TEMPLATE_CONTENT = $tasksTemplateContent
    } | ConvertTo-Json -Compress
} else {
    Write-Output "FEATURE_DIR: $($paths.FEATURE_DIR)"
    Write-Output "TASKS: $($paths.TASKS)"
    Write-Output "AVAILABLE_DOCS: $($docs -join ', ')"
}
