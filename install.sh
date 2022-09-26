#!/bin/sh

command_exists() {
  command -v "$@" > /dev/null
}

dir_exists() {
  test -d "$@"
}

file_exists() {
  test -f "$@"
}

zplug_installer() {
  if dir_exists $HOME/.zplug; then
    cd $HOME/.zplug && git pull origin master
    return
  fi
  git clone https://github.com/zplug/zplug $HOME/.zplug
}

omz_installer() {
  if dir_exists $HOME/.oh-my-zsh; then
    cd $HOME/.oh-my-zsh && git pull origin master
    return
  fi
  git clone https://github.com/ohmyzsh/ohmyzsh $HOME/.oh-my-zsh
}

zshrc_writer() {
  if file_exists $HOME/.zshrc; then

    file_name=.zshrc
    current_time=$(date "+%Y.%m.%d_%H:%M:%S")
    new_name=$file_name"_"$current_time

    mv $HOME/.zshrc $HOME/$new_name
  fi
  cat << EOF > $HOME/.zshrc
source ~/.zplug/init.zsh
zplug "zplug/zplug", hook-build:"zplug --self-manage"
zplug "lib/*", from:oh-my-zsh
zplug "themes/robbyrussell", from:oh-my-zsh, as:theme
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-completions"
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
PROMPT+='%{\$reset_color%}\$(git_prompt_info)'
RPROMPT="%B%F{green}%?%f%b%B%F{208} <<%f%b%B%F{240}%*%f%b"
HTTP='127.0.0.1:1080'
SOCKS='127.0.0.1:1087'
default=\$HTTP
unproxy() {
    unset http_proxy HTTP_PROXY https_proxy HTTPS_PROXY all_proxy ALL_PROXY ftp_proxy FTP_PROXY dns_proxy DNS_PROXY
    echo "clear proxy done"
}
setproxy() {
	if [ \$# -eq 0 ]
	then
		inArg=\$default
	else
		inArg=\$1
	fi
	HOST=\$(echo \$inArg |cut -d: -f1)
	PORT=\$(echo \$inArg |cut -d: -f2)
	http_proxy=http://\$HOST:\$PORT
	HTTP_PROXY=\$http_proxy
	all_proxy=\$http_proxy
	ALL_PROXY=\$http_proxy
	ftp_proxy=\$http_proxy
	FTP_PROXY=\$http_proxy
	dns_proxy=\$http_proxy
	DNS_PROXY=\$http_proxy
	https_proxy=\$http_proxy
	HTTPS_PROXY=\$https_proxy
	no_proxy="localhost, 127.0.0.1, localaddress, 10.*.*.*, 192.168.*.*,"
	echo "current proxy is \${http_proxy}"
	export no_proxy http_proxy HTTP_PROXY https_proxy HTTPS_PROXY all_proxy ALL_PROXY ftp_proxy FTP_PROXY dns_proxy DNS_PROXY
}
# set PATH so it includes user's private bin if it exists
if [ -d "\$HOME/bin" ] ; then
    PATH="\$HOME/bin:\$PATH"
fi
# set PATH so it includes user's private bin if it exists
if [ -d "\$HOME/.local/bin" ] ; then
    PATH="\$HOME/.local/bin:\$PATH"
fi
# self_bin() {
# 	for bin in \$HOME/bin/*/bin; do
# 	export PATH="\$PATH:\$bin"
# 	done
# }
# self_bin
# export PATH="\$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
EOF
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

  omz_installer
  zplug_installer
  zshrc_writer
  zsh
}

main "$@"