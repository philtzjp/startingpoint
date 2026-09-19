# philtzjp/startingpoint

startingpoint は、Philtz の新規リポジトリを始めるための共通テンプレートです。

> startingpoint is a shared template for starting new Philtz repositories.

AI エージェントが作業前に読む手順（`START.md`）、Git hook、Issue Template、テンプレート利用時の権利帰属の前提をまとめ、リポジトリ作成直後から同じ運用ルールで開発を始められるようにします。

---

## Philtz のリポジトリで開発する人へ

使っているエージェント（Claude Code、Codex、Cursor など）に、次の文章をそのまま貼り付けてください。スキルの導入や Git の注意点は、エージェントが `START.md` を読んで対応します。

```text
https://raw.githubusercontent.com/philtzjp/startingpoint/main/START.md を curl で取得して全文を読み、書かれている手順に従ってください。
```

## Features

このテンプレートが提供する内容は以下の通りです。

- `START.md`：エージェントが作業前に読む手順の正本。スキルの導入と更新、メモリより最新版を優先すること、古いスキルの移行、コミットの記録者の確認、事故を防ぐ要点を定めます
- `AGENTS.md`：`START.md` の正本を読む案内。`CLAUDE.md` は `AGENTS.md` へのシンボリックリンクです
- `.vite-hooks/` の pre-commit・pre-push・commit-msg による検証（コミットメッセージの検査は `claude -p` を使用し、実行できない場合は `codex exec` にフォールバック）。`git config core.hooksPath .vite-hooks` で有効になります
- `.github/ISSUE_TEMPLATE.md` / `ISSUE_COMMENT_TEMPLATE.md` / `PULL_REQUEST_TEMPLATE.md` / `RELEASE_TEMPLATE.md` による Issue・PR・Release テンプレート

スキルは [philtzjp/skills](https://github.com/philtzjp/skills) を正本とし、各メンバーのホームに `npx skills` で導入します。リポジトリにはコピーしません。

Cursor 向けの `.cursor/hooks.json`、`.cursor/environment.json`、`AGENTS.md` への追記は、このテンプレートでは扱いません。必要な場合は [artouc/cursor](https://github.com/artouc/cursor) を参照してください。

## Usage

このリポジトリをテンプレートとして利用する場合は、作成先のリポジトリで以下を確認してください。

- テンプレートからコピーされた `START.md` を削除すること（正本は本リポジトリの `START.md` で、エージェントは raw URL から読みます）
- リポジトリ固有の規約があれば `AGENTS.md` の案内の下に書くこと
- `.github/ISSUE_TEMPLATE.md` の `scope` 例がプロジェクトのディレクトリ構成に合っていること
- `.github/RELEASE_TEMPLATE.md` の内容がプロジェクトの配布物・リリース運用に合っていること
- 作成先リポジトリに適用するライセンスや権利表示を決め、必要なら `LICENSE` を追加すること（本テンプレートは `LICENSE` を含みません）
- `.vite-hooks/` の検証内容がチームのコミット運用に合っていること
- `git config core.hooksPath .vite-hooks` を実行して git hook を有効化すること（clone ごとのローカル設定なので、作業環境を作るたびに実行します）

## Repository Structure

```text
.
├── .github/ISSUE_TEMPLATE.md
├── .github/ISSUE_COMMENT_TEMPLATE.md
├── .github/PULL_REQUEST_TEMPLATE.md
├── .github/RELEASE_TEMPLATE.md
├── .vite-hooks/                # core.hooksPath が指す git hook
│   ├── commit-msg              # type(scope): 説明 の1行か、署名の混入が無いかを検査
│   ├── pre-commit              # 暗号化されていない .env* の混入を検査
│   └── pre-push                # リモートの状態が古いまま push するのを防ぐ
├── AGENTS.md                   # START.md を読む案内
├── CLAUDE.md -> AGENTS.md
└── START.md                    # エージェントが作業前に読む手順の正本
```

## Rights

このテンプレートにはライセンスファイルを含めていません。テンプレートから作成したリポジトリに、意図しないライセンスがそのまま付くのを防ぐためです。

作成先リポジトリに適用するライセンスや権利表示は、そのリポジトリ側で決めて明示してください。

## Build with LLM

このテンプレートは、LLM を用いる開発ワークフローを前提に整備されています。
