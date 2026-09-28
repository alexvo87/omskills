#!/bin/sh
# Install the agentkit-lite bundle into Claude Code by symlinking its two skills and
# one agent.
#
# Usage: install.sh [--project] [--uninstall]
#   (default)    install into ${CLAUDE_CONFIG_DIR:-$HOME/.claude}
#   --project    install into ./.claude of the current directory instead
#   --uninstall  remove only the symlinks that point into this bundle
#
# Idempotent: a link that already points at this bundle is left as is. An existing
# entry that is not such a link (a real file or directory, or a symlink to somewhere
# else) is never overwritten; the script names it and exits 1 without changing
# anything.
set -eu

usage() {
  sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'
}

mode=install
scope=user
for arg in "$@"; do
  case "$arg" in
    --uninstall) mode=uninstall ;;
    --project) scope=project ;;
    -h|--help) usage; exit 0 ;;
    *) echo "install.sh: unknown argument: $arg" >&2; usage >&2; exit 2 ;;
  esac
done

bundle=$(cd "$(dirname "$0")" && pwd -P)
if [ "$scope" = project ]; then
  dest="$(pwd -P)/.claude"
else
  dest="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
fi

items="skills/ak-brainstorm skills/ak-plan agents/fullstack-developer.md"

for item in $items; do
  if [ ! -e "$bundle/$item" ]; then
    echo "install.sh: bundle is incomplete, missing $bundle/$item" >&2
    exit 1
  fi
done

if [ "$mode" = uninstall ]; then
  for item in $items; do
    link="$dest/$item"
    if [ -L "$link" ]; then
      case "$(readlink "$link")" in
        "$bundle"/*) rm "$link"; echo "removed   $link" ;;
        *) echo "kept      $link (symlink not owned by this bundle)" ;;
      esac
    elif [ -e "$link" ]; then
      echo "kept      $link (not a symlink)"
    else
      echo "absent    $link"
    fi
  done
  exit 0
fi

conflicts=0
for item in $items; do
  link="$dest/$item"
  if [ -L "$link" ]; then
    [ "$(readlink "$link")" = "$bundle/$item" ] && continue
    echo "install.sh: refusing to replace $link -> $(readlink "$link")" >&2
    conflicts=1
  elif [ -e "$link" ]; then
    echo "install.sh: refusing to overwrite existing non-symlink $link" >&2
    conflicts=1
  fi
done
if [ "$conflicts" -ne 0 ]; then
  echo "install.sh: nothing changed; move the entries above away and re-run" >&2
  exit 1
fi

mkdir -p "$dest/skills" "$dest/agents"
for item in $items; do
  link="$dest/$item"
  if [ -L "$link" ]; then
    echo "unchanged $link -> $bundle/$item"
  else
    ln -s "$bundle/$item" "$link"
    echo "linked    $link -> $bundle/$item"
  fi
done
