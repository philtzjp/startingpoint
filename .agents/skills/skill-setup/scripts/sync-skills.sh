#!/usr/bin/env bash
set -euo pipefail

repo_url="https://github.com/philtzjp/skills.git"
source_subdir="."
skills_csv=""
apply=0
force=0
list_only=0

usage() {
    cat <<'USAGE'
Usage:
  sync-skills.sh --list [--repo URL] [--source-subdir PATH]
  sync-skills.sh --skills name[,name...] [--apply] [--force] [--repo URL] [--source-subdir PATH]

Defaults:
  --repo https://github.com/philtzjp/skills.git
  --source-subdir .

Behavior:
  Without --apply, the script only prints planned changes.
  Existing local skills with diffs are never overwritten unless --force is also set.
USAGE
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --repo)
            repo_url="${2:?--repo requires a value}"
            shift 2
            ;;
        --source-subdir)
            source_subdir="${2:?--source-subdir requires a value}"
            shift 2
            ;;
        --skills)
            skills_csv="${2:?--skills requires a value}"
            shift 2
            ;;
        --apply)
            apply=1
            shift
            ;;
        --force)
            force=1
            shift
            ;;
        --list)
            list_only=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

if [ "$list_only" -eq 0 ] && [ -z "$skills_csv" ]; then
    echo "--skills is required unless --list is used" >&2
    usage >&2
    exit 2
fi

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

if [ ! -d ".agents/skills" ]; then
    echo "Missing .agents/skills. Run this from a project root." >&2
    exit 1
fi

mkdir -p ".claude/skills"

tmp_dir="$(mktemp -d)"
cleanup() {
    rm -rf "$tmp_dir"
}
trap cleanup EXIT

if [ "$source_subdir" = "." ]; then
    source_skills_path=".agents/skills"
else
    source_skills_path="$source_subdir/.agents/skills"
fi

git clone --quiet --depth 1 --filter=blob:none --sparse "$repo_url" "$tmp_dir/repo" >/dev/null
git -C "$tmp_dir/repo" sparse-checkout set "$source_skills_path" >/dev/null

source_skills_dir="$tmp_dir/repo/$source_skills_path"
if [ ! -d "$source_skills_dir" ]; then
    echo "Upstream skills directory not found: $source_skills_path" >&2
    exit 1
fi

if [ "$list_only" -eq 1 ]; then
    find "$source_skills_dir" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
    exit 0
fi

IFS=',' read -r -a skills <<< "$skills_csv"
had_blocked_diff=0

for skill_name in "${skills[@]}"; do
    if ! printf "%s" "$skill_name" | grep -Eq '^[a-z0-9][a-z0-9-]*$'; then
        echo "Invalid skill name: $skill_name" >&2
        exit 1
    fi

    source_skill_dir="$source_skills_dir/$skill_name"
    target_skill_dir=".agents/skills/$skill_name"
    claude_link=".claude/skills/$skill_name"

    if [ ! -f "$source_skill_dir/SKILL.md" ]; then
        echo "Missing upstream skill: $skill_name" >&2
        exit 1
    fi

    if [ -d "$target_skill_dir" ]; then
        if diff -qr "$source_skill_dir" "$target_skill_dir" >/dev/null; then
            echo "unchanged: $skill_name"
        elif [ "$force" -eq 0 ]; then
            echo "blocked-diff: $skill_name"
            diff -ru "$target_skill_dir" "$source_skill_dir" | sed -n '1,200p' || true
            had_blocked_diff=1
            continue
        else
            echo "update: $skill_name"
        fi
    else
        echo "add: $skill_name"
    fi

    if [ "$apply" -eq 1 ]; then
        rm -rf "$target_skill_dir"
        cp -R "$source_skill_dir" "$target_skill_dir"
        rm -rf "$claude_link"
        ln -s "../../.agents/skills/$skill_name" "$claude_link"
    fi
done

if [ "$had_blocked_diff" -eq 1 ]; then
    echo "One or more local skills differ from upstream. Review the diff and rerun with --force only after approval." >&2
    exit 1
fi

if [ "$apply" -eq 0 ]; then
    echo "Dry-run complete. Rerun with --apply to write changes."
else
    echo "Sync complete. Update AGENTS.md/CLAUDE.md skill table if the adopted skill set changed."
fi
