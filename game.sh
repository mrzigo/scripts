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


continue_execution "Устанавливаем steam?"
if [ $? -eq 0 ]; then
  log 'Начинаю загрузку...'
  wget -O ${WORK_DIR}steam.deb https://steamcdn-a.akamaihd.net/client/installer/steam.deb 2>/dev/null
  if [ $? ]; then
    su -c "dpkg -i ${WORK_DIR}steam.deb"
    su -c 'apt-get install -f'
    su -c 'apt-get install steam -y'
    su -c 'apt-get install -f'
    log 'Возможно потребуется допил, запустить'
  else
    log "Ну сарян, иди сюда и делай сам :-]" "http://store.steampowered.com/about/"
  fi
fi
