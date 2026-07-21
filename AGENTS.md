本ドキュメントにおけるキーワード「MUST」「NEVER」「SHOULD」「MAY」は、RFC 2119 に規定された意味で解釈すること。

# スキル
場面依存のルールは `.agents/skills/<name>/SKILL.md` に正本を置き、`.claude/skills/<name>` から相対シンボリックリンクで参照する。Claude Code は frontmatter の `description` を見て該当作業時のみ自動ロードする; 他エージェントは `.agents/skills/` 配下のファイルを直接参照すること。

| skill | 発火タイミング |
| --- | --- |

## Cursor を使う場合（任意）
Cursor（Agent / Composer / Cloud Agent）を使うリポジトリは `./scripts/install-cursor.sh` を実行して Hook と Cloud Agent 環境定義を導入する。詳細は README を参照。

## スキル導入
1. MUST: 初回セットアップ時、および `refresh-skills` 実行時に `philtzjp/skills` リポジトリの `AGENTS.md` を取得する
2. MUST: 取得した内容に基づき本ファイルのスキル表・スキル運用に関する記述を最新化する; MUST: 本リポジトリ固有の記述があるセクションは保持する
3. MUST: `refresh-skills` と `skill-escalation` を必須スキルとして導入する
4. MUST: プロジェクトの技術スタック・運用ルール・依頼内容に照らし、必要なスキルだけを追加で導入する
5. NEVER: 上流の全スキルを無条件に取り込まない
6. MUST: 採用する各スキルについて、上流の `.agents/skills/<skill-name>/SKILL.md` を本リポジトリの同一パスへ配置する
7. MUST: 各スキルについて `.claude/skills/<skill-name>` を `../../.agents/skills/<skill-name>` への相対シンボリックリンクとして作成する
8. MUST: 導入完了後、上記スキル表を採用したスキル一覧と一致させる
