本ドキュメントにおけるキーワード「MUST」「NEVER」「SHOULD」「MAY」は、RFC 2119 に規定された意味で解釈すること。

# スキル
場面依存のルールは `.agents/skills/<name>/SKILL.md` に正本を置き、`.claude/skills/<name>` から相対シンボリックリンクで参照する。Claude Code は frontmatter の `description` を見て該当作業時のみ自動ロードする; 他エージェントは `.agents/skills/` 配下のファイルを直接参照すること。

| skill | 発火タイミング |
| --- | --- |
| `commit-and-git` | コミット・プッシュ・ブランチ作成/切替/削除・マージ・リベース時 |
| `issue-branch-pr-flow` | パッチバグフィクス以外の実装作業（Issue 起票・専用ブランチ作成・PR 作成・マージ前確認）時 |
| `japanese-writing` | 日本語での応答・文章作成・編集・校正、コミットメッセージ・PR 説明・ドキュメント・UI 文言を書く時 |
| `refresh-skills` | スキル追加・削除・リネーム時、`.claude/skills/` のシンボリックリンクや `AGENTS.md` / `CLAUDE.md` のスキル表の整合性確認・修復時、上流リポジトリからスキル定義を取り込み直す時 |
| `skill-escalation` | 既存スキル通りに進まない時、Web 検索で異なる情報が得られた時、条件分岐の厳守がスタックの自由度を制限する時にスキル本体をローカルで改変し、有用な変更を `philtzjp/skills` の Issue として起票する時 |
| `skill-selection` | 上流リポジトリからスキル群を初期導入する時、新規スキルを採用するか判断する時、不要になったスキルを除外する時、`AGENTS.md` / `CLAUDE.md` のスキル表や記述を採用構成に合わせて書き換える時 |
| `typescript-monorepo` | 新規パッケージ追加・`turbo.json` / `pnpm-workspace.yaml` / `tsconfig` 編集時 |

## Cursor を使う場合（任意）
Cursor（Agent / Composer / Cloud Agent）を使うリポジトリは `./scripts/install-cursor.sh` を実行して Hook と Cloud Agent 環境定義を導入する。詳細は README を参照。

<!-- cursor-overlay-begin -->
| `cursor-hook-authoring` | Cursor の Hook（`.cursor/hooks.json` / `.cursor/hooks/` 配下スクリプト）を作成・変更・デバッグする時 |

# ブランチ運用
Cursor Cloud（`cursor/*`）や Claude Code リモートセッション（`claude/*`）は、作業ブランチ名を自動生成する。これらはプラットフォームの管理領域として扱う。

1. MUST: 自動生成されたブランチ名はそのまま使用する; NEVER: `git branch -m` で改名したり、別ブランチへ作業を移し替えたりしない（セッション・PR の追跡が切れる）
2. MUST: 命名規則が必要な情報（type、scope、変更内容）はコミットメッセージと PR タイトルで担保する
3. MAY: `cursor/` プレフィクス自体を変えたい場合は Cursor ダッシュボードの Cloud Agent 設定で変更する（エージェントの作業ではなくユーザーの設定作業）

# 環境変数と認証情報
外部サービスを操作するときは、以下の環境変数で渡された認証情報を必ず使用する。

| 変数 | 用途 | 使い方 |
| --- | --- | --- |
| `OPENROUTER_API_KEY` | 画像生成 | `https://openrouter.ai/api/v1` へ `Authorization: Bearer $OPENROUTER_API_KEY` で認証する |
| `OPENROUTER_MANAGEMENT_KEY` | OpenRouter API キーの発行・管理 | `https://openrouter.ai/api/v1/keys` へ `Authorization: Bearer $OPENROUTER_MANAGEMENT_KEY` で操作する |
| `TAVILY_API_KEY` | Web 検索 | Tavily API / SDK が環境変数を直接参照する（`https://api.tavily.com`） |
| `GH_PAT` | GitHub 操作 | `GH_TOKEN="$GH_PAT"` として `gh` CLI / GitHub API に渡す |
| `VERCEL_SCOPED_TOKEN_OSA` | Vercel 操作 | `vercel --token "$VERCEL_SCOPED_TOKEN_OSA"`（または `VERCEL_TOKEN` として渡す） |
| `NEON_API_KEY` | NeonDB の作成・マイグレーション | `neonctl` が環境変数を直接参照する、Neon API へは `Authorization: Bearer $NEON_API_KEY` |
| `OP_SERVICE_ACCOUNT_TOKEN` | 1Password からの `op://` 読み取り | `op read "op://..."` / `op run` が環境変数を直接参照する |

