#!/usr/bin/env bash

# NOTE: Following functions have been deprecated, use others instead
# Refer to the man pages for info

cln () {

	echo "FUNCTION HAS BEEN DEPRECATED, USE 'wrt()' INSTEAD!"
	echo " +++ Deleting .out files... +++ "
	rm -f -- ./*.out ./.*.swp

	echo " +++    Norminette says:    +++"
	norminette
	echo

	echo " +++  Following files left:  +++"
	ls -A
}

hod () {
	local HODPATH="$HOME/.local/share/man/man1"
	local cmd_name="$1"

	echo "THIS FUNCTION HAS BEEN DEPRECATED, USE THE MAN PAGES INSTEAD!"
	if [[ $# -eq 1 ]]; then
		nano "$HODPATH/$cmd_name.1"
	else
		echo "These are all the utils that pertain to the Hand of God (HOD) project:"
		find "$HODPATH" -name "*.1" \
			-exec sed -n '/^\.SH NAME/{n;p;}' {} \; \
			| sed 's/^/ - /'
	fi
}
