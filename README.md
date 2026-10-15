# 🔐 local-ssl-domain

> Universal setup script and Antigravity Skill for custom local domains (`.local`, `.test`) with trusted HTTPS/SSL certificates via `mkcert`.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 🌟 Features
- **1-Command Setup**: Installs `mkcert`, adds `/etc/hosts` mapping, generates trusted local certificates, and reloads Nginx reverse proxy.
- **Trusted by Modern Browsers**: Zero security warnings, real green lock in Chrome, Firefox, Brave, and Edge.
- **Full Secure Context Support**: Unlocks WebRTC (LiveKit), Web Notifications, Clipboard API, and Service Workers on local dev.
- **Antigravity AI Assistant Skill**: Integrates directly with Google Antigravity so AI agents can automate local domain SSL setup across any project.

---

## 🚀 Quick Start in Any Project

### Method A: Direct Script Execution
Copy `scripts/setup-local-ssl.sh` into your project and run:

```bash
# Default domain: myapp.local (or specify your custom domain)
./scripts/setup-local-ssl.sh batur.local ./nginx/certs
```

### Method B: Install as Antigravity Global Skill
On any machine with Antigravity installed, run:

```bash
curl -fsSL https://raw.githubusercontent.com/supardi98/local-ssl-domain/main/install-skill.sh | bash
```

Once installed, simply prompt Antigravity in your project:
> *"Bantu buatkan domain lokal https://myproject.local dengan SSL terpercaya"*

---

## 🛠️ How It Works

```
                        [ Browser ]
                             │
                  https://batur.local (Port 443)
                             │
                             ▼
              [ Nginx Gateway Container (Docker) ]
              - SSL Certs: ./nginx/certs/batur.local.pem
              - SSL Key:   ./nginx/certs/batur.local-key.pem
                             │
             ┌───────────────┴───────────────┐
             ▼                               ▼
    [ Frontend / Vite ]             [ Backend / API ]
       (Port 9081)                     (Port 9082)
```

1. **Hosts Resolution**: `127.0.0.1 <domain>` is added to `/etc/hosts`.
2. **Local Root CA**: `mkcert -install` registers a local Root Certificate Authority directly in your OS and browser NSS databases.
3. **Cert Generation**: Generates domain certificates matching `<domain>`, `localhost`, `127.0.0.1`, and `::1`.
4. **Nginx Reverse Proxy**: Forwards HTTPS traffic (including WebSockets `wss://`) to internal frontend/backend containers.

---

## 📦 OS Support
- **Arch Linux / CachyOS**: `sudo pacman -S mkcert nss`
- **Ubuntu / Debian**: `sudo apt install libnss3-tools mkcert`
- **Fedora**: `sudo dnf install nss-tools mkcert`
- **macOS**: `brew install mkcert nss`
- **Windows**: `choco install mkcert` or `scoop install mkcert`

---

## 📄 License
MIT License © [Supardi](https://github.com/supardi98)
