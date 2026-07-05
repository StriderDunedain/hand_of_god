#!/usr/bin/env bash

clr () { clear; }

la () { ls -A "$@"; }

ll () { ls -A -l "$@"; }

ce () { mkdir -p "$1" && cd "$1"; }  # 'Create and enter'

rd () { rm -rf "$@"; }  # 'Remove directory'

md () { mkdir -p "$@" }  # 'Make directory'

l () { dm-tool lock }  # Lock screen

brb () { xset dpms force off }

tch () { touch "$@" }

up () {
	N=${1:-1}

	if ! _is_positive_int "$N"; then
		echo "The argument $N isn't a positive integer"
		return 1;
	fi

	while ((N-- > 0)); do
		cd .. || return
	done
}
