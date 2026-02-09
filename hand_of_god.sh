#!/usr/bin/env bash

# NOTES:
# man-pages are in ~/.local/share/man/man1

# VALIDATORS

is_spositive_int () {
	[[ $1 =~ ^[1-9]+$ ]]
}

is_positive_int () {
	[[ $1 =~ ^[0-9]+$ ]]
}

is_int () {
	[[ $1 =~ ^-?[0-9]+$ ]]
}

no_args () {
	[[ $# -eq 0 ]]
}

# HELPER FUNCTIONS

get_next_ex_name () {
	if [[ ! -d ".git" ]]; then
		echo "Are you sure you are in a project? I don't see a .git file" >&2
		echo "Aborting creating an exercise folder..." >&2
		return 1
	fi


	setopt -s nullglob
        dirs=(ex*/)
	if (( ${#dirs[@]} == 0 )); then
		echo "Found no previous exercise directories. Creating ex00..." >&2
		dir_name="ex00"
	else
		last_dir="${dirs[-1]%/}"  # remove the trailing slash
		last_ex_number=${last_dir:2}
		next_ex_number=$(( last_ex_number + 1 ))
        	dir_name=$(printf "ex%02d" "next_ex_number")

	fi

	echo "$dir_name"
}

# FUNCTIONS

cpl () {
	file="$1"

	if no_args "$@" || [[ "$file" != *.c ]]; then
		echo "No .c file provided"
		return 1;
	fi

        echo "Compiling..."
	cc -Wall -Wextra -Werror "$file" && ./a.out
}

wrt () {
	message="$1"

	if no_args "$@"; then
		echo "Using <${PWD##*/}> as commit message..."
		if [[ ${PWD##*/} == ex* ]]; then
			up
		elif [[ ! -d ".git" ]]; then
			echo "I can't seem to find the project folder..."
			return 1
		fi
		message="${PWD##*/}"
	fi

	echo "Wrapping everything up..."
	git add . && git commit -m "$message" && git push
}

cln () {
	echo " +++ Deleting .out files... +++ "
	rm -f *.out(N)

	echo " +++ Norminette says: +++ "
	norminette
	echo ""

	echo " +++ Following files left: +++ "
	ls -a -A
}

hod () {
	local HODPATH="$HOME/.local/share/man/man1"
	cmd_name="$1"

	if [[ $# -eq 1 ]]; then
		nano "$HODPATH/$cmd_name.1"
	else
		echo "These are all the utils that pertain to the Hand of God (HOD) project:"
		find "$HODPATH" -name "*.1" \
			-exec sed -n '/^\.SH NAME/{n;p;}' {} \; \
			| sed 's/^/ • /'
	fi
}

adv () {
	if no_args "$@"; then
		if [[ ${PWD##*/} == ex* ]]; then
			up
		fi
		dir_name=$(get_next_ex_name) || return 1
	else
		dir_name="$1"
	fi
	mkdir -p "$dir_name" && cd "$dir_name"
}

prev () {
	setopt -s nullglob
	dirs=(ex*/)

	up

	curr_dir="${dirs[-1]%/}"  # remove the trailing slash
	curr_ex_number=${curr_dir:2}
	prev_ex_number=$(( curr_ex_number - 1 ))
	prev_ex=$(printf "ex%02d" "prev_ex_number")

	cd "$prev_ex"
}

next () {
        setopt -s nullglob
        dirs=(ex*/)

        up

        curr_dir="${dirs[-1]%/}"  # remove the trailing slash
        curr_ex_number=${curr_dir:2}
        next_ex_number=$(( next_ex_number + 1 ))
        next_ex=$(printf "ex%02d" "next_ex_number")

        cd "$next_ex"
}

refresh () { source "$HOME/.zshrc" }

clr () { clear }

ll () { ls -a -A -l }

la () { ls -a -A }

up () {
	N=${1:-1}

	if ! is_positive_int "$N"; then
		echo "The argument $N isn't a positive integer"
		return 1;
	fi

	ups=""
	while ((N-- > 0)); do
		ups+="../"
	done

	cd "$ups"
}
