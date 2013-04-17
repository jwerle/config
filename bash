if ! test -d ~/repos; 
  then
  echo "Making repos directory in " $(cd ~ && pwd)
  mkdir ~/repos
fi

if ! test -d ~/repos/config;
  then
  cd ~/repos && git clone git@github.com:jwerle/config.git
fi

if test -d ~/repos/config;
  then
  echo "Updating config repo"
  sleep .003
  cd ~/repos/config && git pull origin master 2> /dev/null && cd
  if ! test -f ~/.bashrc; then ln -s ~/repos/config/bash ~/.bashrc; fi;
fi;
# Don't put duplicate lines in the history
export HISTCONTROL=ignoreboth:erasedups

# Set history length
HISTFILESIZE=1000000000
HISTSIZE=1000000

# Append to the history file, don't overwrite it
shopt -s histappend
# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize
# Autocorrect typos in path names when using `cd`
shopt -s cdspell
# Save all lines of a multiple-line command in the same history entry (allows easy re-editing of multi-line commands)
shopt -s cmdhist
# Do not autocomplete when accidentally pressing Tab on an empty line. (It takes forever and yields "Display all 15 gazillion possibilites?")
shopt -s no_empty_cmd_completion

# Do not overwrite files when redirecting using ">". Note that you can still override this with ">|"
set -o noclobber

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
  shopt -s "$option" 2> /dev/null
done

# Locale
export LC_ALL=en_US.UTF-8
export LANG="en_US"


# Prepend $PATH without duplicates
function _prepend_path() {
  if ! $( echo "$PATH" | tr ":" "\n" | grep -qx "$1" ) ; then
    PATH="$1:$PATH"
  fi
}

# Extend $PATH
[ -d /usr/local/bin ] && _prepend_path "/usr/local/bin"
[ -d /usr/local/share/python ] && _prepend_path "/usr/local/share/python"
[ -d /usr/local/share/npm/bin ] && _prepend_path "/usr/local/share/npm/bin"
command -v brew >/dev/null 2>&1 && _prepend_path "$(brew --prefix coreutils)/libexec/gnubin"
[ -d ~/dotfiles/bin ] && _prepend_path "$HOME/dotfiles/bin"
[ -d ~/bin ] && _prepend_path "$HOME/bin"
export PATH

# Colors
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
MAGENTA="$(tput setaf 5)"
CYAN="$(tput setaf 6)"
WHITE="$(tput setaf 7)"
GRAY="$(tput setaf 8)"
BOLD="$(tput bold)"
UNDERLINE="$(tput sgr 0 1)"
INVERT="$(tput sgr 1 0)"
NOCOLOR="$(tput sgr0)"

# Load prompt and aliases
for file in ~/dotfiles/includes/bash_{prompt,aliases,functions,git}.bash; do
  [ -r "$file" ] && source "$file"
done
unset file

# If possible, add tab completion for many commands
[ -f /etc/bash_completion ] && source /etc/bash_completion

