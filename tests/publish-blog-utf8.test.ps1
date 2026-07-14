$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$script = Join-Path $root 'scripts/publish-blog.ps1'
$temp = Join-Path ([System.IO.Path]::GetTempPath()) "blog-publish-utf8-$PID"
$inbox = Join-Path $temp 'inbox'
$blog = Join-Path $temp 'blog'
$title = ([char]0x4e2d).ToString() + ([char]0x6587)
$description = ([char]0x6d4b).ToString() + ([char]0x8bd5)

try {
  New-Item -ItemType Directory -Force -Path $inbox, $blog | Out-Null
  $draft = "# $title`n`n$description`n"
  [System.IO.File]::WriteAllText((Join-Path $inbox 'draft.md'), $draft, [System.Text.UTF8Encoding]::new($false))
  $env:FAKE_TODAY = '2026-07-14'
  & $script -Inbox $inbox -BlogDir $blog -SkipBuild -SkipGit -NoNotify
  if (-not $?) { throw 'Publishing script failed.' }
  $post = Get-ChildItem -LiteralPath $blog -File | Select-Object -First 1
  $content = [System.IO.File]::ReadAllText($post.FullName, [System.Text.UTF8Encoding]::new($false))
  if (-not $content.Contains("title: '$title'")) { throw 'UTF-8 title was corrupted.' }
  if (-not $content.Contains("description: '$description'")) { throw 'UTF-8 description was corrupted.' }
  Write-Host 'PASS: UTF-8 without BOM remains readable.'
}
finally {
  Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
}
