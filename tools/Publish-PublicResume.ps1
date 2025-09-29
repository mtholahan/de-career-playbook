[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)]
  [string]$SourcePdf,              # e.g., 'Public Resume.pdf' in OneDrive\Career\Resumes\<Year>
  [int]$Year = (Get-Date).Year,    # default to current year
  [string]$Tag = ''                # optional, e.g. 'DataEng' -> Resume_DataEng_2025-09-28.pdf
)

$ErrorActionPreference = 'Stop'

# Where to read from (OneDrive) and write to (repo)
$srcDir  = Join-Path $env:OneDrive "Career\Resumes\$Year"
$srcPath = Join-Path $srcDir $SourcePdf

# Infer repo root from this script's location
$repoRoot = Split-Path -Parent $PSScriptRoot
$destDir  = Join-Path $repoRoot 'applications\resume-public'
New-Item -ItemType Directory -Force -Path $destDir | Out-Null

if (-not (Test-Path $srcPath)) {
  Write-Error "Source PDF not found: $srcPath"
  exit 1
}

# Build destination name
$stamp = Get-Date -Format 'yyyy-MM-dd'
$base  = 'Resume'
if ($Tag -and $Tag.Trim().Length -gt 0) { $base = "${base}_$Tag" }
$destPath = Join-Path $destDir ("{0}_{1}.pdf" -f $base, $stamp)

Copy-Item $srcPath $destPath -Force
Write-Host "Published: $destPath"
Write-Host "Reminder: commit the new file:"
Write-Host "  git add `"$([IO.Path]::GetFileName($destPath))`""
Write-Host "  git commit -m 'Publish resume $stamp'"
