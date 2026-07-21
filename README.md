# philtzjp/startingpoint

<img src="https://github.com/philtzjp/.github/blob/main/images/philtz.png?raw=true" width="150px" alt="Philtz Logo">

startingpoint は、Philtz の新規リポジトリを始めるための共通テンプレートです。

> startingpoint is a shared template for starting new Philtz repositories.

AI エージェント向けの作業規約、Claude Code 向けの参照リンク、Git hook、Issue Template、テンプレート利用時の権利帰属の前提をまとめ、リポジトリ作成直後から同じ運用ルールで開発を始められるようにします。

---

## Features

このテンプレートが提供する内容は以下の通りです。

- `AGENTS.md` による AI エージェント向け作業規約
- `CLAUDE.md` から `AGENTS.md` へのシンボリックリンク
- `AGENTS.md` の「スキル導入」による `philtzjp/skills` からの必要スキル導入手順
- `lefthook.yaml` によるコミット前・push 前・コミットメッセージ検証（`claude -p` を使用し、実行できない場合は `codex exec` にフォールバック）
- `scripts/refresh-skills.sh` によるスキル表と `.claude/skills/` シンボリックリンクの整合性検査・修復
- `.github/ISSUE_TEMPLATE.md` / `ISSUE_COMMENT_TEMPLATE.md` / `PULL_REQUEST_TEMPLATE.md` / `RELEASE_TEMPLATE.md` による Issue・PR・Release テンプレート
- MIT License によるライセンス表示

Cursor を使う場合のみ、オプションで以下を `./scripts/install-cursor.sh` から導入できます（テンプレート本体には含めません）。

- `.cursor/hooks.json` と Hook スクリプト（Git 操作ガード、GitHub 投稿の署名検証）
- `.cursor/environment.json`（Cursor Cloud Agent 向けの lefthook 導入と起動時スキル検査）
- リポジトリ固有スキル `cursor-hook-authoring`
- `AGENTS.md` への Cursor 向け規約（ブランチ運用、環境変数、署名規約）の追記

## Usage

このリポジトリをテンプレートとして利用する場合は、作成先のリポジトリで以下を確認してください。

- `AGENTS.md` のルールがプロジェクトの実情に合っていること
- `AGENTS.md` の「スキル導入」に従って `philtzjp/skills` の `AGENTS.md` を取得し、`refresh-skills` と `skill-escalation` を必ず導入すること
- 必要なスキルだけを `philtzjp/skills` から追加導入すること
- 導入後の `.agents/skills` の内容が実装予定の技術スタックに合っていること
- `AGENTS.md` のスキル表が `.agents/skills` 配下の実体と一致していること
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

導入後は Cursor のワークスペースをリロードし、`commit-and-git` スキルを `philtzjp/skills` から導入してください（`.cursor/hooks/git-guard.sh` が参照する規約です）。

参考実装: [artouc/cursor](https://github.com/artouc/cursor)（startingpoint をベースに Cursor 向け構成をすべて有効化したリポジトリ）

## Repository Structure

```text
.
├── .github/ISSUE_TEMPLATE.md
├── .github/ISSUE_COMMENT_TEMPLATE.md
├── .github/PULL_REQUEST_TEMPLATE.md
├── .github/RELEASE_TEMPLATE.md
├── scripts/
│   ├── refresh-skills.sh       # スキル表・シンボリックリンクの整合性検査
│   └── install-cursor.sh       # Cursor 向けオーバーレイの導入（任意）
├── templates/cursor/           # install-cursor.sh が配置する Cursor 向けファイル群
│   ├── .cursor/
│   ├── .agents/skills/cursor-hook-authoring/
│   └── AGENTS.append.md
├── AGENTS.md
├── CLAUDE.md -> AGENTS.md
├── LICENSE
└── lefthook.yaml
```

導入したスキルは `.agents/skills/<name>/SKILL.md` に配置し、`.claude/skills/<name>` から `../../.agents/skills/<name>` への相対シンボリックリンクを作成する（`AGENTS.md` の「スキル導入」を参照）。

## Rights

このテンプレート自体は MIT License の下で公開しています。詳細は [LICENSE](LICENSE) を参照してください。

作成先リポジトリ全体に適用するライセンスや権利表示は、そのリポジトリ側で必要に応じて明示してください。

## Build with LLM

このテンプレートは、LLM を用いる開発ワークフローを前提に整備されています。
