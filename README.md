# 🎓 EduHub — Modern Educational Learning Portal

EduHub is a clean, modern, typography-led educational portal built with **Tailwind CSS**, featuring a responsive **Bento Box** grid, spotlight search (`Cmd+K`), interactive category filters, and bookmarking.

---

## 🚀 Live Demo & GitHub Pages
Deployable directly via GitHub Pages by serving the repository root (`index.html`).

---

## ⚡ Features
- **Global Sticky Header**: Glassmorphism navigation with brand badge, Cmd+K search trigger, and sign-in actions.
- **Hero Section**: Abstract glowing mesh gradients and cohort announcement badges.
- **Category Filter Pills**: Horizontally scrollable slider to filter by Coding, AI, Design, Business, and Growth tracks.
- **Bento Box Grid**: Featured Course of the Month (Production LLMs), Live Workshops, and Field Guides.
- **Course Grid**: 8 structured cards with difficulty levels, duration, and bookmarking.
- **Spotlight Search Modal**: Accessible via `Cmd+K` (or `Ctrl+K`) and `Esc` to close.
- **Server Ready**: Includes zero-dependency Node.js (`server.js`) and Python (`server.py`) servers.

---

## 🛠️ Server Usage

### Node.js (Recommended for Linux server / screen)
```bash
node server.js
# Or
npm start
```

### Python 3
```bash
python3 server.py
```

### Linux Server (monitor.sh + screen + Cloudflare Tunnel)
See `deploy_monitor_snippet.sh` for easy integration into your existing screen monitoring script.
