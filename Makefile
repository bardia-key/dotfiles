all: bash tmux vim git nvim brew
	@echo "All dotfiles have been set up!"

DOTFILES := $(shell pwd)

bash:
	ln -fs ${DOTFILES}/bash/alias ${HOME}/.alias
	ln -fns $(DOTFILES)/etc/ ${HOME}/etc
	ln -fs $(DOTFILES)/bash/bashrc ${HOME}/.bashrc
	ln -fs $(DOTFILES)/bash/bash_profile ${HOME}/.bash_profile
	$(DOTFILES)/bash/install_fzf.sh

tmux:
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || true
	ln -fs $(DOTFILES)/tmux/tmux.conf ${HOME}/.tmux.conf

vim:
	mkdir -p ${HOME}/.vim/pack/plugins/start/
	mkdir -p ${HOME}/.vim/swap
	mkdir -p ${HOME}/.vim/backup
	mkdir -p ${HOME}/.vim/undodir
	cp -r $(DOTFILES)/vim/colors ${HOME}/.vim/
	ln -fs $(DOTFILES)/vim/vimrc ${HOME}/.vimrc
	$(DOTFILES)/vim/setup_plugins.sh $(DOTFILES)/vim/plugins.txt

nvim:
	ln -fns $(DOTFILES)/nvim/ ${HOME}/.config/nvim

git:
	ln -fs $(DOTFILES)/git/gitconfig ${HOME}/.gitconfig
	ln -fs $(DOTFILES)/git/gitcommit ${HOME}/.gitcommit
	ln -fs $(DOTFILES)/git/gitignore ${HOME}/.gitignore

brew:
ifeq ($(shell uname -s),Darwin)
	brew install fzf fd ripgrep
endif

clean:
	@echo "Cleaning up symbolic links..."
	rm -f $(HOME)/.alias
	rm -f $(HOME)/.bashrc
	rm -f $(HOME)/.bash_profile
	rm -f $(HOME)/.tmux.conf
	rm -f $(HOME)/.vimrc
	rm -f $(HOME)/.gitconfig
	rm -f $(HOME)/.gitcommit
	rm -f $(HOME)/.gitignore
	rm -f $(HOME)/.config/nvim
	rm -rf $(HOME)/etc
	rm -rf $(HOME)/.vim
	@echo "Cleanup complete!"