# Bash completion (installed via Homebrew; source after `brew` is added to PATH)
command -v brew >/dev/null 2>&1 && [ -r "$(brew --prefix)/etc/bash_completion" ] && source "$(brew --prefix)/etc/bash_completion"

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
function _ssh_reload_autocomplete() {
  [ -e "~/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh
}
_ssh_reload_autocomplete

# Nano is default editor
export EDITOR='nano'

# Tell ls to be colourful
export CLICOLOR=1

# Tell grep to highlight matches
export GREP_OPTIONS='--color=auto'

# Make less the default pager, and specify some useful defaults.
less_options=(
  # If the entire text fits on one screen, just show it and quit. (Be more
  # like "cat" and less like "more".)
  --quit-if-one-screen

  # Do not clear the screen first.
  --no-init

  # Like "smartcase" in Vim: ignore case unless the search pattern is mixed.
  --ignore-case

  # Do not automatically wrap long lines.
  --chop-long-lines

  # Allow ANSI colour escapes, but no other escapes.
  --RAW-CONTROL-CHARS

  # Do not ring the bell when trying to scroll past the end of the buffer.
  --quiet

  # Do not complain when we are on a dumb terminal.
  --dumb
);
export LESS="${less_options[*]}"
unset less_options
export PAGER='less'

# Load extra (private) settings
[ -f ~/.bashlocal ] && source ~/.bashlocal
# Useful variables
OS=$(uname)
DIRCOLORS=$(which dircolors)

# Add OSX specific directories to PATH
if [ $OS == "Darwin" ]; then
  export PATH="/usr/local/bin:$PATH"
  export PATH="/usr/local/sbin:$PATH"
fi

# on Arch ack needs vendor_perl added to path
export PATH=$PATH:/usr/bin/vendor_perl

# export JAVA_HOME on FreeBSD when Java installed
if [ $OS == "FreeBSD" ]; then
  [ -d /usr/local/diablo-jdk1.6.0 ] && JAVA_HOME=/usr/local/diablo-jdk1.6.0
fi

# Add the current folder and Drobox/bin to PATH
export PATH=$PATH:$HOME/Dropbox/bin
export PATH=$PATH:.

# Add Vim as the default editor
export EDITOR=subl
export CVSEDITOR=subl
export SVN_EDITOR=subl

# Regular Colors
txtrst='\e[0m'          # Text Reset
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

PS1="\n${Yellow}[${txtrst} \h-${Green}\u${txtrst} \w\$(__git_ps1) ${Yellow}]${txtrst}\n $ "

# Enable use of git in the shell environment/prompt
. $HOME/.dotfiles/git-completion.bash
GIT_PS1_SHOWDIRTYSTATE=true

# Exec dircolors for gnome-terminal solarized
if [ ! -z $DIRCOLORS ]; then
  eval $(dircolors $HOME/.dotfiles/gnome-term-dircolors)
fi

# Aliases to make the CLI a little easier to handle
alias cs="clear"
alias cdcs="cd ~ && clear"
alias cscd="cd ~ && clear"
alias grep="grep --color=auto"
alias df="df -h"
alias du="du -shc"
alias top="htop"
alias apt="sudo apt-get"
alias pac="sudo pacman"
alias pak="sudo packer"
alias dot_clean="find /home -name '._*' -exec rm {} \;"

if [ $OS == "Darwin" -o $OS == "FreeBSD" ]; then
  alias ls="ls -hG"
  alias ll="ls -hlG"
  alias la="ls -hlaG"
else
  alias ls="ls -h --color=always"
  alias ll="ls -hl --color=always"
  alias la="ls -hla --color=always"
fi

# Aliases for git
alias gstat="git status"
alias gdiff="git diff"
alias ghist="git log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short"

# This adds color to man pages
export PAGER="most"

# Load rbenv
[[ -d $HOME/.rbenv ]] && source $HOME/.rbenvrc

# Load phpenv
[[ -d $HOME/.phpenv ]] && source $HOME/.phpenvrc

# Enable tab completion with sudo
complete -cf sudo

# Easier navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias -- -="cd -"  # The alias is `-`, not `--`

# Shortcuts
alias dr="cd ~/Dropbox"
alias pj="cd ~/Dropbox/Projects"
alias pjr="cd ~/Dropbox/Projects/_Repos"
alias pjf="cd ~/Dropbox/Projects/_Forks"
alias pjm="cd ~/Dropbox/Projects/!"
alias o="open"
alias oo="open ."
alias e="subl"
alias gh="github"
alias +x="chmod +x"
alias x+="chmod +x"
alias g="ack -ri"

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then  # GNU `ls`
  colorflag="--color"
else  # OS X `ls`
  colorflag="-G"
fi

# Always use color output for `ls`
alias ls="command ls ${colorflag}"
export LS_COLORS="no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:"

# Enable aliases to be sudo’ed
alias sudo="sudo "

# Avoid stupidity
alias rm="rm -i"

# Gzip-enabled `curl`
#alias gurl="curl --compressed"


# Update dotfiles
alias dotfiles="pushd "$HOME/dotfiles" > /dev/null 2>&1; git pull && ./sync.py && . "$HOME/.bashrc"; popd > /dev/null 2>&1; nyan"

# Clean up LaunchServices to remove duplicates in the “Open With” menu
#alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"

# Trim new lines and copy to clipboard
alias c="tr -d '\n' | pbcopy"

# Recursively delete `.DS_Store` files
#alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Empty the Trash on all mounted volumes and the main HDD
# Also, clear Apple’s System Logs to improve shell startup speed
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"

# Show/hide hidden files in Finder
alias show="defaults write com.apple.Finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.Finder AppleShowAllFiles -bool false && killall Finder"

# URL-encode strings
#alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'

# Ring the terminal bell, and put a badge on Terminal.app’s Dock icon (useful when executing time-consuming commands)
alias badge="tput bel"

# HTTP requests by @janmoesen
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
  alias "$method"="lwp-request -m '$method'"
done

# Convert line endings to UNIX
alias dos2unix="perl -pi -e 's/\r\n?/\n/g'"

# Password generator
password() { openssl rand -base64 ${1:-8}; }

# Show $PATH in a readable way
alias path='echo -e ${PATH//:/\\n}'

# Say what’s in the clipboard
alias sayit="pbpaste | say"

# NPM
alias npm-patch='npm version patch -m "%s"'
alias npm-release='npm version minor -m "%s"'

# Grunt
alias gw="grunt watch --debug"
alias gs="grunt connect watch --debug"
gi() { grunt-init $@; }

# Magic Project Opener
function proj { cd "$("$HOME/dotfiles/bin/opener.py" "$HOME/Dropbox/Projects" $1 -w project $2)"; }
function repo { cd "$("$HOME/dotfiles/bin/opener.py" "$HOME/Dropbox/Projects" $1 -w repo $2)"; }
function wptheme { cd "$("$HOME/dotfiles/bin/opener.py" "$HOME/Dropbox/Projects" $1 -w wptheme $2)"; }

# Color conversion
alias hex2hsl="color.js $1 $2"
alias hex2rgb="color.js --rgb $1 $2"

# Dotfiles help
alias dot-bash="killall Marked; open -a marked --args $HOME/dotfiles/docs/Bash.md"
alias dot-git="killall Marked; open -a marked --args $HOME/dotfiles/docs/Git.md"
alias dot-hub="killall Marked; find /usr/local/Cellar/hub/ -name README.md -exec open -a marked --args {} \;"
#alias dot-extras="killall Marked; find /usr/local/Cellar/git-extras/ -name README.md -exec open -a marked --args {} \;"
alias dot-extras="open https://github.com/visionmedia/git-extras/blob/master/Readme.md#readme"
# Print cyan underlined header 
function header() {
  echo -e "$UNDERLINE$CYAN$1$NOCOLOR"
}

# Create a new directory and enter it
function md() {
  mkdir -p "$@" && cd "$@"
}

# Find shorthand
function f() {
  find . -name "$1" 2>/dev/null
}

# Compare original and gzipped file size
function gz() {
  local origsize=$(wc -c < "$1")
  local gzipsize=$(gzip -c "$1" | wc -c)
  local ratio=$(echo "$gzipsize * 100/ $origsize" | bc -l)
  printf "Original: %d bytes\n" "$origsize"
  printf "Gzipped: %d bytes (%2.2f%%)\n" "$gzipsize" "$ratio"
}

# Test if HTTP compression (RFC 2616 + SDCH) is enabled for a given URL.
# Send a fake UA string for sites that sniff it instead of using the Accept-Encoding header. (Looking at you, ajax.googleapis.com!)
function httpcompression() {
  encoding="$(curl -LIs -H 'User-Agent: Mozilla/5 Gecko' -H 'Accept-Encoding: gzip,deflate,compress,sdch' "$1" | grep '^Content-Encoding:')" && echo "$1 is encoded using ${encoding#* }" || echo "$1 is not using any encoding"
}

# Show HTTP headers for given URL
# Usage: headers <URL>
# https://github.com/rtomayko/dotfiles/blob/rtomayko/bin/headers
function headers() {
  curl -sv -H "User-Agent: Mozilla/5 Gecko" "$@" 2>&1 >/dev/null |
    grep -v "^\*" |
    grep -v "^}" |
    cut -c3-
}

# Escape UTF-8 characters into their 3-byte format
function escape() {
  printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u)
  echo
}

