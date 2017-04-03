#!/bin/bash

set -e

colorize_remotes() {
    perl -pe 's|^(remotes/.*)$|\033[31m$1\033[m|g'
}

remove_color() {
    perl -pe 's/\e\[?.*?[\@-~]//g'
}

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

get_filter() {
    local x candidates

    if [[ -z $1 ]]; then
        return 1
    fi

    # candidates should be list like "a:b:c" concatenated by a colon
    candidates="$1:"

    while [[ -n $candidates ]]
    do
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

# If you are not in a git repository, the script ends here
git_root_dir="$(git rev-parse --show-toplevel)"
current_branch="$(git rev-parse --abbrev-ref HEAD)"

GIT_FILTER=${GIT_FILTER:-fzy:fzf-tmux:fzf:peco}

filter="$(get_filter "$GIT_FILTER")"
if [[ -z $filter ]]; then
    echo "No available filter in \$GIT_FILTER" >&2
    exit 1
fi

logfile="$git_root_dir/.git/logs/switch.log"
post_script="$git_root_dir/.git/hooks/post-checkout"

if [[ ! -x $post_script ]]; then
    cat <<HOOK >|"$post_script"
git rev-parse --abbrev-ref HEAD >>$logfile
HOOK
    chmod 755 "$post_script"
fi

if [[ ! -f $logfile ]]; then
    touch "$logfile"
fi

candidates="$(
{
    cat "$logfile" \
        | reverse \
        | unique
    git branch -a --no-color \
        | cut -c3-
} \
    | unique \
    | colorize_remotes \
    | grep -v "HEAD" \
    | grep -v "$current_branch" || true
    # ^ if the candidates is empty, grep return false
)"

if [[ -z $candidates ]]; then
    echo "No available branches to be checkouted" >&2
    exit 1
fi

selected_branch="$(echo "$candidates" | $filter | remove_color)"
if [[ -z $selected_branch ]]; then
    exit 0
fi

git checkout "$selected_branch"
exit $?
