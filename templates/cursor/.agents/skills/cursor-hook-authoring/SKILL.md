---
name: cursor-hook-authoring
description: "Cursor の Hook（`.cursor/hooks.json` と `.cursor/hooks/` 配下のスクリプト）を作成・変更・デバッグするときに参照する。hooks.json のスキーマ、beforeShellExecution など各イベントのペイロード / レスポンス形式、exit code の意味、fail-open 設計、テスト手順を定義する。"
---

# Cursor Hook の作成規約

## 配置

1. MUST: プロジェクト用 Hook 設定は `<project-root>/.cursor/hooks.json` に置く（ユーザーグローバルは `~/.cursor/hooks.json`）
2. MUST: Hook スクリプトは `.cursor/hooks/` 配下に置き、実行権限（`chmod +x`）を付与する
3. MUST: `hooks.json` の `command` はプロジェクトルートからの相対パス（`./.cursor/hooks/<name>.sh`）で書く

## hooks.json スキーマ

```json
{
  "version": 1,
  "hooks": {
    "<eventName>": [
      {
        "type": "command",
        "command": "./.cursor/hooks/script.sh",
        "matcher": "正規表現",
        "timeout": 10,
        "failClosed": false
      }
    ]
  }
}
```

- `beforeShellExecution` / `afterShellExecution` の `matcher` はシェルコマンド全文に対する正規表現
- `preToolUse` / `postToolUse` の `matcher` はツール種別（`Shell`, `Read`, `Write`, `Task`, `MCP:<tool>`）

## 主なイベント

| イベント | 用途 |
| --- | --- |
| `beforeShellExecution` | シェルコマンド実行前の検査・ブロック・確認（Git ガード等） |
| `afterShellExecution` | 実行結果の記録・監査 |
| `beforeMCPExecution` | MCP ツール呼び出し前の検査 |
| `afterFileEdit` | ファイル編集後のフォーマット・lint |
| `beforeSubmitPrompt` | プロンプト送信前の検査 |
| `stop` | エージェント停止時のフォローアップ（`followup_message`） |

## ペイロードとレスポンス

1. Hook は stdin から JSON を受け取る。`beforeShellExecution` の主要フィールドは `command`（コマンド全文）、`cwd`、`hook_event_name`、`workspace_roots`。`beforeMCPExecution` は `tool_name` と `tool_input`（オブジェクトではなく JSON 文字列で渡される場合があるため両対応する）。共通フィールドの `model` には Auto モードでも解決済みの実モデル名が入るため、モデル依存の判定・メッセージに利用できる
2. stdout に単一の JSON を出力する。`permission` は `allow` / `deny` / `ask`:
   - `deny`: ブロックし、`user_message` をユーザーに通知、`agent_message` をエージェントに返す（自己修正を促す指示を書く）
   - `ask`: 実行前にユーザーへ確認ダイアログを表示する
3. MUST: レスポンスのメッセージキーは snake_case（`user_message` / `agent_message`）と camelCase（`userMessage` / `agentMessage`）の両方を出力する（公式ドキュメントと実装記事で表記が揺れており、両方出せばどちらのバージョンでも動く）
4. exit code: `0` = stdout の JSON を採用、`2` = 強制ブロック、その他 = fail-open（許可）。ブロック必須の Hook は `failClosed: true` を設定する

## 設計規約

1. MUST: 判定不能（stdin 解析失敗・依存コマンド欠如・リポジトリ外）の場合は fail-open で `{"permission":"allow"}` を返し、エージェントの作業を止めない
2. MUST: JSON 解析は `jq` → `python3` の順にフォールバックする
3. MUST: メッセージに変数を埋め込む場合は JSON エスケープする
4. NEVER: `git rev-parse --git-dir` の相対パス（`.git`）をそのまま使用しない; MUST: `--absolute-git-dir` を使用する（Hook のカレントディレクトリと対象リポジトリは一致しない）
5. NEVER: stdout に JSON 以外（デバッグ出力等）を混ぜない; デバッグは stderr またはファイルに出す

## テスト手順

MUST: 変更後は代表ペイロードをパイプして deny / ask / allow の全分岐を確認する:

```sh
jq -n --arg cmd 'git add .' --arg cwd "$PWD" '{command:$cmd, cwd:$cwd}' \
  | ./.cursor/hooks/git-guard.sh
```
