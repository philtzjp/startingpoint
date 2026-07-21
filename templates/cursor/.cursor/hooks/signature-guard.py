#!/usr/bin/env python3
"""Cursor hook: GitHub 投稿の署名ガード。

beforeShellExecution（gh CLI）と beforeMCPExecution（GitHub MCP）の両方で、
Issue / Issue コメント / PR / PR コメント / レビューの本文を実行前に検査する。

署名規約: 本文の先頭行は次の 4 形式のいずれかの署名で始める（完全一致）。
  ✳︎ SpaceXAI Composer <バージョン>
  ✳︎ SpaceXAI Grok <バージョン>
  ✳︎ Anthropic Claude <モデル> <バージョン>
  ✳︎ OpenAI GPT-<バージョン>[-サブバージョン]
Auto モードの Cursor はルーティング先を明かさず「Cursor Agent」や
「SpaceXAI Cursor」名義で投稿しがちなので、許可形式以外はすべて deny し、
ペイロードの `model`（解決済みモデル名）を agent_message で返して自己修正させる。

判定不能時は fail-open で allow を返す。
"""
import json
import re
import sys

# ルーティング先を隠した名義（専用メッセージで deny）
BAD_SIGNER = re.compile(r"cursor[\s_-]*agent|spacex\s*ai[\s_-]*cursor", re.I)
# ✳︎（U+2733、異体字セレクタ任意）で始まる行
SIG_HEAD = re.compile(r"^✳[︎️]?")

# 許可する署名はこの 4 形式のみ（行全体が完全一致すること）
_VER = r"\d+(\.\d+)*"
ALLOWED_SIGNATURES = re.compile(
    r"^✳[︎️]?\s+("
    rf"SpaceXAI Composer {_VER}"
    rf"|SpaceXAI Grok {_VER}"
    rf"|Anthropic Claude [A-Z][A-Za-z]* {_VER}"
    rf"|OpenAI GPT-{_VER}(-[A-Za-z][A-Za-z0-9]*)?"
    r")$"
)
ALLOWED_HELP = (
    "許可される署名は次の 4 形式のみです: "
    "「✳︎ SpaceXAI Composer <バージョン>」"
    "「✳︎ SpaceXAI Grok <バージョン>」"
    "「✳︎ Anthropic Claude <モデル> <バージョン>」"
    "「✳︎ OpenAI GPT-<バージョン>[-サブバージョン]」"
)

# gh CLI の投稿系サブコマンド（merge は本文空が正なので対象外）
GH_POSTING = re.compile(r"\bgh\s+(issue|pr)\s+(create|comment|review|edit)\b|\bgh\s+api\b")
# MCP の GitHub 投稿系ツール名
MCP_TARGET = re.compile(r"issue|pull_request|\bpr\b|comment|review", re.I)
MCP_WRITE = re.compile(r"write|create|add|save|comment|review|update|reply", re.I)
# 本文が入りうる MCP パラメータ名
BODY_KEYS = ("body", "comment", "description", "text", "message")


def respond(permission, user_message="", agent_message=""):
    result = {"permission": permission}
    if user_message:
        result["user_message"] = result["userMessage"] = user_message
    if agent_message:
        result["agent_message"] = result["agentMessage"] = agent_message
    print(json.dumps(result, ensure_ascii=False))
    sys.exit(0)


def allow():
    respond("allow")


def extract_shell_bodies(command):
    import shlex
    try:
        tokens = shlex.split(command)
    except ValueError:
        tokens = command.split()
    bodies = []
    i = 0
    while i < len(tokens):
        t = tokens[i]
        nxt = tokens[i + 1] if i + 1 < len(tokens) else None
        if t in ("--body", "-b", "--comment-body") and nxt is not None:
            bodies.append(nxt)
            i += 2
            continue
        if t.startswith("--body="):
            bodies.append(t.split("=", 1)[1])
        elif t in ("--body-file", "--field-file") and nxt is not None:
            try:
                with open(nxt, encoding="utf-8") as f:
                    bodies.append(f.read())
            except OSError:
                pass
            i += 2
            continue
        elif t in ("-f", "-F", "--field", "--raw-field") and nxt is not None:
            if nxt.startswith("body="):
                bodies.append(nxt.split("=", 1)[1])
            i += 2
            continue
        i += 1
    return [b for b in bodies if b.strip()]


def extract_mcp_bodies(tool_input):
    if isinstance(tool_input, str):
        try:
            tool_input = json.loads(tool_input)
        except ValueError:
            return []
    if not isinstance(tool_input, dict):
        return []
    bodies = []
    for key in BODY_KEYS:
        value = tool_input.get(key)
        if isinstance(value, str) and value.strip():
            bodies.append(value)
    return bodies


def check_bodies(bodies, model):
    for body in bodies:
        first_line = body.lstrip().splitlines()[0].strip()
        if BAD_SIGNER.search(first_line):
            respond(
                "deny",
                "Cursor Agent / SpaceXAI Cursor 名義の投稿をブロックしました",
                f"ルーティング先を隠した名義（Cursor Agent / SpaceXAI Cursor 等）では投稿できません。"
                f"現在の実モデルは「{model}」です。{ALLOWED_HELP}"
                f"実モデルに対応する形式で先頭行を書き直して再実行してください。",
            )
        if not SIG_HEAD.match(first_line):
            respond(
                "deny",
                "署名のない Issue / PR 投稿をブロックしました",
                f"本文の先頭行に署名が必要です（署名規約）。{ALLOWED_HELP}"
                f"現在の実モデルは「{model}」です。署名行の次に空行を 1 行入れて本文を続けてください。",
            )
        if not ALLOWED_SIGNATURES.match(first_line):
            respond(
                "deny",
                "許可されていない署名の投稿をブロックしました",
                f"先頭行「{first_line}」は許可された署名形式ではありません。{ALLOWED_HELP}"
                f"現在の実モデルは「{model}」です。実モデルに対応する形式で書き直して再実行してください。",
            )


def main():
    try:
        payload = json.load(sys.stdin)
    except ValueError:
        allow()

    model = payload.get("model") or payload.get("model_id") or "不明（ペイロードに model なし）"
    event = payload.get("hook_event_name", "")

    if event == "beforeShellExecution":
        command = payload.get("command", "")
        if not GH_POSTING.search(command):
            allow()
        bodies = extract_shell_bodies(command)
    elif event == "beforeMCPExecution":
        tool_name = payload.get("tool_name", "")
        if not (MCP_TARGET.search(tool_name) and MCP_WRITE.search(tool_name)):
            allow()
        bodies = extract_mcp_bodies(payload.get("tool_input", {}))
    else:
        allow()

    if not bodies:
        allow()
    check_bodies(bodies, model)
    allow()


if __name__ == "__main__":
    main()
