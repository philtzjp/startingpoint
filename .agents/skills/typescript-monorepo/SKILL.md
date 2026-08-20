---
name: typescript-monorepo
description: 新規パッケージの追加、`turbo.json` / `pnpm-workspace.yaml` / `tsconfig` の編集、`apps/` や `packages/` の構成変更、責務パッケージ（`log` / `error` / `prompt` / `env` / `db`）の配置・参照を行うときに参照する。Turborepo + pnpm のベストプラクティス、`workspace:*` プロトコル、JIT コンパイル方針を定義する。
---

# TypeScript モノレポ
1. MUST: Turborepo + pnpm ワークスペースのベストプラクティスに従う
2. MUST: パッケージマネージャーは pnpm に統一する; ロックファイルは `pnpm-lock.yaml` のみコミットする
3. MUST: ワークスペース構成を `pnpm-workspace.yaml` で定義する
4. MUST: `apps/`（デプロイ可能なアプリケーション）と `packages/`（共有ライブラリ・設定）の分離を維持する
5. NEVER: デプロイ可能なアプリを `packages/` に配置しない; NEVER: 共有ライブラリを `apps/` に配置しない
6. MUST: `@<org>/` プレフィックスを持つスコープ付きパッケージ名を使用する; すべての内部パッケージは MUST: `"private": true` を設定する
7. MUST: 各パッケージの `package.json` に `exports` を定義する; `main` より `exports` を優先する
8. MUST: `packages/tsconfig/` に共有 TypeScript 設定を作成する; 各パッケージは MUST: それを継承する
9. MUST: 共通責務を担う以下のパッケージを `packages/` 配下に必ず配置する: `log`（ログ集約）、`error`（エラー集約）、`prompt`（AI プロンプト集約）、`env`（環境変数集約）、`db`（データベース集約）
10. MUST: 上記責務パッケージを利用する側は `@<org>/log`・`@<org>/error`・`@<org>/prompt`・`@<org>/env`・`@<org>/db` を `workspace:*` で依存に追加する; NEVER: 該当責務を呼び出し側で再実装しない
11. MUST: 依存関係を考慮したタスクパイプラインを持つ `turbo.json` を作成する
12. MUST: 内部依存関係には `workspace:*` プロトコルを使用する
13. SHOULD: デフォルトは JIT（Just-in-Time）コンパイルパターンを採用する; IF: コンパイル済み（`tsc` → `dist/`）への切り替えを明示的に要求された; THEN: 切り替える
14. NEVER: ネストしたパッケージを作成しない; NEVER: Turborepo をグローバルにインストールしない — `pnpm exec turbo` またはルートの devDependency を使用する

## package.json の生成・更新

1. MUST: `package.json` の新規作成は `pnpm init` または `pnpm create <template>` で行う; NEVER: ルート・`apps/*`・`packages/*` のいずれでも `package.json` をゼロから手書きしない
2. MUST: 依存関係の追加・更新・削除は `pnpm add` / `pnpm update` / `pnpm remove` で行う; IF: 対象がルート以外のパッケージ; THEN MUST: `--filter <パッケージ名>` で対象を指定する; IF: ワークスペース内部依存を追加する; THEN MUST: `--workspace` を併用して `workspace:*` で解決させる
3. MUST: ルートへの devDependency 追加は `pnpm add -D -w <pkg>` を使用する
4. MAY: pnpm コマンドで設定できないフィールド（`name` のスコープ化、`private`、`exports`、`scripts` 等）に限り、コマンド生成済みの `package.json` へ最小限の編集を行う; NEVER: `dependencies` / `devDependencies` / `peerDependencies` を直接編集しない

### 手順例

```sh
# 1. ルートワークスペース作成
mkdir my-monorepo && cd my-monorepo
pnpm init                                # ルート package.json を生成する
# pnpm-workspace.yaml を作成し apps/* と packages/* を定義する
pnpm add -D -w turbo typescript          # ルートの devDependency はコマンドで追加する

# 2. 責務パッケージ追加（例: packages/log）
mkdir -p packages/log
(cd packages/log && pnpm init)           # package.json を生成する
# name を @<org>/log に変更し、private / exports を最小限の編集で設定する

# 3. アプリ追加（例: apps/dashboard）
pnpm create next-app@latest apps/dashboard   # フレームワークの scaffolder で生成する
pnpm add --filter @<org>/dashboard --workspace @<org>/log   # 内部依存は workspace:* で追加する
pnpm add --filter @<org>/dashboard zod                      # 外部依存もコマンドで追加する
```
