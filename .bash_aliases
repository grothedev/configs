alias ag='sudo apt-get'
alias agi='ag install'
alias agu='ag update'
alias ll='ls -la'
alias lr='ls -lrt'
#!/bin/bash

alias q='exit 0'
alias d='clear'

alias la='ls -Ah'
alias ll='ls -lAh'
alias l.='ls -ld .*'

alias mkdir='mkdir -pv'
alias grep='grep --color=auto'
alias debug="set -o nounset; set -o xtrace"
alias x='chmod +x'
alias du='du -kh'
alias df='df -kTh'

if hash nvim >/dev/null 2>&1; then
    alias vim='nvim'
    alias v='nvim'
    alias sv='sudo nvim'
else
    alias v='vim'
    alias sv='sudo vim'
fi

alias f='ranger'

alias gp='git pull'
alias gf='git fetch'
alias gc='git clone'
alias gs='git stash'
alias gb='git branch'
alias gm='git merge'
alias gch='git checkout'
alias gcm='git commit -m'
alias glg='git log --stat'
alias gpo='git push origin HEAD'
alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'
alias ghcp='gh copilot'

alias pup='sudo pacman -Syyu' # update
alias pin='sudo pacman -S'    # install
alias pun='sudo pacman -Rs'   # remove
alias pcc='sudo pacman -Scc'  # clear cache
alias pls='pacman -Ql'        # list files
alias prm='sudo pacman -Rnsc' # really remove, configs and all

alias pkg='makepkg --printsrcinfo > .SRCINFO && makepkg -fsrc'
alias spkg='pkg --sign'

alias mk='make && make clean'
alias smk='sudo make clean install && make clean'
alias ssmk='sudo make clean install && make clean && rm -iv config.h'

# aliases inside tmux session
if [[ $TERM == *tmux* ]]; then
    alias :sp='tmux split-window'
    alias :vs='tmux split-window -h'
fi

alias rcp='rsync -v --progress'
alias rmv='rcp --remove-source-files'

alias calc='python -qi -c "from math import *"'
alias brok='sudo find . -type l -! -exec test -e {} \; -print'
alias timer='time read -p "Press enter to stop"'

# shellcheck disable=2142
alias xp='xprop | awk -F\"'" '/CLASS/ {printf \"NAME = %s\nCLASS = %s\n\", \$2, \$4}'"
alias get='curl --continue-at - --location --progress-bar --remote-name --remote-time'
#!/bin/bash

# shell helper functions
# mostly written by Nathaniel Maia, some pilfered from around the web

# better ls and cd
unalias ls >/dev/null 2>&1
ls()
{
    command ls --color=auto -F "$@"
}

#unalias cd >/dev/null 2>&1
#cd()
#{
#    builtin cd "$@" && command ls -lrt --color=auto -F
#}

src()
{
    . ~/.mkshrc 2>/dev/null
}

por()
{
    local orphans
    orphans="$(pacman -Qtdq 2>/dev/null)"
    [[ -z $orphans ]] && printf "System has no orphaned packages\n" || sudo pacman -Rns $orphans
}

pss()
{
    PS3=$'\n'"Enter a package number to install, Ctrl-C to exit"$'\n\n'">> "
    select pkg in $(pacman -Ssq "$1"); do sudo pacman -S $pkg; break; done
}

pacsearch()
{
    echo -e "$(pacman -Ss "$@" | sed \
        -e 's#core/.*#\\033[1;31m&\\033[0;37m#g' \
        -e 's#extra/.*#\\033[0;32m&\\033[0;37m#g' \
        -e 's#community/.*#\\033[1;35m&\\033[0;37m#g' \
        -e 's#^.*/.* [0-9].*#\\033[0;36m&\\033[0;37m#g')"
}

mir()
{
    if hash reflector >/dev/null 2>&1; then
        su -c 'reflector --score 100 -l 50 -f 10 --sort rate --save /etc/pacman.d/mirrorlist --verbose'
    else
        local pg="https://www.archlinux.org/mirrorlist/?country=US&country=CA&use_mirror_status=on"
        su -c "printf 'ranking the mirror list...\n'; curl -s '$pg' |
            sed -e 's/^#Server/Server/' -e '/^#/d' |
            rankmirrors -v -t -n 10 - > /etc/pacman.d/mirrorlist"
    fi
}

