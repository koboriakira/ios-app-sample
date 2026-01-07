#!/bin/bash
#
# Git hooks installation script
# Usage: ./scripts/install-hooks.sh
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$SCRIPT_DIR/hooks"
GIT_HOOKS_DIR="$(git rev-parse --git-dir)/hooks"

echo "🔧 Installing Git hooks..."
echo ""

# フックディレクトリが存在するか確認
if [ ! -d "$HOOKS_DIR" ]; then
    echo "❌ Hooks directory not found: $HOOKS_DIR"
    exit 1
fi

# 各フックをインストール
for hook in "$HOOKS_DIR"/*; do
    if [ -f "$hook" ]; then
        hook_name=$(basename "$hook")
        target="$GIT_HOOKS_DIR/$hook_name"

        # 既存のフックをバックアップ
        if [ -f "$target" ] && [ ! -L "$target" ]; then
            echo "📦 Backing up existing $hook_name to $hook_name.backup"
            mv "$target" "$target.backup"
        fi

        # シンボリックリンクを作成
        ln -sf "$hook" "$target"
        chmod +x "$hook"
        echo "✅ Installed: $hook_name"
    fi
done

echo ""
echo "✅ Git hooks installed successfully!"
echo ""
echo "Installed hooks:"
ls -la "$GIT_HOOKS_DIR" | grep -E "pre-commit|pre-push|commit-msg" || true
echo ""
echo "To uninstall hooks, run: ./scripts/uninstall-hooks.sh"
