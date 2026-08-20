#!/usr/bin/env bash
# Cursor beforeShellExecution hook: Git 操作ガード
#
# エージェントが実行しようとするシェルコマンドを実行前に検査し、
# commit-and-git スキル / lefthook.yaml の規約に反する Git 操作を
# deny（ブロック + 通知）または ask（ユーザー確認）に振り分ける。
#
# stdin:  {"command": "...", "cwd": "...", ...}
# stdout: {"permission": "allow|deny|ask", "user_message": "...", "agent_message": "..."}
#         互換のため snake_case / camelCase 両方のキーを出力する。
# exit:   常に 0（判定は JSON で返す）。解析不能時は fail-open で allow。
set -u

INPUT=$(cat)

json_field() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$INPUT" | jq -r --arg k "$1" '.[$k] // ""'
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$INPUT" | python3 -c 'import json,sys; d=json.load(sys.stdin); v=d.get(sys.argv[1],""); print(v if v is not None else "")' "$1"
  else
    printf ''
  fi
}

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' ' '
}

respond() {
  local perm="$1" user_msg="$2" agent_msg="$3"
  local u a
  u=$(json_escape "$user_msg")
  a=$(json_escape "$agent_msg")
  printf '{"permission":"%s","user_message":"%s","agent_message":"%s","userMessage":"%s","agentMessage":"%s"}\n' \
    "$perm" "$u" "$a" "$u" "$a"
  exit 0
}

allow() { printf '{"permission":"allow"}\n'; exit 0; }
deny()  { respond "deny" "$1" "$2"; }
ask()   { respond "ask"  "$1" "$2"; }

COMMAND=$(json_field "command")
CWD=$(json_field "cwd")
[ -z "$COMMAND" ] && allow
case "$COMMAND" in
  *git*|*gh\ *) ;;
  *) allow ;;
esac

# --- リポジトリ情報（cwd がリポジトリ外なら関連チェックをスキップ） ---
# コミット・プッシュ時点で検証できる規約（メッセージ形式、Co-Authored-By 禁止、
# デフォルトブランチ保護、fetch 鮮度）は lefthook.yaml が担う。
# 本 Hook は git hook が存在しないタイミングの操作だけを守る。
BRANCH=""
if [ -n "$CWD" ] && git -C "$CWD" rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git -C "$CWD" symbolic-ref --short -q HEAD 2>/dev/null || true)
fi

# ============================================================
# deny: 規約上の NEVER（ブロックして正しい手順をエージェントに指示）
# ============================================================

# git add . / -A / --all の禁止
if printf '%s' "$COMMAND" | grep -qE 'git[[:space:]]+add[[:space:]]+(-A([[:space:]]|$)|--all([[:space:]]|$)|\.([[:space:]]|$)|.*[[:space:]]\.([[:space:]]|$))'; then
  deny "git add . / -A はブロックしました（commit-and-git 規約）" \
       "git add . / git add -A は禁止です。コミット対象のファイルをパス指定で明示的に git add してください。"
fi

# force push の禁止（--force-with-lease は ask に降格）
if printf '%s' "$COMMAND" | grep -qE 'git[[:space:]]+push[^|;&]*(--force([[:space:]]|$)|[[:space:]]-f([[:space:]]|$))'; then
  deny "git push --force をブロックしました" \
       "force push は禁止です。履歴の書き換えが本当に必要ならユーザーに理由を説明し、--force-with-lease の使用可否を確認してください。"
fi

# squash merge の禁止
if printf '%s' "$COMMAND" | grep -qE 'gh[[:space:]]+pr[[:space:]]+merge[^|;&]*--squash|git[[:space:]]+merge[^|;&]*--squash'; then
  deny "squash merge をブロックしました" \
       "squash merge は禁止です。gh pr merge <番号> --merge --subject \"merge(scope): 説明\" --body \"\" を使用してください。"
fi

# ============================================================
# ask: 破壊的・要ユーザー承認の操作（実行前にユーザーへ確認通知）
# ============================================================

