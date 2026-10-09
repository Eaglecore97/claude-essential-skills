# Claude Essential Skills - Windows installer
# Installs hand-picked Agent Skills from their original GitHub repos into ~/.claude/skills
#
#   .\install.ps1                         # core + design + tiktok
#   .\install.ps1 -Pack core,video        # pick packs
#   .\install.ps1 -All                    # every pack
#   .\install.ps1 -List                   # show what would be installed
#   .\install.ps1 -Force                  # overwrite skills you already have
#
# One-liner (no download needed):
#   irm https://raw.githubusercontent.com/Eaglecore97/claude-essential-skills/main/install.ps1 | iex

param(
    [string[]]$Pack = @('core', 'design', 'tiktok'),
    [switch]$All,
    [switch]$Force,
    [switch]$List,
    [string]$Target = (Join-Path $HOME '.claude\skills')
)

$ErrorActionPreference = 'Stop'
$RawBase = 'https://raw.githubusercontent.com/Eaglecore97/claude-essential-skills/main'

function Say($msg, $color = 'Gray') { Write-Host $msg -ForegroundColor $color }

# --- load manifest (local copy first, otherwise from GitHub) ----------------------
$manifestPath = $null
if ($PSScriptRoot) { $manifestPath = Join-Path $PSScriptRoot 'manifest.txt' }
if ($manifestPath -and (Test-Path $manifestPath)) {
    $manifestText = Get-Content $manifestPath -Raw -Encoding UTF8
} else {
    $manifestText = (Invoke-WebRequest "$RawBase/manifest.txt" -UseBasicParsing).Content
}

$rows = @()
foreach ($line in ($manifestText -split "`r?`n")) {
    $t = $line.Trim()
    if (-not $t -or $t.StartsWith('#')) { continue }
    $c = $t -split '\|' | ForEach-Object { $_.Trim() }
    $only = @()
    if ($c.Count -ge 4 -and $c[3]) { $only = $c[3] -split ',' | ForEach-Object { $_.Trim() } }
    $rows += [pscustomobject]@{ Pack = $c[0]; Repo = $c[1]; Path = $c[2]; Only = $only }
}

$allPacks = $rows | Select-Object -ExpandProperty Pack -Unique
if ($All) { $Pack = $allPacks }
$Pack = $Pack | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim().ToLower() } | Where-Object { $_ }
$bad = $Pack | Where-Object { $allPacks -notcontains $_ }
if ($bad) { throw "Unknown pack: $($bad -join ', '). Available: $($allPacks -join ', ')" }

$selected = $rows | Where-Object { $Pack -contains $_.Pack }

if ($List) {
    $selected | Format-Table Pack, Repo, Path -AutoSize
    return
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Say 'Git is not installed. Install it first:  winget install --id Git.Git -e' 'Red'
    return
}

New-Item -ItemType Directory -Force -Path $Target | Out-Null
$work = Join-Path ([IO.Path]::GetTempPath()) ("ces-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Force -Path $work | Out-Null

function Get-SkillName($dir) {
    $md = Join-Path $dir 'SKILL.md'
    foreach ($l in (Get-Content $md -Encoding UTF8 -TotalCount 15)) {
        if ($l -match '^name:\s*(.+)$') { return $Matches[1].Trim().Trim('"', "'") }
    }
    return Split-Path $dir -Leaf
}

function Install-SkillDir($dir, $only) {
    $name = Get-SkillName $dir
    $dest = Join-Path $Target $name
    if ((Test-Path $dest) -and -not $Force) { Say "  skip     $name (already installed, use -Force to update)" 'DarkGray'; return 0 }
    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    $items = if ($only.Count) { $only | ForEach-Object { Join-Path $dir $_ } } else { Get-ChildItem $dir -Force | Where-Object { $_.Name -ne '.git' } | ForEach-Object { $_.FullName } }
    foreach ($i in $items) { if (Test-Path $i) { Copy-Item $i $dest -Recurse -Force } }
    Say "  ok       $name" 'Green'
    return 1
}

$count = 0
try {
    foreach ($group in ($selected | Group-Object Repo)) {
        $repo = $group.Name
        Say "`n== $repo" 'Yellow'
        $clone = Join-Path $work ($repo -replace '/', '__')
        git clone --depth 1 --quiet "https://github.com/$repo.git" $clone 2>$null
        if (-not (Test-Path $clone)) { Say "  failed to download $repo" 'Red'; continue }
        foreach ($row in $group.Group) {
            if ($row.Path.EndsWith('/*')) {
                $base = Join-Path $clone ($row.Path.TrimEnd('*').TrimEnd('/'))
                foreach ($d in (Get-ChildItem $base -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') })) {
                    $count += Install-SkillDir $d.FullName $row.Only
                }
            } else {
                $dir = if ($row.Path -eq '.') { $clone } else { Join-Path $clone $row.Path }
                if (Test-Path (Join-Path $dir 'SKILL.md')) { $count += Install-SkillDir $dir $row.Only }
                else { Say "  missing  $($row.Path) (repo layout changed?)" 'Red' }
            }
        }
    }
} finally {
    Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
}

# --- extra setup for packs that need more than files ------------------------------
if ($Pack -contains 'video') {
    Say "`n== watch-skill engine (Python)" 'Yellow'
    $py = Get-Command python -ErrorAction SilentlyContinue
    if (-not $py) { Say '  Python 3.10+ not found. Install it (winget install Python.Python.3.12), then run this again with -Pack video.' 'Red' }
    else {
        $venv = Join-Path $HOME '.watch-skill'
        if (-not (Test-Path $venv)) { & python -m venv $venv }
        & (Join-Path $venv 'Scripts\python.exe') -m pip install -q -U 'watch-skill[standard,ocr,whisper]'
        $exe = Join-Path $venv 'Scripts\watch-skill.exe'
        if (Get-Command claude -ErrorAction SilentlyContinue) {
            & claude mcp add watch-skill --scope user -- $exe serve 2>$null
            Say '  ok       watch-skill MCP registered' 'Green'
        } else {
            Say "  Claude Code CLI not found. Register later with:  claude mcp add watch-skill --scope user -- `"$exe`" serve" 'Yellow'
        }
    }
}

Say "`nDone. $count skill(s) installed to $Target" 'Cyan'
if ($Pack -contains 'research') { Say 'Research pack needs a paid key: set SCRAPECREATORS_API_KEY (https://scrapecreators.com)' 'Yellow' }
Say 'Restart Claude Code (or open a new chat) to load them. Type /skills to check.' 'Cyan'
