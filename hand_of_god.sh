#!/usr/bin/env bash

# NOTES:
# man-pages should be in ~/.local/share/man/man1


# VALIDATORS

is_spositive_int () { [[ $1 =~ ^[1-9]+$ ]] }  # 's' means 'strictly'

is_positive_int () { [[ $1 =~ ^[0-9]+$ ]] }

is_int () { [[ $1 =~ ^-?[0-9]+$ ]] }

no_args () { [[ $# -eq 0 ]] }

adv () {
	local prefix="ex"
	local width=2

	local OPTIND opt

	while getopts "p:w:n" opt; do
		case "$opt" in
			p) prefix="$OPTARG" ;;
			w) width="$OPTARG" ;;
			n) width=0 ;;
			*) return 1 ;;
		esac
	done

	shift $((OPTIND - 1))

	local root dir_name

	root=$(git rev-parse --show-toplevel 2>/dev/null) || return 1

	# if inside prefixNN go to git root
	if [[ ${PWD:t} == ${prefix}<-> ]]; then
		cd "$root" || return 1
	fi

	dir_name=$(_get_next_name "$prefix") || return 1

	mkdir -p "$dir_name" &&
	cd "$dir_name"

	if [[ "$prefix" == task ]]; then
		tsk || return 1;
	fi
}

_get_next_name () {
	local prefix="$1"
	local last="$2"

	local dir num last=-1 format

	for dir in ${prefix}<->(/N); do
		num="${dir#$prefix}"
		(( num > last )) && last=$num
	done

	if (( width > 0 )); then
		format="%0${width}d"
	else
		format="%d"
	fi

	printf "%s${format}\n" "$prefix" $((last + 1))
}

# FUNCTIONS

tsk () {
	touch "main.cpp" && code -r "main.cpp"
}

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
	printf "Wrapping everything up...\n\n"

	if [[ ! -f README.md ]]; then
		printf "Add a README.md file. Aborting\n"
		return 1
	fi

	if ! norminette; then
		printf "\nNorm errors found. Fix before committing\n" >&2
		return 1
	fi

	printf "\n"

	local artifact_files=( *.out(N) *.o(N) *.a(N) )

	if (( ${#artifact_files} > 0 )); then
		printf "These files will be deleted prior to commit:\n"
		printf "  %s;\n" "${artifact_files[@]}"

		read "answer?Delete those files? (y/n): "

		if [[ "$answer" == [Yy] ]]; then
			rm -- "${artifact_files[@]}"
			printf "Deleted. Proceeding with the commit\n"
		elif [[ "$answer" == [Nn] ]]; then
			printf "Committing with files present\n"
		else
			printf "Invalid answer: '%s'. Aborting\n" "$answer" >&2
			return 1
		fi
	fi

	local git_dirs=( */**/.git(ND) )

	if (( ${#git_dirs} > 0)); then
		printf "Nested git repos found. Aborting\n"
		return 1
	fi

	git add -A

	if git diff --cached --name-only --quiet; then
		printf "\nNo changes detected. Aborting commit\n" >&2
		return 1
	fi

	typeset -A status_map

	while IFS=$'\t' read -r git_status file; do
		status_map["$file"]="$git_status"
	done < <(git diff --cached --name-status)

	local staged_files=( ${(k)status_map} )

	printf "\nStaged files:\n"
	printf "  %s\n" "${staged_files[@]}"

	local message="$1"
	if [[ -z "$message" ]]; then
		local message_parts=()
		local count=${#staged_files}

		local file_num="file"
		(( count != 1 )) && file_num="files"

		for file in "${staged_files[@]}"; do
			message_parts+=("${file}(${status_map[$file]})")
		done

		message="Diff: ${(j:, :)message_parts} (${count} ${file_num})"
	fi
	printf "\nCommit message will be: \n<%s>\n\n" "$message"
	
	if git commit -m "$message"; then
		git push
	else
		printf "\nCommit failed. Aborting\n" >&2
		return 1
	fi
}

cln () {

	echo "FUNCTION HAS BEEN DEPRECATED, USE 'wrt()' INSTEAD!"
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

refresh () { source "$HOD_PATH" }

clr () { clear; }

la () { ls -A $1; }

ll () { ls -A -l; }

ce () { mkdir -p "$1" && cd "$1"; }  # 'Create and enter'

rd () { rm -rf "$@"; }  # 'Remove directory'

md () { mkdir -p "$1" }

work () { cd "$WORK_DIR_PATH" }

evl () { cd "$EVAL_PATH" }

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

pr () {
	[[ -z "$WORK_DIR_PATH" ]] && echo "WORK_PATH_DIR is not set" && return 1

	local query="$1"
	local project=$(find "$WORK_DIR_PATH" -maxdepth 1 -type d -printf "%f\n" \
		| fzf --filter="$query" | head -n 1) || return

	[[ -z "$project" ]] && echo "No match found" && return 1

	cd "${WORK_DIR_PATH}/${project}" || return
}
