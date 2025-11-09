# Simple Headless ZSH Theme

Minimal ASCII-only prompt that just shows what you need.

## Features

- **Smart path shortening** - Long paths get truncated intelligently
- **Virtual env detection** - Python venv/conda environments 
- **Node project info** - Shows Node version in Node projects
- **Git status** - Branch + file stats on the right
- **Clean format** - `[user@host: /path]` with colors
- **Works everywhere** - Pure ASCII, any terminal/font

## What it looks like

![Screenshot](https://raw.githubusercontent.com/H3xaChad/zsh-simple-headless-theme/main/example.png)

## Installation

Requires zsh + Oh My Zsh.

1. `curl -L https://raw.githubusercontent.com/H3xaChad/zsh-simple-headless-theme/main/simple-headless.zsh-theme -o $ZSH_CUSTOM/themes/simple-headless.zsh-theme`
2. Set `ZSH_THEME="simple-headless"` in `.zshrc`
3. Restart your shell