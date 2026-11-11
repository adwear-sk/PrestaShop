#!/usr/bin/env bash
# Run shot.mjs in the pinned Playwright image. Usage: shot.sh <outDir> <url> [url...]
# Local checkouts: http://localhost:8001 (main), http://wtN.localhost:80N1 (worktrees).
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
out="$(mkdir -p "$1" && cd "$1" && pwd)"; shift
cache="${HOME}/.cache/adwear-playwright"   # npm install of playwright is kept here between runs
mkdir -p "$cache"
cp "$here/shot.mjs" "$cache/shot.mjs"
docker run --rm --network host --ipc host -u "$(id -u):$(id -g)" -e HOME=/tmp -e HOST_OUT="$out" \
  -v "$cache:/work" -v "$out:/out" -w /work mcr.microsoft.com/playwright:v1.48.2-jammy \
  sh -c '[ -d node_modules/playwright ] || npm i --silent --no-save playwright@1.48.2 >/dev/null; node shot.mjs /out "$@"' sh "$@"
