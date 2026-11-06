#!/usr/bin/env pwsh
# Lean SpecKit Core PowerShell Library (Nov-XS)

function Find-SpecifyRoot {
    param([string]$StartDir = (Get-Location).Path)
    $resolved = Resolve-Path -LiteralPath $StartDir -ErrorAction SilentlyContinue
    $current = if ($resolved) { $resolved.Path } else { $null }
    while ($current) {
        if (Test-Path -LiteralPath (Join-Path $current '.specify') -PathType Container) {
            return $current
        }
        $parent = Split-Path $current -Parent
        if ([string]::IsNullOrEmpty($parent) -or $parent -eq $current) { break }
        $current = $parent
    }
    return $null
}

function Get-RepoRoot {
    param([switch]$ReturnNullOnError)
    if ($env:SPECIFY_INIT_DIR) {
        $resolved = Resolve-Path -LiteralPath $env:SPECIFY_INIT_DIR -ErrorAction SilentlyContinue
        if ($resolved -and (Test-Path -LiteralPath (Join-Path $resolved.Path '.specify') -PathType Container)) {
            return $resolved.Path.TrimEnd('/', '\')
        }
        [Console]::Error.WriteLine("ERROR: SPECIFY_INIT_DIR is not a valid SpecKit root: $($env:SPECIFY_INIT_DIR)")
        if ($ReturnNullOnError) { return $null }
        exit 1
    }
    $root = Find-SpecifyRoot
    if ($root) { return $root }
    return (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
}

function Save-FeatureJson {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$FeatureDirectory
    )
    $prefix = $RepoRoot + [System.IO.Path]::DirectorySeparatorChar
    if ($FeatureDirectory.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        $FeatureDirectory = $FeatureDirectory.Substring($prefix.Length)
    }
    $fjPath = Join-Path $RepoRoot '.specify/feature.json'
    $json = @{ feature_directory = $FeatureDirectory } | ConvertTo-Json -Compress
    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($fjPath, $json, $utf8NoBom)
}

function Get-FeaturePathsEnv {
    param([switch]$NoPersist, [switch]$ReturnNullOnError)
    $noPersistFlag = [bool]$NoPersist -or $env:SPECIFY_FEATURE_NO_PERSIST -in @('1', 'true')
    $repoRoot = Get-RepoRoot -ReturnNullOnError:$ReturnNullOnError
    if (-not $repoRoot) { return $null }

    $featureDir = $null
    $featureJson = Join-Path $repoRoot '.specify/feature.json'
    if ($env:SPECIFY_FEATURE_DIRECTORY) {
        $featureDir = if ([System.IO.Path]::IsPathRooted($env:SPECIFY_FEATURE_DIRECTORY)) {
            $env:SPECIFY_FEATURE_DIRECTORY
        } else {
            Join-Path $repoRoot $env:SPECIFY_FEATURE_DIRECTORY
        }
        if (-not $noPersistFlag) {
            Save-FeatureJson -RepoRoot $repoRoot -FeatureDirectory $env:SPECIFY_FEATURE_DIRECTORY
        }
    } elseif (Test-Path -LiteralPath $featureJson -PathType Leaf) {
        try {
            $cfg = (Get-Content -LiteralPath $featureJson -Raw -Encoding UTF8) | ConvertFrom-Json
            if ($cfg.feature_directory) {
                $featureDir = if ([System.IO.Path]::IsPathRooted($cfg.feature_directory)) {
                    $cfg.feature_directory
                } else {
                    Join-Path $repoRoot $cfg.feature_directory
                }
            }
        } catch {}
    }

    if (-not $featureDir) {
        [Console]::Error.WriteLine('ERROR: Feature directory not found. Run create-new-feature.ps1 or set SPECIFY_FEATURE_DIRECTORY.')
        if ($ReturnNullOnError) { return $null }
        exit 1
    }

    $currentBranch = if ($env:SPECIFY_FEATURE) { $env:SPECIFY_FEATURE } else { Split-Path -Leaf ($featureDir.TrimEnd('/', '\')) }

    [PSCustomObject]@{
        REPO_ROOT     = $repoRoot
        CURRENT_BRANCH = $currentBranch
        FEATURE_DIR   = $featureDir
        FEATURE_SPEC  = Join-Path $featureDir 'spec.md'
        IMPL_PLAN     = Join-Path $featureDir 'plan.md'
        TASKS         = Join-Path $featureDir 'tasks.md'
        CHECKLIST     = Join-Path $featureDir 'checklist.md'
    }
}

function Resolve-Template {
    param(
        [Parameter(Mandatory = $true)][string]$TemplateName,
        [Parameter(Mandatory = $true)][string]$RepoRoot
    )
    if ($TemplateName -cnotmatch '^[a-z0-9-]+$') { return $null }
    $base = Join-Path $RepoRoot '.specify/templates'
    $override = Join-Path $base "overrides/$TemplateName.md"
    if (Test-Path -LiteralPath $override -PathType Leaf) { return $override }
    $core = Join-Path $base "$TemplateName.md"
    if (Test-Path -LiteralPath $core -PathType Leaf) { return $core }
    return $null
}

function Resolve-TemplateContent {
    param(
        [Parameter(Mandatory = $true)][string]$TemplateName,
        [Parameter(Mandatory = $true)][string]$RepoRoot
    )
    $path = Resolve-Template -TemplateName $TemplateName -RepoRoot $RepoRoot
    if (-not $path) { return $null }
    return [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
}
