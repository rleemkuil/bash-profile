# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null;
done;

# Add tab completion for many Bash commands
if which brew > /dev/null && [ -f "$(brew --prefix)/etc/bash_completion" ]; then
	source "$(brew --prefix)/etc/bash_completion";
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

# Add color to terminal
# http://osxdaily.com/2012/02/21/add-color-to-the-terminal-in-mac-os-x/
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# Command Aliases
alias psg="ps aux | grep -v grep | grep -i -e VSZ -e"

# Functions

function extract {
 if [ -z "$1" ]; then
    # display usage if no parameters given
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
 else
    if [ -f $1 ] ; then
        # NAME=${1%.*}
        # mkdir $NAME && cd $NAME
        case $1 in
          *.tar.bz2)   tar xvjf ../$1    ;;
          *.tar.gz)    tar xvzf ../$1    ;;
          *.tar.xz)    tar xvJf ../$1    ;;
          *.lzma)      unlzma ../$1      ;;
          *.bz2)       bunzip2 ../$1     ;;
          *.rar)       unrar x -ad ../$1 ;;
          *.gz)        gunzip ../$1      ;;
          *.tar)       tar xvf ../$1     ;;
          *.tbz2)      tar xvjf ../$1    ;;
          *.tgz)       tar xvzf ../$1    ;;
          *.zip)       unzip ../$1       ;;
          *.Z)         uncompress ../$1  ;;
          *.7z)        7z x ../$1        ;;
          *.xz)        unxz ../$1        ;;
          *.exe)       cabextract ../$1  ;;
          *)           echo "extract: '$1' - unknown archive method" ;;
        esac
    else
        echo "$1 - file does not exist"
    fi
fi
}

# ESX Stuff for my blackbox (VMWare ESX Host)
ESX_USER="root"
ESX_HOST="192.168.100.200"
ESX_MAC="84:2B:2B:99:53:CC"

alias esx-start='wakeonlan $ESX_MAC'
alias esx-stop='esx-cmd "poweroff"'
alias esx-list='esx-cmd "vim-cmd vmsvc/getallvms"'

function esx-cmd {
	if [ -z "$1" ]; then
		echo "Usage: esx-cmd '<cmd>'"
	else
		ssh ${ESX_USER}@${ESX_HOST} $1
	fi
}

function esx-vm-state {
	if [ -z "$1" ]; then
		echo "Usage: esx-vm-config <id>"
	else
		esx-cmd "vim-cmd vmsvc/power.getstate $1" | tail -n 1
	fi
}

function esx-vm-state-all {
	line=0
	for id in $(esx-list | cut -d ' ' -f 1); do
		if (( line == 0)); then
			line=1
		else
			if [[ $(esx-vm-state $id) == *"Powered on"* ]]; then
				echo "VM $id: powered on"
			else
				echo "VM $id: powered off"
			fi
		fi
	done
}

function esx-vm-start {
	if [ -z "$1" ]; then
		echo "Usage: esx-vm-start <id>"
	else
		esx-cmd "vim-cmd vmsvc/power.on $1"
	fi
}

function esx-vm-stop {
	if [ -z "$1" ]; then
		echo "Usage: esx-vm-stop <id>"
	else
		esx-cmd "vim-cmd vmsvc/power.off $1" | tail -n 1
	fi
}

function esx-vm-stop-all {
	line=0
	for id in $(esx-list | cut -d ' ' -f 1); do
		if (( line == 0)); then
			line=1
		else
			if [[ $(esx-vm-state $id) == *"Powered on"* ]]; then
				echo "VM is powered on: $id"
				esx-vm-stop $id
			fi
		fi
	done
	echo "Done."
}
