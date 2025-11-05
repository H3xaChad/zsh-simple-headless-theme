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

1. `git clone https://github.com/H3xaChad/zsh-simple-headless-theme.git $ZSH_CUSTOM/themes/zsh-simple-headless-theme`
2. Set `ZSH_THEME="zsh-simple-headless-theme/simple-headless"` in `.zshrc`
3. Restart you shell