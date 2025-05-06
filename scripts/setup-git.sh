#!/usr/bin/env bash

set -e

# 設定預設編輯器為 nvim
git config --global core.editor nvim

# 設定 pager 為 diffr 並帶上各種顏色參數
git config --global core.pager "diffr \
  --line-numbers \
  --colors added:none:foreground:238,238,238:background:83,113,80 \
  --colors refine-added:none:foreground:69,71,90:background:166,227,161:bold \
  --colors removed:none:foreground:238,238,238:background:121,69,84 \
  --colors refine-removed:none:foreground:69,71,90:background:243,139,168:bold \
| less -R"

# 刪除所有已失聯（gone）的本地分支
git config --global alias.gone '!git fetch -p && \
  git for-each-ref --format "%(refname:short) %(upstream:track)" | \
  awk '\''$2 == "[gone]" {print $1}'\'' | \
  xargs -r git branch -D'

# 同步到遠端（需要安裝 hub）
git config --global alias.sync '!hub sync'

# 將目前 branch 重置到最根 commit
git config --global alias.hard-reset-branch-root '!f() { \
  git reset --hard "$(git rev-list --max-parents=0 HEAD)"; \
}; f'

# 在 tig 中檢視所有 dangling commit
git config --global alias.dangling-commits '!f() { \
  tig --all "$(git fsck --no-reflog | awk '\''/dangling commit/ {print $3}'\'')" ; \
}; f'
