<div align="center">
  <img src="https://wpdistro.cz/laskobot-mascot.jpg" alt="LaskoBOT Mascot" width="800"/>
</div>

# LaskoBOT — Protocol v2, Multi‑Instance, Cross‑Browser

<div align="center">

  **LaskoBOT v1.30.7**

  [![Version](https://img.shields.io/badge/version-1.30.7-blue.svg)](https://github.com/david-strejc/browsermcp-enhanced/releases)
  [![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
  [![MCP](https://img.shields.io/badge/MCP-Compatible-purple.svg)](https://modelcontextprotocol.io)
</div>

Modern MCP server + browser extensions for reliable, multi‑instance automation over a single WebSocket daemon.

## ✨ Features

### ✨ Highlights
- Single WS daemon (8765), many sessions (Claude instances)
- Per‑session tab routing and ownership (no cross‑talk)
- Unified tools across Chrome and Firefox
- Auto‑reconnect (Firefox adds alarms + online hooks)

## 🚀 Quick Start

### Prerequisites
- Node.js 20+
- Chrome or Firefox
- Claude Code
- Also works with WSL2 and Windows Chrome

### Installation

#### Option 1: Quick Deploy Script
```bash
git clone https://github.com/david-strejc/browsermcp-enhanced.git
cd browsermcp-enhanced
./scripts/deploy
```

#### Option 2: Manual Installation

1. **Clone and build:**
```bash
git clone https://github.com/david-strejc/browsermcp-enhanced.git
cd browsermcp-enhanced
npm install
npm run build
```

2. **Install systemd services (HTTP + WS daemon):**

   **Option A: User services (recommended for nvm users, no sudo required):**
   ```bash
   ./scripts/systemd-user-install.sh
   ```

   **Option B: System services (requires sudo):**
   ```bash
   sudo ./scripts/systemd-install.sh --user "$USER" \
     --install-dir "/home/$USER/.local/lib/browsermcp-enhanced" \
     --http-port 3000 --ws-port 8765
   ```

3. **Load extension (one browser at a time):**
- Chrome: `chrome://extensions` → Developer mode → Load unpacked → `chrome-extension/`
- Firefox: `about:debugging#/runtime/this-firefox` → Load Temporary Add‑on → `firefox-extension/manifest.json`

4. **Configure MCP**
    ```json
      {
        "mcpServers": {
          "browsermcp": {
            "type": "http",
            "url": "http://127.0.0.1:3000/mcp"
          }
        }
      }
    ```

**For detailed architecture and troubleshooting information, see [ADVANCE_INFO.md](docs/ADVANCE_INFO.md)**

## 🐛 Known Issues

- WebSocket reconnection may require Chrome restart
- Some sites with strict CSP may require unsafe mode
- Safari and Firefox support coming in v2.0.0
- **Behind proxy:** If you're behind a proxy, set `NO_PROXY=localhost,127.0.0.1` to allow local connections

## 📖 Usage

### Basic Navigation
```javascript
// Navigate to a URL
await browser_navigate({ url: "https://example.com" })

// Snapshot
await snapshot.accessibility({ mode: 'scaffold' })

// Click an element
await browser_click({ ref: "button-1", element: "Submit button" })
```

### JavaScript Execution
```javascript
// Plain DOM
await js.execute({ code: "return document.title" })

// Safe operation (no code)
await js.execute({ method: 'query', args: ['h3', { attrs: ['textContent'], limit: 10 }] })

// Unsafe (enable in extension options first)
await js.execute({ code: "(function(){ return location.href })()", unsafe: true })
```

### Form Automation
```javascript
// Multi-step form filling
await browser_multitool({
  intent: "form_fill",
  snapshot: snapshotData,
  fields: {
    "username": "john.doe",
    "email": "john@example.com",
    "message": "Hello world"
  }
})
```

### Debugging & Logs
Daemon: `/tmp/browsermcp-daemon.log`, `/tmp/browsermcp-events.log`
Chrome: `chrome://extensions` → Inspect (background)
Firefox: `about:debugging` → Inspect (background)

## 🔧 Advanced Configuration

### Environment Variables
```bash
# Allow all origins (development)
BROWSER_MCP_ALLOWED_ORIGINS="*"

# Specific origins (production)
BROWSER_MCP_ALLOWED_ORIGINS="https://example.com,https://app.example.com"

# Custom WebSocket port
BROWSER_MCP_PORT=8765
```

### Extension Options (Firefox)
- Unsafe mode toggle (required for `unsafe: true`)

## 📚 API Reference

### Core Tools
- `browser_navigate`, `browser_go_back`, `browser_go_forward`
- `dom.click`, `dom.type`, `dom.hover`, `dom.select`
- `snapshot.accessibility`
- `tabs.list`, `tabs.select`, `tabs.new`, `tabs.close`
- `console.get`, `screenshot.capture`, `js.execute`

## 🧪 Testing

```bash
# Run tests
npm test

# Quick test
npm run test:quick

# With coverage
npm run test:coverage
```

## 🛠️ Development

```bash
# Watch mode
npm run watch

# Type checking
npm run typecheck

# Inspector
npm run inspector
```

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

### v1.0.0 (Latest)
- 🚀 First production-ready release
- ✅ RPC-based safe mode execution
- ✅ Sandboxed iframe isolation
- ✅ Comprehensive testing suite
- ✅ Full documentation

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Model Context Protocol](https://modelcontextprotocol.io) team for the MCP specification
- [Playwright](https://playwright.dev) for browser automation inspiration
- Claude and the o3 model for architectural guidance
- All contributors and testers

## 🐛 Known Issues

- WebSocket reconnection may require Chrome restart
- Some sites with strict CSP may require unsafe mode
- Safari and Firefox support coming in v2.0.0

## 📞 Support

- [Issues](https://github.com/david-strejc/browsermcp-enhanced/issues)
- [Discussions](https://github.com/david-strejc/browsermcp-enhanced/discussions)
- [Release Notes](https://github.com/david-strejc/browsermcp-enhanced/releases)

---

**Made with ❤️ by the LaskoBOT Contributors**
