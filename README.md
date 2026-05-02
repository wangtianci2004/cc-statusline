# Claude Code 增强状态栏

一行式状态栏，聚合 Claude Code 的模型、上下文、缓存、成本与速率限制信息。

## 显示样例

```
Opus 4.7 | ~/d/c/proj main'+2↑1 | 135.2k/14% | 1R:0·Rq:4·ΔW:1.8k·ΣW:135.6k | R$1.17·T$3.62·D$3.80 | 5H:85%(16:30)·7D:35%
```

> 动态值默认 ANSI 绿（`\033[32m`）；上下文 / 5H / 7D 任一百分比 ≥80% 时改为加粗红（`\033[1;31m`）。标签字符（`R`/`T`/`D`/`1R`/`Rq` 等）保持终端默认色。

| 段位 | 含义 |
|------|------|
| `Opus 4.7[·perm_mode]` | 当前模型；非 default 权限模式追加 |
| `~/d/c/proj main'+2↑1↓3` | 路径缩写 + git 分支 + 工作树状态（`'` dirty / `+n` staged / `↑n` ahead / `↓n` behind） |
| `19.3k/12%` | 上下文 token 数 / 占窗口百分比（≤1 位小数）；≥80% 标红 |
| `1h 17:36:` | 当前缓存 TTL 档位 + 失效时间（1h 显示 HH:MM、5m 显示 :MM:SS） |
| `1R:12.3k` | 本轮首个请求的 cache_read；若中途下降 ≥3 块改为 `∧R:` 提示缓存退化 |
| `Rq:n` | 本轮请求数 |
| `ΔW:n` | 当前请求新写入 cache 的 token |
| `ΣW:n` | 本轮累计 cache 写入 token |
| `R8¢·T$1.23·D$4.50` | 本轮（R）/ 会话总（T）/ 今日跨会话累计（D） |
| `5H:32%(16:30)·7D:30%` | 5h 已用百分比 + 重置时刻 / 7d 已用百分比；任一 ≥80% 该段标红 |

**dirty 含义**：工作区有改动但尚未 `git add` —— 来源 `git status --porcelain` 第二列为 `M`/`D`/`?`。`+n` 是已 staged 待 commit 的文件数，`↑n`/`↓n` 是相对远端 ahead/behind。

## 一键安装

```sh
cd claude-statusline
sh install.sh
```

脚本会自动：
1. 复制 `statusline-command.sh` 到 `~/.claude/` 并赋可执行权限
2. 备份原 `settings.json` 后注入 `statusLine` 字段
3. 提示重启 Claude Code 生效

## 手动安装

```sh
cp statusline-command.sh ~/.claude/
chmod u+x ~/.claude/statusline-command.sh
```

在 `~/.claude/settings.json` 中加入：
```json
{
  "statusLine": {
    "type": "command",
    "command": "/Users/<你>/.claude/statusline-command.sh"
  }
}
```

## 依赖

- `jq`（必需）
- `git`（git 段位）
- `awk` / `date`（POSIX 自带）

macOS 用 `brew install jq` 安装。

## 状态文件

- `/tmp/claude-sl-state.json` — 跨调用持久化的本轮统计
- `/tmp/claude-sl-trace.log` — 每个请求的 token/cost 明细日志
- `~/.claude/.cost-day-YYYY-MM-DD.json` — 今日跨会话花费聚合（>3 天自动清理）

## 卸载

删除脚本 + 在 `settings.json` 移除 `statusLine` 字段：
```sh
rm ~/.claude/statusline-command.sh
jq 'del(.statusLine)' ~/.claude/settings.json > tmp && mv tmp ~/.claude/settings.json
```
