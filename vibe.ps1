#!/usr/bin/env pwsh
# Nov-XS 1-Word CLI:
#   ./vibe.ps1 new <AppName> [FirstSlice]   -> Scaffold app in current folder (or ../<AppName> with -Out)
#   ./vibe.ps1 slice <SliceName>            -> Add a new vertical slice + isolated UI component
#   ./vibe.ps1 run                          -> Run the .NET 10 app
#   ./vibe.ps1 check                        -> Run tests + Unbreakable UI audit
param(
    [Parameter(Position = 0)]
    [ValidateSet('new', 'slice', 'run', 'check', 'help')]
    [string]$Command = 'help',

    [Parameter(Position = 1)]
    [string]$Name = '',

    [Parameter(Position = 2)]
    [string]$SliceOrDesc = '',

    [switch]$Out
)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

switch ($Command) {
    'new' {
        if (-not $Name) { $Name = Read-Host "App Name (e.g. PulseNotes)" }
        $cleanName = ($Name -replace '[^a-zA-Z0-9]', '')
        $firstSlice = if ($SliceOrDesc) { $SliceOrDesc } else { 'Items' }
        $target = if ($Out) { Join-Path (Split-Path $root -Parent) $cleanName } else { $root }
        & "$root/.agents/skills/vibe-init/scripts/scaffold-project.ps1" `
            -ProjectName $cleanName `
            -FirstSlice $firstSlice `
            -Mission "$cleanName application" `
            -TargetRoot $target `
            -InitGit:$Out
    }
    'slice' {
        if (-not $Name) { $Name = Read-Host "Slice Name (e.g. Bookmarks)" }
        $desc = if ($SliceOrDesc) { $SliceOrDesc } else { "$Name feature slice" }
        & "$root/.agents/skills/lean-slice/scripts/new-slice.ps1" -SliceName $Name -Description $desc -TargetRoot $root
    }
    'run' {
        $proj = Get-ChildItem -Path "$root/src" -Filter "*.csproj" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $proj) { Write-Error "No app found yet. Run: ./vibe.ps1 new MyApp"; exit 1 }
        dotnet run --project $proj.FullName
    }
    'check' {
        & "$root/.agents/skills/ui-dod-audit/scripts/audit-dod.ps1" -TargetRoot $root
    }
    default {
        Write-Host "`n⚡ Nov-XS Vibe Commands:" -ForegroundColor Cyan
        Write-Host "  ./vibe.ps1 new MyApp          # Scaffold app right here"
        Write-Host "  ./vibe.ps1 new MyApp -Out     # Create ../MyApp with fresh Git repo"
        Write-Host "  ./vibe.ps1 slice Bookmarks    # Add a new feature slice + UI card"
        Write-Host "  ./vibe.ps1 run                # Start the web app"
        Write-Host "  ./vibe.ps1 check              # Run tests & UI anti-breakage check`n"
    }
}
