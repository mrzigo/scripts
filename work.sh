#!/bin/bash

log() {
  if [ -n "$2" ]; then
    echo -e "\033[1;32m$1:\033[0;32m $2\033[0m"
  else
    echo -e "\033[0;32m$1\033[0m"
  fi
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

WORK_DIR="/tmp/"
log "Рабочий каталог" $WORK_DIR
cd $WORK_DIR


continue_execution "Устанавливаем slack-desktop (GUI)?"
if [ $? -eq 0 ]; then
  log 'Начинаю загрузку...'
  VERSION=$(wget -O - https://slack.com/downloads/debian 2>/dev/null | grep -i 'version ' | awk -F'Version' '{print $2}' | awk -F'</strong' '{print $1}')
  VERSION="$(echo $VERSION)"
  wget -O ${WORK_DIR}slack-desktop.deb https://downloads.slack-edge.com/linux_releases/slack-desktop-$VERSION-amd64.deb 2>/dev/null
  if [ $? ]; then
    su -c "dpkg -i ${WORK_DIR}slack-desktop.deb"
    su -c 'apt-get install -f'
    log 'Готово'
  else
    log "Ну сарян, иди сюда и делай сам :-]" "https://slack.com/downloads/debian"
  fi
fi


continue_execution "Устанавливаем atom.io (GUI)?"
if [ $? -eq 0 ]; then
  log 'Начинаю загрузку...'
  wget -O ${WORK_DIR}atom.io.deb https://atom.io/download/deb 2>/dev/null
  if [ $? ]; then
    su -c "dpkg -i ${WORK_DIR}atom.io.deb"
    su -c 'apt-get install -f'
    log 'Готово'
  else
    log "Ну сарян, иди сюда и делай сам :-]" "https://atom.io/"
  fi
fi



continue_execution "Устанавливаем RVM (Ruby Version Manager)?"
if [ $? -eq 0 ]; then
  su -c 'gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB'
  su -c 'curl -sSL https://get.rvm.io | bash -s stable --ruby --gems=rails,puma'
  log 'Известные версии:'
  rvm list known
  log 'Автоустановка 2.3.4'
  rvm install 2.3.4
  if [ $? ]; then
    log 'Готово'
  else
    log "Ну сарян, иди сюда и делай сам :-]" "https://rvm.io"
  fi
fi
