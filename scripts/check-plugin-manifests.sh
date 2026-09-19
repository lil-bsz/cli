#!/usr/bin/env bash
# Keeps the four plugin manifests in step. Run locally or in CI.
set -euo pipefail
cd "$(dirname "$0")/.."

files=(.claude-plugin/plugin.json .claude-plugin/marketplace.json .codex-plugin/plugin.json .cursor-plugin/plugin.json plugin.json .mcp.json mcp.json)
for f in "${files[@]}"; do jq -e . "$f" >/dev/null || { echo "invalid JSON: $f"; exit 1; }; done

# name, version and description must match across every manifest and the marketplace entry
for key in name version description; do
  ref=$(jq -r ".$key" plugin.json)
  for f in .claude-plugin/plugin.json .codex-plugin/plugin.json .cursor-plugin/plugin.json; do
    [ "$(jq -r ".$key" "$f")" = "$ref" ] || { echo "$key differs in $f"; exit 1; }
  done
  [ "$(jq -r ".plugins[0].$key" .claude-plugin/marketplace.json)" = "$ref" ] || { echo "$key differs in marketplace entry"; exit 1; }
done

# the Codex interface block lives in two places (overlay + portable manifest); they must be identical
a=$(jq -S .interface .codex-plugin/plugin.json)
b=$(jq -S '.extensions["com.openai"].interface' plugin.json)
[ "$a" = "$b" ] || { echo "Codex interface block differs between .codex-plugin/plugin.json and plugin.json extensions.com.openai"; exit 1; }

# both MCP files must point at the same server URL
u1=$(jq -r '.mcpServers.testerarmy.url' .mcp.json)
u2=$(jq -r '.mcpServers.testerarmy.url' mcp.json)
[ "$u1" = "$u2" ] || { echo "MCP url differs: .mcp.json=$u1 mcp.json=$u2"; exit 1; }
[ "$(jq -r '.mcpServers.testerarmy.type' .mcp.json)" = "http" ] || { echo ".mcp.json must use type http (Claude Code)"; exit 1; }
[ "$(jq -r '.mcpServers.testerarmy.type' mcp.json)" = "streamable-http" ] || { echo "mcp.json must use type streamable-http (Agent Plugins)"; exit 1; }

# referenced logo must exist
for p in "$(jq -r .logo .cursor-plugin/plugin.json)" "$(jq -r .interface.logo .codex-plugin/plugin.json)"; do
  [ -f "${p#./}" ] || { echo "missing logo file: $p"; exit 1; }
done

echo "plugin manifests consistent"
