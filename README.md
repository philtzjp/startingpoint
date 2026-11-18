# philtzjp/startingpoint

startingpoint は、Philtz の新規リポジトリを始めるための共通テンプレートです。

> startingpoint is a shared template for starting new Philtz repositories.

テンプレートに入れるのは、リポジトリに置くしかないものだけです。手順や規約は写すと古くなるので、次の正本から読みます。

| 内容                                     | 正本                                                                         |
| ---------------------------------------- | ---------------------------------------------------------------------------- |
| エージェントが作業前に読む手順           | このリポジトリの `START.md`                                                  |
| Git と GitHub の規約、日本語の書き方など | [philtzjp/skills](https://github.com/philtzjp/skills) のスキル               |
| Issue と PR のテンプレート               | [philtzjp/.github](https://github.com/philtzjp/.github) の org の既定        |
| Issue、PR、コミットメッセージの書式      | [philtzjp/.github](https://github.com/philtzjp/.github) の `conventions.yml` |

---

## Philtz のリポジトリで開発する人へ

使っているエージェント（Claude Code、Codex、Cursor など）に、次の文章をそのまま貼り付けてください。スキルの導入や Git の注意点は、エージェントが `START.md` を読んで対応します。AGENTS.md があるリポジトリでは、貼り付けなくてもエージェントが自分で読みます。

```text
https://raw.githubusercontent.com/philtzjp/startingpoint/main/START.md を curl で取得して全文を読み、書かれている手順に従ってください。
```

## Features

- `package.json`: スキルを入れるコマンドを `skills` に置き、`postinstall` から呼ぶ。`vp install` のたびにスキルが最新になる。`postinstall` は CI の中と `.git` のない場所では動かさない。`prepare` で `vp config` を呼び、git hook を有効にする
- `AGENTS.md`: `START.md` の正本を読む案内と、スキルを入れ直すコマンド。Claude Code は CLAUDE.md がなければ AGENTS.md を読むので、CLAUDE.md は置きません
- `.gitignore`: リポジトリごとに入れたスキルをコミットしない設定
- `.vite-hooks/`: pre-commit、pre-push、commit-msg の git hook。`vp install` で有効になります。commit-msg は、conventions スキルの検査器を呼んで正本の規約で検査します
- `vite.config.ts`: [Vite+](https://viteplus.dev/) の設定。`vp check` で型、lint、整形を検査し、`vp staged` でコミットするファイルを整形します
- `.fallowrc.jsonc`: [fallow](https://github.com/fallow-rs/fallow) の設定。未使用のファイル、export、依存、重複、複雑度、セキュリティの検査をすべて error にしています
- `tsconfig.json`: strict に加え、`exactOptionalPropertyTypes` や `noUncheckedIndexedAccess` などの厳しい検査を有効にした設定

## Usage

新しいリポジトリは philtzjp/pulumi の宣言から作ります。このテンプレートから作ったリポジトリでは、次を確認してください。

- 入れるスキルを足すときは、`package.json` の `skills` に `-s <スキル名>` を足すこと。`pnpm init` は使わず、このファイルに依存を足していくこと
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
- `vp install` を実行して git hook を有効にすること。`prepare` の `vp config` が `core.hooksPath` を設定します。clone ごとの設定なので、作業環境を作るたびに実行します
- fallow の `production` は有効にしてあるので、テストや設定ファイルは検査の対象外です。エントリポイントが `src/index.ts` などの既定と違う場合は、`.fallowrc.jsonc` の `entry` に足すこと

## Repository Structure

```text
.
├── .vite-hooks/
│   ├── commit-msg      # conventions スキルの検査器で、コミットメッセージを正本の規約で検査
│   ├── pre-commit      # vp staged で整形
│   └── pre-push        # vp check と fallow で検査
├── .fallowrc.jsonc     # fallow の設定
├── .gitignore          # リポジトリごとに入れたスキルを無視する
├── AGENTS.md           # START.md を読む案内と、スキルを入れ直すコマンド
├── package.json        # skills にスキルを入れるコマンド。postinstall から呼ぶ。prepare で git hook を有効にする
├── pnpm-lock.yaml
├── README.md
├── START.md            # エージェントが作業前に読む手順の正本。テンプレートから作るときには写さない
├── tsconfig.json
└── vite.config.ts      # Vite+ の設定
```

## Rights

このテンプレートにはライセンスファイルを含めていません。テンプレートから作成したリポジトリに、意図しないライセンスがそのまま付くのを防ぐためです。

作成先リポジトリに適用するライセンスや権利表示は、そのリポジトリ側で決めて明示してください。
