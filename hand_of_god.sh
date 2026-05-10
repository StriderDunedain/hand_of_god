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
	local last=0

	for dir in ex*/; do
		[[ -d $dir ]] || continue
		num="${dir%/}"
		num="${num:2}"
		(( num >> last )) && last=$num
	done

	if (( last == 0 )); then
		echo "No exercises found. Creating ex00..." >&2
		echo "ex00"
		return
	fi
    printf "ex%02d" $((last + 1))
}

# FUNCTIONS

ll () { ls -A -l; }

cpl () {
    local simple=false;
	local debug=false;
	local outfile="a.out"

	while [[ $# -gt 0 ]]; do
		case "$1" in
			-s) simple=true ;;
			-g) garbage=true ;;
			*) break ;;
		esac
		shift
	done

	local cmd=(cc)
	if ! $simple; then
		cmd+=("-Wall" "-Wextra" "-Werror")
	fi

	if $garbage; then
		cmd+=("-g")
	fi

	cmd+=("-o" "$outfile")
	cmd+=("$@")

	if "${cmd[@]}"; then
		"./$outfile"
	else
		echo "Build failed"
		return 1
	fi
}

wrt () {
	local message="$1"

	echo "Wrapping everything up..."

	local files=( *.out(N) *.o(N) )

	if ! norminette; then
		echo "Norm errors found. Fix before commiting"
		return 1
	fi

	if (( ${#files} > 0)); then
		echo "These files will be deleted prior to commit:"
		printf "%s\n" "${files[@]}"

		read "answer?Delete those files? (y/n): "

		if [[ "$answer" =~ ^[Yy]$ ]]; then
			rm -- "${files[@]}"
			echo "Deleted. Proceding with the commit"
		else
			echo "Will commit with these files"
		fi
	fi

	git add -A

	if no_args "$@"; then
		if git diff --cached --name-only --quiet; then
			echo "No changes detected. Aborting commit"
			return 1
		fi
		files="$(git diff --cached --name-only)"
		count="$(printf "%s\n" "$files" | grep -c .)"
		message="Updating: $files ($count files)"
		echo "Commit message will be: <$message>"
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

refresh () { source "$HOD_PATH" }

clr () { clear; }

la () { ls -A $1; }

ce () { mkdir -p "$1" && cd "$1"; }  # 'Create and enter'

rd () { rm -rf "$@"; }  # 'Remove directory'

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

work () { cd "$WORK_DIR_PATH" }

pr () {
	[[ -z "$WORK_DIR_PATH" ]] && echo "WORK_PATH_DIR is not set" && return 1

	local query="$1"
	local project=$(find "$WORK_DIR_PATH" -maxdepth 1 -type d -printf "%f\n" \
		| fzf --filter="$query" | head -n 1) || return

	[[ -z "$project" ]] && echo "No match found" && return 1

	cd "${WORK_DIR_PATH}/${project}" || return
}

evl () { cd "$EVAL_PATH" }

md () { mkdir -p "$1" }
