---
name: skill-setup
description: 新規リポジトリで最初に `philtzjp/skills` から必要なスキルだけを導入するときに参照する一時 bootstrap スキル。`refresh-skills` と `skill-escalation` を必ず導入し、必要な追加スキルを選んで配置し、`.claude/skills` と `AGENTS.md` を整合させた後に `skill-setup` 自体を削除する。
---

# スキルセットアップ

## 目的

このスキルは、新規リポジトリの初期セットアップ時にだけ使う bootstrap 手順である。

スクリプトではなく、エージェントが `philtzjp/skills` の正本を確認し、必要なスキルだけをこのリポジトリへ取り込む。セットアップ完了後、`skill-setup` 自体は削除する。

## 上流

- リポジトリ: `https://github.com/philtzjp/skills`
- スキル正本: `.agents/skills/<skill-name>/SKILL.md`
- Claude Code 用リンク例: `.claude/skills/<skill-name> -> ../../.agents/skills/<skill-name>`

## 導入方針

1. MUST: `refresh-skills` を必ず導入する
2. MUST: `skill-escalation` を必ず導入する
3. MUST: そのプロジェクトに必要なスキルだけを追加で導入する
4. NEVER: 上流の全スキルを無条件に取り込まない
5. NEVER: `.claude/skills/<skill-name>/SKILL.md` を実ファイルとして作成・編集しない
6. MUST: 導入完了後に `skill-setup` 自体を `.agents/skills` と `.claude/skills` から削除する

## 手順

1. `philtzjp/skills` の `.agents/skills` 配下を確認し、利用可能なスキル一覧を把握する。
2. 必須スキルとして `refresh-skills` と `skill-escalation` を採用リストに入れる。
3. プロジェクトの技術スタック、運用ルール、ユーザーの依頼内容に照らし、追加で必要なスキルだけを採用リストに入れる。
4. 採用する各スキルについて、上流の `.agents/skills/<skill-name>/SKILL.md` をこのリポジトリの `.agents/skills/<skill-name>/SKILL.md` へ配置する。
5. 各スキルについて `.claude/skills/<skill-name>` を `../../.agents/skills/<skill-name>` への相対シンボリックリンクとして作成する。
6. `AGENTS.md` のスキル表を、採用したスキル一覧と一致するように更新する。
7. `skill-setup` の行を `AGENTS.md` のスキル表から削除する。
8. `.agents/skills/skill-setup` と `.claude/skills/skill-setup` を削除する。
9. `refresh-skills` に従って、スキル本体、シンボリックリンク、`AGENTS.md` のスキル表の整合性を確認する。

## 取得方法

上流取得方法は状況に応じて選ぶ。

- `git clone` で一時ディレクトリへ clone して必要な `SKILL.md` だけコピーする
- `gh api` で対象ファイルを取得する
- `git show` や sparse checkout を使って対象ディレクトリだけ参照する

どの方法でも、最終的な配置は次の形に揃える。

```text
.agents/skills/<skill-name>/SKILL.md
.claude/skills/<skill-name> -> ../../.agents/skills/<skill-name>
```

## 整合性条件

セットアップ完了時点で、次の条件をすべて満たすこと。

1. `.agents/skills/refresh-skills/SKILL.md` が存在する
2. `.agents/skills/skill-escalation/SKILL.md` が存在する
3. `.claude/skills/refresh-skills` が正しい相対シンボリックリンクである
4. `.claude/skills/skill-escalation` が正しい相対シンボリックリンクである
5. `AGENTS.md` のスキル表が `.agents/skills` 配下の実体と一致する
6. `.agents/skills/skill-setup` が存在しない
7. `.claude/skills/skill-setup` が存在しない
