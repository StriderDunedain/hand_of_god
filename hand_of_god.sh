#!/usr/bin/env bash

# NOTES:
# man-pages should be in ~/.local/share/man/man1


# VALIDATORS

is_spositive_int () { [[ $1 =~ ^[1-9]+$ ]] }  # 's' means 'strictly'

is_positive_int () { [[ $1 =~ ^[0-9]+$ ]] }

is_int () { [[ $1 =~ ^-?[0-9]+$ ]] }

no_args () { [[ $# -eq 0 ]] }

# HELPER FUNCTIONS

get_next_ex_name () {
	local found=false
	local last=0

	for dir in ex*/; do
		[[ -d $dir ]] || continue
		found=true
		num="${dir%/}"
		num="${num:2}"
		(( num > last )) && last=$num
	done

	if ! $found; then
		echo "No exercises found. Creating ex00..." >&2
		echo "ex00"
		return
	fi
    printf "ex%02d" $((last + 1))
}

# Make those a part of existing ones

get_next_ex_name2 () {
	local found=false
	local last=0

	for dir in task*/; do
		[[ -d $dir ]] || continue
		found=true
		num="${dir%/}"
		num="${num:2}"
		(( num > last )) && last=$num
	done

	if ! $found; then
		echo "No tasks found. Creating task1..." >&2
		echo "task1"
		return
	fi
    printf "task%d" $((last + 1))
}

nxt () {
	dir_name="$1"

	if no_args "$@"; then
		if [[ ${PWD##*/} == task* ]]; then
			up
		fi
		dir_name=$(get_next_ex_name2) || return 1
	fi

	mkdir -p "$dir_name" && cd "$dir_name"
}

# FUNCTIONS

# ll () { ls -A -l; }

tsk () {
	touch "main.cpp" && code -r "main.cpp"
}

cpl () {
	file="$1"

	if no_args "$@" || { [[ "$file" != *.c ]] && [[ "$file" != *.cpp ]] }; then
		echo "Provide a .c / .cpp file"
		return 1;
	fi
	if [[ "$file" != *.c ]]; then
		gcc -Wall -Wextra -Werror "$file" -o a.out && ./a.out
		return 1;
	fi
	g++ -o "$file" a.out && ./a.out
}

wrt () {
	local message="$1"

	echo " +++       Wrapping everything up       +++"

	git add -A

	if no_args "$@"; then
		if git diff --cached --name-only --quiet; then
			echo " +++ No changes detected. Aborting commit +++"
			return 1
		fi
		files="$(git diff --cached --name-only)"
		count="$(printf "%s\n" "$files" | grep -c .)"
		message="Updating: $files ($count files)"
		echo " +++ Commit message will be: <$message> +++"
	fi

	git commit -m "$message" &&
	git push
}

cln () {
	echo " +++ Deleting .out files... +++ "
	rm -f *.out(N)
	rm -f .*.swp(N)

	echo " +++    Norminette says:    +++"
	norminette
	echo ""

	echo " +++  Following files left:  +++"
	ls -A
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
			| sed 's/^/ - /'
	fi
}

adv () {
	dir_name="$1"

	if no_args "$@"; then
		if [[ ${PWD##*/} == ex* ]]; then
			up
		fi
		dir_name=$(get_next_ex_name) || return 1
	fi

	mkdir -p "$dir_name" && cd "$dir_name"
}

refresh () {
	source "$HOD_PATH"
}

clr () { clear; }

la () { ls -A; }

ce () { mkdir -p "$1" && cd "$1"; }  # 'Create and enter'

rd () { rm -rf "$1"; }  # 'Remove directory'

up () {
	N=${1:-1}

	if ! is_positive_int "$N"; then
		echo "The argument $N isn't a positive integer"
		return 1;
	fi

	while ((N-- > 0)); do
		cd .. || return
	done
}
