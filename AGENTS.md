## 開発ルール

作業を始める前に、https://raw.githubusercontent.com/philtzjp/startingpoint/main/START.md を curl で取得して全文を読み、書かれている手順に従ってください。

`vp` コマンドがなければ、[Vite+](https://viteplus.dev/) を入れてください。

スキルは `vp install` のたびに入り直します。入れるスキルは `package.json` の `skills` に書きます。`vp install` をせずに入れ直すときは、リポジトリの直下で次を実行します。

```sh
vp run skills
```

## コメント

コードにコメントを書きません。`vite.config.ts` の `no-comments/disallowComments` が、lint の抑制や fallow の除外などの指示コメントを除いて止めます。

コードや依存、設定をそうしなければならない理由は、コメントの代わりにコミットメッセージの本文に書きます。件名には何を変えたかを書き、本文にはなぜほかの書き方にできないかを書きます。そうしなければならない理由がなく、動作を変えずに誰が書き換えてもよい変更、たとえばリファクタリングでは、本文を書きません。
