#!/bin/sh
# Claude Code 状态栏一键安装脚本
# 用法：sh install.sh
set -e

SRC_DIR=$(cd "$(dirname "$0")" && pwd)
DEST="$HOME/.claude/statusline-command.sh"
SETTINGS="$HOME/.claude/settings.json"

# 1. 检查依赖
for cmd in jq awk git date; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "[ERR] 缺少依赖: $cmd"; exit 1; }
done

# 2. 复制脚本并赋权
mkdir -p "$HOME/.claude"
cp "$SRC_DIR/statusline-command.sh" "$DEST"
chmod u+x "$DEST"
echo "[OK] 已安装: $DEST"

# 3. 注入 settings.json 的 statusLine 配置
if [ -f "$SETTINGS" ]; then
  cp "$SETTINGS" "${SETTINGS}.bak.$(date +%s)"
  jq --arg cmd "$DEST" \
    '.statusLine = {"type":"command","command":$cmd}' \
    "$SETTINGS" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"
else
  jq -n --arg cmd "$DEST" \
    '{statusLine: {type:"command", command:$cmd}}' > "$SETTINGS"
fi
echo "[OK] 已配置: $SETTINGS"
echo "[DONE] 重启 Claude Code 生效。"
