#!/usr/bin/env bash
# refresh-skills スキルの機械的検査・修復を行う。
#
# 手動実行、または Cursor Cloud 利用時（.cursor/environment.json の start）に実行される想定:
#   1. .agents/skills/<name> ごとに .claude/skills/<name> の相対シンボリックリンクを検査・修復する
#   2. .claude/skills/ 配下のリンク切れシンボリックリンクを削除する
#   3. AGENTS.md のスキル表と .agents/skills/ 配下の実体を突合し、乖離を警告する
#   4. --upstream 指定時のみ、philtzjp/skills の正本と導入済みスキルの差分を報告する
#
# 判断が必要な修復（スキル表の文言、上流との差分の取り込み）は行わず、
# 警告の出力に留める。boot を止めないため常に exit 0 で終了する。
set -u
cd "$(dirname "$0")/.." || exit 0

AGENTS_DIR=.agents/skills
CLAUDE_DIR=.claude/skills
UPSTREAM_REPO=https://github.com/philtzjp/skills.git
PREFIX="[refresh-skills]"

[ -d "$AGENTS_DIR" ] || { echo "$PREFIX $AGENTS_DIR がありません。スキル未導入としてスキップします"; exit 0; }
mkdir -p "$CLAUDE_DIR"

# 1. 正本ごとにシンボリックリンクを検査・修復する
for dir in "$AGENTS_DIR"/*/; do
  [ -d "$dir" ] || continue
  name=$(basename "$dir")
  link="$CLAUDE_DIR/$name"
  expected="../../$AGENTS_DIR/$name"
  if [ -L "$link" ]; then
    actual=$(readlink "$link")
    if [ "$actual" != "$expected" ]; then
      ln -sfn "$expected" "$link"
      echo "$PREFIX 修復: $link のリンク先を $actual から $expected に直しました"
    fi
  elif [ -e "$link" ]; then
    echo "$PREFIX 警告: $link がシンボリックリンクではなく実体です。正本は $AGENTS_DIR/$name に置き、手動で置き換えてください"
  else
    ln -s "$expected" "$link"
    echo "$PREFIX 修復: $link を作成しました"
  fi
done

# 2. リンク切れシンボリックリンクを削除する
for link in "$CLAUDE_DIR"/*; do
  [ -L "$link" ] || continue
  if [ ! -e "$link" ]; then
    rm "$link"
    echo "$PREFIX 修復: リンク切れの $link を削除しました"
  fi
done

# 3. AGENTS.md のスキル表と実体を突合する
if [ -f AGENTS.md ]; then
  table_skills=$(grep -oE '^\| `[a-z0-9-]+` \|' AGENTS.md | sed 's/^| `//; s/` |$//' | sort)
  dir_skills=$(find "$AGENTS_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)
  only_table=$(comm -23 <(printf '%s\n' "$table_skills") <(printf '%s\n' "$dir_skills") | grep -v '^$' || true)
  only_dir=$(comm -13 <(printf '%s\n' "$table_skills") <(printf '%s\n' "$dir_skills") | grep -v '^$' || true)
  [ -n "$only_table" ] && echo "$PREFIX 警告: スキル表にあるが実体がないスキル: $(echo "$only_table" | tr '\n' ' ')"
  [ -n "$only_dir" ] && echo "$PREFIX 警告: 実体があるがスキル表にないスキル: $(echo "$only_dir" | tr '\n' ' ')"
  if [ -z "$only_table" ] && [ -z "$only_dir" ]; then
    echo "$PREFIX スキル表と実体は一致しています（$(printf '%s\n' "$dir_skills" | grep -c .) 件）"
  fi
fi

# 4. 上流との差分確認（--upstream 指定時のみ、失敗しても無視）
if [ "${1:-}" = "--upstream" ]; then
  tmp=$(mktemp -d)
  if git clone --quiet --depth 1 "$UPSTREAM_REPO" "$tmp/skills" 2>/dev/null; then
    for dir in "$AGENTS_DIR"/*/; do
      name=$(basename "$dir")
      upstream_md="$tmp/skills/$AGENTS_DIR/$name/SKILL.md"
      [ -f "$upstream_md" ] || continue
      if ! diff -q "$dir/SKILL.md" "$upstream_md" >/dev/null 2>&1; then
        echo "$PREFIX 情報: $name は上流と差分があります（ローカル改変または上流更新。skill-escalation / refresh-skills を参照）"
      fi
    done
  else
    echo "$PREFIX 情報: 上流 $UPSTREAM_REPO に到達できないため差分確認をスキップしました"
  fi
  rm -rf "$tmp"
fi

exit 0