# Get a character’s Unicode code point: £ → \x00A3
function codepoint() {
  perl -e "use utf8; print sprintf('\x%04X', ord(\"$@\"))"
  echo
}

# Remove screenshots from desktop
function cleandesktop() {
  header "Cleaning desktop..."
  for file in ~/Desktop/Screen\ Shot*.png; do
    unlink "$file"
  done
  echo
}

# Extract archives of various types
function extract() {
  if [ -f $1 ] ; then
    local dir_name=${1%.*}  # Filename without extension
    case $1 in
      *.tar.bz2)  tar xjf           $1 ;;
      *.tar.gz)   tar xzf           $1 ;;
      *.tar.xz)   tar Jxvf          $1 ;;
      *.tar)      tar xf            $1 ;;
      *.tbz2)     tar xjf           $1 ;;
      *.tgz)      tar xzf           $1 ;;
      *.bz2)      bunzip2           $1 ;;
      *.rar)      unrar x           $1 $2 ;;
      *.gz)       gunzip            $1 ;;
      *.zip)      unzip -d$dir_name $1 ;;
      *.Z)        uncompress        $1 ;;
      *)          echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Print nyan cat
# https://github.com/steckel/Git-Nyan-Graph/blob/master/nyan.sh
# If you want big animated version: `telnet miku.acm.uiuc.edu`
function nyan() {
  local delay=.05
  echo -en $RED'-_-_-_-_-_-_-_'
  sleep $delay
  echo -e $NOCOLOR$BOLD',------,'$NOCOLOR
  sleep $delay
  echo -en $YELLOW'_-_-_-_-_-_-_-'
  sleep $delay
  echo -e $NOCOLOR$BOLD'|   /\_/\\'$NOCOLOR
  sleep $delay
  echo -en $GREEN'-_-_-_-_-_-_-'
  sleep $delay
  echo -e $NOCOLOR$BOLD'~|__( ^ .^)'$NOCOLOR
  sleep $delay
  echo -en $CYAN'-_-_-_-_-_-_-'
  sleep $delay
  echo -e $NOCOLOR$BOLD'""  ""'$NOCOLOR
  sleep $delay
}

