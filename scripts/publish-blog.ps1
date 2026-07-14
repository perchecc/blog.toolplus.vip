param(
  [string]$Inbox,
  [string]$BlogDir,
  [switch]$SkipBuild,
  [switch]$SkipGit,
  [switch]$NoNotify
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$waiting = ([char]0x5f85).ToString() + ([char]0x53d1) + ([char]0x5e03)
$published = ([char]0x5df2).ToString() + ([char]0x53d1) + ([char]0x5e03)
$study = ([char]0x5b66).ToString() + ([char]0x4e60)
$utf8 = [System.Text.UTF8Encoding]::new($false)

if (-not $Inbox) { $Inbox = Join-Path $root (Join-Path 'content-inbox' $waiting) }
if (-not $BlogDir) { $BlogDir = Join-Path $root 'src/content/blog' }
$archive = Join-Path (Split-Path -Parent $Inbox) $published
New-Item -ItemType Directory -Force -Path $Inbox, $archive | Out-Null

function Fail([string]$Message) {
  Write-Host "ERROR: $Message" -ForegroundColor Red
  exit 1
}

function Get-Description([string]$Content, [int]$Start) {
  $lines = $Content.Substring($Start) -split "`r?`n"
  $paragraph = New-Object System.Collections.Generic.List[string]
  $started = $false
  foreach ($line in $lines) {
    $text = $line.Trim()
    if (-not $text) {
      if ($started) { break }
      continue
    }
    $started = $true
    $paragraph.Add($text)
  }
  $description = ($paragraph -join ' ') -replace '\s+', ' '
  if ($description.Length -gt 160) { $description = $description.Substring(0, 160) }
  return $description
}

function Remove-Frontmatter([string]$Content) {
  return [regex]::Replace($Content, '\A(?:\uFEFF)?---\r?\n.*?\r?\n---\r?\n?', '', [System.Text.RegularExpressions.RegexOptions]::Singleline)
}

$drafts = @(Get-ChildItem -LiteralPath $Inbox -File -Filter '*.md' -ErrorAction SilentlyContinue)
if (-not $drafts.Count) {
  Write-Host 'No Markdown drafts found.'
  exit 0
}

$date = if ($env:FAKE_TODAY) { $env:FAKE_TODAY } else { Get-Date -Format 'yyyy-MM-dd' }
$posts = foreach ($draft in $drafts) {
  $body = Remove-Frontmatter ([System.IO.File]::ReadAllText($draft.FullName, $utf8))
  $heading = [regex]::Match($body, '(?m)^\s*#\s+(.+?)\s*$')
  if (-not $heading.Success) { Fail "$($draft.Name): first-level heading (# title) is required." }
  $title = $heading.Groups[1].Value.Trim()
  if ($title.Length -gt 60) { Fail "$($draft.Name): title exceeds 60 characters." }
  $description = Get-Description $body ($heading.Index + $heading.Length)
  if (-not $description) { Fail "$($draft.Name): the first paragraph after the title is required." }
  $safeTitle = ($title -replace '[\\/:*?"<>|]', '-').Trim(' ', '.')
  if (-not $safeTitle) { Fail "$($draft.Name): title cannot form a file name." }
  $target = Join-Path $BlogDir "$date-$safeTitle.md"
  if (Test-Path -LiteralPath $target) { Fail "$($draft.Name): target article already exists." }
  [pscustomobject]@{ Draft = $draft; Body = $body; Title = $title; Description = $description; Target = $target }
}

New-Item -ItemType Directory -Force -Path $BlogDir | Out-Null
$created = New-Object System.Collections.Generic.List[string]
try {
  foreach ($post in $posts) {
    $title = $post.Title.Replace("'", "''")
    $description = $post.Description.Replace("'", "''")
    $frontmatter = "---`ntitle: '$title'`ndescription: '$description'`npublishDate: '$date'`ntags: ['$study']`ndraft: false`n---`n`n"
    [System.IO.File]::WriteAllText($post.Target, $frontmatter + $post.Body.TrimStart(), $utf8)
    $created.Add($post.Target)
  }

  if (-not $SkipBuild) {
    if (Get-Command bun -ErrorAction SilentlyContinue) {
      & bun run build
      if ($LASTEXITCODE -ne 0) { throw 'Build failed.' }
    }
    else {
      if (-not (Test-Path -LiteralPath (Join-Path $root 'node_modules'))) {
        Write-Host 'Installing project dependencies (first run only)...'
        & npm.cmd install --package-lock=false
        if ($LASTEXITCODE -ne 0) { throw 'Dependency installation failed.' }
      }
      & npx.cmd astro check
      if ($LASTEXITCODE -ne 0) { throw 'Check failed.' }
      & npx.cmd astro build
      if ($LASTEXITCODE -ne 0) { throw 'Build failed.' }
    }
  }

  if (-not $SkipGit) {
    $relativeTargets = $created | ForEach-Object { Resolve-Path -Relative $_ }
    & git add -- $relativeTargets
    if ($LASTEXITCODE -ne 0) { throw 'Git add failed.' }
    & git commit -m ("post: " + (($posts | ForEach-Object Title) -join ', '))
    if ($LASTEXITCODE -ne 0) { throw 'Git commit failed.' }
    & git push origin master
    if ($LASTEXITCODE -ne 0) { throw 'Git push failed.' }
  }
}
catch {
  foreach ($file in $created) { Remove-Item -LiteralPath $file -Force -ErrorAction SilentlyContinue }
  Fail $_.Exception.Message
}

foreach ($post in $posts) { Move-Item -LiteralPath $post.Draft.FullName -Destination $archive }
if (-not $NoNotify) {
  Add-Type -AssemblyName System.Windows.Forms
  [System.Windows.Forms.MessageBox]::Show('Blog post pushed successfully.', 'Blog Publisher') | Out-Null
}
Write-Host 'Published successfully.' -ForegroundColor Green
exit 0
