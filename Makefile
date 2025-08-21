DOTFILES := $(shell pwd)

.PHONY: bash
bash:
	@echo "Setting up bash configuration..."
	@ln -fs ${DOTFILES}/bash/alias ${HOME}/.alias || (echo "Failed to link alias file" && exit 1)
	@ln -fns $(DOTFILES)/etc/ ${HOME}/etc || (echo "Failed to link etc directory" && exit 1)
	@ln -fs $(DOTFILES)/bash/bashrc ${HOME}/.bashrc || (echo "Failed to link bashrc" && exit 1)
	@ln -fs $(DOTFILES)/bash/bash_profile ${HOME}/.bash_profile || (echo "Failed to link bash_profile" && exit 1)
	@$(DOTFILES)/bash/install_fzf.sh || (echo "Failed to install FZF" && exit 1)
	@echo "Bash setup complete!"

.PHONY: tmux
tmux:
	@echo "Setting up tmux..."
	@git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 2>/dev/null || echo "TPM already exists"
	@ln -fs $(DOTFILES)/tmux/tmux.conf ${HOME}/.tmux.conf || (echo "Failed to link tmux config" && exit 1)
	@echo "Tmux setup complete!"

.PHONY: vim
vim:
	@echo "Setting up vim..."
	@mkdir -p ${HOME}/.vim/pack/plugins/start/ ${HOME}/.vim/swap ${HOME}/.vim/backup ${HOME}/.vim/undodir || (echo "Failed to create vim directories" && exit 1)
	@cp -r $(DOTFILES)/vim/colors ${HOME}/.vim/ || (echo "Failed to copy vim colors" && exit 1)
	@ln -fs $(DOTFILES)/vim/vimrc ${HOME}/.vimrc || (echo "Failed to link vimrc" && exit 1)
	@$(DOTFILES)/vim/setup_plugins.sh $(DOTFILES)/vim/plugins.txt || (echo "Failed to setup vim plugins" && exit 1)
	@echo "Vim setup complete!"

.PHONY: nvim
nvim:
	@echo "Setting up neovim..."
	@mkdir -p ${HOME}/.config || (echo "Failed to create config directory" && exit 1)
	@ln -fns $(DOTFILES)/nvim/ ${HOME}/.config/nvim || (echo "Failed to link nvim config" && exit 1)
	@echo "Neovim setup complete!"

.PHONY: git
git:
	@echo "Setting up git..."
	@ln -fs $(DOTFILES)/git/gitconfig ${HOME}/.gitconfig || (echo "Failed to link gitconfig" && exit 1)
	@ln -fs $(DOTFILES)/git/gitcommit ${HOME}/.gitcommit || (echo "Failed to link gitcommit" && exit 1)
	@ln -fs $(DOTFILES)/git/gitignore ${HOME}/.gitignore || (echo "Failed to link gitignore" && exit 1)
	@echo "Git setup complete!"

.PHONY: brew
brew:
ifeq ($(shell uname -s),Darwin)
	@echo "Installing brew packages..."
	@brew install fzf fd ripgrep || (echo "Failed to install brew packages" && exit 1)
	@echo "Brew packages installed!"
else
	@echo "Skipping brew installation (not on macOS)"
endif

.PHONY: clean
clean:
	@echo "Cleaning up symbolic links..."
	@rm -f $(HOME)/.alias $(HOME)/.bashrc $(HOME)/.bash_profile $(HOME)/.tmux.conf $(HOME)/.vimrc $(HOME)/.gitconfig $(HOME)/.gitcommit $(HOME)/.gitignore $(HOME)/.config/nvim
	@rm -rf $(HOME)/etc $(HOME)/.vim
	@echo "Cleanup complete!"

.PHONY: all
all: bash tmux vim git nvim brew
	@echo "All dotfiles have been set up!"