1. MUST: 上記の用途では対応する環境変数を使用する; NEVER: キーの新規発行（下記 OpenRouter の場合を除く）、別アカウントでのログイン、対話的な認証フローを行わない
2. MUST: 新しい OpenRouter API キーが必要な場合は `OPENROUTER_MANAGEMENT_KEY` で発行して使用する; MUST: キー名は `@<org名>/<リポジトリ名>` とする; NEVER: 発行したキーの値を出力・保存する（下記のシークレット取り扱いルールに従う）
3. MUST: 変数が未設定・認証エラーの場合は作業を中断してユーザーに報告する; NEVER: 代替の認証手段を探さない
4. MUST: シークレットの実値が必要な設定ファイルは `op://` 参照で書き、実行時に `op run` / `op read` で解決する
5. NEVER: シークレットの値を `echo`・ログ・チャット応答・コミット・コード・ドキュメントに出力しない
6. NEVER: シークレットの値を平文の `.env` に書き出さない（`.env` は dotenvx で暗号化する; `lefthook.yaml` の pre-commit が検証する）

# 署名規約（Issue / PR / コメント）
GitHub Issue 本体・Issue コメント・PR 本文・PR コメントを書く / 更新するとき（`gh` CLI / GitHub MCP の全経路を含む）は、本セクションを常時適用する。

1. MUST: 本文の先頭行に書き手であるエージェント自身の署名を入れ、次の 4 形式のいずれかに完全一致させる:
   - `✳︎ SpaceXAI Composer <バージョン>`
   - `✳︎ SpaceXAI Grok <バージョン>`
   - `✳︎ Anthropic Claude <モデル> <バージョン>`
   - `✳︎ OpenAI GPT-<バージョン>`（サブバージョンがあれば `GPT-<バージョン>-<サブバージョン>`）
2. MUST: 署名行の次に空行を 1 行入れ、その後に本文を続ける
3. MUST: Cursor の Auto モードでは、実際にルーティングされているモデルを確認して署名する（Hook ペイロードの `model` フィールドで確認できる）
4. NEVER: `Cursor Agent` / `SpaceXAI Cursor` などルーティング先を隠した名義で署名しない
5. NEVER: 署名行に日時、ID、装飾文字、その他追加情報を含めない
6. MUST: PR の作成・コメントは `gh` CLI または GitHub MCP 経由で行う; NEVER: Cursor の「Create PR」ボタンやプラットフォームの自動 PR 作成に任せない（エージェントのシェルを通らないため Hook の署名検査が効かない）

許可形式以外の署名・無署名の投稿は `.cursor/hooks/signature-guard.py` が実行前にブロックする。
<!-- cursor-overlay-end -->
## スキル導入
1. MUST: 初回セットアップ時、および `refresh-skills` 実行時に `philtzjp/skills` リポジトリの `AGENTS.md` を取得する
2. MUST: 取得した内容に基づき本ファイルのスキル表・スキル運用に関する記述を最新化する; MUST: 本リポジトリ固有の記述があるセクションは保持する
3. MUST: `refresh-skills` と `skill-escalation` を必須スキルとして導入する
4. MUST: プロジェクトの技術スタック・運用ルール・依頼内容に照らし、必要なスキルだけを追加で導入する
5. NEVER: 上流の全スキルを無条件に取り込まない
6. MUST: 採用する各スキルについて、上流の `.agents/skills/<skill-name>/SKILL.md` を本リポジトリの同一パスへ配置する
7. MUST: 各スキルについて `.claude/skills/<skill-name>` を `../../.agents/skills/<skill-name>` への相対シンボリックリンクとして作成する
8. MUST: 導入完了後、上記スキル表を採用したスキル一覧と一致させる
