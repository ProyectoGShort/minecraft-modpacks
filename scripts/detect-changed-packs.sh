#!/usr/bin/env bash
# Outputs a JSON array of pack directories that need to be exported.
#
# Required environment variables (set by the GitHub Actions workflow):
#   EVENT       - github.event_name  (push | workflow_dispatch)
#   INPUT_PACK  - manual pack name from workflow_dispatch input (optional)
#   BEFORE      - SHA of the commit before the push
#   AFTER       - SHA of the current commit

set -euo pipefail

# Returns a JSON array with every pack directory under modpacks/
all_packs() {
    find modpacks -maxdepth 2 -name "pack.toml" \
        | sed 's|/pack.toml||' \
        | jq -R . | jq -sc .
}

# Returns a JSON array with only pack directories that have changed files in this push
changed_packs() {
    local first_push="0000000000000000000000000000000000000000"

    if [ "$BEFORE" = "$first_push" ]; then
        # No previous commit to compare against — export all packs
        all_packs
        return
    fi

    # grep exits 1 when there are no matches; with pipefail that would fail the whole script
    # (e.g. push that only touches README or files outside modpacks/).
    local changed_dirs
    changed_dirs=$(git diff --name-only "$BEFORE" "$AFTER" \
        | { grep '^modpacks/' || true; } \
        | cut -d/ -f1-2 | sort -u)

    local packs=()
    local dir
    if [ -n "$changed_dirs" ]; then
        while IFS= read -r dir; do
            [ -z "$dir" ] && continue
            [ -f "$dir/pack.toml" ] && packs+=("$dir")
        done <<< "$changed_dirs"
    fi

    if [ "${#packs[@]}" -eq 0 ]; then
        echo '[]'
        return
    fi
    printf '%s\n' "${packs[@]}" | jq -R . | jq -sc .
}

# -----------------------------------------------------------------
# Main: decide which packs to export based on how the workflow ran
# -----------------------------------------------------------------

if [ "$EVENT" = "workflow_dispatch" ] && [ -n "$INPUT_PACK" ]; then
    # Manual run targeting a specific pack
    PACKS="[\"$INPUT_PACK\"]"

elif [ "$EVENT" = "workflow_dispatch" ]; then
    # Manual run with no specific pack — export everything
    PACKS=$(all_packs)

else
    # Triggered by a push — export only what changed
    PACKS=$(changed_packs)
fi

echo "Packs to export: $PACKS"
echo "packs=$PACKS" >> "$GITHUB_OUTPUT"
