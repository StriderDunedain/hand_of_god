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

	dir_name=$(_get_next_name "$prefix" "$width") || return 1

	mkdir -p "$dir_name" &&
	cd "$dir_name"

	_task "$prefix" "$ex_name" || return 1
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
	[[ -z "$WORK_DIR_PATH" ]] && echo "WORK_PATH_DIR is not set" && return 1

	local query="$1"
	local project=$(find "$WORK_DIR_PATH" -maxdepth 1 -type d -printf "%f\n" \
		| fzf --filter="$query" | head -n 1) || return

	[[ -z "$project" ]] && echo "No match found" && return 1

	cd "${WORK_DIR_PATH}/${project}" || return
}


work () { cd "$WORK_DIR_PATH" }

cpr () { cd "$CURRENT_PROJECT" }

# PYTHON

py () {
	[ $# -eq 0 ] && return
	clear && python -I "$@"
}

# C

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

# SUPPOT FUNCTIONS

_get_next_name () {
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

_task () {
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