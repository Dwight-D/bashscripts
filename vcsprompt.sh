#!/bin/bash

# Adapted from from https://github.com/hoelzro/bashrc/blob/master/colors.sh

function __prompt
{
    # List of color variables that bash can use
    local COL0="\[\033[0;30m\]"   # Black
    local COL1="\[\033[1;30m\]"   # Dark Gray
    local COL2="\[\033[0;31m\]"     # Red
    local COL3="\[\033[1;31m\]"    # Light Red
    local COL4="\[\033[0;32m\]"   # Green
    local COL5="\[\033[1;32m\]"  # Light Green
    local COL6="\[\033[0;33m\]"   # Brown
    local COL7="\[\033[1;33m\]"  # Yellow
    local COL8="\[\033[0;34m\]"    # Blue
    local COL9="\[\033[1;34m\]"   # Light Blue
    local COL10="\[\033[0;35m\]"  # Purple
    local COL11="\[\033[1;35m\]" # Light Purple
    local COL12="\[\033[0;36m\]"    # Cyan
    local COL13="\[\033[1;36m\]"   # Light Cyan
    local COL14="\[\033[0;37m\]"   # Light Gray
    local COL15="\[\033[1;37m\]"   # White

    local RESET="\[\033[0m\]"      # Color reset
    local BOLD="\[\033[;1m\]"      # Bold

    # Base prompt
    PS1="$COL13\h:$COL7\w$COL13 \\\$$RESET "

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
            status_color=$COL5
        else
            status_color=$COL3
        fi
        PS1="$COL13($BOLD$status_color$branch$COL13)$RESET $PS1"
    fi
}

if [[ -z "$PROMPT_COMMAND" ]]; then
    PROMPT_COMMAND=__prompt
else
    PROMPT_COMMAND="$PROMPT_COMMAND ; __prompt"
fi
__prompt
