#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

. "${SCRIPT_DIR}/bashlibs/git_utils.sh" $SCRIPT_DIR
git_exit_if_not_clean

function usage() {
    echo "Usage: $0"
    echo "  [-b <n> Go back n commits, defaults to 1]"
    echo "  [-f <n> Force failure when increase greater than n lines, defaults to 10]"
    echo "  [-h print this message]"
}

function isWholeNumber() {
    value=$1
    option=$2
    wholeNumber='^[0-9]+$'
    if ! [[ $value =~ $wholeNumber ]] ; then
       echo "Value provided for $2 option must be a positive whole number"
       echo "Actual value: '$value'"
       exit 1
    fi
}

function total {
    echo $($SCRIPT_DIR/dups.sh 2>/dev/null | $SCRIPT_DIR/utils/summarize.awk | awk -F"," 'BEGIN{sum=0} {sum += $3} END {print sum}')
}

TOTAL_COMMITS_BACK=1
FAIL_THRESHOLD=0
RETURN_STATUS=0
while getopts hb:f: opt
do
    case $opt in
        b )
            TOTAL_COMMITS_BACK=$OPTARG
            isWholeNumber $TOTAL_COMMITS_BACK '-b'
            ;;
        f)
            FAIL_THRESHOLD=$OPTARG
            isWholeNumber $FAIL_THRESHOLD '-f'
            ;;
        h)
            usage
            exit 0
            ;;
        :)
            echo "Invalid Option: -$OPTAG requires an argument" 1>&2
            usage
            exit 1
            ;;
        \?)
            echo "Invalid Option: -$OPTAG" 1>&2
            usage
            exit 1
            ;;
    esac
done

PWD=`pwd`
PROJ=`basename $PWD`
INITIAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)
INITIAL_COMMIT=$(git rev-parse HEAD)


for i in $(git log --pretty=format:"%H" -n $TOTAL_COMMITS_BACK);do
    git checkout $i 2>/dev/null
    COMMIT_DATE=$(git show -s --format=%ci $i)
    START_COMMIT=$(git rev-parse HEAD)
    START_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    START_TOKEN_COUNT=$(total)
    git checkout HEAD^ 2>/dev/null
    END_TOKEN_COUNT=$(total)
    DIFF=`expr $START_TOKEN_COUNT - $END_TOKEN_COUNT`
    if [[ $END_TOKEN_COUNT -gt 0 ]]; then
        DELTA=`expr $DIFF \* 100 / $END_TOKEN_COUNT`
    else
        DELTA=0
    fi
    printf "%-30s: Diff: %8d (%4d%%) Current: %7d Previous: %7d Commit: %7s [%s]\n" \
        "$PROJ" "$DIFF" "$DELTA" "$START_TOKEN_COUNT" "$END_TOKEN_COUNT" \
        "$START_COMMIT" "$COMMIT_DATE"
    if [[ $FAIL_THRESHOLD -gt 0 && $DIFF -ge $FAIL_THRESHOLD ]]; then
        echo "Last commit increased duplication by $DIFF tokens" 1>&2
        echo "Allowed threshold was set to $FAIL_THRESHOLD" 1>&2
        RETURN_STATUS=1
    fi
done

if [[ 'HEAD' == "$INITIAL_BRANCH" ]]; then # detatched head
    git checkout "$INITIAL_COMMIT" > /dev/null 2>&1
else
    git checkout "$INITIAL_BRANCH" > /dev/null 2>&1
fi
exit $RETURN_STATUS
