#!/usr/bin/env bash

# PROJECT LIFE CYCLE

if ! declare -p ADV_PREFIX >/dev/null 2>&1; then
	declare -gA ADV_PREFIX=()
fi
if ! declare -p ADV_WIDTH >/dev/null 2>&1; then
	declare -gA ADV_WIDTH=()
fi
if ! declare -p ADV_NAME_REQUIRED >/dev/null 2>&1; then
	declare -gA ADV_NAME_REQUIRED=()
fi

adv () {
	local root
	root=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
	root=$(cd "$root" && pwd -P) || return 1
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
	if (( $# > 1 )); then
		printf "adv accepts at most one name\n" >&2
		return 1
	fi

	local ex_name="${1:-}"

	if [[ -z $prefix ]]; then
		printf "Directory prefix cannot be empty\n" >&2
		return 1
	fi

	if ! [[ $width =~ ^[0-9]+$ ]]; then
		printf "Width must be a non-negative integer: %s\n" "$width" >&2
		return 1
	fi

	if (( name_required )) && [[ -z $ex_name ]]; then
		printf "Project requires an exercise name\n" >&2
		return 1
	fi

	dir_name=$(_adv_get_next_name "$root" "$prefix" "$width") || return 1

	mkdir "$root/$dir_name" || return 1
	cd "$root/$dir_name" || return 1

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
	[[ -z "$WORK_DIR" ]] && {
		echo "WORK_DIR is not set" >&2
		return 1
	}

	if [[ $# -eq 0 ]]; then
		cd "$WORK_DIR" || return 1
		return 0
	fi

	local query="$1"

	local project
	project=$(
		find "$WORK_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2>/dev/null \
		| fzf --filter="$query" \
		| head -n 1
	) || return 1

	[[ -z "$project" ]] && {
		echo "No match found" >&2
		return 1
	}

	cd "$WORK_DIR/$project" || return 1
}

nr () { norminette "$@"; }

cpr () { cd "$CURRENT_PROJECT"; }  # 'Current project'

# PYTHON

py() {
    if [ $# -eq 0 ]; then
        python
        return
    fi

    file="$1"
    shift

    # Add .py extension if missing
    [[ "$file" != *.py ]] && file="${file}.py"

    # Create and open file if it doesn't exist
    if [ ! -f "$file" ]; then
        touch "$file"
        code "$file"
        return
    fi

    black "$file" >/dev/null 2>&1

    python "$file" "$@"
}

# C/C++

cpl () {
	local compiler=cc
	local outfile=a.out
	local verbose=false
	local dry_run=false
	local source_found=false
	local -a compiler_args=()
	local -a run_args=()

	while [[ $# -gt 0 ]]; do
		case $1 in
			-s|--simple)
				compiler_args+=(-Wall -Wextra -Werror) ;;
			-g|--debug)
				compiler_args+=(-g) ;;
			-n|--dry-run)
				dry_run=true ;;
			-v|--verbose)
				verbose=true ;;
			-o|--output)
				if [[ $# -lt 2 ]]; then
					printf "Missing filename after %s\n" "$1" >&2
					return 1
				fi
				outfile="$2"
				shift ;;
			--)
				shift
				run_args=("$@")
				break ;;
			--*)
				printf "Unknown cpl option: %s\n" "$1" >&2
				return 1 ;;
			*)
				compiler_args+=("$1")
				case $1 in
					*.c)
						source_found=true ;;
					*.cpp|*.cc|*.cxx|*.C|*.CPP)
						source_found=true
						compiler=g++ ;;
				esac
				;;
		esac
		shift
	done

	if ! $source_found; then
		printf "No C or C++ source files supplied\n" >&2
		return 1
	fi

	local -a cmd=(
		"$compiler"
		-o "$outfile"
		"${compiler_args[@]}"
	)

	if $verbose || $dry_run; then
		printf 'Compile: '
		printf '%q ' "${cmd[@]}"
		printf '\n'

		local displayed_executable="$outfile"
		if [[ $displayed_executable != */* ]]; then
			displayed_executable="./$displayed_executable"
		fi
		printf 'Run: %q' "$displayed_executable"
		if (( ${#run_args[@]} > 0 )); then
			printf ' %q' "${run_args[@]}"
		fi
		printf '\n'

		if $dry_run; then
			return 0
		fi
	fi

	if ! "${cmd[@]}"; then
		printf "Build failed\n" >&2
		return 1
	fi

	local executable="$outfile"
	if [[ $executable != */* ]]; then
		executable="./$executable"
	fi

	"$executable" "${run_args[@]}"
}

# SUPPORT FUNCTIONS

_adv_get_next_name () {
	local root="$1"
	local prefix="$2"
	local width="$3"

	local dir name number value last=-1 format

	for dir in "$root/$prefix"*; do
		[[ -d $dir ]] || continue
		name=${dir##*/}
		number=${name#"$prefix"}
		[[ $number =~ ^[0-9]+$ ]] || continue
		value=$((10#$number))
		if (( value > last )); then
			last=$value
		fi
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
			if [[ -z $ex_name ]]; then
				ex_name=main
			fi
			touch "${ex_name}.py" && code -r "${ex_name}.py"
			;;
	esac
}
