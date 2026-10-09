# Claude Essential Skills

A hand-picked starter pack of **Agent Skills for Claude Code** — the ones worth installing on day one of a fresh Claude setup. One command installs them all, straight from each author's official GitHub repo.

This repo does **not** copy anyone's skills. It only holds a list ([`manifest.txt`](manifest.txt)) and two installer scripts that download the latest version from the original source. Credit and licenses stay with the original authors.

---

## Install in one line

**Windows (PowerShell)**

```powershell
irm https://raw.githubusercontent.com/Eaglecore97/claude-essential-skills/main/install.ps1 | iex
```

**Mac / Linux (Terminal)**

```bash
curl -fsSL https://raw.githubusercontent.com/Eaglecore97/claude-essential-skills/main/install.sh | bash
```

That installs the 3 default packs: **core + design + tiktok** (33 skills).
Then restart Claude Code (or open a new chat) and type `/skills` to see them.

**Requirements:** [Claude Code](https://claude.com/claude-code) and Git (`winget install Git.Git` on Windows, `xcode-select --install` on Mac).

---

## Choose your packs

| Pack | Default | What you get | Skills |
|---|---|---|---|
| `core` | ✅ | Word / PowerPoint / Excel / PDF files, posters, web artifacts, build your own skills, better prompts for any AI tool | 11 |
| `design` | ✅ | Websites, dashboards and slides that don't look AI-generated | 14 |
| `tiktok` | ✅ | 3-second hooks, captions, trend mapping, content plans, remove "AI voice" from scripts | 8 |
| `research` | — | Outlier posts, comment mining, competitor and ad-library teardowns, trends | 13 |
| `video` | — | Let Claude "watch" videos: frames, on-screen text, transcripts, Q&A with timestamps | 10 |

**Windows**

```powershell
# download first, then pick packs
git clone https://github.com/Eaglecore97/claude-essential-skills
cd claude-essential-skills
.\install.ps1 -Pack core,design,video     # choose packs
.\install.ps1 -All                        # everything
.\install.ps1 -List                       # preview only, installs nothing
.\install.ps1 -Force                      # update skills you already have
```

> If Windows blocks the script, run once: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

**Mac / Linux**

```bash
./install.sh core design video   # choose packs
./install.sh --all               # everything
./install.sh --list              # preview only
./install.sh --force             # update skills you already have
```

Skills you already have are **skipped**, never overwritten, unless you add `-Force` / `--force`.

---

## What's inside

### core — everyone needs these
| Skill | What it does | Source |
|---|---|---|
| `skill-creator` | Turn any repeated task into your own skill | [anthropics/skills](https://github.com/anthropics/skills) |
| `docx` `pptx` `xlsx` `pdf` | Create and edit real Office files and PDFs | [anthropics/skills](https://github.com/anthropics/skills) |
| `canvas-design` | Posters and visual art as PNG / PDF | [anthropics/skills](https://github.com/anthropics/skills) |
| `frontend-design` | Distinctive, production-grade web pages | [anthropics/skills](https://github.com/anthropics/skills) |
| `theme-factory` | Apply a consistent theme to slides, docs, pages | [anthropics/skills](https://github.com/anthropics/skills) |
| `web-artifacts-builder` | Multi-component React / Tailwind artifacts | [anthropics/skills](https://github.com/anthropics/skills) |
| `mcp-builder` | Build MCP servers to connect Claude to any app | [anthropics/skills](https://github.com/anthropics/skills) |
| `prompt-master` | Writes the right prompt for any AI tool (Midjourney, video AI, Cursor…) — saves credits | [nidhinjs/prompt-master](https://github.com/nidhinjs/prompt-master) |

### design — stop the "AI look"
| Skill | What it does | Source |
|---|---|---|
| `design-taste-frontend` (+ `-v1`) | Anti-slop rules for landing pages and redesigns | [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) |
| `high-end-visual-design` | Fonts, spacing, shadows that feel expensive | [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) |
| `minimalist-ui` / `industrial-brutalist-ui` / `stitch-design-taste` | Ready-made style directions | [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) |
| `gpt-taste` | Stricter variant with bold layouts and GSAP motion | [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) |
| `redesign-existing-projects` | Audit and upgrade an existing site | [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) |
| `image-to-code` / `imagegen-frontend-web` / `imagegen-frontend-mobile` | Design an image first, then build it | [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) |
| `brandkit` | Brand-guideline boards and logo systems | [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) |
| `full-output-enforcement` | Stops Claude from cutting long outputs short | [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) |
| `ui-ux-pro-max` | Searchable library of styles, palettes, font pairs, UX rules | [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) |

### tiktok — short-video copy
| Skill | What it does |
|---|---|
| `tt-hook-scripter` | The first 1–3 seconds: spoken line + on-screen text + opening visual |
| `tt-caption-writer` | Caption + 3–5 hashtags |
| `tt-humanizer` | Removes AI-sounding phrases from scripts and captions |
| `tt-trend-mapper` | Fit a trending sound or format to your niche |
| `tt-content-planner` / `tt-repurposer` / `tt-profile-optimizer` / `tt-audience-insights` | Weekly plan, repurposing, bio, audience |

Source: [sergebulaev/tiktok-skills](https://github.com/sergebulaev/tiktok-skills). Draft-only unless you add a Publora key yourself.

### research (optional) — needs a paid API key
13 skills such as `outlier-post-finder`, `comment-mining`, `competitor-social-research`, `ad-library-teardown`, `trend-discovery`, `creator-profile-teardown`.
Source: [ScrapeCreators/social-media-research-skills](https://github.com/ScrapeCreators/social-media-research-skills).
Set your key after installing: `SCRAPECREATORS_API_KEY` (get one at scrapecreators.com).

### video (optional) — needs Python 3.10+
10 skills such as `watch`, `watching-videos`, `asking-with-evidence`, `extracting-structure`.
Source: [oxbshw/watch-skill](https://github.com/oxbshw/watch-skill).
The installer also sets up the `watch-skill` Python package in `~/.watch-skill` and registers its MCP server with Claude Code.

---

## Tips

- **Update everything later:** run the installer again with `-Force` / `--force`.
- **Remove a skill:** delete its folder in `~/.claude/skills/`.
- **Safety:** skills are instructions Claude follows, and some include scripts. Everything here comes from public, widely used repos — still, skim a skill's `SKILL.md` before you rely on it for important work.
- **Add your own rules on top.** Generic skills don't know your brand or platform rules. Put those in your own `CLAUDE.md` or a private skill.

---

## 中文快速说明

给新 Claude 一键装好必备 skills。

1. 先装好 Claude Code 和 Git。
2. Windows 打开 PowerShell，粘贴：
   `irm https://raw.githubusercontent.com/Eaglecore97/claude-essential-skills/main/install.ps1 | iex`
3. 重启 Claude Code，输入 `/skills` 确认。

默认装 core + design + tiktok 三个包（33 个）。要全部装：下载仓库后运行 `.\install.ps1 -All`。research 包需要付费的 ScrapeCreators key，video 包需要 Python。

---

## Credits & license

All skills belong to their original authors and keep their original licenses — see each source repo. The installer scripts and list in this repo are MIT licensed.
