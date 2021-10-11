#!/bin/bash
_notes_dir=$NOTES_DIR
_today=$(date "+%Y-%m-%d")

_project_dir="$NOTES_DIR/$1"
if [[ ! -d $_project_dir ]]; then
    mkdir -p $_project_dir
fi

_note_file="${_project_dir}/${_today}.txt"

vim $_note_file