tmuxx()
{
    session="${1:-main}"
    if ! grep -q "$session" <<< "$(tmux ls 2>/dev/null | awk -F':' '{print $1}')"; then
        tmux new -d -s "$session"
        tmux neww
        tmux neww
        tmux splitw -h
        tmux selectw -t 1
        tmux -2 attach -d
    elif [[ -z $TMUX ]]; then
        session_id="$(date +%Y%m%d%H%M%S)"
        tmux new-session -d -t "$session" -s "$session_id"
        tmux attach-session -t "$session_id" \; set-option destroy-unattached
    fi
}

surfs()
{
    if ! hash surf-open tabbed surf >/dev/null 2>&1; then
        local reqs="tabbed, surf, surf-open (shell script provided with surf)"
        printf "error: this requires the following installed\n\n\t%s\n" "$reqs"
        return 1
    fi

    declare -a urls
    if (( $# == 0 )); then
        local main="https://www.google.com"
        urls=("https://www.youtube.com"
        "https://forum.archlabslinux.com"
        "https://bitbucket.org"
        "https://suckless.org"
        )
    else
        local main="$1"
        shift
        for arg in "$@"; do
            urls+=("$arg")
        done
    fi

    (
        surf-open "$main" &
        sleep 0.1
        for url in "${urls[@]}"; do
            surf-open "$url" &
        done
    ) & disown
}

flac_to_mp3()
{
    for i in "${1:-.}"/*.flac; do
        [[ -e "${1:-.}/$(basename "$i" | sed 's/.flac/.mp3/g')" ]] || ffmpeg -i "$i" -qscale:a 0 "${i/%flac/mp3}"
    done
}

deadsym()
{
    for i in **/*; do [[ -h $i && ! -e $(readlink -fn "$i") ]] && rm -rfv "$i"; done
}

gitpr()
{
    github="pull/$1/head:$2"
    _fetchpr $github $2 $3
}

bitpr()
{
    bitbucket="refs/pull-requests/$1/from:$2"
    _fetchpr $bitbucket $2 $3
}

_fetchpr()
{
    # shellcheck disable=2154
    [[ $ZSH_VERSION ]] && program=${funcstack#_fetchpr} || program='_fetchpr'

    if (( $# != 2 && $# != 3 )); then
        printf "usage: %s <id> <branch> [remote]" "$program"
        return 1
    else
        ref=$1
        branch=$2
        origin=${3:-origin}
        if git rev-parse --git-dir >/dev/null 2>&1; then
            git fetch $origin $ref && git checkout $branch
        else
            echo 'error: not in git repo'
        fi
    fi
}

sloc()
{
    [[ $# -eq 1 && -r $1 ]] || { printf "Usage: sloc <file>"; return 1; }
    if [[ $1 == *.vim ]]; then
        awk '!/^[[:blank:]]*("|^$)/' "$1" | wc -l
    elif [[ $1 == *.c || $1 == *.h || $1 == *.j ]]; then
        awk '!/^[[:blank:]]*(\/\/|\*|\/\*|^$)/' "$1" | wc -l
    else
        awk '!/^[[:blank:]]*(\/\/|#|\*|\/\*|^$)/' "$1" | wc -l
    fi
}

nh()
{
    nohup "$@" >/dev/null 2>&1 &
}

hex2dec()
{
    awk 'BEGIN { printf "%d\n",0x$1}'
}

dec2hex()
{
    awk 'BEGIN { printf "%x\n",$1}'
}

ga()
{
    git add "${1:-.}"
}

gr()
{
    git rebase -i HEAD~${1:-10}
}

mktar()
{
    tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"
}

mkzip()
{
    zip -r "${1%%/}.zip" "$1"
}

sanitize()
{
    chmod -R u=rwX,g=rX,o= "$@"
}

mp()
{
    ps "$@" -u $USER -o pid,%cpu,%mem,bsdtime,command
}

pp()
{
    mp f | awk '!/awk/ && $0~var' var=${1:-".*"}
}

ff()
{
    find . -type f -iname '*'"$*"'*' -ls
}

fe()
{
    find . -type f -iname '*'"${1:-}"'*' -exec ${2:-file} {} \;
}

ranger()
{
    local dir tmpf
    [[ $RANGER_LEVEL && $RANGER_LEVEL -gt 2 ]] && exit 0
    local rcmd="command ranger"
    [[ $TERM == 'linux' ]] && rcmd="command ranger --cmd='set colorscheme default'"
    tmpf="$(mktemp -t tmp.XXXXXX)"
    eval "$rcmd --choosedir='$tmpf' '${*:-$(pwd)}'"
    [[ -f $tmpf ]] && dir="$(cat "$tmpf")"
    [[ -e $tmpf ]] && rm -f "$tmpf"
    [[ -z $dir || $dir == "$PWD" ]] || builtin cd "${dir}" || return 0
}

fstr()
{
    OPTIND=1
    local case=""
    local usage='Usage: fstr [-i] "pattern" ["filename pattern"]'
    while getopts :it opt; do case "$opt" in
        i) case="-i " ;;
        *) printf "%s" "$usage"; return ;;
    esac done
    shift $((OPTIND - 1))
    [[ $# -lt 1 ]] && printf "fstr: find string in files.\n%s" "$usage"
    find . -type f -name "${2:-*}" -print 0 | xargs -0 egrep --color=always -sn ${case} "$1" 2>&- | more
}

swap()
{ # Swap 2 filenames around, if they exist
    local tmpf=tmp.$$
    [[ $# -ne 2 ]] && printf "swap: takes 2 arguments\n" && return 1
    [[ ! -e $1 ]] && printf "swap: %s does not exist\n" "$1" && return 1
    [[ ! -e $2 ]] && printf "swap: %s does not exist\n" "$2" && return 1
    mv "$1" $tmpf && mv "$2" "$1" && mv $tmpf "$2"
}

take()
{
    mkdir -p "$1"
    cd "$1" || return
}

csrc()
{
    [[ $1 ]] || { printf "Missing operand" >&2; return 1; }
    [[ -r $1 ]] || { printf "File %s does not exist or is not readable\n" "$1" >&2; return 1; }
    local out=${TMPDIR:-/tmp}/${1##*/}
    gcc "$1" -o "$out" && "$out"
    rm "$out"
    return 0
}

hr()
{
  local start=$'\e(0' end=$'\e(B' line='qqqqqqqqqqqqqqqq'
  local cols=${COLUMNS:-$(tput cols)}
  while ((${#line} < cols)); do line+="$line"; done
  printf '%s%s%s\n' "$start" "${line:0:cols}" "$end"
}

arc()
{
    arg="$1"; shift
    case $arg in
        -e|--extract)
            if [[ $1 && -e $1 ]]; then
                case $1 in
                    *.tbz2|*.tar.bz2) tar xvjf "$1" ;;
                    *.tgz|*.tar.gz) tar xvzf "$1" ;;
                    *.tar.xz) tar xpvf "$1" ;;
                    *.tar) tar xvf "$1" ;;
                    *.gz) gunzip "$1" ;;
                    *.zip) unzip "$1" ;;
                    *.bz2) bunzip2 "$1" ;;
                    *.7zip) 7za e "$1" ;;
                    *.rar) unrar x "$1" ;;
                    *) printf "'%s' cannot be extracted" "$1"
                esac
            else
                printf "'%s' is not a valid file" "$1"
            fi ;;
        -n|--new)
            case $1 in
                *.tar.*)
                    name="${1%.*}"
                    ext="${1#*.tar}"; shift
                    tar cvf "$name" "$@"
                    case $ext in
                        .gz) gzip -9r "$name" ;;
                        .bz2) bzip2 -9zv "$name"
                    esac ;;
                *.gz) shift; gzip -9rk "$@" ;;
                *.zip) zip -9r "$@" ;;
                *.7z) 7z a -mx9 "$@" ;;
                *) printf "bad/unsupported extension"
            esac ;;
        *) printf "invalid argument '%s'" "$arg"
    esac
}

