# startingpoint

<img src="https://github.com/philtzjp/.github/blob/main/images/philtz.png?raw=true" width="150px" alt="Philtz Logo">

startingpoint は、Philtz の新規リポジトリを始めるための共通テンプレートです。

> startingpoint is a shared template for starting new Philtz repositories.

AI エージェント向けの作業規約、Claude Code 向けの参照リンク、Git hook、Issue Template、テンプレート利用時の権利帰属の前提をまとめ、リポジトリ作成直後から同じ運用ルールで開発を始められるようにします。

---

## Features

このテンプレートが提供する内容は以下の通りです。

- `AGENTS.md` による AI エージェント向け作業規約
- `CLAUDE.md` から `AGENTS.md` へのシンボリックリンク
- `.agents/skills/skill-setup` による `philtzjp/skills` からの必要スキル同期
- `.claude/skills/skill-setup` から `.agents/skills/skill-setup` へのシンボリックリンク
- `lefthook.yaml` によるコミット前・コミットメッセージ検証
- `.github/ISSUE_TEMPLATE/task.md` によるタスク起票テンプレート
- テンプレート利用時の権利帰属に関する前提の明記

## Usage

このリポジトリをテンプレートとして利用する場合は、作成先のリポジトリで以下を確認してください。

- `AGENTS.md` のルールがプロジェクトの実情に合っていること
- `skill-setup` を使って、必要なスキルだけを `philtzjp/skills` から同期すること
- 同期後の `.agents/skills` の内容が実装予定の技術スタックに合っていること
- `.github/ISSUE_TEMPLATE/task.md` の `scope` 例がプロジェクトのディレクトリ構成に合っていること
- 作成先リポジトリに適用するライセンスや権利表示を必要に応じて設定すること
- `lefthook.yaml` の検証内容がチームのコミット運用に合っていること

## Repository Structure

```text
.
├── .agents/skills/skill-setup/
├── .claude/skills/skill-setup -> ../../.agents/skills/skill-setup
├── .github/ISSUE_TEMPLATE/task.md
├── AGENTS.md
├── CLAUDE.md -> AGENTS.md
├── LICENSE
└── lefthook.yaml
```

## Rights

このテンプレート自体には、現時点で明示的なオープンソースライセンスを設定していません。詳細は [LICENSE](LICENSE) を参照してください。

このテンプレートを用いて作成されたリポジトリのうち、そのリポジトリの製作者が独自に作成・追加したコード、文書、資産、その他の成果物の権利は、その製作者に帰属します。

作成先リポジトリ全体に適用するライセンスや権利表示は、そのリポジトリ側で明示してください。

## Build with LLM

このテンプレートは、LLM を用いる開発ワークフローを前提に整備されています。
