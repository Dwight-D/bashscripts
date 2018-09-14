#!/bin/bash

# Adapted from from https://github.com/hoelzro/bashrc/blob/master/colors.sh
# Color variables set in .bashrc

function __prompt
{

    # Base prompt
    #PS1="$COL13\u $COL15 @ $COL9 \W\n$COL5>$COL_RESET "
    PS1="$COL13\u $COL15 / $COL5 \W\n$COL5>$COL8 "
    trap 'echo -ne "\e[0m" ' DEBUG
    local dirty
    local branch

    # Look for Git status
    if git status &>/dev/null; then
        if git status -uno -s | grep -q . ; then
            dirty=1
        fi
        branch=$(git branch --color=never | sed -ne 's/* //p')

    # Look for Subversion status
    else
        svn_info=$( (svn info | grep ^URL) 2>/dev/null )
        if [[ ! -z "$svn_info" ]] ; then
            branch_pattern="^URL: .*/(branch(es)?|tags)/([^/]+)"
            trunk_pattern="^URL: .*/trunk(/.*)?$"
            if [[ $svn_info =~ $branch_pattern ]]; then
                branch=${BASH_REMATCH[3]}
            elif [[ $svn_info =~ $trunk_pattern ]]; then
                branch='trunk'
            else
                branch='SVN'
            fi
            dirty=$(svn status -q)
        fi
    fi

    if [[ ! -z "$branch" ]]; then
        local status_color
        if [[ -z "$dirty" ]] ; then
            status_color=$COL4
	
        else
            status_color=$COL3
        fi
        PS1="$COL15($status_color$branch$COL15)$RESET $PS1"
    fi
}

if [[ -z "$PROMPT_COMMAND" ]]; then
    PROMPT_COMMAND=__prompt
else
    PROMPT_COMMAND="$PROMPT_COMMAND ; __prompt"
fi
__prompt
