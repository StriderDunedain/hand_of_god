#!/usr/bin/env bash

wrt () {
	local checks_42=0
	local no_readme=0

	printf "Wrapping everything up...\n\n"

	while [[ $# -gt 0 ]]; do
		case $1 in
			-42)
				checks_42=1 ;;
			--no_readme)
				no_readme=1 ;;
			*)
				break ;;
		esac
		shift
	done

	if [[ $checks_42 -eq 1 ]]; then
		_wrt_checks_42 "$no_readme"
		printf "\n"
	fi

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
		printf "Nested git repos found. Aborting\n" >&2
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

	local message="$*"
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

# SUPPORT FUNCTIONS

_wrt_checks_42 () {
	local no_readme=$1

	if [[ $no_readme -eq 0 && ! -f README.md ]]; then
        printf "\nAdd a README.md file. Aborting\n" >&2
        return 1
    fi

    if ! norminette; then
        printf "\nNorm errors found. Fix before committing\n" >&2
        return 1
    fi
}











