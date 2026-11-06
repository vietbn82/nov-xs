#!/usr/bin/env pwsh
# Protocol-Compliant Antigravity Hook Handler (Nov-XS)
# Reads JSON payload from stdin and guarantees valid JSON output on stdout.
[CmdletBinding()]
param(
    [ValidateSet('SessionStart', 'PostToolUse')]
    [string]$Event = 'PostToolUse'
)
$ErrorActionPreference = 'SilentlyContinue'

# Drain stdin JSON payload if piped
if ([Console]::IsInputRedirected) {
    $null = [Console]::In.ReadToEnd()
}

if ($Event -eq 'SessionStart') {
    $out = @{
        injectSteps = @(
            @{
                ephemeralMessage = "Nov-XS Lean SpecKit workspace active. Follow AGENTS.md and use .agents/skills/ (vibe-init, lean-slice, ai-slice, ui-dod-audit)."
            }
        )
    } | ConvertTo-Json -Compress -Depth 5
    [Console]::Out.Write($out)
    exit 0
}

# Default PostToolUse contract requires `{}` on stdout
[Console]::Out.Write('{}')
exit 0
