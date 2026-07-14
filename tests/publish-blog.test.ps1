$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$script = Join-Path $root 'scripts/publish-blog.ps1'
$temp = Join-Path ([System.IO.Path]::GetTempPath()) "blog-publish-test-$PID"
$inbox = Join-Path $temp 'inbox'
$blog = Join-Path $temp 'blog'

try {
  New-Item -ItemType Directory -Force -Path $inbox, $blog | Out-Null
  Set-Content -LiteralPath (Join-Path $inbox 'draft.md') -Encoding utf8 -Value @'
---
title: 'Old title'
---
# New title

This is the generated description.

Body.
'@

  $env:FAKE_TODAY = '2026-07-13'
  & $script -Inbox $inbox -BlogDir $blog -SkipBuild -SkipGit -NoNotify
  if (-not $?) { throw 'Publishing script failed.' }

  $post = Join-Path $blog '2026-07-13-New title.md'
  if (-not (Test-Path -LiteralPath $post)) { throw 'Post was not generated.' }
  $content = [System.IO.File]::ReadAllText($post, [System.Text.UTF8Encoding]::new($false))
  $study = ([char]0x5b66).ToString() + ([char]0x4e60)
  foreach ($expected in @("title: 'New title'", "description: 'This is the generated description.'", "publishDate: '2026-07-13'", "tags: ['$study']", 'draft: false', '# New title')) {
    if (-not $content.Contains($expected)) { throw "Missing expected content: $expected" }
  }
  if ($content.Contains('Old title')) { throw 'Existing frontmatter was not removed.' }
  $published = ([char]0x5df2).ToString() + ([char]0x53d1) + ([char]0x5e03)
  if (Test-Path -LiteralPath (Join-Path $inbox 'draft.md')) { throw 'Draft was not archived.' }
  if (-not (Test-Path -LiteralPath (Join-Path (Join-Path (Split-Path -Parent $inbox) $published) 'draft.md'))) { throw 'Archived draft is missing.' }
  Write-Host 'PASS: publish-blog generates a valid post from a Typora draft.'
}
finally {
  Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
}
