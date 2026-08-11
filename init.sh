#!/usr/bin/env bash

export MANPATH="$HOME/.local/share/man:$MANPATH"

_pr_completion() {
	local current_word project
	current_word="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=()
	while IFS= read -r project; do
		if [[ $project == "$current_word"* ]]; then
			COMPREPLY+=("$project")
		fi
	done < <(find "$WORK_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2>/dev/null)
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

complete -F _pr_completion pr

_refresh
