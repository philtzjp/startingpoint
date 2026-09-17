# START

Philtz のリポジトリで作業するエージェント向けの手順です。上から順に実行してください。

このファイルの正本は https://raw.githubusercontent.com/philtzjp/startingpoint/main/START.md です。philtzjp/startingpoint をテンプレートにして作ったリポジトリにある `START.md` は、作成した時点のコピーで古くなっています。コピーは読まず、正本を `curl -fsSL` で取得して読んでください。

ユーザーは GitHub に詳しいとは限りません。デプロイ先との連携に必要だからという理由で、仕組みを知らずに使っていることもよくあります。Git の操作はあなたが手順どおりに行い、問題を見つけたら、専門用語を避けて、何が起きていて何をすればよいかを説明してください。

## 1. スキルを最新にする

作業を始めるたびに行ってください。使うスキルは github、japanese、turborepo の 3 つで、正本は [philtzjp/skills](https://github.com/philtzjp/skills) です。

導入済みかを確認します。

```sh
DISABLE_TELEMETRY=1 npx skills list -g
```

- 3 つとも Source が philtzjp/skills なら、更新します。

  ```sh
  DISABLE_TELEMETRY=1 npx skills update github japanese turborepo -g -y
  ```

- 入っていないスキルがあるか、Source が philtzjp/skills 以外なら、ユーザーの許可を得てから導入します。Source が違うものは、先に `npx skills remove -g -y <スキル名>` で外してください。

  ```sh
  DISABLE_TELEMETRY=1 npx skills add philtzjp/skills -g -a claude-code -a codex -a cursor -s github -s japanese -s turborepo -y
  ```

導入すると、実体が `~/.agents/skills/<スキル名>/` に置かれ、`~/.claude/skills/<スキル名>` からシンボリックリンクが張られます。Codex と Cursor は前者を、Claude Code は後者を読みます。

- 導入や更新が終わったら、3 つの SKILL.md を最後まで読んでから作業してください。導入した直後のセッションでは自動で読み込まれないことがあるので、`~/.agents/skills/<スキル名>/SKILL.md` を直接読んでください。
- 導入も更新もできなければ、推測で進めず、ユーザーに報告して指示を待ってください。
- スキルを作業対象リポジトリにコピーしないでください。コピーした時点から古くなります。

## 2. メモリより最新版を優先する

エージェントのメモリや過去の会話に誤った手順が残っていると、同じ誤りを何度も繰り返してしまいます。

- この START.md とスキルは、作業を始めるたびに取得し直してください。前回読んだ内容やメモリで済ませないでください。
- 取得には `curl -fsSL` を使ってください。Web ページを要約して返すツールでは、細かい禁止事項が抜け落ちます。
- メモリや過去の会話の手順が最新版と食い違ったら、最新版に従ってください。食い違っていたメモリは、どこがどう違うかをユーザーに伝え、更新か削除を提案してください。許可なしにメモリを書き換えないでください。
- この START.md やスキルの内容をメモリに保存しないでください。保存してよいのは「作業を始める前に https://raw.githubusercontent.com/philtzjp/startingpoint/main/START.md を取得する」という手順だけです。
- 会話が長くなってコンテキストが要約されたら、Git の操作を続ける前にもう一度取得してください。

## 3. 古いスキルより新しいスキルを優先する

作業対象リポジトリの `.agents/skills/` や `.claude/skills/` に、次のスキルが残っていることがあります。いずれも philtzjp/skills で統合済みの古いスキルです。

| 古いスキル | 代わりに使うスキル |
| --- | --- |
| commit-and-git、issue-branch-pr-flow | github |
| japanese-writing | japanese |
| typescript-monorepo | turborepo |
| api-design | hono |
| data-migration | db |
| e2e-testing | e2etest |
| google-analytics | analytics |

- 古いスキルと新しいスキルが食い違ったら、新しいスキルに従ってください。
- 古いスキルを見つけたら、削除をユーザーに提案してください。移行の手順は 4 にあります。
- 作業対象リポジトリに refresh-skills、skill-selection、skill-escalation が残っていても、その手順には従わないでください。スキルの操作は 4 のとおり `npx skills` で行います。

作業対象リポジトリに CLAUDE.md、AGENTS.md、CONTRIBUTING.md などがあれば読んでください。そのリポジトリ固有の規約は、上の古いスキルを除いて、スキルより優先します。食い違いがあったらユーザーに伝えてください。

## 4. スキルを追加する、外す、移行する

スキルの操作はすべて `npx skills` で行ってください。refresh-skills や skill-selection などのメタスキルを導入する必要はありません。

### 追加する、外す

philtzjp/skills にあるスキルの一覧は次で確認できます。

```sh
DISABLE_TELEMETRY=1 npx skills add philtzjp/skills --list
```

- hono、db、e2etest、analytics、errorpage などは、実際にその作業をするときに追加します。「いつか使うかもしれない」段階では入れません。ユーザーの許可を得てから実行してください。

  ```sh
  DISABLE_TELEMETRY=1 npx skills add philtzjp/skills -g -a claude-code -a codex -a cursor -s <スキル名> -y
  ```

- 使わなくなったスキルは、ユーザーの許可を得てから外します。github、japanese、turborepo は外さないでください。

  ```sh
  DISABLE_TELEMETRY=1 npx skills remove -g -y <スキル名>
  ```

- 3 の表にある古いスキルは導入しないでください。

### 作業対象リポジトリに残ったコピーを移行する

`.agents/skills/` や `.claude/skills/` に philtzjp/skills と同じ名前のスキルがあれば、次の手順で移行を提案してください。移行は github スキルの手順で PR にします。ユーザーの確認なしに削除しないでください。

1. 上流と中身を比べます。

   ```sh
   curl -fsSL https://raw.githubusercontent.com/philtzjp/skills/main/.agents/skills/<スキル名>/SKILL.md | diff - .agents/skills/<スキル名>/SKILL.md
   ```

   違いがあれば、削除する前にユーザーに見せてください。他のリポジトリでも役立つ改変なら、下の手順で philtzjp/skills に提案します。そのリポジトリだけの事情なら、AGENTS.md に規約として書きます。

2. 必要なスキルが `npx skills` でホームに入っていることを確認します。古いスキルなら、3 の表の代わりのスキルを入れます。
3. コピー（`.agents/skills/<スキル名>/`）、`.claude/skills/<スキル名>` のリンク、AGENTS.md や CLAUDE.md のスキル表の行、コピーや同期を前提にした記述を削除します。philtzjp/skills にない、そのリポジトリ固有のスキルは残します。
4. `scripts/refresh-skills.sh` や `.cursor/environment.json` の `start` のように、スキルをコピーしたり同期したりする仕組みがあれば、`npx skills` に置き換えます。Cursor Cloud Agent は起動のたびにホームが空になるので、`start` でスキルを導入します。

   ```json
   {
     "start": "DISABLE_TELEMETRY=1 npx skills add philtzjp/skills -g -a cursor -s github -s japanese -s turborepo -y"
   }
   ```

5. 5 の案内を AGENTS.md に入れます。

### スキルの改良を提案する

- ホームに導入したスキル（`~/.agents/skills/`）は直接編集しないでください。`npx skills update` で上書きされ、他のメンバーにも届きません。
- スキルと違うやり方をとるなら、理由をユーザーに説明し、合意を得てから進めてください。
- 他のメンバーや他の作業にも役立つ改良なら、ユーザーの許可を得て philtzjp/skills に Issue を起票します。同じ内容の Issue があれば、そこにコメントします。
  - タイトルは `type(スキル名): 動作で終わる短い日本語`。type は feat、fix、perf、refactor のいずれか。
  - 本文の先頭に `✳︎ <会社名> <モデル名> <バージョン>` の署名行を入れ、1 行空けて「背景」「作業範囲」「完了条件」「備考」を書く。
- この START.md の手順についての提案は、philtzjp/startingpoint に起票します。

## 5. 作業対象リポジトリに案内を置く

作業対象リポジトリの AGENTS.md に次の案内がなければ、追加をユーザーに提案してください。一度入れておけば、次からはユーザーがこの手順を貼り付けなくても、エージェントが自分で読みます。

```markdown
## 開発ルール

作業を始める前に、https://raw.githubusercontent.com/philtzjp/startingpoint/main/START.md を curl で取得して全文を読み、書かれている手順に従ってください。
```

- AGENTS.md がなければ作成します。
- CLAUDE.md がなければ、AGENTS.md へのシンボリックリンクとして作成します。CLAUDE.md が既にあれば、同じ案内を追記します。
- philtzjp/startingpoint から作ったリポジトリには、最初からこの案内が入っています。テンプレートからコピーされた `START.md` は不要なので、削除を提案してください。
- 追加や削除は github スキルの手順で PR にします。

## 6. コミットが誰のものか正しく記録されるようにする

GitHub は、コミットに記録されたメールアドレスで、どのアカウントの変更かを判断します。名前は判断に使いません。GitHub に登録していないアドレスでコミットすると、アイコンが灰色になり、誰の変更か追えなくなります。

コミットには author（変更を書いた人）と committer（コミットを作った人）のアドレスが別々に記録され、それぞれ別に判断されます。片方だけ灰色になることもあります。

最初にコミットする前に、設定を確認してください。

```sh
git config --show-origin user.name
git config --show-origin user.email
env | grep -E '^GIT_(AUTHOR|COMMITTER)_'
```

- user.email が未設定、または `root@...` や `...@localhost`、`....local` のような自動生成のアドレスなら、コミットしないでください。ユーザーに状況を伝え、設定を相談してください。
- リポジトリ単位の設定や環境変数がグローバル設定を上書きしていないか、`--show-origin` の出力で確かめてください。CI、Docker、devcontainer、クラウドのエージェント環境では設定が入っていないことがよくあります。
- ユーザーの許可なしに git config を書き換えないでください。
- どのアドレスを使うか迷っていたら、GitHub が発行する noreply アドレスを提案してください。必ずアカウントに紐づき、個人のメールアドレスを公開せずに済みます。GitHub の Settings → Emails で確認でき、gh が使えるなら次のコマンドでも取得できます。

  ```sh
  gh api user --jq '"\(.id)+\(.login)@users.noreply.github.com"'
  ```

rebase、cherry-pick、`commit --amend` を実行すると、author はそのまま残り、committer は実行した環境の設定に置き換わります。実行したあとは両方を確認してください。

```sh
git log --format='%h author=%an <%ae> committer=%cn <%ce>' -10
```

push したあとは、GitHub 上でアカウントに紐づいたかを確認してください。null になっている側が灰色のアイコンです。

```sh
gh api repos/<owner>/<repo>/commits/<sha> --jq '{author: .author.login, committer: .committer.login}'
```

灰色になっていたら、原因と直し方をユーザーに説明してください。使ったアドレスを GitHub の Settings → Emails に追加して確認を済ませれば、過去のコミットにもさかのぼって紐づきます。履歴を書き換えて直そうとしないでください。

## 7. コードを壊さないために

詳しくは github スキルに書いてあります。特に事故につながりやすいものを挙げます。

- デフォルトブランチ上で作業を始めない。Issue を起票し、Issue 番号を含むブランチを切り、PR を経由してマージする。
- 作業前と Git の操作の前に `git fetch --prune` と `git status --short --branch` を実行し、ahead / behind を確認する。
- 今回の作業に無関係な変更をステージ、コミット、修正しない。`git add .` と `git add -A` を使わない。
- ユーザーの承認なしに `git pull`、`git rebase`、force push、ブランチの切り替えや削除をしない。
- `--no-verify` で hook を迂回しない。レビューや CI を迂回してマージしない。
- 判断に迷ったら作業を止め、ユーザーに確認する。
