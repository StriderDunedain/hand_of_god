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
