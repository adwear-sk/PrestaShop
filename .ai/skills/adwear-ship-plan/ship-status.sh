#!/usr/bin/env bash
# List local commits not on the remote, and dirty trees, for the main repo and every nested
# Adwear repo (theme + custom modules). Read-only: fetches, never pushes.
# Usage: ship-status.sh [checkout-root]   (default: main checkout)
set -uo pipefail
root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"

report() {
  local dir="$1" label="$2" branch upstream ahead dirty
  branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null) || return
  git -C "$dir" fetch -q origin 2>/dev/null || echo "  (fetch failed for $label)"
  upstream="origin/$branch"
  git -C "$dir" rev-parse -q --verify "$upstream" >/dev/null || upstream="(no remote branch)"
  if [ "$upstream" = "(no remote branch)" ]; then ahead="?"; else ahead=$(git -C "$dir" rev-list --count "$upstream..HEAD"); fi
  dirty=$(git -C "$dir" status --porcelain | wc -l)
  [ "$ahead" = "0" ] && [ "$dirty" = "0" ] && return
  echo "== $label  [$branch → $upstream]  unpushed=$ahead  dirty=$dirty"
  [ "$ahead" != "0" ] && [ "$ahead" != "?" ] && git -C "$dir" log --format='   %h %s' "$upstream..HEAD"
  [ "$dirty" != "0" ] && git -C "$dir" status --short | sed 's/^/   ~ /' | head -15
}

report "$root" "main (adwear-sk/PrestaShop)"
for g in "$root"/themes/*/.git "$root"/modules/*/.git; do
  [ -d "$g" ] || continue
  d=$(dirname "$g"); report "$d" "${d#$root/}"
done
echo "-- done"