# Copy public SSH key to clipboard. Generate it if necessary
ssh-key() {
  file="$HOME/.ssh/id_rsa.pub"
  if [ ! -f "$file" ]; then
    ssh-keygen -t rsa
  fi
  
  cat "$file" | c
  echo "Your public key copied to clipboard."
}

# Create an SSH key and uploads it to the given host
# Based on https://gist.github.com/1761938
ssh-add-host() {
  username=$1
  hostname=$2
  identifier=$3

  if [[ "$identifier" == "" ]] || [[ "$username" == "" ]] || [[ "$hostname" == "" ]]; then
    echo "Usage: ssh-add-host <username> <hostname> <identifier>"
  else
    header "Generating key..."
    if [ ! -f "$HOME/.ssh/$identifier.id_rsa" ]; then
      ssh-keygen -f ~/.ssh/$identifier.id_rsa -C "$USER $(date +'%Y/%m%/%d %H:%M:%S')"
    fi

    if ! grep -Fxiq "host $identifier" "$HOME/.ssh/config"; then
      echo -e "Host $identifier\n\tHostName $hostname\n\tUser $username\n\tIdentityFile ~/.ssh/$identifier.id_rsa" >> ~/.ssh/config
    fi

    header "Uploading key..."
    ssh $identifier 'mkdir -p .ssh && cat >> ~/.ssh/authorized_keys' < ~/.ssh/$identifier.id_rsa.pub

    tput bold; ssh -o PasswordAuthentication=no $identifier true && { tput setaf 2; echo "SSH key added."; } || { tput setaf 1; echo "Failure"; }; tput sgr0

    _ssh_reload_autocomplete
  fi
}


# Backup remote MySQL database to ~/Backups/hostname/dbname_YYYY-MM-DD.sql.gz
# USAGE: mysql-dump <ssh_hostname> <mysql_database> [mysql_username] [mysql_host]
mysql-dump() {
  local ssh_hostname=$1
  local mysql_database=$2
  local mysql_username=$3
  local mysql_host=$4
  local location="$HOME/Backups"
  local suffix=$(date +'%Y-%m-%d')

  if [[ $ssh_hostname == "" ]] || [[ $mysql_database == "" ]]; then
    echo "Usage: mysql-dump <ssh_hostname> <mysql_database> [mysql_username] [mysql_host]"
  else
    header "Backing up $mysql_database@$ssh_hostname..."

    if [[ $mysql_username != "" ]]; then
      mysql_username="-u $mysql_username -p "
    fi

    if [[ $mysql_host != "" ]]; then
      mysql_host=" -h $mysql_host"
    fi

    # Ensure backup directory
    local backup_dir="$location/$ssh_hostname"
      mkdir -p $backup_dir

    # Give the user a warning if the file already exists
    local basename=$mysql_database"_"$suffix
    local local_filepath="$backup_dir/$basename.sql.gz"
    if [ -f "$local_filepath" ]; then
        echo -e $RED"WARNING: Backup file '$local_filepath' already exists.$NOCOLOR\nOwerwrite? (Y/N)"
        read proceed

        if [[ $proceed != "y" ]]; then
          return
        fi
    fi

    ssh -C $ssh_hostname "mysqldump --opt --compress $mysql_username$mysql_database$mysql_host | gzip -c" > "$local_filepath"

    echo
    echo "Done: $local_filepath"
  fi
}

