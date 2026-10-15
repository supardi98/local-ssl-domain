#!/usr/bin/env bash
# ==============================================================================
# Universal Local Domain & SSL Setup Script
# Repository: https://github.com/supardi98/local-ssl-domain
# Usage: ./setup-local-ssl.sh [domain] [target_certs_dir]
# Examples:
#   ./setup-local-ssl.sh batur.local ./nginx/certs
#   ./setup-local-ssl.sh myapp.local
# ==============================================================================

set -e

DOMAIN="${1:-myapp.local}"
CERTS_DIR="${2:-./nginx/certs}"

echo "=========================================================="
echo "🚀 Universal Local Domain & Trusted HTTPS/SSL Setup"
echo "🌐 Target Domain : $DOMAIN"
echo "📁 Certs Directory: $CERTS_DIR"
echo "=========================================================="

mkdir -p "$CERTS_DIR"

# 1. Deteksi OS & cek keberadaan mkcert
if ! command -v mkcert &> /dev/null; then
    echo "⚠️  'mkcert' belum terpasang di sistem Anda."
    echo "📦 Mendeteksi package manager..."

    if [ -f /etc/arch-release ] || grep -q -i "arch\|cachy" /etc/os-release 2>/dev/null; then
        echo "💡 Terdeteksi Arch Linux / CachyOS."
        echo "👉 Menjalankan: sudo pacman -S --needed mkcert nss"
        sudo pacman -S --needed mkcert nss
    elif [ -f /etc/debian_version ] || grep -q -i "ubuntu\|debian" /etc/os-release 2>/dev/null; then
        echo "💡 Terdeteksi Debian / Ubuntu."
        echo "👉 Menjalankan: sudo apt update && sudo apt install -y libnss3-tools mkcert"
        sudo apt update && sudo apt install -y libnss3-tools mkcert
    elif [ -f /etc/fedora-release ]; then
        echo "💡 Terdeteksi Fedora."
        echo "👉 Menjalankan: sudo dnf install -y nss-tools mkcert"
        sudo dnf install -y nss-tools mkcert
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "💡 Terdeteksi macOS."
        echo "👉 Menjalankan: brew install mkcert nss"
        brew install mkcert nss
    else
        echo "❌ Sistem operasi tidak dikenali secara otomatis."
        echo "Silakan install mkcert secara manual: https://github.com/FiloSottile/mkcert"
        exit 1
    fi
fi

# 2. Pastikan Root CA mkcert terpasang di trust store lokal
echo "🔐 Memastikan Root CA mkcert terdaftar di browser & trust store..."
mkcert -install

# 3. Daftarkan domain ke /etc/hosts jika belum ada
echo "📝 Memeriksa entri /etc/hosts untuk $DOMAIN..."
if grep -qE "(^|\s)$DOMAIN(\s|$)" /etc/hosts; then
    echo "✅ Entri $DOMAIN sudah ada di /etc/hosts."
else
    echo "➕ Menambahkan '127.0.0.1  $DOMAIN' ke /etc/hosts (memerlukan sudo)..."
    echo "127.0.0.1  $DOMAIN" | sudo tee -a /etc/hosts > /dev/null
    echo "✅ Berhasil didaftarkan ke /etc/hosts."
fi

# 4. Generate sertifikat SSL terpercaya via mkcert
CERT_FILE="$CERTS_DIR/$DOMAIN.pem"
KEY_FILE="$CERTS_DIR/$DOMAIN-key.pem"

echo "📜 Membuat sertifikat SSL untuk $DOMAIN, localhost, dan 127.0.0.1..."
mkcert -key-file "$KEY_FILE" -cert-file "$CERT_FILE" "$DOMAIN" localhost 127.0.0.1 ::1

chmod 600 "$KEY_FILE"
chmod 644 "$CERT_FILE"

echo "✅ Sertifikat SSL berhasil dibuat:"
echo "   - Cert: $CERT_FILE"
echo "   - Key : $KEY_FILE"

# 5. Reload / Restart Docker Nginx Gateway jika Dockerfile/Compose terdeteksi
if command -v docker &> /dev/null && [ -f "./docker-compose.yml" ] || [ -f "./compose.yaml" ]; then
    echo "🐳 Memeriksa status container Docker..."
    if docker compose ps --services 2>/dev/null | grep -qE "gateway|nginx|proxy"; then
        docker compose exec -T gateway nginx -s reload 2>/dev/null || docker compose restart gateway 2>/dev/null || docker compose up -d
        echo "✅ Reverse proxy gateway berhasil di-reload dengan sertifikat baru."
    fi
fi

echo ""
echo "=========================================================="
echo "🎉 SETUP SELESAI!"
echo "Sekarang Anda dapat membuka aplikasi di browser dengan:"
echo "👉 https://$DOMAIN"
echo "👉 https://localhost"
echo "=========================================================="
