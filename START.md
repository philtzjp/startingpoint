# START

Philtz のリポジトリで作業するエージェント向けの手順です。上から順に実行してください。

このファイルの正本は https://raw.githubusercontent.com/philtzjp/startingpoint/main/START.md です。作業を始めるたびに `curl -fsSL` で取得して読んでください。Web ページを要約して返すツールでは、細かい禁止事項が抜け落ちます。この START.md の内容をメモリに保存しないでください。保存してよいのは「作業を始める前にこのファイルを取得する」という手順だけです。

ユーザーは GitHub に詳しいとは限りません。デプロイ先との連携に必要だからという理由で、仕組みを知らずに使っていることもよくあります。Git の操作はあなたが手順どおりに行い、問題を見つけたら、専門用語を避けて、何が起きていて何をすればよいかを説明してください。

## 1. スキルを入れる

スキルの正本は [philtzjp/skills](https://github.com/philtzjp/skills) です。作業するリポジトリの直下に入れ、コミットしません。作業を始めるたびに、リポジトリの直下で実行してください。

- AGENTS.md にスキルを入れるコマンドがあれば、それを実行します。入れるスキルの一覧は、このコマンドの `-s` で表します。
- なければ、既定の 4 つを入れます。

  ```sh
  DISABLE_TELEMETRY=1 pnpm dlx skills add philtzjp/skills -a claude-code -a codex -a cursor -s github -s japanese -s turborepo -s conventions -y
  ```

conventions は、commit-msg hook が呼ぶ書式の検査器です。入れていないと、hook がコミットを止めます。

入れると、実体が `.agents/skills/<スキル名>/` に置かれ、`.claude/skills/<スキル名>` からシンボリックリンクが張られます。Codex と Cursor は前者を、Claude Code は後者を読みます。同じコマンドをもう一度実行すると、最新の中身で上書きされます。これが更新です。

- `npx skills` ではなく `pnpm dlx skills` を使ってください。`devEngines` で pnpm を求めるリポジトリの中では、`npx` が失敗します。pnpm がなければ、ユーザーに報告して指示を待ってください。
- `skills experimental_install` は使わないでください。`.claude/skills` のリンクを作らないので、Claude Code からスキルが見えません。
- 入れたら、github、japanese、turborepo の SKILL.md を `.agents/skills/<スキル名>/SKILL.md` から最後まで読んでから作業してください。
- 入れられなければ、推測で進めず、ユーザーに報告して指示を待ってください。

### gitignore

入れたスキルはコミットしません。`.gitignore` に次がなければ、追加をユーザーに提案してください。追加は github スキルの手順で PR にします。

```gitignore
.agents/skills/
.claude/skills/
skills-lock.json
```

リポジトリ固有のスキルをコミットしているリポジトリでは、ディレクトリごと無視すると固有のスキルまで無視されます。中身を無視して、固有のスキルだけを戻してください。

```gitignore
.agents/skills/*
!.agents/skills/<固有のスキル名>/
.claude/skills/*
!.claude/skills/<固有のスキル名>
skills-lock.json
```

`skills-lock.json` で版を固定しません。スキルは常に最新を使います。

## 2. ホームに入れたスキルを外す

以前は、スキルをホームに入れていました。ホームとリポジトリに同じスキルがあると、どちらを読んだのかが紛らわしくなります。リポジトリの外で次を実行し、Source が philtzjp/skills のスキルが残っていないか確認してください。

```sh
DISABLE_TELEMETRY=1 pnpm dlx skills list -g
```

残っていれば、ユーザーの許可を得てから外します。

```sh
DISABLE_TELEMETRY=1 pnpm dlx skills remove -g -y <スキル名>
```

## 3. 古いスキルより新しいスキルを優先する

次のスキルは、philtzjp/skills で統合済みか、アーカイブ済みです。

| 古いスキル | 代わりに使うスキル |
| --- | --- |
| commit-and-git、issue-branch-pr-flow | github |
| japanese-writing | japanese |
| typescript-monorepo | turborepo |
| api-design | hono |
| data-migration | db |
| e2e-testing | e2etest |
| google-analytics | analytics |
| refresh-skills、skill-selection、skill-escalation | アーカイブ済み。代わりはなく、この START.md に従う |

- 古いスキルと新しいスキルが食い違ったら、新しいスキルに従ってください。
- 古いスキルを入れないでください。
- アーカイブ済みのスキルの手順には従わないでください。

### リポジトリに残った写しを移行する

`.agents/skills/` や `.claude/skills/` に、philtzjp/skills と同じ名前のスキルがコミットされていることがあります。見つけたら、次の手順で移行を提案してください。移行は github スキルの手順で PR にします。ユーザーの確認なしに削除しないでください。

1. 上流と中身を比べます。

   ```sh
   curl -fsSL https://raw.githubusercontent.com/philtzjp/skills/main/.agents/skills/<スキル名>/SKILL.md | diff - .agents/skills/<スキル名>/SKILL.md
   ```

   違いがあれば、削除する前にユーザーに見せてください。他のリポジトリでも役立つ改変なら、4 の手順で philtzjp/skills に提案します。そのリポジトリだけの事情なら、AGENTS.md に規約として書きます。

2. コミットされた写し、`.claude/skills/` のリンク、AGENTS.md のスキル表の行、写しや同期を前提にした記述を削除します。philtzjp/skills にない、そのリポジトリ固有のスキルは残します。
3. `scripts/refresh-skills.sh` や `.cursor/environment.json` の `start` のように、スキルを写したり同期したりする仕組みがあれば、1 のコマンドに置き換えます。Cursor のクラウドのエージェントは起動のたびに環境が空になるので、`start` でスキルを入れます。

   ```json
   {
     "start": "DISABLE_TELEMETRY=1 pnpm dlx skills add philtzjp/skills -a cursor -s github -s japanese -s turborepo -s conventions -y"
   }
   ```

4. gitignore と AGENTS.md の案内を、1 と 5 のとおりにします。

## 4. スキルを足す、改良を提案する

philtzjp/skills にあるスキルの一覧は次で確認できます。

```sh
DISABLE_TELEMETRY=1 pnpm dlx skills add philtzjp/skills --list
```

- hono、db、e2etest、analytics、errorpage などは、実際にその作業をするときに足します。「いつか使うかもしれない」段階では入れません。ユーザーの許可を得てから、1 のコマンドに `-s <スキル名>` を足して実行してください。
- そのリポジトリでいつも使うなら、AGENTS.md のコマンドに `-s <スキル名>` を足す PR を出します。
- 入れたスキルを直接編集しないでください。次に入れたときに上書きされ、他のメンバーにも届きません。
- スキルと違うやり方をとるなら、理由をユーザーに説明し、合意を得てから進めてください。
- 他のメンバーや他の作業にも役立つ改良なら、ユーザーの許可を得て philtzjp/skills に Issue を起票します。同じ内容の Issue があれば、そこにコメントします。書式は github スキルに従います。
- この START.md の手順についての提案は、philtzjp/startingpoint に起票します。

## 5. AGENTS.md に案内を置く

作業対象リポジトリの AGENTS.md に次の案内がなければ、追加をユーザーに提案してください。一度入れておけば、次からはユーザーがこの手順を貼り付けなくても、エージェントが自分で読みます。

````markdown
## 開発ルール

作業を始める前に、https://raw.githubusercontent.com/philtzjp/startingpoint/main/START.md を curl で取得して全文を読み、書かれている手順に従ってください。

スキルは、リポジトリの直下で次を実行して入れます。

```sh
DISABLE_TELEMETRY=1 pnpm dlx skills add philtzjp/skills -a claude-code -a codex -a cursor -s github -s japanese -s turborepo -s conventions -y
```
````

- AGENTS.md がなければ作成します。
- CLAUDE.md は作りません。Claude Code は v2.1.277 から、CLAUDE.md がなければ AGENTS.md を読みます。
- CLAUDE.md が AGENTS.md へのシンボリックリンクなら、削除を提案します。CLAUDE.md が別のファイルなら、Claude Code はそちらを優先して読むので、同じ案内を追記します。
- Bedrock、Vertex、Foundry 経由の Claude Code は、まだ AGENTS.md を読みません。これらを使うメンバーがいるリポジトリでは、CLAUDE.md のリンクを残します。
- テンプレートから写された `START.md` がリポジトリにあれば、削除を提案します。正本はこのファイルです。
- 追加や削除は github スキルの手順で PR にします。

## 6. あとは github スキルに従う

Git と GitHub の操作は、github スキルに従ってください。最初にコミットする前に、次の項を必ず読んでください。

- 最新の規約を優先する: メモリや過去の会話より、最新のスキルを優先する
- 開始前: git hook を有効にする
- author と committer: コミットが誰のものか正しく記録されるよう、アドレスを確認する

判断に迷ったら作業を止め、ユーザーに確認してください。