# Save page screenshot to file
# USAGE: rasterize <URL> <filename>
# Based on https://github.com/oxyc/dotfiles/blob/master/.bash/commands
function rasterize() {
  local url="$1"
  local filename="$2"
  if [[ $url == "" ]] || [[ $filename == "" ]]; then
    echo "Usage: rasterize <URL> <filename>"
  else
    header "Rasterizing $url..."

    [[ $url != http* ]] && url="http://$url"
    [[ $filename != *png ]] && filename="$filename.png"
    phantomjs <(echo "
      var page = new WebPage();
      page.viewportSize = { width: 1280 };
      page.open('$url', function (status) {
        if (status !== 'success') {
          console.log('Unable to load the address.');
          phantom.exit();
        }
        else {
          window.setTimeout(function() {
            page.render('$filename');
            phantom.exit();
          }, 1000);
        }
      });
    ")

    echo "Screenshot saved to: $filename"
  fi
}

# Add note to Notes.app (OS X 10.8)
# Usage: note "foo" or echo "foo" | note
function note() {
  local text
  if [ -t 0 ]; then  # Argument
    text="$1"
  else  # Pipe
    text=$(cat)
  fi
  body=$(echo "$text" | sed -E 's|$|<br>|g')
  osascript >/dev/null <<EOF
tell application "Notes"
  tell account "iCloud"
    tell folder "Notes"
      make new note with properties {name:"$text", body:"$body"}
    end tell
  end tell
end tell
EOF
}

# Start an HTTP server from a directory, optionally specifying the port (default: 8000)
# Usage: server [port]
function server() {
  local port="${1:-8000}"
  open "http://localhost:${port}/"
  # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
  # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
  python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"
}

function sayit() {
  pbpaste | say
}

# Add special aliases that will copy result to clipboard (escape → escape+)
for cmd in password hex2hsl hex2rgb escape codepoint; do
  eval "function $cmd+() { $cmd \$@ | c; }"
done
# Git related Bash aliases

github_user="sapegin"
bitbucket_user="sapegin"


# `cd` to repo root
alias git-root='git rev-parse 2>/dev/null && cd "./$(git rev-parse --show-cdup)"'
alias gr="git-root"

# Deploy using Fabric
alias pff="push && fab"

# Setup syncronization of current Git repo with GitHub repo of the same name
# USAGE: git-github [repo]
function git-github() {
  local repo=${1-`basename "$(pwd)"`}
  git remote add origin "git@github.com:$github_user/$repo.git"
  git push -u origin master
}

# Setup syncronization of current Git repo with Bitbucket repo of the same name
# USAGE: git-bitbucket [repo]
function git-bitbucket() {
  local repo=${1-`basename "$(pwd)"`}
  git remote add origin "git@bitbucket.org:$bitbucket_user/$repo.git"
  git push -u origin master
}

# Add remote upstream
# USAGE: git-fork <original-author>
function git-fork() {
  local user=$1
  if [[ "$user" == "" ]]; then
    echo "Usage: git-fork <original-author>"
  else
    local repo=`basename "$(pwd)"`
    git remote add upstream "git@github.com:$user/$repo.git"
  fi
}

# Sync branch with upstream
# USAGE: git-upstream [branch]
function git-upstream() {
  local branch=${1-master}
  git fetch upstream
  git checkout $branch
  git rebase upstream/$branch
}

# Add all staged files to previous commit
function git-append() {
  git log -n 1 --pretty=tformat:%s%n%n%b | git commit -F - --amend
}

# List of files with unresolved conflicts
function git-conflicts() {
  git ls-files -u | awk '{print $4}' | sort -u
}
#
# Clean and minimalistic Bash prompt
# Author: Artem Sapegin, sapegin.me
# 
# Inspired by: https://github.com/sindresorhus/pure & https://github.com/dreadatour/dotfiles/blob/master/.bash_profile
#
# Notes:
# - $local_username - username you don’t want to see in the prompt - can be defined in ~/.bashlocal : `local_username="admin"`
# - Colors ($RED, $GREEN) - defined in ../tilde/bash_profile.bash
#


# User color
case $(id -u) in
  0) user_color="$RED" ;;  # root
  *) user_color="$GREEN" ;;
esac

# Symbols
prompt_symbol="❯"
prompt_clean_symbol="☀ "
prompt_dirty_symbol="☂ "

