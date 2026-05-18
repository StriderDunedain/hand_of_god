#!/usr/bin/env bash

# NOTE: Following functions have been deprecated, use others instead
# Refer to the man pages for info

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