# 作業ツリー・履歴を破壊しうる操作
if printf '%s' "$COMMAND" | grep -qE 'git[[:space:]]+reset[[:space:]]+--hard|git[[:space:]]+clean[[:space:]]+-[a-zA-Z]*f|git[[:space:]]+checkout[[:space:]]+(--[[:space:]]+)?\.([[:space:]]|$)|git[[:space:]]+restore[[:space:]]+\.([[:space:]]|$)|git[[:space:]]+stash[[:space:]]+(drop|clear)'; then
  ask "未コミットの変更が失われる可能性のある Git 操作です。実行を許可しますか？" \
      "作業ツリーまたは stash を破壊する操作です。ユーザーの承認を待ってください。"
fi

# ユーザー承認なしの pull / rebase の禁止（要承認）
if printf '%s' "$COMMAND" | grep -qE 'git[[:space:]]+(pull|rebase)([[:space:]]|$)'; then
  ask "git pull / git rebase の実行にはユーザーの承認が必要です。許可しますか？" \
      "git pull / git rebase はユーザーの承認なしに実行できません。承認を待ってください。"
fi

# プラットフォーム管理ブランチ（Cursor Cloud: cursor/*、Claude Code: claude/*）の保護
# 改名・付け替えするとクラウドセッションや PR の追跡が切れるため deny、
# その上での新規ブランチ作成（作業の分岐）は ask にする
case "$BRANCH" in
  cursor/*|claude/*)
    if printf '%s' "$COMMAND" | grep -qE 'git[[:space:]]+branch[^|;&]*[[:space:]]-[a-zA-Z]*[mM]([[:space:]]|$)'; then
      deny "プラットフォーム管理ブランチ（$BRANCH）の改名をブロックしました" \
           "$BRANCH は Cursor Cloud / Claude Code が自動生成・追跡しているブランチです。改名するとセッションや PR の追跡が切れます。ブランチ名は変更せず、命名規則はコミットメッセージと PR タイトルで満たしてください。"
    fi
    if printf '%s' "$COMMAND" | grep -qE 'git[[:space:]]+checkout[^|;&]*[[:space:]]-[a-zA-Z]*b|git[[:space:]]+switch[^|;&]*[[:space:]]-[a-zA-Z]*c'; then
      ask "クラウドセッションのブランチ（$BRANCH）から新しいブランチを作ろうとしています。許可しますか？" \
          "現在のブランチはプラットフォームが追跡しています。別ブランチへ移ると以後の push がセッションに反映されない可能性があります。ユーザーの承認を待ってください。"
    fi
    ;;
esac

# ブランチ削除（要確認）
if printf '%s' "$COMMAND" | grep -qE 'git[[:space:]]+branch[^|;&]*[[:space:]]-[a-zA-Z]*[dD]([[:space:]]|$)|git[[:space:]]+push[^|;&]*--delete'; then
  ask "ブランチを削除しようとしています。実行を許可しますか？" \
      "ブランチ削除はユーザーの確認が必要です。承認を待ってください。"
fi

# ブランチ切替（新規作成 -b / -c を除く、要確認）
if printf '%s' "$COMMAND" | grep -qE 'git[[:space:]]+(checkout|switch)[[:space:]]' \
  && ! printf '%s' "$COMMAND" | grep -qE 'git[[:space:]]+(checkout|switch)[^|;&]*[[:space:]](-b|-c|--)([[:space:]]|$)' \
  && ! printf '%s' "$COMMAND" | grep -qE 'git[[:space:]]+(checkout|switch)[^|;&]*[[:space:]]-[a-zA-Z]*\.'; then
  ask "ブランチを切り替えようとしています。実行を許可しますか？" \
      "ブランチ切替はユーザーの確認が必要です。承認を待ってください。"
fi

# --force-with-lease の push（要確認）
if printf '%s' "$COMMAND" | grep -qE 'git[[:space:]]+push[^|;&]*--force-with-lease'; then
  ask "--force-with-lease で push しようとしています。実行を許可しますか？" \
      "履歴を書き換える push です。ユーザーの承認を待ってください。"
fi

allow
