#!/bin/bash

log() {
  if [ -n "$2" ]; then
    echo -e "\033[1;32m$1:\033[0;32m $2\033[0m"
  else
    echo -e "\033[0;32m$1\033[0m"
  fi
}

as_root() {
  $CMD = $1
  log "Нужен root доступ для выполнения" $CMD
  su -c "$CMD"
}

continue_execution() {
  if [ -n "$1" ]; then
    echo -e "\033[1;32m$1 \033[0;32m[Y/n]\033[0m"
    read key
    if [ -n "$(echo $key | grep -i n)" ]; then
       return 1
    fi
  else
    echo "Продолжить выполнение? [Enter] - продолжить, [Ctrl]+[C] - отмена"
    read
  fi
}

complete_log() {
  if [ -n "$1" ]; then
    log 'Готово'
  else
    log "Ну сарян, иди сюда и делай сам :-]" "$2"
    log "[Enter] - продолжить скрипт"
    read
  fi
}

CODENAME=$(lsb_release -a 2>/dev/null | grep -i codename | awk '{print $2}')

WORK_DIR="/tmp/"
log "Рабочий каталог" $WORK_DIR
cd $WORK_DIR
BASHRC="$HOME/.bashrc"


continue_execution "Устанавливаем slack-desktop (GUI)?"
if [ $? -eq 0 ]; then
  log 'Начинаю загрузку...'
  VERSION=$(wget -O - https://slack.com/downloads/debian 2>/dev/null | grep -i 'version ' | awk -F'Version' '{print $2}' | awk -F'</strong' '{print $1}')
  VERSION="$(echo $VERSION)"
  wget -O ${WORK_DIR}slack-desktop.deb https://downloads.slack-edge.com/linux_releases/slack-desktop-$VERSION-amd64.deb 2>/dev/null
  as_root "dpkg -i ${WORK_DIR}slack-desktop.deb 2>/dev/null && apt-get install -f"
  complete_log "$(which slack)" "https://slack.com/downloads/debian"
fi


continue_execution "Устанавливаем atom.io (GUI)?"
if [ $? -eq 0 ]; then
  log 'Начинаю загрузку...'
  wget -O ${WORK_DIR}atom.io.deb https://atom.io/download/deb 2>/dev/null
  as_root "dpkg -i ${WORK_DIR}atom.io.deb 2>/dev/null && apt-get install -f"
  complete_log "$(which atom)" "https://atom.io/"
fi


continue_execution "Устанавливаем RVM (Ruby Version Manager)?"
if [ $? -eq 0 ]; then
  gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  curl -sSL https://get.rvm.io | bash -s stable --ruby --gems=rails,puma
  . ~/.bashrc
  log 'Известные версии:'
  rvm list known | egrep "\[ruby-\]"
  # log 'Автоустановка 2.3.4'
  # rvm install 2.3.4
  log 'rvm list'
  rvm list
  NEW_PATH=$(echo 'echo $PATH' | bash --login)
  if [ -n "$(echo $NEW_PATH | grep gems)" ]; then
    log ""
    log "сейчас PATH=$PATH"
    log "будет PATH=$NEW_PATH"
    continue_execution "Выполнить замену PATH в файле $BASHRC?"
    if [ $? -eq 0 ]; then
      echo >> $BASHRC
      echo "export PATH=$NEW_PATH" >> $BASHRC
    fi
  fi
  complete_log "$(which rvm)" "https://rvm.io/"
  complete_log "$(which ruby)" "https://rvm.io/"
fi

continue_execution "Устанавливаем NodeJS & NPM via NVM (Node Version Manager)?"
if [ $? -eq 0 ]; then
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash
  log "Какую версию будем устанавливать (default 8.12)?"
  read NODE_VERSION
  . "$HOME/.nvm/nvm.sh"  # This loads nvm
  if [ -z "${NODE_VERSION}" ]; then
    log 'Выбрана версия 8.12'
    NODE_VERSION=8.12
  fi
  
  nvm install ${NODE_VERSION}
  nvm use ${NODE_VERSION}
  
  log 'node -v' "$(node -v)"
  log 'npm -v' "$(npm -v)"
fi
