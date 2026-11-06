#!/usr/bin/env pwsh
# Automated 4-Point Definition of Done (DoD) & Token Purity Auditor (Nov-XS)
[CmdletBinding()]
param(
    [string]$TargetRoot = '',
    [switch]$SkipTests,
    [switch]$Json
)
$ErrorActionPreference = 'Stop'

$repoRoot = if ($TargetRoot) {
    (Resolve-Path -LiteralPath $TargetRoot).Path
} else {
    (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../..')).Path
}

$violations = [System.Collections.Generic.List[string]]::new()

# 1. Scan wwwroot/ (excluding tokens.css) for hardcoded hex colors, px font sizes, and raw z-index
$webFiles = Get-ChildItem -Path (Join-Path $repoRoot 'src') -Recurse -File -Include *.css, *.html, *.js -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -ne 'tokens.css' -and $_.FullName -like '*wwwroot*' }

foreach ($file in $webFiles) {
    $lines = Get-Content -LiteralPath $file.FullName
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match '#[0-9a-fA-F]{3,8}\b' -and $line -notmatch '^\s*(//|/\*|\*)') {
            $violations.Add("Token Violation (Hex Color) in $($file.Name):$($i + 1) -> $($line.Trim())")
        }
        if ($line -match 'font-size\s*:\s*\d+(\.\d+)?px') {
            $violations.Add("Token Violation (Pixel Font Size) in $($file.Name):$($i + 1) -> $($line.Trim())")
        }
        if ($line -match 'z-index\s*:\s*\d+' -and $line -notmatch 'var\(--z-') {
            $violations.Add("Top-Layer Violation (Hardcoded z-index) in $($file.Name):$($i + 1) -> $($line.Trim())")
        }
    }
}

# 2. Scan for accidental secret / API key leaks
$codeFiles = Get-ChildItem -Path $repoRoot -Recurse -File -Include *.cs, *.json, *.js, *.html -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\(bin|obj|\.git)\\' }

foreach ($file in $codeFiles) {
    $raw = [System.IO.File]::ReadAllText($file.FullName)
    if ($raw -match 'AIza[0-9A-Za-z\-_]{35}' -or $raw -match 'sk-[A-Za-z0-9]{24,}') {
        $violations.Add("Security Violation (Potential API Key Leak) in $($file.FullName)")
    }
}

# 3. Run dotnet test if a solution exists and -SkipTests is not set
$testsPassed = $true
$slnFile = Get-ChildItem -LiteralPath $repoRoot -File -Filter *.sln* -ErrorAction SilentlyContinue | Select-Object -First 1
if ($slnFile -and -not $SkipTests) {
    & dotnet test $slnFile.FullName --nologo --verbosity quiet
    if ($LASTEXITCODE -ne 0) {
        $testsPassed = $false
        $violations.Add("Automated Test Suite Failed: dotnet test returned exit code $LASTEXITCODE")
    }
}

$passed = ($violations.Count -eq 0) -and $testsPassed

if ($Json) {
    [PSCustomObject]@{
        Passed     = $passed
        TestsRun   = [bool]($slnFile -and -not $SkipTests)
        Violations = $violations
    } | ConvertTo-Json -Compress
} else {
    if ($passed) {
        Write-Output "✅ DoD Gate Audit PASSED (0 token/z-index/secret violations; tests green)."
    } else {
        Write-Output "❌ DoD Gate Audit FAILED ($($violations.Count) violation(s)):"
        foreach ($v in $violations) {
            Write-Output "  - $v"
        }
    }
}

if (-not $passed) { exit 1 }
