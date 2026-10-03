#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/nvim-modules.XXXXXX")
echo "Isolated test files: $tmp"
export HOME="$tmp/home" XDG_CONFIG_HOME="$tmp/config" XDG_DATA_HOME="$tmp/data"
export XDG_STATE_HOME="$tmp/state" XDG_CACHE_HOME="$tmp/cache"
unset NVIM_APPNAME VIMINIT EXINIT
mkdir -p "$HOME" "$XDG_CONFIG_HOME/nvim" "$tmp/work"
cp "$root/init.lua" "$XDG_CONFIG_HOME/nvim/"
cp "$root/nvim-pack-lock.json" "$XDG_CONFIG_HOME/nvim/"
cp -R "$root/lua" "$XDG_CONFIG_HOME/nvim/"
cd "$tmp/work"
scenarios=(startup discovery)
for scenario in "${scenarios[@]}"; do
  if [[ "$scenario" == discovery ]]; then
    printf '%s\n' 'return { plugins = { "plenary.nvim" }, setup = function() vim.g.discovery_probe = 1 end }' \
      > "$XDG_CONFIG_HOME/nvim/lua/features/discovery_probe.lua"
  fi
  log="$tmp/$scenario.log"
  if ! NVIM_TEST_SCENARIO="$scenario" nvim --headless -i NONE -u "$root/tests/smoke.lua" >"$log" 2>&1; then
    printf 'FAIL %s — see %s\n' "$scenario" "$log"
    exit 1
  fi
  printf 'PASS %s\n' "$scenario"
done
printf 'All %s scenarios passed. Temporary files retained at %s\n' "${#scenarios[@]}" "$tmp"
