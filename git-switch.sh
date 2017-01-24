#!/bin/bash

logfile=".git/logs/switch.log"
post_script=".git/hooks/post-checkout"

if [[ ! -x $post_script ]]; then
    cat <<HOOK >|"$post_script"
git rev-parse --abbrev-ref HEAD >>$logfile
HOOK
    chmod 755 "$post_script"
fi

if [[ ! -f $logfile ]]; then
    touch "$logfile"
fi

GIT_FILTER=${GIT_FILTER:-fzy:peco:fzf}

unique() {
    if [[ -n $1 ]] && [[ -f $1 ]]; then
        cat "$1"
    else
        cat <&0
    fi | awk '!a[$0]++' 2>/dev/null
}

reverse() {
    if [[ -n $1 ]] && [[ -f $1 ]]; then
        cat "$1"
    else
        cat <&0
    fi | awk '
        {
            line[NR] = $0
        }
        
        END {
            for (i = NR; i > 0; i--) {
                print line[i]
            }
        }' 2>/dev/null
}

get_filter()
{
    local x candidates

    if [[ -z $1 ]]; then
        return 1
    fi

    # candidates should be list like "a:b:c" concatenated by a colon
    candidates="$1:"

    while [[ -n $candidates ]]; do
        # the first remaining entry
        x=${candidates%%:*}
        # reset candidates
        candidates=${candidates#*:}

        if type "${x%% *}" &>/dev/null; then
            echo "$x"
            return 0
        else
            continue
        fi
    done

    return 1
}

filter="$(get_filter "$GIT_FILTER")"

current_branch="$(git rev-parse --abbrev-ref HEAD)"

{
    cat "$logfile" \
        | reverse \
        | unique
    git branch -a \
        | cut -c3-
} \
    | unique \
    | grep -v "$current_branch" \
    | $filter \
    | xargs git checkout
