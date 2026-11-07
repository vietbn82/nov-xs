#!/usr/bin/env pwsh
# Create or reuse a Lean SpecKit feature slice directory and spec.md
[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$AllowExistingBranch,
    [switch]$DryRun,
    [string]$ShortName,
    [string]$Number = '',
    [switch]$Timestamp,
    [switch]$Help,
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$FeatureDescription
)
$ErrorActionPreference = 'Stop'

if ($Help) {
    Write-Output "Usage: ./create-new-feature.ps1 [-Json] [-DryRun] [-AllowExistingBranch] [-ShortName <name>] [-Number N] [-Timestamp] <feature description>"
    exit 0
}

$featureDesc = ($FeatureDescription -join ' ').Trim()
if ([string]::IsNullOrWhiteSpace($featureDesc)) {
    Write-Error "Error: Feature description is required."
    exit 1
}

. "$PSScriptRoot/common.ps1"
$repoRoot = Get-RepoRoot
$specsDir = Join-Path $repoRoot 'specs'

function ConvertTo-Slug([string]$Text) {
    $lower = $Text.ToLowerInvariant()
    $slug = ($lower -replace '[^a-z0-9]+', '-').Trim('-')
    if ([string]::IsNullOrWhiteSpace($slug)) { return 'feature' }
    return $slug
}

$branchSuffix = if (-not [string]::IsNullOrWhiteSpace($ShortName)) {
    ConvertTo-Slug $ShortName
} else {
    $words = ($featureDesc.ToLowerInvariant() -split '[^a-z0-9]+' | Where-Object { $_.Length -gt 2 } | Select-Object -First 4)
    ConvertTo-Slug ($words -join '-')
}

# Reuse existing feature directory when -AllowExistingBranch is set (idempotent re-runs)
$existingDir = $null
if ($AllowExistingBranch -and (Test-Path -LiteralPath $specsDir -PathType Container)) {
    $existingDir = Get-ChildItem -LiteralPath $specsDir -Directory |
        Where-Object { $_.Name -match "^(\d{3}|[0-9]{8}-[0-9]{6})-$([regex]::Escape($branchSuffix))$" } |
        Select-Object -First 1
}

if ($existingDir) {
    $branchName = $existingDir.Name
    $featureNum = ($branchName -split '-')[0]
    $featureDir = $existingDir.FullName
} else {
    if ($Timestamp) {
        $featureNum = (Get-Date).ToString('yyyyMMdd-HHmmss')
    } elseif (-not [string]::IsNullOrWhiteSpace($Number)) {
        $featureNum = '{0:000}' -f [int]$Number
    } else {
        $maxNum = 0
        if (Test-Path -LiteralPath $specsDir -PathType Container) {
            Get-ChildItem -LiteralPath $specsDir -Directory | ForEach-Object {
                if ($_.Name -match '^(\d{3})-') {
                    $n = [int]$matches[1]
                    if ($n -gt $maxNum) { $maxNum = $n }
                }
            }
        }
        $featureNum = '{0:000}' -f ($maxNum + 1)
    }
    $branchName = "$featureNum-$branchSuffix"
    $featureDir = Join-Path $specsDir $branchName
}

$specFile = Join-Path $featureDir 'spec.md'

if (-not $DryRun) {
    if ((Test-Path -LiteralPath $featureDir -PathType Container) -and -not $AllowExistingBranch) {
        Write-Error "Error: Feature directory '$featureDir' already exists."
        exit 1
    }
    New-Item -ItemType Directory -Path $featureDir -Force | Out-Null

    if (-not (Test-Path -LiteralPath $specFile -PathType Leaf)) {
        $content = Resolve-TemplateContent -TemplateName 'spec-template' -RepoRoot $repoRoot
        if ($null -ne $content) {
            $today = (Get-Date).ToString('yyyy-MM-dd')
            $content = $content.Replace('[FEATURE NAME]', $featureDesc).Replace('[###-feature-name]', $branchName).Replace('[DATE]', $today).Replace('$ARGUMENTS', $featureDesc)
            $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
            [System.IO.File]::WriteAllText($specFile, $content, $utf8NoBom)
        } else {
            New-Item -ItemType File -Path $specFile -Force | Out-Null
        }
    }

    if ($env:SPECIFY_FEATURE_NO_PERSIST -notin @('1', 'true')) {
        Save-FeatureJson -RepoRoot $repoRoot -FeatureDirectory $featureDir
    }
    $env:SPECIFY_FEATURE = $branchName
    $env:SPECIFY_FEATURE_DIRECTORY = $featureDir
}

if ($Json) {
    $obj = [PSCustomObject]@{
        BRANCH_NAME = $branchName
        SPEC_FILE   = $specFile
        FEATURE_NUM = $featureNum
    }
    if ($DryRun) { $obj | Add-Member -NotePropertyName 'DRY_RUN' -NotePropertyValue $true }
    $obj | ConvertTo-Json -Compress
} else {
    Write-Output "BRANCH_NAME: $branchName"
    Write-Output "SPEC_FILE: $specFile"
    Write-Output "FEATURE_NUM: $featureNum"
}
