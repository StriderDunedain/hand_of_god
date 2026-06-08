#!/usr/bin/env bash

# PROJECT LIFE CYCLE

adv () {
	local root
	root=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
	root="${root:A}"
	local prefix="${ADV_PREFIX[$root]:-ex}"
	local width="${ADV_WIDTH[$root]:-1}"
	local name_required="${ADV_NAME_REQUIRED[$root]:-0}"
	local dir_name

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

	local ex_name="$1"

	if (( name_required )) && [[ -z $ex_name ]]; then
		printf "Project requires an exercise name\n" >&2
		return 1
	fi

	# if inside prefix* go to git root
	if [[ ${PWD:t} == ${prefix}<-> ]]; then
		cd "$root" || return 1
	fi

	dir_name=$(_adv_get_next_name "$prefix" "$width") || return 1

	mkdir -p "$dir_name" &&
	cd "$dir_name"

	_adv_task "$prefix" "$ex_name" || return 1
}

evl () {
	cd "$EVAL_PATH" || return

	[ $# -eq 0 ] && return

	local pr_link="$1"

	find . -mindepth 1 -maxdepth 1 -type d -exec rm -rf -- {} +

	git clone "$pr_link" || {
		printf "git clone failed"
		return 1
	}

	cd ./*/ || {
		printf "Could not enter cloned dir"
		return 1
	}
		
	code .
}

pr () {
	[[ -z "$WORK_DIR_PATH" ]] && {
		echo "WORK_DIR_PATH is not set" >&2
		return 1
	}

	if [[ $# -eq 0 ]]; then
		cd "$WORK_DIR_PATH" || return 1
		return 0
	fi

	local query="$1"

	local project
	project=$(
		find "$WORK_DIR_PATH" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2>/dev/null \
		| fzf --filter="$query" \
		| head -n 1
	) || return 1

	[[ -z "$project" ]] && {
		echo "No match found" >&2
		return 1
	}

	cd "$WORK_DIR_PATH/$project" || return 1
}


work () { cd "$WORK_DIR_PATH" }

co () { code . }

cpr () { cd "$CURRENT_PROJECT" }  # 'current project'

# PYTHON

py () {
	[ $# -eq 0 ] && return
	clear && python -I "$@"
}

# C/C++

cpl () {
	local compiler=cc
	local outfile=a.out

	local verbose=false
	local dry_run=false

	local -a flags=()
	local -a sources=()
	local -a run_args=()

	while [[ $# -gt 0 ]]; do
		case $1 in
			-s|--simple)
				flags+=(-Wall -Wextra -Werror) ;;
			-g|--debug)
				flags+=(-g) ;;
			-n|--dry-run)
				dry_run=true ;;
			-v|--verbose)
				verbose=true ;;
			--)
				shift
				run_args=("$@")
				break ;;
			*)
				sources+=("$1") ;;
		esac
		shift
	done
	
	if ((${#sources[@]} == 0)); then
		echo "No source files"
		return 1
	fi

	local file
	for file in "${sources[@]}"; do
		case $file in
			*.cpp|*.cc|*.cxx|*.CPP)
				compiler=g++
				break ;;
		esac
	done

	local -a cmd=(
		"$compiler"
		"${flags[@]}"
		-o "$outfile"
		"${sources[@]}"
	)

	if $verbose || $dry_run; then
		printf 'Compile: '
		printf '%q ' "${cmd[@]}"
		printf '\n'

		printf 'Run: ./%q ' "$outfile"
		printf '%q ' "${run_args[@]}"
		printf '\n'

		if $dry_run; then
			return 0
		fi
	fi
 
	if ! "${cmd[@]}"; then
		echo "Build failed"
		return 1
	fi

	"./$outfile" "${run_args[@]}"
}

# SUPPORT FUNCTIONS

_adv_get_next_name () {
	local prefix="$1"
	local width="$2"

	local dir num last=-1 format

	for dir in ${prefix}<->(/N); do
		num="${dir:t}"
		num="${num#$prefix}"
		(( num > last )) && last=$num
	done

	if (( width > 0 )); then
		format="%0${width}d"
	else
		format="%d"
	fi

	printf "%s${format}\n" "$prefix" $((last + 1))
}

_adv_task () {
	local prefix="$1"
	local ex_name="$2"

	case "$prefix" in
		task)
			touch main.cpp &&
			code -r main.cpp
			;;
		ex)
			touch "${ex_name}.py" &&
			code -r "${ex_name}.py"
			;;
	esac
}
