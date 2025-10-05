#!/usr/bin/env bash

set -e

# 清空所有現有的 git alias
git config --global --remove-section alias 2>/dev/null || true

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

# 將目前 branch 重置到與 parent branch 的分歧點
git config --global alias.reset-branch-start '!f() { \
    MODE=""; \
    BRANCH=""; \
    for arg in "$@"; do \
      case "$arg" in \
        --hard|--soft|--mixed) MODE="$arg" ;; \
        *) BRANCH="$arg" ;; \
      esac; \
    done; \
    if [ -z "$BRANCH" ]; then \
      echo "Usage: git reset-branch-start [--hard|--soft|--mixed] <parent-branch>"; \
      exit 1; \
    fi; \
    git reset $MODE $(git merge-base HEAD $BRANCH); \
  }; f'

# 將目前 branch 重置到最根 commit
git config --global alias.reset-to-root '!f() { \
    MODE=""; \
    for arg in "$@"; do \
      case "$arg" in \
        --hard|--soft|--mixed) MODE="$arg" ;; \
        *) echo "Usage: git reset-to-root [--hard|--soft|--mixed]"; exit 1 ;; \
      esac; \
    done; \
    git reset $MODE "$(git rev-list --max-parents=0 HEAD)"; \
  }; f'
