#!/usr/bin/env bash
# Outputs a JSON array of pack directories that need to be exported.
#
# Required environment variables (set by the GitHub Actions workflow):
#   EVENT       - github.event_name  (push | workflow_dispatch)
#   INPUT_PACK  - manual pack name from workflow_dispatch input (optional)
#   BEFORE      - SHA of the commit before the push
#   AFTER       - SHA of the current commit

set -euo pipefail

# Returns a JSON array with every directory that contains a pack.toml
all_packs() {
    find . -maxdepth 2 -name "pack.toml" \
        | sed 's|/pack.toml||; s|^\./||' \
        | jq -R . | jq -sc .
}

# Returns a JSON array with only directories that have changed files in this push
changed_packs() {
    local first_push="0000000000000000000000000000000000000000"

    if [ "$BEFORE" = "$first_push" ]; then
        # No previous commit to compare against — treat as all packs
        all_packs
        return
    fi

    git diff --name-only "$BEFORE" "$AFTER" \
        | cut -d/ -f1 | sort -u \
        | while read -r dir; do
            [ -f "$dir/pack.toml" ] && echo "$dir"
          done \
        | jq -R . | jq -sc .
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
