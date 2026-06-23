---
name: refresh-skills
description: スキルの追加・削除・リネーム時、`.claude/skills/` のシンボリックリンクが切れている疑いがあるとき、`CLAUDE.md` のスキル表とディレクトリ実体が乖離しているとき、上流リポジトリ (`philtzjp/PHILTZ.md`) の `ouchiarata/path-to-project/` 配下スキルを取り込み直すときに参照する。`.agents/skills/<name>/SKILL.md`（正本）、`.claude/skills/<name>`（相対シンボリックリンク）、`CLAUDE.md` のスキル表の三者を整合させる検査・修復手順、および上流からの同期手順を定義する。
---

# スキル整合性のリフレッシュ

## 原則

1. MUST: スキルの正本は `.agents/skills/<name>/SKILL.md` に置く; NEVER: `.claude/skills/<name>/SKILL.md` を実ファイルとして編集しない
2. MUST: `.claude/skills/<name>` は `../../.agents/skills/<name>` への相対シンボリックリンクとして作成する; NEVER: 絶対パスのシンボリックリンクを作成しない
3. MUST: `CLAUDE.md` のスキル表に列挙されたエントリと、`.agents/skills/` 配下のディレクトリ集合と、`.claude/skills/` 配下のシンボリックリンク集合の三者を一致させる
4. MUST: スキル名は `kebab-case` を使用する
5. NEVER: スキル本体に機密情報、トークン、認証情報を記載しない

## 発火タイミング

1. 新しいスキルを追加する
2. 既存スキルを削除またはリネームする
3. `.claude/skills/<name>` のシンボリックリンクが切れている／不正である疑いがある
4. `CLAUDE.md` のスキル表とディレクトリ実体が一致していない疑いがある
5. 上流 (`philtzjp/PHILTZ.md` の `ouchiarata/path-to-project/`) からスキル定義の更新を取り込みたい

## 上流からの同期

1. MUST: 同期前に `git fetch --prune` を実行する
2. MUST: `ouchiarata/path-to-project/.agents/skills/` および `ouchiarata/path-to-project/CLAUDE.md` の差分を `git diff origin/main -- ouchiarata/path-to-project/.agents/skills ouchiarata/path-to-project/CLAUDE.md` で確認する
3. IF: 差分がある; THEN MUST: 取り込み方針（マージ / リベース / ピックアップ）をユーザーに確認する
4. NEVER: ユーザーの確認なしに上流変更を強制取り込みしない
5. MUST: 同期後に「整合性検査」と「整合性修復」を実行する

## 整合性検査

1. MUST: `.agents/skills/` 配下のディレクトリ一覧と、それぞれに `SKILL.md` が存在することを確認する
2. MUST: `.claude/skills/` 配下のエントリがすべて `../../.agents/skills/<name>` 形式の相対シンボリックリンクであることを確認する
3. MUST: `.agents/skills/<name>` に対応する `.claude/skills/<name>` が存在することを確認する
4. MUST: `.claude/skills/<name>` の解決先が実在する `.agents/skills/<name>` ディレクトリであることを確認する
5. MUST: `CLAUDE.md` のスキル表 (`| skill | 発火タイミング |`) に列挙された `skill` 名が、`.agents/skills/` 配下のディレクトリ集合と完全一致することを確認する
6. MUST: 各 `SKILL.md` の frontmatter `name` フィールドがディレクトリ名と一致することを確認する

## 整合性修復

1. IF: `.agents/skills/<name>/SKILL.md` が存在するのに `.claude/skills/<name>` が存在しない; THEN MUST: 相対シンボリックリンクを作成する: `ln -s ../../.agents/skills/<name> .claude/skills/<name>`
2. IF: `.claude/skills/<name>` が実ファイル、または不正なリンク先を指している; THEN MUST: 削除して相対シンボリックリンクを作成し直す
3. IF: `.claude/skills/<name>` の解決先 `.agents/skills/<name>` が存在しない（孤立シンボリックリンク）; THEN MUST: 削除する
4. IF: `CLAUDE.md` のスキル表とディレクトリ集合が乖離している; THEN MUST: 表に行を追加・削除する
5. IF: `SKILL.md` の frontmatter `name` がディレクトリ名と一致しない; THEN MUST: frontmatter を修正する
6. MUST: 修復後、もう一度「整合性検査」を実行して再発しないことを確認する

## スキル追加時の手順

1. MUST: `.agents/skills/<name>/SKILL.md` を作成し、frontmatter に `name`（kebab-case のスキル名）と `description`（発火タイミングを具体的に説明する一文）を記述する
2. MUST: `.claude/skills/<name>` を `../../.agents/skills/<name>` への相対シンボリックリンクとして作成する
3. MUST: `CLAUDE.md` のスキル表に新しいスキル名と発火タイミングの行を追加する
4. MUST: 「整合性検査」を実行する
5. MUST: コミットは `commit-and-git` スキルに従って行う

## スキル削除時の手順

1. MUST: `.agents/skills/<name>/` ディレクトリを削除する
2. MUST: `.claude/skills/<name>` のシンボリックリンクを削除する
3. MUST: `CLAUDE.md` のスキル表から該当行を削除する
4. MUST: 「整合性検査」を実行する

## スキルリネーム時の手順

1. MUST: `.agents/skills/<old-name>/` を `.agents/skills/<new-name>/` にリネームする
2. MUST: リネーム後のディレクトリ内の `SKILL.md` の frontmatter `name` を `<new-name>` に更新する
3. MUST: `.claude/skills/<old-name>` のシンボリックリンクを削除し、`.claude/skills/<new-name>` を `../../.agents/skills/<new-name>` への相対シンボリックリンクとして作成する
4. MUST: `CLAUDE.md` のスキル表内の名前を更新する
5. MUST: 「整合性検査」を実行する
