#!/usr/bin/env bash

wrt () {
	local norm=1
	local no_readme=0
	local dir

	printf "Wrapping everything up...\n\n"

	while [[ $# -gt 0 ]]; do
		case $1 in
			--no-norm)
				norm=0 ;;
			--no-readme)
				no_readme=1 ;;
			--*)
				printf "Unknown wrt option: %s\n" "$1" >&2
				return 1 ;;
			*)
				break ;;
		esac
		shift
	done

	if (( norm )); then
		for dir  in "${NORM_COMPLIANT_DIRS[@]}"; do
			if [[ $PWD == "$dir" || "$PWD" == "$dir"/* ]]; then
				_wrt_42_check "$no_readme" || return
				printf "\n"
				break
			fi
		done
	fi

	local -a artifact_files=()
	local artifact
	while IFS= read -r -d '' artifact; do
		artifact_files+=("$artifact")
	done < <(find . -maxdepth 1 -type f \( -name '*.out' -o -name '*.o' -o -name '*.a' \) -print0)

	if (( ${#artifact_files} > 0 )); then
		printf "These files will be deleted prior to commit:\n"
		printf "  %s;\n" "${artifact_files[@]}"

		local answer
		read -r -p "Delete those files? (y/n): " answer

		if [[ "$answer" == [Yy] ]]; then
			rm -- "${artifact_files[@]}" || return 1
			printf "Deleted. Proceeding with the commit\n"
		elif [[ "$answer" == [Nn] ]]; then
			printf "Committing with files present\n"
		else
			printf "Invalid answer: '%s'. Aborting\n" "$answer" >&2
			return 1
		fi
	fi

	local nested_git_dir
	nested_git_dir=$(find . -mindepth 2 -name .git -print -quit)
	if [[ -n $nested_git_dir ]]; then
		printf "Nested git repos found. Aborting\n" >&2
		return 1
	fi

	git add -A || return 1

	if git diff --cached --name-only --quiet; then
		printf "\nNo changes detected. Aborting commit\n" >&2
		return 1
	fi

	declare -A status_map=()

	while IFS=$'\t' read -r git_status file; do
		status_map["$file"]="$git_status"
	done < <(git diff --cached --name-status)

	local -a staged_files=( "${!status_map[@]}" )

	printf "\nStaged files:\n"
	printf "  %s\n" "${staged_files[@]}"

	local message="$*"
	if [[ -z "$message" ]]; then
		local message_parts=()
		local count=${#staged_files[@]}

		local file_num="file"
		(( count != 1 )) && file_num="files"

		for file in "${staged_files[@]}"; do
			message_parts+=("${file}(${status_map[$file]})")
		done

		local joined_parts=""
		local part
		for part in "${message_parts[@]}"; do
			if [[ -n $joined_parts ]]; then
				joined_parts+=", "
			fi
			joined_parts+="$part"
		done

		message="Diff: $joined_parts (${count} ${file_num})"
	fi
	printf "\nCommit message will be: \n<%s>\n\n" "$message"
	
	if git commit -m "$message"; then
		if ! git push; then
			printf "\nPush failed\n" >&2
			return 1
		fi
	else
		printf "\nCommit failed. Aborting\n" >&2
		return 1
	fi
}

# SUPPORT FUNCTIONS

_wrt_42_check () {
	local no_readme=$1

	if [[ $no_readme -eq 0 && ! -f README.md ]]; then
		printf "\nAdd a README.md file. Aborting\n" >&2
		return 1
	fi

	if ! norminette; then
		printf "\nNorm errors found. Fix before committing\n" >&2
		return 1
	fi

	return 0
}