killp()
{
    local pid name sig="-TERM"   # default signal
    [[ $# -lt 1 || $# -gt 2 ]] && printf "Usage: killp [-SIGNAL] pattern" && return 1
    [[ $# -eq 2 ]] && sig=$1
    for pid in $(mp | awk '!/awk/ && $0~pat { print $1 }' pat=${!#}); do
        name=$(mp | awk '$1~var { print $5 }' var=$pid)
        ask "Kill process $pid <$name> with signal $sig?" && kill $sig $pid
    done
}

mdf()
{
    local cols
    cols=$(( ${COLUMNS:-$(tput cols)} / 3 ))
    for fs in "$@"; do
        [[ ! -d $fs ]] && printf "%s :No such file or directory" "$fs" && continue
        local info=($(command df -P $fs | awk 'END{ print $2,$3,$5 }'))
        local free=($(command df -Pkh $fs | awk 'END{ print $4 }'))
        local nbstars=$((cols * info[1] / info[0]))
        local out="["
        for ((i=0; i<cols; i++)); do
            [[ $i -lt $nbstars ]] && out=$out"*" || out=$out"-"
        done
        out="${info[2]} $out] (${free[*]} free on $fs)"
        printf "%s" "$out"
    done
}

mip()
{
    local ip
    ip=$(/usr/bin/ifconfig "$(ifconfig | awk -F: '/RUNNING/ && !/LOOP/ {print $1}')" |
        awk '/inet/ { print $2 } ' | sed -e s/addr://)
    printf "%s" "${ip:-Not connected}"
}

ii()
{
    echo -e "\nYou are logged on \e[1;31m$HOSTNAME"
    echo -e "\n\e[1;31mAdditionnal information:\e[m " ; uname -a
    echo -e "\n\e[1;31mUsers logged on:\e[m "         ; w -hs | awk '{print $1}' | sort | uniq
    echo -e "\n\e[1;31mCurrent date:\e[m "            ; date
    echo -e "\n\e[1;31mMachine stats:\e[m "           ; uptime
    echo -e "\n\e[1;31mMemory stats:\e[m "            ; free
    echo -e "\n\e[1;31mDiskspace:\e[m "               ; mdf / $HOME
    echo -e "\n\e[1;31mLocal IP Address:\e[m"         ; mip
    echo -e "\n\e[1;31mOpen connections:\e[m "        ; netstat -pan --inet;
    echo
}

rep()
{
    local max=$1
    shift
    for (( i=0; i<max; i++ )); do
        eval "$@"
    done
}

ask()
{
    printf "$@" '[y/N] '; read -r ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1
    esac
}

args()
{
    # Bash or ksh93 debugging function for colored display of argv.
    # Optionally set OFD to the desired output file descriptor.
    { BASH_XTRACEFD=3 command eval ${BASH_VERSION+"$(</dev/fd/0)"}; } <<-'EOF' 3>/dev/null
                case $- in *x*)
                        set +x
                        trap 'trap RETURN; set -x' RETURN
                esac
EOF

    [[ ${OFD-1} == +([0-9]) ]] || return

    if [[ -t ${OFD:-2} ]]; then
        typeset -A clr=([green]=$(tput setaf 2) [sgr0]=$(tput sgr0))
    else
        typeset clr
    fi

    if ! ${1+false}; then
        printf -- "${clr[green]}<${clr[sgr0]}%s${clr[green]}>${clr[sgr0]} " "$@"
        echo
    else
        echo 'no args.'
    fi >&"${OFD:-2}"
}

fast_chr()
{
    local __octal
    local __char
    printf -v __octal '%03o' $1
    printf -v __char \\$__octal
    REPLY=$__char
}

unichr()
{
    if [[ $# -lt 1 || $1 == '-h' || $1 == '--help' ]]; then
        cat << EOF
Usage example:

        for (( i=0x2500; i<0x2600; i++ )); do
            unichr $i
        done

EOF
    fi

    local c=$1  # Ordinal of char
    local l=0   # Byte ctr
    local o=63  # Ceiling
    local p=128 # Accum. bits
    local s=''  # Output string

    (( c < 0x80 )) && { fast_chr "$c"; echo -n "$REPLY"; return; }

    while (( c > o )); do
        fast_chr $(( t = 0x80 | c & 0x3f ))
        s="$REPLY$s"
        (( c >>= 6, l++, p += o + 1, o >>= 1 ))
    done

    # shellcheck disable=2034
    fast_chr $(( t = p | c ))
    echo -n "$REPLY$s"
}

#prepend [text] [filename]
prepend()
{
    cp ${2} ${2}.prev
    echo ${1} > ${2}
    echo "" >> ${2}
    cat ${2}.prev >> ${2}
    rm ${2}.prev
}

alias lr='ll -rt'
alias gj='cat ~/_journal | grep -C 5'

alias mce='mcrcon -H 192.168.1.157 -p goofball777 '
alias j='journal'
alias poet='appendToFile _poetry'
alias p='poet'

alias giff='git diff'
alias gis='git status'
alias giph='git push origin HEAD'
alias gipu='git pull'
alias gic='git commit -m'
alias gia='git add'
alias svi='sudo vi'
alias gil='git log'

alias 4q='python ~/dev/4chan_search/query.py'

tm() {
    if [[ `tmux list-sessions` ]]; then
        tmux attach
    else
        tmux
    fi
}

journal () {
    if [[ -z $(cat ~/_journal | grep `date +%Y.%m.%d`) ]]; then
        echo '' >> ~/_journal
        date +%Y.%m.%d >> ~/_journal
    fi
    echo "$@" >> ~/_journal
    echo '' >> ~/_journal
}

#for adding a thought or words to a document, with timestamp
#pass in filename, relative to home dir
appendToFile () {
    if [[ -z $1 ]]; then
        exit 0
    fi
    fn=${1}
    shift 1
    if [[ -z $1 ]]; then
        echo ~/${fn}
    fi
    if [[ -z $(cat ~/${fn} | grep `date +%Y.%m.%d`) ]]; then
        echo '' >> ~/${fn}
        date +%Y.%m.%d >> ~/${fn}
    fi
    echo "$@" >> ~/${fn}
    echo '' >> ~/${fn}
}

#add to ~/do
ado () {
    size_og=`du ~/do`
    if [[ -z $1 ]]; then
        vi ~/do
    else
        echo "$@\n\n`cat ~/do`" > ~/do
    fi
    if [[ size_og != `du ~/do` ]]; then
        backup_simple ~/do /home/thomas/do
    fi
}

#grep for odt files
ogrep () {
	if [[ -z $1 || -z $2 ]]; then
		echo "usage: ogrep [pattern] [file(s)]"
		exit 0
	fi
	for f in `ls ${2}`; do
		if [[ ! ${f} == *".odt" ]]; then
			continue
		fi
		echo "got " ${f}
		echo "${f}: "
		odt2txt ${f} | grep ${1}
	done
}

fnd () {
	find $1 -type f -not -name "*node_modules*" -not -name "vendor"
}

export -f ls
export -f src
export -f por
export -f pss
export -f pacsearch
export -f mir
export -f tmuxx
export -f surfs
export -f flac_to_mp3
export -f deadsym
export -f gitpr
export -f bitpr
export -f _fetchpr
export -f sloc
export -f nh
export -f hex2dec
export -f dec2hex
export -f ga
export -f gr
export -f mktar
export -f mkzip
export -f sanitize
export -f mp
export -f pp
export -f ff
export -f fe
export -f ranger
export -f fstr
export -f swap
export -f take
export -f csrc
export -f hr
export -f arc
export -f killp
export -f mdf
export -f mip
export -f ii
export -f rep
export -f ask
export -f args
export -f fast_chr
export -f unichr
export -f prepend
