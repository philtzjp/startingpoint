---
name: skill-setup
description: 上流リポジトリ `philtzjp/skills` から必要なプロジェクトスキルを初期導入・同期・更新するとき、採用するスキルを選定するとき、`.agents/skills`、`.claude/skills`、`AGENTS.md`、`CLAUDE.md` のスキル構成を上流由来の構成に合わせるときに参照する。
---

# スキルセットアップ

## 目的

このスキルは、プロジェクトごとの `.agents/skills` が上流正本と少しずつ乖離する問題を抑えるため、必要なスキルだけを `philtzjp/skills` から取り込む手順を定義する。

`skill-setup` 自体はこのテンプレートの bootstrap skill として扱う。上流の採用スキル一覧に含まれていなくても、ユーザーが明示的に削除を指示しない限り残す。

## 上流

- リポジトリ: `https://github.com/philtzjp/skills.git`
- 既定の参照パス: `.agents/skills`
- 既定の指示ファイル: `AGENTS.md`

旧リポジトリ名 `philtzjp/PHILTZ.md` は使用しない。

## 基本方針

1. MUST: 上流から無条件に全スキルを取り込まず、プロジェクトに必要なスキルだけを採用する
2. MUST: 既存のローカルスキルに差分がある場合、差分確認なしに上書きしない
3. MUST: スキル正本は `.agents/skills/<name>/SKILL.md` に置く
4. MUST: `.claude/skills/<name>` は `../../.agents/skills/<name>` への相対シンボリックリンクにする
5. MUST: `AGENTS.md` が実体で `CLAUDE.md` がそのシンボリックリンクなら、スキル表は `AGENTS.md` を編集する
6. NEVER: `.claude/skills/<name>/SKILL.md` を実ファイルとして編集しない
7. NEVER: `skill-setup` 自体を同期スクリプトの結果だけで削除しない

## 手順

1. 採用するスキル名を決める。ユーザーが明示していない場合は、上流一覧と現在の `.agents/skills` を比較し、追加・削除候補を説明して確認する。
2. 同期前に `git fetch --prune` を実行し、現在の作業ツリーに未コミット変更があるか確認する。
3. `scripts/sync-skills.sh` を dry-run で実行し、追加・更新・差分ありの結果を確認する。
4. 差分ありの既存スキルは、ユーザーが上書きを承認するまで `--force` を使わない。
5. `--apply` でスキル本体と `.claude/skills` のリンクを同期する。
6. `AGENTS.md` のスキル表に、採用済みスキルと発火タイミングを反映する。
7. 本スキルの「整合性検査」に従って、スキル本体・シンボリックリンク・スキル表を確認する。

## 同期スクリプト

上流のスキル一覧を確認する:

```bash
bash .agents/skills/skill-setup/scripts/sync-skills.sh --list
```

指定スキルの dry-run:

```bash
bash .agents/skills/skill-setup/scripts/sync-skills.sh --skills commit-and-git,refresh-skills
```

指定スキルを反映する:

```bash
bash .agents/skills/skill-setup/scripts/sync-skills.sh --skills commit-and-git,refresh-skills --apply
```

差分確認後に既存スキルを上書きする:

```bash
bash .agents/skills/skill-setup/scripts/sync-skills.sh --skills refresh-skills --apply --force
```

## AGENTS.md の更新

1. MUST: スキル表の `skill` 列は `.agents/skills` 配下のディレクトリ集合と一致させる
2. MUST: `skill-setup` の行を残す
3. MUST: 新規導入したスキルは、frontmatter `description` と本文の発火タイミングを読んで、短い日本語の説明で表に追加する
4. MUST: 不採用にしたスキルの行を表から削除する
5. MUST: `CLAUDE.md` が `AGENTS.md` へのシンボリックリンクなら `CLAUDE.md` を直接編集しない

## 整合性検査

同期後は少なくとも以下を確認する。

```bash
find .agents/skills -mindepth 1 -maxdepth 1 -type d -print | sort
find .claude/skills -mindepth 1 -maxdepth 1 -print | sort
```

確認観点:

1. `.agents/skills/<name>/SKILL.md` が存在する
2. `.claude/skills/<name>` が `../../.agents/skills/<name>` への相対シンボリックリンクである
3. `.claude/skills/<name>` のリンク先が存在する
4. `AGENTS.md` のスキル表と `.agents/skills` のディレクトリ集合が一致する
5. 各 `SKILL.md` の frontmatter `name` がディレクトリ名と一致する

## 上流から追加できる代表的なスキル

必要になった時点で、上流から個別に同期する。

- `commit-and-git`: コミット・ブランチ・PR など Git 操作の規約
- `refresh-skills`: 同期後の整合性検査と修復を細かく運用したい場合の手順
- `skill-selection`: 採用するスキルを選ぶ判断軸
- `skill-escalation`: ローカルで改善したスキルを上流へ提案する手順
