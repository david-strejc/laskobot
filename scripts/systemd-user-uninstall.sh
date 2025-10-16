#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 [options]

User-level systemd uninstaller (no sudo required)

Options:
  --keep-env              Keep ~/.config/browsermcp/env file
  --env-file <path>       Path to env file (default: ~/.config/browsermcp/env)
  -h, --help              Show this help

Examples:
  $0
  $0 --keep-env
EOF
}

ENV_FILE="$HOME/.config/browsermcp/env"
KEEP_ENV=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --keep-env) KEEP_ENV=1; shift ;;
    --env-file) ENV_FILE="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

echo "Stopping services..."
systemctl --user stop browsermcp-http.service browsermcp-daemon.service 2>/dev/null || true

echo "Disabling services..."
systemctl --user disable browsermcp-http.service browsermcp-daemon.service 2>/dev/null || true

echo "Removing unit files..."
rm -f "$HOME/.config/systemd/user/browsermcp-http.service"
rm -f "$HOME/.config/systemd/user/browsermcp-daemon.service"

echo "Reloading systemd..."
systemctl --user daemon-reload

if [[ "$KEEP_ENV" -eq 0 ]]; then
  if [[ -f "$ENV_FILE" ]]; then
    echo "Removing env file: $ENV_FILE"
    rm -f "$ENV_FILE"
    rmdir "$(dirname "$ENV_FILE")" 2>/dev/null || true
  fi
else
  echo "Keeping env file: $ENV_FILE"
fi

echo "Uninstall complete. Installation directory was not touched."
