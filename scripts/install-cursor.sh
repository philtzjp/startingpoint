#!/usr/bin/env bash
# Cursor 向けオーバーレイ（Hook / Cloud Agent 環境 / AGENTS.md への規約追記）を導入する。
#
# startingpoint は Cursor 非前提のため、Cursor を使うリポジトリだけが本スクリプトを実行する。
# テンプレート本体は templates/cursor/ に置き、リポジトリルートへコピーする。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="$ROOT/templates/cursor"
PREFIX="[install-cursor]"

if [ ! -d "$TEMPLATE/.cursor" ]; then
  echo "$PREFIX templates/cursor/.cursor がありません。startingpoint のテンプレート構成を確認してください" >&2
  exit 1
fi

if [ -f "$ROOT/.cursor/hooks.json" ]; then
  echo "$PREFIX .cursor/ は既に存在します。上書きする場合は .cursor/ を削除してから再実行してください"
  exit 1
fi

echo "$PREFIX .cursor/ を配置します"
cp -R "$TEMPLATE/.cursor" "$ROOT/.cursor"
chmod +x "$ROOT/.cursor/hooks/"*.sh "$ROOT/.cursor/hooks/"*.py 2>/dev/null || true

if [ -f "$ROOT/AGENTS.md" ] && ! grep -q 'cursor-overlay-begin' "$ROOT/AGENTS.md"; then
  echo "$PREFIX AGENTS.md の末尾に Cursor 向け規約を追記します"
  printf '\n' >> "$ROOT/AGENTS.md"
  cat "$TEMPLATE/AGENTS.append.md" >> "$ROOT/AGENTS.md"
elif grep -q 'cursor-overlay-begin' "$ROOT/AGENTS.md"; then
  echo "$PREFIX AGENTS.md には既に Cursor 向け規約が含まれています"
else
  echo "$PREFIX 警告: AGENTS.md が見つかりません。Cursor 向け規約は手動で templates/cursor/AGENTS.append.md を追記してください"
fi

cat <<EOF
$PREFIX 完了しました。次を確認してください:

  1. Cursor のワークスペースをリロードする（Hook を読み込むため）
  2. lefthook install を実行する（未導入の場合）
  3. github と cursor-hook-authoring スキルをホームに導入する（git-guard.sh が参照する規約）
       DISABLE_TELEMETRY=1 npx skills add philtzjp/skills -g -a cursor -s github -s cursor-hook-authoring -y
  4. Cursor Cloud を使う場合は .cursor/environment.json の install が lefthook を、start が npx skills でスキルを導入する

Hook の動作確認例:

  jq -n --arg cmd 'git add .' --arg cwd "\$PWD" '{command:\$cmd, cwd:\$cwd}' \\
    | ./.cursor/hooks/git-guard.sh
EOF
