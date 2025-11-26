<#
Fetch and show last 200 lines of logs for a GitHub Actions run.
Usage:
  # get latest run for current branch and download logs
  .\scripts\fetch-run-logs.ps1

  # download logs for a specific run id
  .\scripts\fetch-run-logs.ps1 -RunId 123456789

Notes:
  - Requires `gh` in PATH and authenticated (gh auth status).
  - PowerShell treats < and > as redirection, so pass numeric run id only.
#>

param(
    [long]$RunId,
    [int]$Tail = 200
)

Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path) | Out-Null
Set-Location ..\

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "gh CLI not found in PATH. Install GitHub CLI and run 'gh auth login' first.\nExample: run `winget install --id GitHub.cli -e` then `gh auth login`."
    exit 1
}

if (-not $RunId) {
    # determine current branch
    $branch = (git rev-parse --abbrev-ref HEAD).Trim()
    Write-Host "No run id supplied. Looking up latest run for branch: $branch"
    $json = gh run list --branch $branch --limit 1 --json database? 2>$null
    try {
        $obj = $json | ConvertFrom-Json
        if ($null -eq $obj -or $obj.Count -eq 0) {
            Write-Error "No runs found for branch $branch"
            exit 2
        }
        $RunId = $obj[0].id
    } catch {
        # fallback: parse first token from gh run list plain output
        $text = gh run list --branch $branch --limit 1 2>$null
        $firstLine = $text -split "\n" | Select-Object -First 1
        if ($firstLine -match "^(\d+)") { $RunId = [int]$matches[1] }
    }
}

if (-not $RunId) { Write-Error "Could not determine run id."; exit 3 }

Write-Host "Using run id: $RunId"

$outDir = Join-Path (Get-Location) "run-logs-$RunId"
Remove-Item $outDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Downloading run logs..."
gh run download $RunId --dir $outDir 2>$null

# if gh produced a zip
if (Test-Path "$outDir.zip") {
    Expand-Archive -LiteralPath "$outDir.zip" -DestinationPath $outDir -Force
}

if (-not (Test-Path $outDir)) { Write-Error "Download failed or no logs available for run $RunId"; exit 4 }

Write-Host "Logs saved to: $outDir"

$files = Get-ChildItem $outDir -Recurse -File | Where-Object { $_.Name -match '\.txt$' }
if ($files.Count -eq 0) {
    Write-Host "No *.txt step logs found. Listing all files:"; Get-ChildItem $outDir -Recurse | Select-Object FullName
    exit 0
}

Write-Host "Found step logs. Showing last $Tail lines for each (non-sensitive):`n"
foreach ($f in $files) {
    Write-Host "--- $($f.FullName) ---" -ForegroundColor Cyan
    Get-Content -Path $f.FullName -Tail $Tail | Out-String
}
