#!/bin/bash

# shellcheck source=.

script_dir="$1"
LANGUAGE=$3

. "${script_dir}/bashlibs/get_pmd.sh"
. "${script_dir}/bashlibs/check_src.sh"

RULES="${script_dir}/rulesets/${2}"
RUN_PMD=$(find -L "$script_dir" -name run.sh)

function check_code() {
    FILELIST=$(mktemp)
    find . -type d -name src > "$FILELIST"
    check_src_dir
    "$RUN_PMD" pmd -language $LANGUAGE -filelist $FILELIST -rulesets $RULES -f text 2>/dev/null
    rm "$FILELIST"
}
