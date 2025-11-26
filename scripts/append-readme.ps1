<#
Append contents of README_APPEND.md to README.md safely.
Usage:
  Set-Location C:\Users\Administrator\muse-bob
  .\scripts\append-readme.ps1

This script will:
  - Check that README.md exists (will create if missing)
  - Append a separator and the contents of README_APPEND.md to README.md
  - Show a short preview of the appended lines
#>

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root\..\

$appendFile = Join-Path (Get-Location) 'README_APPEND.md'
$readme = Join-Path (Get-Location) 'README.md'

if (-not (Test-Path $appendFile)) {
    Write-Error "Append file not found: $appendFile"
    exit 1
}

if (-not (Test-Path $readme)) {
    Write-Host "README.md not found — creating new file."
    New-Item -Path $readme -ItemType File -Force | Out-Null
}

Write-Host "Appending $appendFile -> $readme"
Add-Content -Path $readme -Value "`n---`n" -Encoding UTF8
Get-Content -Path $appendFile -Encoding UTF8 | Add-Content -Path $readme -Encoding UTF8

Write-Host "Append complete. Preview of appended content:"
Get-Content -Path $readme -Tail 60 | ForEach-Object { Write-Host $_ }

Write-Host "If this looks good, commit the change:"
Write-Host "  git add README.md" -ForegroundColor Green
Write-Host "  git commit -m 'docs: append repository hygiene notes to README'" -ForegroundColor Green
