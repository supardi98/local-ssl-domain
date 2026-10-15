---
name: local-ssl-domain
description: Set up custom local domains (e.g. .local, .test) with trusted HTTPS/SSL certificates using mkcert and reverse proxies (Nginx, Caddy, or Vite) across any web project. Use when the user requests HTTPS on localhost, custom local domain names, WebRTC/Web Notification secure origin requirements, or local SSL automation.
---

# Local Domain & Trusted HTTPS/SSL Setup Skill

This skill provides step-by-step guidance and automation patterns to configure custom local domain names (e.g. `myapp.local`, `batur.local`, `dev.local`) with locally trusted SSL/TLS certificates.

## 1. Prerequisites: `mkcert`
`mkcert` is the standard tool to create zero-config, locally trusted development certificates. It installs a local Root CA into your system and browser trust stores (Firefox, Chrome, NSS, System Keychain) so browsers show a valid green lock without security warnings.

### Installation by OS:
- **Arch Linux / CachyOS**:
  ```bash
  sudo pacman -S mkcert nss
  ```
- **Ubuntu / Debian**:
  ```bash
  sudo apt update && sudo apt install -y libnss3-tools mkcert
  ```
- **Fedora**:
  ```bash
  sudo dnf install -y nss-tools mkcert
  ```
- **macOS**:
  ```bash
  brew install mkcert nss
  ```
- **Windows** (PowerShell as Admin):
  ```powershell
  choco install mkcert
  # or
  scoop install mkcert
  ```

### Initialize Local Root CA:
```bash
mkcert -install
```

---

## 2. Domain Mapping (`/etc/hosts`)

Add your desired `.local` or `.test` domain to `/etc/hosts`:

```bash
# Check if already present
grep -E "(^|\s)myapp.local(\s|$)" /etc/hosts || echo "127.0.0.1  myapp.local" | sudo tee -a /etc/hosts
```

---

## 3. Generate Certificates

Run `mkcert` pointing to your project's certs directory:

```bash
mkdir -p nginx/certs
mkcert -key-file nginx/certs/myapp.local-key.pem -cert-file nginx/certs/myapp.local.pem myapp.local localhost 127.0.0.1 ::1
```

---

## 4. Docker & Nginx Reverse Proxy Pattern

### A. `docker-compose.yml`
Expose port 80 and 443, and mount the certs directory:
```yaml
services:
  gateway:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/certs:/etc/nginx/certs:ro
    depends_on:
      - web
      - backend
```

### B. `nginx/nginx.conf`
```nginx
events { worker_connections 1024; }

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    upstream web_service { server web:3000; }
    upstream api_service { server backend:8000; }

    # HTTP (Port 80) -> Redirect to HTTPS
    server {
        listen 80;
        server_name myapp.local localhost 127.0.0.1;
        return 301 https://$host$request_uri;
    }

    # HTTPS (Port 443)
    server {
        listen 443 ssl;
        server_name myapp.local localhost 127.0.0.1;

        ssl_certificate     /etc/nginx/certs/myapp.local.pem;
        ssl_certificate_key /etc/nginx/certs/myapp.local-key.pem;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        # API & WebSocket (WSS)
        location /api/ {
            proxy_pass http://api_service;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Proto https;
        }

        # Frontend SPA / Next.js / Vite (with HMR WebSocket support)
        location / {
            proxy_pass http://web_service;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Proto https;
        }
    }
}
```

---

## 5. Standalone Vite (Without Docker/Nginx)
If a project only uses Vite without Docker, use `vite-plugin-mkcert`:
```bash
npm i -D vite-plugin-mkcert
```
In `vite.config.js`:
```js
import { defineConfig } from 'vite';
import mkcert from 'vite-plugin-mkcert';

export default defineConfig({
  server: {
    https: true,
    host: 'myapp.local',
  },
  plugins: [mkcert()],
});
```

---

## 6. Verification Checklist
- [ ] `/etc/hosts` resolves: `ping -c 1 myapp.local` returns `127.0.0.1`.
- [ ] Browser shows green lock icon without certificate warning.
- [ ] Secure contexts enabled: `window.isSecureContext === true` in browser DevTools console.
- [ ] Web Notifications, Clipboard API, and WebRTC functions work without origin errors.
