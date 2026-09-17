# philtzjp/startingpoint

<img src="https://github.com/philtzjp/.github/blob/main/images/philtz.png?raw=true" width="150px" alt="Philtz Logo">

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
- `lefthook.yaml` によるコミット前・push 前・コミットメッセージ検証（`claude -p` を使用し、実行できない場合は `codex exec` にフォールバック）
- `.github/ISSUE_TEMPLATE.md` / `ISSUE_COMMENT_TEMPLATE.md` / `PULL_REQUEST_TEMPLATE.md` / `RELEASE_TEMPLATE.md` による Issue・PR・Release テンプレート
- MIT License によるライセンス表示

スキルは [philtzjp/skills](https://github.com/philtzjp/skills) を正本とし、各メンバーのホームに `npx skills` で導入します。リポジトリにはコピーしません。

Cursor を使う場合のみ、オプションで以下を `./scripts/install-cursor.sh` から導入できます（テンプレート本体には含めません）。

- `.cursor/hooks.json` と Hook スクリプト（Git 操作ガード、GitHub 投稿の署名検証）
- `.cursor/environment.json`（Cursor Cloud Agent 向けの lefthook 導入と、起動時の `npx skills` によるスキル導入）
- `AGENTS.md` への Cursor 向け規約（ブランチ運用、環境変数、署名規約）の追記

## Usage

このリポジトリをテンプレートとして利用する場合は、作成先のリポジトリで以下を確認してください。

- テンプレートからコピーされた `START.md` を削除すること（正本は本リポジトリの `START.md` で、エージェントは raw URL から読みます）
- リポジトリ固有の規約があれば `AGENTS.md` の案内の下に書くこと
- `.github/ISSUE_TEMPLATE.md` の `scope` 例がプロジェクトのディレクトリ構成に合っていること
- `.github/RELEASE_TEMPLATE.md` の内容がプロジェクトの配布物・リリース運用に合っていること
- 作成先リポジトリに適用するライセンスや権利表示を必要に応じて見直すこと
- `lefthook.yaml` の検証内容がチームのコミット運用に合っていること
- `lefthook install` を実行して git hook を有効化すること

### Cursor を使う場合（任意）

Cursor（Agent / Composer / Cloud Agent）を使うリポジトリだけ、プロジェクトルートで次を実行します。

```sh
chmod +x scripts/install-cursor.sh
./scripts/install-cursor.sh
```

導入後は Cursor のワークスペースをリロードし、`.cursor/hooks/git-guard.sh` が参照する github スキルと、Hook を扱うときの cursor-hook-authoring スキルをホームに導入してください。

```sh
DISABLE_TELEMETRY=1 npx skills add philtzjp/skills -g -a cursor -s github -s cursor-hook-authoring -y
```

参考実装: [artouc/cursor](https://github.com/artouc/cursor)（startingpoint をベースに Cursor 向け構成をすべて有効化したリポジトリ）

## Repository Structure

```text
.
├── .github/ISSUE_TEMPLATE.md
├── .github/ISSUE_COMMENT_TEMPLATE.md
├── .github/PULL_REQUEST_TEMPLATE.md
├── .github/RELEASE_TEMPLATE.md
├── scripts/
│   └── install-cursor.sh       # Cursor 向けオーバーレイの導入（任意）
├── templates/cursor/           # install-cursor.sh が配置する Cursor 向けファイル群
│   ├── .cursor/
│   └── AGENTS.append.md
├── AGENTS.md                   # START.md を読む案内
├── CLAUDE.md -> AGENTS.md
├── START.md                    # エージェントが作業前に読む手順の正本
├── LICENSE
└── lefthook.yaml
```

## Rights

このテンプレート自体は MIT License の下で公開しています。詳細は [LICENSE](LICENSE) を参照してください。

作成先リポジトリ全体に適用するライセンスや権利表示は、そのリポジトリ側で必要に応じて明示してください。

## Build with LLM

このテンプレートは、LLM を用いる開発ワークフローを前提に整備されています。
