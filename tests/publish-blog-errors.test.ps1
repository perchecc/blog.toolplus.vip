$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$script = Join-Path $root 'scripts/publish-blog.ps1'
$temp = Join-Path ([System.IO.Path]::GetTempPath()) "blog-publish-errors-$PID"
$env:FAKE_TODAY = '2026-07-13'

function Assert-Rejected([string]$Name, [string]$Draft, [string]$ExistingPost = '') {
  $case = Join-Path $temp $Name
  $inbox = Join-Path $case 'inbox'
  $blog = Join-Path $case 'blog'
  New-Item -ItemType Directory -Force -Path $inbox, $blog | Out-Null
  $source = Join-Path $inbox 'draft.md'
  Set-Content -LiteralPath $source -Encoding utf8 -Value $Draft
  if ($ExistingPost) { Set-Content -LiteralPath (Join-Path $blog $ExistingPost) -Encoding utf8 -Value 'existing' }
  & powershell -NoProfile -ExecutionPolicy Bypass -File $script -Inbox $inbox -BlogDir $blog -SkipBuild -SkipGit -NoNotify
  if ($LASTEXITCODE -eq 0) { throw "$Name was accepted." }
  if (-not (Test-Path -LiteralPath $source)) { throw "$Name moved the rejected draft." }
  if ((Get-ChildItem -LiteralPath $blog -File).Count -ne $(if ($ExistingPost) { 1 } else { 0 })) { throw "$Name created a post." }
}

try {
  Assert-Rejected 'no-title' "Paragraph only."
  Assert-Rejected 'no-description' "# Title"
  Assert-Rejected 'long-title' ("# " + ('a' * 61) + "`n`nDescription.")
  Assert-Rejected 'duplicate' "# Existing`n`nDescription." '2026-07-13-Existing.md'
  Write-Host 'PASS: invalid drafts remain unpublished and in the inbox.'
}
finally {
  Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
}
