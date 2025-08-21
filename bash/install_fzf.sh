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
