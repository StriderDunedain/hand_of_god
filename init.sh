#!/usr/bin/env bash

export WORK_DIR_PATH="$HOME/dev"
export MANPATH="$HOME/.local/share/man:$MANPATH"

export CURRENT_PROJECT="$WORK_DIR_PATH/python/module03"
export EVAL_PATH="$WORK_DIR_PATH/evals"

# HOD FUNCTIONS

center_text() {
  local width=$(tput cols)
  while IFS= read -r line; do
    local len=${#line}
    local padding=$(( (width - len) / 2 ))
    printf "%*s%s\n" "$padding" "" "$line"
  done
}

_pr_completion() {
    local -a projects
    projects=(${(f)"$(find "$WORK_DIR_PATH" -mindepth 1 -maxdepth 1 -type d -printf "%f\n")"})

    _describe 'projects' projects
}

hod () {
	local HOD_MAN_PATH="$HOME/.local/share/man/man1"
	cmd_name="$1"

	if [[ $# -eq 1 ]]; then
		vim "$HOD_MAN_PATH/$cmd_name.1"
	else
		printf "These are all the utils that pertain to the Hand of God (HOD) project:"
		find "$HOD_MAN_PATH" -name "*.1" \
			-exec sed -n '/^\.SH NAME/{n;p;}' {} \; \
			| sed 's/^/ - /'
	fi
}

_refresh () {
	local dir="$HOME/dev/hand_of_god/functions"

	[ -d "$dir" ] || {
		printf "The functions/ directory not found: %s\n" "$dir"
		return 1
	}

	for file in "$dir"/*.sh; do
		[ -e "$file" ] || continue
		source "$file"
	done
}

refresh () {
	_refresh
	printf "Functions refreshed\n"
}

# INIT

typeset -g -A ADV_PREFIX
typeset -g -A ADV_WIDTH
typeset -g -A ADV_NAME_REQUIRED

ADV_PREFIX[$CURRENT_PROJECT]="ex"
ADV_WIDTH[$CURRENT_PROJECT]=1
ADV_NAME_REQUIRED[$CURRENT_PROJECT]=1

ADV_PREFIX[$WORK_DIR_PATH/uni_cpp]="task"
ADV_WIDTH[$WORK_DIR_PATH/uni_cpp]=1

ADV_PREFIX[$WORK_DIR_PATH/piscine]="ex"
ADV_WIDTH[$WORK_DIR_PATH/piscine]=2

compdef _pr_completion pr

# pyfiglet -f small "Praise the Emperor!" | center_text
# center_text << "EOF"
# ;+xxxxxxxxxxxxxxxXXXXXXXXXXXXXXXX$$$$+                      :$&&&&&&&&&&&&&&&$$$$$$$$$$$XXXXXXXXXXX;
#  +&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&X.                         .&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&x  
#  .xxxxx+++;;;::::::::;;++xXX$&&&$:    ;&;&&&x.     :x&&&&;     +&&&&&&&&&&&$Xxx+;;::........ ..    
#    .xX$$&&&&&&&&&&&&&&$XxxX$$&&&.   ;$$+:+x+&&x  ;$&&x&++$&+   :&&&&$XxxX$&&&&&&&&&&&&&&&&&&$:     
#      ;&&&&&&&$x;...:+$&&&&&&&&&&.    ..    ;&&&.+X&&;     :    ;&&&$+$&&&&&&$x;:.:+X$&&&&&$:       
#            .:;X&&&&&&&&&$X;+&&&&$:     .:x&X:X.XX:+.X&&&x;:::+&&&&&&&&$;:+X$&&&&&&&&$x;:           
#          +&&&&&&&&&$+;:;X&&&X$&&&&&&&&&&&&&&&:+&&+:&&&&&&&&&&&&&&&&Xx&&&&&$x;.;+$&&&&&X.           
#            ;&&&+.  :X&&&&&;+&&&X&&&&&&&&&$X&x;&&&&:X&X+&$&&&&&&&&$&&&x:x&&&&&&&$+. .:.             
#                .;&&&&&&X.:&&&$+&&+X&$$&;;&&$;$&&&&& &&x.:&$+&&:&&&:$&&&X. x&&&&&&&+                
#                 +&&&&; ;&&&&;x&&X+&&:&Xx&&&+X&&&&&&$.&&X.xX;&&&;&&&+:$&&&$; .+$X:                  
#                   :. :$&&&X.x&&$:X&$ ::$&&x+&&&&&&&&X;&&&  .X&&x+&&&X +&&&&&+                      
#                      :$&&:.X&&& +&$.     .:&&&&&&&&&&;.      +$$:x&&&X  $&x                        
#                           +xX$. ;         x&&&&&&&&&&X           .;+++:                            
#                                          xX;x&&&&&&&+xx                                            
#                                         x&$:Xx&&&&X&X;&x                                           
#                                     +XX$&&.x+$X&$X$$&+.$&&$&;                                      
#                                     .;+&&&x.x&x&&X$...x&X&;+.                                      
#                                      ;&:+X    &&&;    :$X.$:                                       
#                                     .$x        +:        +XX:                                      
#EOF

_refresh

if [ "$PWD" = "$HOME" ]; then
    cd "$CURRENT_PROJECT"
fi