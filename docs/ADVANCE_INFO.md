# BrowserMCP Enhanced - Additional info

## Production Architecture (HTTP transport)

```
┌────────────────────────────────────┐
│   Claude Code                      │
│   URL: http://localhost:3000/mcp   │
└──────────┬─────────────────────────┘
           │ HTTP
           │ StreamableHTTPServerTransport
           │
┌──────────▼─────────────────────────┐
│  browsermcp-http.service           │
│  index-http.js (port 3000)         │
│  - HTTP endpoint /mcp              │
│  - HTTP endpoint /ws-message       │
└──────────▲─────────────────────────┘
           │ HTTP POST
           │ /ws-message
           │
┌──────────┴─────────────────────────┐
│  browsermcp-daemon.service         │
│  websocket-daemon.js (port 8765)   │
│  - WebSocket server                │
│  - Middleware (forwards messages)  │
└──────────▲─────────────────────────┘
           │ WebSocket
           │ ws://localhost:8765/session/<instanceId>
           │
┌──────────┴─────────────────────────┐
│  Browser Extension                 │
└────────────────────────────────────┘
```

**Config Claude Code**
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

---

## Message Flow

```
User: "Navigate to seznam.cz"
    ↓
Claude: browser_navigate({ url: "https://www.seznam.cz" })
    ↓
MCP Server: CallToolRequestSchema
    ↓
Tool.handle(context, args)
    ↓
context.sendSocketMessage('browser_navigate', { url })
    ↓
WebSocket → Extension
    ↓
chrome.tabs.update(tabId, { url })
    ↓
Response back: Extension → WebSocket → Context → Tool → Claude
```

---

**Management:**
```bash
# Note: For system services omit --user and use sudo
# E.g.: sudo systemctl start browsermcp-http.service

# Start/Stop/Restart
systemctl --user start browsermcp-http.service browsermcp-daemon.service
systemctl --user stop browsermcp-http.service browsermcp-daemon.service
systemctl --user restart browsermcp-http.service browsermcp-daemon.service

# Status
systemctl --user status browsermcp-http.service browsermcp-daemon.service

# Logs
journalctl --user -u browsermcp-http.service -f
journalctl --user -u browsermcp-daemon.service -n 50

# Autostart on user login (enable/disable)
# For system services: autostart on system boot
systemctl --user enable browsermcp-http.service browsermcp-daemon.service
systemctl --user disable browsermcp-http.service browsermcp-daemon.service
```

---

## Port Conflicts

**Problem:**
```
Port 8765 already in use by another process
→ EADDRINUSE: address already in use :::8765
```

**Solution:**
```bash
# Check what's running on the port
ss -tlnp | grep :8765
lsof -i :8765

# Stop systemd daemon if running
sudo systemctl stop browsermcp-daemon.service
# OR for user services
systemctl --user stop browsermcp-daemon.service

# Or kill the process
kill <PID>
```

---

## Debug

**Processes:**
```bash
# System services
ps aux | grep -E "index-http|websocket-daemon" | grep -v grep

# User services
systemctl --user status browsermcp-http.service browsermcp-daemon.service
```

**Extension console:**
```
chrome://extensions/ → BrowserMCP Enhanced → "service worker"
Look for: [UnifiedConn] Connecting to: ws://localhost:8765/session/<instanceId>
```

**MCP logs:**
```bash
# System services
sudo journalctl -u browsermcp-http.service -f
sudo journalctl -u browsermcp-daemon.service -f

# User services
journalctl --user -u browsermcp-http.service -f
journalctl --user -u browsermcp-daemon.service -f
```

**Test ports:**
```bash
# HTTP server
curl http://localhost:3000/mcp

# WebSocket daemon
curl http://localhost:8765/
# Expected response: "Upgrade Required"
```
