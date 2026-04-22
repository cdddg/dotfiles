# THEME

Catppuccin colors live in many tool configs. There is no single source of truth
that all tools read at runtime — each tool consumes color in its own format.
This file is the human-readable index. When switching flavor, work through
every entry below.

## Flavor matrix

| File | Flavor | Form |
|---|---|---|
| `ghostty/config` | Mocha | `theme = Catppuccin Mocha` (flavor name) |
| `nvim/lua/lazy-deck/colorscheme.lua` | Mocha | `vim.cmd.colorscheme 'catppuccin-mocha'` (flavor name) |
| `kitty/kitty.conf` | Mocha | hardcoded hex — `tab_bar_background` only |
| `lsd/colors.yaml` | Mocha | hardcoded hex, every line has a semantic-name comment |
| `git/.gitconfig` | Mocha | RGB triplets in `pager = diffr …` (mixed: 3 catppuccin, 3 custom) |
| `nvim/lua/commands/lazy-outdated.lua` | Mocha | hardcoded hex highlight groups |
| `nvim/lua/commands/lazy-list.lua` | Mocha | hardcoded hex highlight groups |
| `zsh/.zshenv` | Mocha | hardcoded hex in `FZF_DEFAULT_OPTS --color=`, legend in file header |
| `tmux/.tmux.conf` | Macchiato | `@catppuccin_flavor 'macchiato'` (flavor name) |
| `k9s/config.yaml` | Macchiato | `skin: catppuccin-macchiato` (flavor name) |
| `.dotbot-scripts/install-catppuccin-kitty.sh` | (installer) | clones catppuccin/kitty theme |
| `.dotbot-scripts/install-catppuccin-k9s.sh` | (installer) | downloads catppuccin/k9s skin |

Two flavors are intentionally in use — Mocha for most editors/terminal, Macchiato
for tmux/k9s (slightly lighter, blends better with status-bar contexts).

## Finding all theme files

```bash
# Everything mentioning catppuccin
rg -li catppuccin --hidden -g '!.git/' -g '!.dotbot/'

# Mocha only
rg -l 'Catppuccin Mocha|catppuccin-mocha' --hidden -g '!.git/' -g '!.dotbot/'

# Macchiato only
rg -l 'Catppuccin Macchiato|catppuccin-macchiato|@catppuccin_flavor .macchiato' --hidden -g '!.git/' -g '!.dotbot/'
```

The convention every theme-related file follows:

- Files where catppuccin is an active config value (ghostty / nvim colorscheme /
  tmux / k9s): the value itself contains the flavor name, so grep finds them.
- Files with hardcoded hex: include the phrase `Catppuccin <Flavor>` in a comment
  so the same grep finds them.

## Switching flavor

For each file in the matrix:

1. **Flavor-name form** (rows marked "flavor name"): replace the flavor string
   in-place. For installer rows (`.dotbot-scripts/install-catppuccin-*.sh`),
   re-run them to fetch the new flavor's theme files.

2. **Hardcoded hex form**: every hex has a Catppuccin semantic name next to it
   in a comment (e.g. `# green`, `# surface0`). Replace each hex with the same
   semantic name from the target flavor. Palette reference:
   <https://catppuccin.com/palette>.

3. **Non-catppuccin colors (do NOT replace)**:
   - `kitty/kitty.conf`: `active_tab_background` `#e8cab3`, `inactive_tab_foreground`
     `#b3e8ca` — custom, kept intentionally.
   - `git/.gitconfig`: outer added/removed bg (`83,113,80` / `121,69,84`) and
     generic fg (`238,238,238`) in the diffr pager — manually-darkened variants
     for diff block backgrounds.
