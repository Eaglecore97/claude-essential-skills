#!/usr/bin/env bash
# Claude Essential Skills - Mac / Linux installer
# Installs hand-picked Agent Skills from their original GitHub repos into ~/.claude/skills
#
#   ./install.sh                     # core + design + tiktok
#   ./install.sh core video          # pick packs
#   ./install.sh --all               # every pack
#   ./install.sh --list              # show what would be installed
#   ./install.sh --force core        # overwrite skills you already have
#
# One-liner:
#   curl -fsSL https://raw.githubusercontent.com/Eaglecore97/claude-essential-skills/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/Eaglecore97/claude-essential-skills/main/install.sh | bash -s -- --all

set -euo pipefail

RAW_BASE="https://raw.githubusercontent.com/Eaglecore97/claude-essential-skills/main"
TARGET="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
FORCE=0; LIST=0; ALL=0; PACKS=()

for a in "$@"; do
  case "$a" in
    --force) FORCE=1 ;;
    --list)  LIST=1 ;;
    --all)   ALL=1 ;;
    *)       PACKS+=("$(echo "$a" | tr 'A-Z,' 'a-z ')") ;;
  esac
done
[ ${#PACKS[@]} -eq 0 ] && PACKS=(core design tiktok)
PACKS=($(echo "${PACKS[*]}"))

# --- load manifest (local copy first, otherwise from GitHub) ----------------------
HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo .)"
if [ -f "$HERE/manifest.txt" ]; then MANIFEST="$(cat "$HERE/manifest.txt")"
else MANIFEST="$(curl -fsSL "$RAW_BASE/manifest.txt")"; fi

ROWS="$(echo "$MANIFEST" | tr -d '\r' | grep -vE '^[[:space:]]*(#|$)' | sed 's/[[:space:]]*|[[:space:]]*/|/g; s/^[[:space:]]*//; s/[[:space:]]*$//')"
ALL_PACKS="$(echo "$ROWS" | cut -d'|' -f1 | awk '!s[$0]++' | tr '\n' ' ')"
[ $ALL -eq 1 ] && PACKS=($ALL_PACKS)

for p in "${PACKS[@]}"; do
  case " $ALL_PACKS " in *" $p "*) ;; *) echo "Unknown pack: $p. Available: $ALL_PACKS"; exit 1 ;; esac
done

SELECTED="$(echo "$ROWS" | while IFS='|' read -r pk repo path only; do
  for p in "${PACKS[@]}"; do if [ "$pk" = "$p" ]; then echo "$pk|$repo|$path|$only"; fi; done
done)"

if [ $LIST -eq 1 ]; then echo "$SELECTED" | column -t -s'|'; exit 0; fi
command -v git >/dev/null || { echo "Git is not installed. Install it first (Mac: xcode-select --install)."; exit 1; }

mkdir -p "$TARGET"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
COUNT=0

skill_name() {
  local n; n="$(head -15 "$1/SKILL.md" | sed -n 's/^name:[[:space:]]*//p' | head -1 | tr -d "\"'\r")"
  [ -n "$n" ] && echo "$n" || basename "$1"
}

install_dir() { # dir only
  local dir="$1" only="$2" name dest
  name="$(skill_name "$dir")"; dest="$TARGET/$name"
  if [ -e "$dest" ] && [ $FORCE -eq 0 ]; then echo "  skip     $name (already installed, use --force to update)"; return; fi
  rm -rf "$dest"; mkdir -p "$dest"
  if [ -n "$only" ]; then
    IFS=',' read -ra items <<< "$only"
    for i in "${items[@]}"; do i="$(echo "$i" | xargs)"; if [ -e "$dir/$i" ]; then cp -R "$dir/$i" "$dest/"; fi; done
  else
    cp -R "$dir/." "$dest/"; rm -rf "$dest/.git"
  fi
  echo "  ok       $name"; COUNT=$((COUNT+1))
}

for repo in $(echo "$SELECTED" | cut -d'|' -f2 | awk '!s[$0]++'); do
  echo; echo "== $repo"
  clone="$WORK/${repo//\//__}"
  git clone --depth 1 --quiet "https://github.com/$repo.git" "$clone" || { echo "  failed to download $repo"; continue; }
  while IFS='|' read -r pk r path only; do
    [ "$r" = "$repo" ] || continue
    if [[ "$path" == */\* ]]; then
      for d in "$clone/${path%/\*}"/*/; do if [ -f "$d/SKILL.md" ]; then install_dir "${d%/}" "$only"; fi; done
    else
      dir="$clone"; [ "$path" != "." ] && dir="$clone/$path"
      if [ -f "$dir/SKILL.md" ]; then install_dir "$dir" "$only"; else echo "  missing  $path (repo layout changed?)"; fi
    fi
  done <<< "$SELECTED"
done

# --- extra setup for packs that need more than files ------------------------------
if [[ " ${PACKS[*]} " == *" video "* ]]; then
  echo; echo "== watch-skill engine (Python)"
  if ! command -v python3 >/dev/null; then echo "  Python 3.10+ not found. Install it, then run again with: video"
  else
    VENV="$HOME/.watch-skill"
    [ -d "$VENV" ] || python3 -m venv "$VENV"
    "$VENV/bin/python" -m pip install -q -U "watch-skill[standard,ocr,whisper]"
    if command -v claude >/dev/null; then
      claude mcp add watch-skill --scope user -- "$VENV/bin/watch-skill" serve >/dev/null 2>&1 || true
      echo "  ok       watch-skill MCP registered"
    else
      echo "  Claude Code CLI not found. Register later with: claude mcp add watch-skill --scope user -- $VENV/bin/watch-skill serve"
    fi
  fi
fi

echo; echo "Done. $COUNT skill(s) installed to $TARGET"
[[ " ${PACKS[*]} " != *" research "* ]] || echo "Research pack needs a paid key: export SCRAPECREATORS_API_KEY=... (https://scrapecreators.com)"
echo "Restart Claude Code (or open a new chat) to load them. Type /skills to check."
