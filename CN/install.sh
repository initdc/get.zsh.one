#!/bin/sh

set -e

# run with: curl -L get-cn.zsh.one | sh
# src at: https://github.com/initdc/get.zsh.one

command_exists() {
    command -v "$@" > /dev/null 2>&1
}

dir_exists() {
    test -d "$@" > /dev/null 2>&1
}

file_exists() {
    test -f "$@" > /dev/null 2>&1
}

zplug_installer() {
    if dir_exists $HOME/.zplug; then
        cd $HOME/.zplug
        git remote set-url origin https://jihulab.com/mirr/zplug
        git pull origin feat/jihulab
        git checkout feat/jihulab
        return
    fi
    git clone https://jihulab.com/mirr/zplug -b feat/jihulab $HOME/.zplug
}

omz_installer() {
    mkdir -p $HOME/.zplug/repos/robbyrussell
    git clone https://jihulab.com/mirr/ohmyzsh $HOME/.zplug/repos/oh-my-zsh
    cp -ap $HOME/.zplug/repos/oh-my-zsh $HOME/.zplug/repos/robbyrussell/oh-my-zsh
}

zshrc_writer() {
    if file_exists $HOME/.zshrc; then

        file_name=.zshrc
        current_time=$(date "+%Y.%m.%d_%H:%M:%S")
        new_name=$file_name"_"$current_time

        mv $HOME/.zshrc $HOME/$new_name
    fi
    echo > $HOME/.zshrc 'source ~/.zplug/init.zsh
# zplug "mirr/zplug", from:jihulab, at: feat/jihulab, hook-build:"zplug --self-manage" # see bug: https://github.com/zplug/zplug/issues/467
zplug "lib/*", from:oh-my-zsh
zplug "themes/robbyrussell", from:oh-my-zsh, as:theme
zplug "mirr/zsh-autosuggestions", from:jihulab
zplug "mirr/zsh-syntax-highlighting", from:jihulab, defer:2
zplug "mirr/zsh-completions", from:jihulab

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi
# Then, source plugins and add commands to PATH
zplug load #--verbose

# https://zsh-prompt-generator.site
PROMPT="%F{green}➜%f %B%F{cyan}%~%f%b "
PROMPT+="%{$reset_color%}$(git_prompt_info)"
RPROMPT="%B%F{green}%?%f%b%B%F{208} <<%f%b%B%F{240}%*%f%b"

# http proxy code block
HTTP="127.0.0.1:1080"
SOCKS="127.0.0.1:1087"
default=$HTTP

unproxy() {
    unset http_proxy HTTP_PROXY https_proxy HTTPS_PROXY all_proxy ALL_PROXY ftp_proxy FTP_PROXY dns_proxy DNS_PROXY
    echo "clear proxy done"
}

setproxy() {
    if [ $# -eq 0 ]
    then
        inArg=$default
    else
        inArg=$1
    fi
    HOST=$(echo $inArg |cut -d: -f1)
    PORT=$(echo $inArg |cut -d: -f2)
    http_proxy=http://$HOST:$PORT
    HTTP_PROXY=$http_proxy
    all_proxy=$http_proxy
    ALL_PROXY=$http_proxy
    ftp_proxy=$http_proxy
    FTP_PROXY=$http_proxy
    dns_proxy=$http_proxy
    DNS_PROXY=$http_proxy
    https_proxy=$http_proxy
    HTTPS_PROXY=$https_proxy
    no_proxy="localhost, 127.0.0.1, localaddress"
    echo "current proxy is ${http_proxy}"
    export no_proxy http_proxy HTTP_PROXY https_proxy HTTPS_PROXY all_proxy ALL_PROXY ftp_proxy FTP_PROXY dns_proxy DNS_PROXY
}

# set PATH so it includes user"s private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user"s private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# for macOS user
# export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
'
}

main() {
    if !(command_exists zsh); then
        echo "This script needs zsh installed to run."
        exit 1
    fi

    if !(command_exists git); then
        echo "This script needs git installed to run."
        exit 1
    fi

    zplug_installer
    zshrc_writer
    omz_installer
    zsh
}

main "$@"