function prompt_command() {
  # Local or SSH session?
  local remote=
  [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] && remote=1

  # Git branch name and work tree status (only when we are inside Git working tree)
  local git_prompt=
  if [[ "true" = "$(git rev-parse --is-inside-work-tree 2>/dev/null)" ]]; then
    # Branch name
    local branch="$(git symbolic-ref HEAD 2>/dev/null)"
    branch="${branch##refs/heads/}"

    # Working tree status (red when dirty)
    local dirty=
    # Modified files
    git diff --no-ext-diff --quiet --exit-code --ignore-submodules 2>/dev/null || dirty=1
    # Untracked files
    [ -z "$dirty" ] && test -n "$(git status --porcelain)" && dirty=1

    # Format Git info
    if [ -n "$dirty" ]; then
      git_prompt=" $RED$prompt_dirty_symbol$branch$NOCOLOR"
    else
      git_prompt=" $GREEN$prompt_clean_symbol$branch$NOCOLOR"
    fi
  fi

  # Only show username if not default
  local user_prompt=
  [ "$USER" != "$local_username" ] && user_prompt="$user_color$USER$NOCOLOR"

  # Show hostname inside SSH session
  local host_prompt=
  [ -n "$remote" ] && host_prompt="@$YELLOW$HOSTNAME$NOCOLOR"

  # Show delimiter if user or host visible
  local login_delimiter=
  [ -n "$user_prompt" ] || [ -n "$host_prompt" ] && login_delimiter=":"

  # Format prompt
  first_line="$user_prompt$host_prompt$login_delimiter$WHITE\w$NOCOLOR$git_prompt"
  # Text (commands) inside \[...\] does not impact line length calculation which fixes stange bug when looking through the history
  # $? is a status of last command, should be processed every time prompt prints
  second_line="\`if [ \$? = 0 ]; then echo \[\$CYAN\]; else echo \[\$RED\]; fi\`\$prompt_symbol\[\$NOCOLOR\] "
  PS1="\n$first_line\n$second_line"

  # Multiline command
  PS2="\[$CYAN\]$prompt_symbol\[$NOCOLOR\] "

  # Terminal title
  local title="$(basename $PWD)"
  [ -n "$remote" ] && title="$title \xE2\x80\x94 $HOSTNAME"
  echo -ne "\033]0;$title"; echo -ne "\007"
}

# Show awesome prompt only if Git is istalled
command -v git >/dev/null 2>&1 && PROMPT_COMMAND=prompt_command
complete -o default -o nospace -W "$(/usr/bin/env ruby -ne 'puts $_.split(/[,\s]+/)[1..-1].reject{|host| host.match(/\*|\?/)} if $_.match(/^\s*Host\s+/);' < $HOME/.ssh/config)" scp sftp ssh

function printDelay () {
  local delay=$1
  shift 1
  local word=$@
  for (( i=0; i<${#word}; i++ )); do
    printf "${word:$i:1}"
    sleep $delay
  done
}

[[ -s /Users/jwerle/.nvm/nvm.sh ]] && . /Users/jwerle/.nvm/nvm.sh # This loads NVM


## where the fun begins......
function makeAFunny () {
  # Array with expressions
  expressions=("Ploink Poink" "I Need Oil" "Some Bytes are Missing!" "Poink Poink" "Piiiip Beeeep!!" "Hello" "Whoops! I'm out of memmory!")

  # Seed random generator
  RANDOM=$$$(date +%s)

  # Get random expression...
  selectedexpression=${expressions[$RANDOM % ${#expressions[@]} ]}

  # Write to Shell
  echo $selectedexpression
}

command -v go && go jwerle;

agent=`uname -a`
printDelay ".002" $YELLOW"Getting ready"$NOCOLOR;
printDelay ".0015" $YELLOW" for "$NOCOLOR;
printDelay ".00075" $YELLOW"action"$NOCOLOR;
printDelay ".000325" $YELLOW"..."$NOCOLOR;
printDelay ".0001125" $CYAN" =)"$NOCOLOR;
printDelay ".00005125" $CYAN" GO!"$NOCOLOR;
echo
clear
sleep .05
printf $BOLD$BLUE"Agent: "$NOCOLOR; printf $BLUE"${agent}"$NOCOLOR
echo
printf $BOLD$BLUE"User: "$NOCOLOR; printf $BLUE"${USER}"$NOCOLOR
echo
header
echo $CYAN$USER$NOCOLOR@$BLUE$(uname)$NOCOLOR;
nyan
echo
echo -en $YELLOW$(date "+The date is: %m/%d/%y")$NOCOLOR;
echo
echo -en $CYAN$(date "+The time is: %H:%M:%S")$NOCOLOR
echo

