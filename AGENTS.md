# Agent Onboarding Guide

This document helps LLM agents quickly understand and work with this dotfiles repository.

## Repository Overview

Personal dotfiles configuration for **Bardia Keyoumarsi** - a Ruby/Go developer at EasyPost working primarily on macOS.

### Core Philosophy
- **Keyboard-driven workflows** with heavy FZF integration
- **Development-focused** with Ruby/Go toolchain optimization  
- **Terminal-centric** environment using bash, vim/neovim, tmux
- **Modular installation** via Makefile with symbolic links

## Repository Structure

```
dotfiles/
├── bash/           # Shell configuration
│   ├── alias       # Custom aliases and functions
│   ├── bashrc      # Shell settings and prompt
│   ├── bash_profile # Profile loader
│   └── install_fzf.sh # FZF installer
├── nvim/           # Modern Neovim config (Lua-based)
│   ├── init.lua    # Entry point
│   ├── vimrc.vim   # Shared vim settings
│   └── lua/        # Lua configuration modules
├── vim/            # Legacy Vim config
│   ├── vimrc       # Full vim configuration
│   ├── plugins.txt # Plugin list
│   └── setup_plugins.sh # Plugin installer
├── git/            # Git configuration
│   ├── gitconfig   # Main git settings
│   ├── gitcommit   # Commit template
│   └── gitignore   # Global ignore patterns
├── tmux/           # Terminal multiplexer
│   └── tmux.conf   # Tmux settings
├── qute/           # Qutebrowser config
│   └── config.py   # Browser settings
├── etc/            # Additional completions
│   └── bash_completion.d/
├── macos/          # macOS-specific files
│   ├── profile.terminal # Terminal.app profile
│   └── tools.txt   # Tool list
├── Makefile        # Installation orchestrator
└── .gitignore      # Repository ignore patterns
```

## Key Technologies & Tools

### Primary Stack
- **Shell**: Bash with custom prompt and extensive aliases
- **Editor**: Neovim (primary) + Vim (fallback) 
- **Multiplexer**: Tmux with TPM plugins
- **Fuzzy Finder**: FZF (heavily integrated)
- **Languages**: Ruby, Go (with dedicated tooling)
- **Git**: Enhanced with aliases and auto-completion

### Notable Integrations
- **FZF**: File finding, process killing, directory navigation
- **fd**: Modern find replacement 
- **ripgrep**: Fast grep alternative
- **Lazy.nvim**: Modern Neovim plugin manager
- **Treesitter**: Syntax highlighting for Go/Ruby/others

## Installation System

The Makefile provides modular installation:

```bash
make all        # Install everything
make bash       # Shell configuration only  
make nvim       # Neovim setup only
make git        # Git configuration only
make tmux       # Tmux setup only
make vim        # Legacy vim setup
make clean      # Remove all symlinks
```

**Installation Method**: Creates symbolic links from `$HOME` to repo files, preserving the ability to version control changes.

## Key Configurations

### Bash Prompt
Two-line git-aware prompt showing:
```
┌─[14:30:25]─[user@hostname]─[/current/working/directory] (main*+?)
└─$ 
```
- `*` = unstaged changes
- `+` = staged changes  
- `?` = untracked files

### Notable Aliases
```bash
# Git shortcuts
g="git", gs="git status", gl="git log"

# Navigation  
..="cd ../", ...="cd ../../" (up to .6)

# Development
be="bundle exec", r="be rspec", nv="nvim"

# FZF integrations
kp()    # Kill processes with fuzzy finder
f()     # File preview with bat/cat
zd()    # Fuzzy directory navigation
```

### Editor Setup
- **Neovim**: Modern Lua config with Lazy.nvim, Treesitter, LSP-ready
- **Vim**: Traditional vimrc with manual plugin management
- **Shared**: Common settings in `nvim/vimrc.vim`
- **Languages**: Optimized for Ruby (RSpec, bundler) and Go (vim-go)

## Development Workflow Context

### Ruby Development
- Uses `bundle exec` extensively (aliased as `be`)
- RSpec testing with `r` alias
- Guard integration for file watching
- Minitest support with `mt` alias

### Go Development  
- vim-go plugin with GoImports on save
- Test running with `<leader>t`
- Build shortcuts with `<leader>b`
- Quickfix integration

### Git Workflow
- Branch-per-feature with username prefixes (`nb` alias)
- Comprehensive status checking in prompt
- Enhanced diff settings (histogram algorithm)
- Auto-pruning of remote branches

## Agent Guidelines

### When Making Changes
1. **Preserve existing workflows** - this is a daily-use environment
2. **Test on macOS** - primary platform (check `$OSTYPE` conditions)  
3. **Maintain symbolic link structure** - don't break the installation system
4. **Consider performance** - prompt functions run on every command
5. **Follow existing patterns** - especially color schemes and alias naming

### Common Tasks
- **Adding aliases**: Edit `bash/alias` 
- **Modifying prompt**: Edit the `git_prompt_info()` function in `bash/bashrc`
- **Neovim plugins**: Add to `nvim/lua/plugins/` directory
- **Git settings**: Modify `git/gitconfig`
- **Installation steps**: Update `Makefile`

### Testing Changes
```bash
# Test specific components
make clean && make bash    # Test shell changes
source ~/.bashrc           # Reload shell config  
nvim                       # Test editor config
```

### Troubleshooting Areas
- **Git prompt performance** in large repositories
- **FZF integration** with fd/ripgrep dependencies  
- **Plugin conflicts** between vim and neovim
- **macOS-specific** paths and behaviors

## Recent Optimizations

The following improvements were recently made:
- Fixed `pruneTags` typo in git config
- Added Go/Ruby parsers to Treesitter
- Enhanced error handling in installation scripts
- Replaced undefined `bundle-hack` functions with standard `bundle` commands
- Upgraded to comprehensive git-aware two-line prompt

---

**Last Updated**: December 2024  
**Primary User**: Bardia Keyoumarsi (bardia@easypost.com)  
**Platform**: macOS (darwin)  / linux
**Shell**: Bash 3.2+ (macOS default)

