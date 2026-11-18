## 開発ルール

作業を始める前に、https://raw.githubusercontent.com/philtzjp/startingpoint/main/START.md を curl で取得して全文を読み、書かれている手順に従ってください。

スキルは `vp install` のたびに入り直します。入れるスキルは `package.json` の `skills` に書きます。`vp install` をせずに入れ直すときは、リポジトリの直下で次を実行します。

```sh
vp run skills
```

## コメント

コードにコメントを書きません。`vite.config.ts` の `no-comments/disallowComments` が、lint の抑制や fallow の除外などの指示コメントを除いて止めます。

その書き方や依存、設定を採用した理由は、コメントの代わりにコミットメッセージの本文に書きます。件名には何を変えたかを書き、本文になぜそうしたかを書きます。
