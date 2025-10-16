#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 [options]

User-level systemd installer (no sudo required)
Services run under your user account and start on login.

Options:
  --install-dir <path>    Install directory with dist/ (default: ~/.local/lib/browsermcp-enhanced)
  --http-port <port>      HTTP MCP port (default: 3000)
  --ws-port <port>        WebSocket daemon port (default: 8765)
  --env-file <path>       Path to env file (default: ~/.config/browsermcp/env)
  --no-restart            Install only; do not restart services
  -h, --help              Show this help

Examples:
  $0
  $0 --install-dir ~/my-browsermcp --http-port 4000
EOF
}

USER_NAME=$(id -un)
USER_HOME="$HOME"
INSTALL_DIR=""
HTTP_PORT=3000
WS_PORT=8765
ENV_FILE="$HOME/.config/browsermcp/env"
RESTART=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --install-dir) INSTALL_DIR="$2"; shift 2 ;;
    --http-port) HTTP_PORT="$2"; shift 2 ;;
    --ws-port) WS_PORT="$2"; shift 2 ;;
    --env-file) ENV_FILE="$2"; shift 2 ;;
    --no-restart) RESTART=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

NODE_EXEC=$(command -v node 2>/dev/null || echo "")
if [[ -z "$NODE_EXEC" ]]; then
  echo "Error: node not found in PATH" >&2
  echo "Make sure Node.js is installed and in your PATH" >&2
  exit 1
fi

if [[ -z "$INSTALL_DIR" ]]; then
  INSTALL_DIR="$USER_HOME/.local/lib/browsermcp-enhanced"
fi

HTTP_UNIT_SRC="debian/systemd/user/browsermcp-http.service"
DAEMON_UNIT_SRC="debian/systemd/user/browsermcp-daemon.service"

if [[ ! -f "$HTTP_UNIT_SRC" || ! -f "$DAEMON_UNIT_SRC" ]]; then
  echo "Error: systemd user unit templates not found (expected debian/systemd/user/)" >&2
  exit 1
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

for unit in "$HTTP_UNIT_SRC" "$DAEMON_UNIT_SRC"; do
  base=$(basename "$unit")
  sed -e "s|__HOME__|${USER_HOME}|g" \
      -e "s|__INSTALL_DIR__|${INSTALL_DIR}|g" \
      -e "s|__NODE_PATH__|${NODE_EXEC}|g" \
      -e "s|__ENV_FILE__|${ENV_FILE}|g" \
      "$unit" > "$TMPDIR/$base"
done

mkdir -p "$HOME/.config/systemd/user"
echo "Installing unit files to ~/.config/systemd/user";
install -D -m 0644 "$TMPDIR/browsermcp-http.service" "$HOME/.config/systemd/user/browsermcp-http.service"
install -D -m 0644 "$TMPDIR/browsermcp-daemon.service" "$HOME/.config/systemd/user/browsermcp-daemon.service"

mkdir -p "$(dirname "$ENV_FILE")"
if [[ ! -f "$ENV_FILE" ]]; then
  cat > "$ENV_FILE" << 'ENVEOF'
# BrowserMCP Enhanced - User Environment

# HTTP MCP Server
BROWSER_MCP_HTTP_PORT=3000

# WebSocket Daemon
BROWSER_MCP_DAEMON_PORT=8765
BROWSER_MCP_HTTP_URL=http://127.0.0.1:${BROWSER_MCP_HTTP_PORT}

# Command timeout (ms)
BROWSER_MCP_COMMAND_TIMEOUT=45000

# Enable HTTP server debug endpoint (/debug/session/<id>)
BROWSER_MCP_ENABLE_DEBUG=0
ENVEOF
fi

sed -i \
  -e "s|^BROWSER_MCP_HTTP_PORT=.*$|BROWSER_MCP_HTTP_PORT=${HTTP_PORT}|" \
  -e "s|^BROWSER_MCP_DAEMON_PORT=.*$|BROWSER_MCP_DAEMON_PORT=${WS_PORT}|" \
  -e "s|^BROWSER_MCP_HTTP_URL=.*$|BROWSER_MCP_HTTP_URL=http://127.0.0.1:${HTTP_PORT}|" \
  "$ENV_FILE"

systemctl --user daemon-reload
systemctl --user enable browsermcp-http.service browsermcp-daemon.service

if [[ "$RESTART" -eq 1 ]]; then
  systemctl --user restart browsermcp-http.service
  systemctl --user restart browsermcp-daemon.service
fi

echo ""
echo "Done. Status:"
systemctl --user --no-pager --full status browsermcp-http.service | sed -n '1,10p'
systemctl --user --no-pager --full status browsermcp-daemon.service | sed -n '1,10p'

echo ""
echo "User services installed successfully!"
echo ""
echo "Manage services with:"
echo "  systemctl --user start/stop/restart browsermcp-http.service"
echo "  systemctl --user status browsermcp-http.service"
echo "  journalctl --user -u browsermcp-http.service -f"
echo ""
echo "Services will start automatically on login."
