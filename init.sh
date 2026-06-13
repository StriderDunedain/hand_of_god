#!/usr/bin/env bash

export MANPATH="$HOME/.local/share/man:$MANPATH"

# HOD FUNCTIONS

_center_text() {
  local width=$(tput cols)
  while IFS= read -r line; do
    local len=${#line}
    local padding=$(( (width - len) / 2 ))
    printf "%*s%s\n" "$padding" "" "$line"
  done
}

_pr_completion() {
    local -a projects
    projects=(${(f)"$(find "$WORK_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n")"})

    _describe 'projects' projects
}

_refresh () {
	local dir="$WORK_DIR/hand_of_god/functions"

	[ -d "$dir" ] || {
		printf "The functions/ directory not found: %s\n" "$dir"
		return 1
	}

	for file in "$dir"/*.sh; do
		[ -e "$file" ] || continue
		source "$file"
	done
}

refresh () {
	_refresh
	printf "Functions refreshed\n"
}

compdef _pr_completion pr

_refresh
