# philtzjp/startingpoint

startingpoint は、Philtz の新規リポジトリを始めるための共通テンプレートです。

> startingpoint is a shared template for starting new Philtz repositories.

テンプレートに入れるのは、リポジトリに置くしかないものだけです。手順や規約は写すと古くなるので、次の正本から読みます。

| 内容 | 正本 |
| --- | --- |
| エージェントが作業前に読む手順 | このリポジトリの `START.md` |
| Git と GitHub の規約、日本語の書き方など | [philtzjp/skills](https://github.com/philtzjp/skills) のスキル |
| Issue と PR のテンプレート | [philtzjp/.github](https://github.com/philtzjp/.github) の org の既定 |
| Issue、PR、コミットメッセージの書式 | [philtzjp/pulumi](https://github.com/philtzjp/pulumi) の `.github/conventions.yml` |

---

## Philtz のリポジトリで開発する人へ

使っているエージェント（Claude Code、Codex、Cursor など）に、次の文章をそのまま貼り付けてください。スキルの導入や Git の注意点は、エージェントが `START.md` を読んで対応します。AGENTS.md があるリポジトリでは、貼り付けなくてもエージェントが自分で読みます。

```text
https://raw.githubusercontent.com/philtzjp/startingpoint/main/START.md を curl で取得して全文を読み、書かれている手順に従ってください。
```

## Features

- `AGENTS.md`: `START.md` の正本を読む案内と、スキルを入れるコマンド。Claude Code は CLAUDE.md がなければ AGENTS.md を読むので、CLAUDE.md は置きません
- `.gitignore`: リポジトリごとに入れたスキルをコミットしない設定
- `.vite-hooks/`: pre-commit、pre-push、commit-msg の git hook。`git config core.hooksPath .vite-hooks` で有効になります

## Usage

新しいリポジトリは philtzjp/pulumi の宣言から作ります。このテンプレートから作ったリポジトリでは、次を確認してください。

- 入れるスキルを足すときは、`AGENTS.md` のコマンドに `-s <スキル名>` を足すこと
- リポジトリ固有の規約があれば、`AGENTS.md` の案内の下に書くこと
- リポジトリ固有のスキルをコミットするときは、`.gitignore` を次のように書き換え、固有のスキルだけを戻すこと

  ```gitignore
  .agents/skills/*
  !.agents/skills/<固有のスキル名>/
  .claude/skills/*
  !.claude/skills/<固有のスキル名>
  skills-lock.json
  ```

- 適用するライセンスや権利表示を決め、必要なら `LICENSE` を足すこと。このテンプレートは `LICENSE` を含みません
- `git config core.hooksPath .vite-hooks` を実行して git hook を有効にすること。clone ごとの設定なので、作業環境を作るたびに実行します

## Repository Structure

```text
.
├── .vite-hooks/
│   ├── commit-msg   # type(scope): 説明 の 1 行か、署名の混入がないかを検査
│   ├── pre-commit   # 暗号化されていない .env* の混入を検査
│   └── pre-push     # リモートの状態が古いまま push するのを防ぐ
├── .gitignore       # リポジトリごとに入れたスキルを無視する
├── AGENTS.md        # START.md を読む案内と、スキルを入れるコマンド
├── README.md
└── START.md         # エージェントが作業前に読む手順の正本。テンプレートから作るときには写さない
```

## Rights

このテンプレートにはライセンスファイルを含めていません。テンプレートから作成したリポジトリに、意図しないライセンスがそのまま付くのを防ぐためです。

作成先リポジトリに適用するライセンスや権利表示は、そのリポジトリ側で決めて明示してください。
