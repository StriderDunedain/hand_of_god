#!/usr/bin/env bash

export MANPATH="$HOME/.local/share/man:$MANPATH"

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

manup() {
    cp "$WORK_DIR/hand_of_god/man_pages/"* "$MAN_PATH"/ || return

    printf '%s\n' "Man pages updated"
}

refresh () {
	_refresh
	printf "Functions refreshed\n"
}

compdef _pr_completion pr

_refresh
