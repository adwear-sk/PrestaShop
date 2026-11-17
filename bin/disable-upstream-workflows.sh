#!/usr/bin/env bash
#
# Disable every upstream PrestaShop workflow on the adwear-sk/PrestaShop fork and
# keep only ours. Run after every upstream merge (version upgrade): merges bring
# upstream workflows back, and new ones arrive active.
#
#   bin/disable-upstream-workflows.sh
#
# Why: on 2026-11-17 GitHub disabled ALL Actions on the fork because 27 upstream
# workflows (nightly test crons and others) were active, which silently stopped
# deploy-prod until Actions was re-enabled in the repo's Actions tab. The files
# stay in the repo: deleting them would conflict on every upgrade merge.
#
set -euo pipefail

R=adwear-sk/PrestaShop
KEEP=" .github/workflows/deploy-prod.yml .github/workflows/base-image-check.yml .github/workflows/upstream-check.yml "

n=0
while read -r id path; do
  case "$KEEP" in *" $path "*) echo "keep  $path"; continue ;; esac
  gh workflow disable -R "$R" "$id" && n=$((n + 1)) && echo "off   $path"
done < <(gh api "repos/$R/actions/workflows" --paginate -q '.workflows[] | select(.state=="active") | "\(.id) \(.path)"')

echo "disabled: $n"
gh api "repos/$R/actions/workflows" --paginate -q '.workflows[] | select(.state=="active") | "active " + .path'
