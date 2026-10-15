#!/usr/bin/env bash
# ==============================================================================
# Installer: Install local-ssl-domain skill into Antigravity global skills
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/supardi98/local-ssl-domain/main/install-skill.sh | bash
# ==============================================================================

set -e

DEST_DIR="$HOME/.gemini/antigravity/skills/local-ssl-domain"
mkdir -p "$DEST_DIR"

echo "📦 Installing 'local-ssl-domain' skill into $DEST_DIR..."

SKILL_URL="https://raw.githubusercontent.com/supardi98/local-ssl-domain/main/SKILL.md"
SCRIPT_URL="https://raw.githubusercontent.com/supardi98/local-ssl-domain/main/scripts/setup-local-ssl.sh"

if command -v curl &> /dev/null; then
    curl -fsSL "$SKILL_URL" -o "$DEST_DIR/SKILL.md"
    mkdir -p "$DEST_DIR/scripts"
    curl -fsSL "$SCRIPT_URL" -o "$DEST_DIR/scripts/setup-local-ssl.sh"
    chmod +x "$DEST_DIR/scripts/setup-local-ssl.sh"
elif command -v wget &> /dev/null; then
    wget -qO "$DEST_DIR/SKILL.md" "$SKILL_URL"
    mkdir -p "$DEST_DIR/scripts"
    wget -qO "$DEST_DIR/scripts/setup-local-ssl.sh" "$SCRIPT_URL"
    chmod +x "$DEST_DIR/scripts/setup-local-ssl.sh"
else
    echo "❌ Neither curl nor wget is installed."
    exit 1
fi

echo "✅ Skill 'local-ssl-domain' successfully installed!"
echo "💡 You can now ask Antigravity in any project: 'bikin domain lokal https untuk project ini'."
