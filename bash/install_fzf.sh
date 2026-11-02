#!/bin/bash

set -e

# Only install if FZF doesn't already exist
if [ ! -d "${HOME}/.fzf" ]; then
    echo "Installing FZF..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/.fzf
    ${HOME}/.fzf/install --all
else
    echo "FZF already installed, skipping..."
fi

# fzf may have been installed by the zsh target first; make sure bash is set up too
if [ ! -f "${HOME}/.fzf.bash" ]; then
    echo "Generating ~/.fzf.bash..."
    ${HOME}/.fzf/install --bin --key-bindings --completion --no-update-rc --no-zsh --no-fish
    cat > "${HOME}/.fzf.bash" << 'EOF'
# Setup fzf
if [[ ! "$PATH" == *$HOME/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
fi

eval "$(fzf --bash)"
EOF
fi
