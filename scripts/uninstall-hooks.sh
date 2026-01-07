#!/bin/bash
#
# Git hooks uninstallation script
# Usage: ./scripts/uninstall-hooks.sh
#

set -e

GIT_HOOKS_DIR="$(git rev-parse --git-dir)/hooks"

echo "🗑️  Uninstalling Git hooks..."
echo ""

HOOKS=("pre-commit" "pre-push" "commit-msg")

for hook_name in "${HOOKS[@]}"; do
    target="$GIT_HOOKS_DIR/$hook_name"

    if [ -L "$target" ]; then
        rm "$target"
        echo "✅ Removed: $hook_name"

        # バックアップがあれば復元
        if [ -f "$target.backup" ]; then
            mv "$target.backup" "$target"
            echo "   ↳ Restored backup"
        fi
    elif [ -f "$target" ]; then
        echo "⚠️  $hook_name is not a symlink, skipping"
    else
        echo "ℹ️  $hook_name not installed"
    fi
done

echo ""
echo "✅ Git hooks uninstalled successfully!"
