#!/bin/bash

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <plugins_file>"
    exit 1
fi

PLUGINS_FILE="$1"
if [ ! -f "$PLUGINS_FILE" ]; then
    echo "Error: Plugin file '$PLUGINS_FILE' not found"
    exit 1
fi

echo "Setting up vim plugins..."
mkdir -p ${HOME}/.vim/pack/plugins/start/
pushd ${HOME}/.vim/pack/plugins/start/

# install plugins
while read plugin; do
    # Skip empty lines and comments
    [[ -z "$plugin" || "$plugin" =~ ^#.* ]] && continue
    
    plugin_name=$(basename "$plugin" .git)
    if [ ! -d "$plugin_name" ]; then
        echo "Installing $plugin_name..."
        git clone $plugin 2>/dev/null || echo "Failed to clone $plugin"
    else
        echo "$plugin_name already exists, skipping..."
    fi
done < "$PLUGINS_FILE"

# update any existing ones
echo "Updating existing plugins..."
for plugin in */; do
    if [ -d "$plugin/.git" ]; then
        echo "Updating $plugin..."
        pushd $plugin
        git pull || echo "Failed to update $plugin"
        popd
    fi
done

popd
echo "Plugin setup complete!"
