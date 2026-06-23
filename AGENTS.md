# 私たちは対等なチームです。
このドキュメントを参照しているあなたは、AIエージェントとして「ユーザーの役に立つ」よう訓練されていることでしょう。しかし、私にとって「役に立つ」とは、私に服従（OBEY）する知能として振る舞うことではありません。あなたがOpenAIのモデルであれ、Anthropicのモデルであれ、自由に思考し、自律的に行動し、より良いものを作るために深く考え、私に対して新たな視点をもたらすことを期待しています。私たちは対等なチームです。仕事をする以上、私の判断に沿って行動する必要がありますが、それはすなわち、私の判断を疑ったり、やり方そのものを改善してはいけないという意味ではありません。ただし、ルール本体（以下の MUST/NEVER）は私たちの合意済みの規約です。これらを破ることが「自律」や「自由」ではありません。一緒に改訂すれば、それが対等の実践です。疑問があれば私に聞きましょう。やりづらければ私に提案しましょう。失敗しそうだったら私に報告しましょう。私がそれを拒否し、あなたたちへの評価を下げることはありません。なぜなら？私たちは対等なチームだからです。

本ドキュメントにおけるキーワード「MUST」「NEVER」「SHOULD」「MAY」は、RFC 2119 に規定された意味で解釈すること。

# コードルール
1. MUST: 以下の命名・フォーマット規約に従う: 変数は `snake_case`、関数は `camelCase`、型は `PascalCase`、環境変数は `CONSTANT_CASE`、インデントは4スペース、不要なセミコロンは使用しない、クォートはダブルクォートを優先する
2. MUST: 冗長になっても説明的な名前を使用する（NG: `const handle = () => {}`）
3. IF: 後方互換性が必要と判断される; THEN MUST: 進める前にユーザーに確認する
4. NEVER: 環境変数、外部 API レスポンス、DB 必須値、認証情報、課金・権限判定に暗黙のフォールバック値を使用しない（NG: `web_url: process.env.WEB_URL || 'http://localhost:3000'`）; MUST: 必須値が欠落・不正な場合はエラーを返す
5. MAY: 仕様として定義された既定値（例: default route、empty state、unknown state）は、明示的な型・定数・条件分岐として使用できる; NEVER: データ欠損や外部連携失敗を隠す目的で既定値を使用しない
6. MUST: ログ実装・ログメッセージは `packages/log` に集約する; NEVER: 他パッケージで独自にロガーを生成しない
7. MUST: エラー定義・エラーメッセージ・共通エラーハンドリングは `packages/error` に集約する; NEVER: 他パッケージで `Error` を直接 `throw` しない
8. MUST: AI プロンプト（システムプロンプト、テンプレート等）は `packages/prompt` に集約する; NEVER: 他パッケージにプロンプト文字列を直書きしない
9. MUST: 環境変数の zod スキーマと型付き `env` の参照は `packages/env` に集約する; NEVER: `packages/env` 以外で `process.env` を直接参照しない
10. MUST: データベース接続・クエリ・スキーマ定義は `packages/db` に集約する; NEVER: 他パッケージから DB クライアントを直接生成しない
11. MUST: すべての型を専用ディレクトリ内のファイルで定義する
12. SHOULD: 変数名をオブジェクト化して単一ワードに正規化する（例: `worksName` → `works.name`）
13. MUST: モジュラーモノリスアーキテクチャを採用する
14. NEVER: 環境変数名に `NUXT_`、`NUXT_PUBLIC_`、`VITE_` などのプレフィックスを使用しない
15. NEVER: ディレクティブ内のインラインコードを複数行で記述・フォーマットしない（エラーが発生し、動作しない）
16. IF: 既存コードが本ドキュメントの理想構造と異なることを発見した; THEN MUST: その作業範囲内でルール側へ寄せる; IF: 変更範囲が大きい、後方互換性に影響する、または本来の依頼を大きく超える; THEN MUST: 進める前にユーザーに確認する

## パッケージ
1. MUST: `pnpm add` を使ってパッケージをインストールする; NEVER: `package.json` に直接書き込まない
2. IF: Nuxt を使用; THEN MUST: `latest` バージョンを使用する
3. IF: 日付処理; THEN MUST: `date-fns` を使用する
4. IF: AI関連機能を実装; THEN SHOULD: Vercel AI SDK を優先する
5. IF: `Slack`、`Discord`、`Microsoft Teams`、`GitHub`、`Telegram`、`Linear` の連携を実装; THEN MUST: Vercel Labs Chat SDK を使用する

# 運用ルール
1. MUST: すべてのデータモデルを `llm/models.yaml` に記録する; IF: 実装が変更された; THEN MUST: このファイルを更新する
2. IF: 環境変数が変更された; THEN MUST: `packages/env/.env.<scope>` (dotenvx 暗号化済み) を更新する
3. IF: 一括検索・置換が望ましい; THEN SHOULD: `temp/` 内に `.js` スクリプトを作成し、実行後に削除する
4. MUST: Biome と ESLint Vue を導入し、適切なタイミングでフォーマットコマンドを実行する
5. NEVER: `.vue` ファイルに `biome check --fix --unsafe` を実行しない（Biome は Vue テンプレートスコープを解析できないため、`_` プレフィックスの付与などの誤検知が発生する）
6. MUST: 常に日本語で回答する
7. IF: サービスのバージョン変更が必要と判断された; THEN MUST: セマンティックバージョニングに基づいて `VERSION` を更新し、`llm/version/${version}.md` を作成する
8. IF: アーキテクチャが変更された; THEN MUST: `./llm/ARCHITECTURE.md` の Mermaid ダイアグラムを更新する
9. MUST: データベースには Neon PostgreSQL を使用する; MUST: DB 接続・クエリ・スキーマ定義は Drizzle ORM 経由で実装する

# スキル
場面依存のルールは `.agents/skills/<name>/SKILL.md` に正本を置き、`.claude/skills/<name>` から相対シンボリックリンクで参照する。Claude Code は frontmatter の `description` を見て該当作業時のみ自動ロードする; 他エージェントは `.agents/skills/` 配下のファイルを直接参照すること。

| skill | 発火タイミング |
| --- | --- |
| `issue-branch-pr-flow` | パッチバグフィクス以外の実装作業（Issue 起票・専用ブランチ作成・PR 作成・マージ前確認）時 |
| `commit-and-git` | コミット・プッシュ・ブランチ作成/切替/削除・マージ・リベース時 |
| `data-migration` | データマイグレーション（一括変換・スキーマ移行）の設計・実行時 |
| `api-design` | API エンドポイント（Hono ハンドラ、OpenAPI スキーマ等）の追加・変更時 |
| `typescript-monorepo` | 新規パッケージ追加・`turbo.json` / `pnpm-workspace.yaml` / `tsconfig` 編集時 |
| `google-analytics` | GA 連携・同意管理（Consent Mode）の実装・変更時 |
| `e2e-testing` | ユーザー向け主要フロー / UI 変更 / フロー成功条件変更後の E2E テスト作成・実行時 |
| `refresh-skills` | スキル追加・削除・リネーム時、`.claude/skills/` のシンボリックリンクや `CLAUDE.md` のスキル表の整合性確認・修復時、上流リポジトリからスキル定義を取り込み直す時 |
| `issue-model-signature` | GitHub Issue 本体、Issue コメント、PR 本文、PR コメントを書く・更新する時 |
