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

complete_log() {
  if [ -n "$1" ]; then
    log 'Готово'
  else
    log "Ну сарян, иди сюда и делай сам :-]" "$2"
    log "[Enter] - продолжить скрипт"
    read
  fi
}

as_root() {
  $CMD = $1
  log "Нужен root доступ для выполнения" $CMD
  su -c "$CMD"
}

WORK_DIR="/tmp/"
log "Рабочий каталог" $WORK_DIR
cd $WORK_DIR


continue_execution "Устанавливаем steam?"
if [ $? -eq 0 ]; then
  log 'Начинаю загрузку...'
  wget -O ${WORK_DIR}steam.deb https://steamcdn-a.akamaihd.net/client/installer/steam.deb 2>/dev/null
  if [ $? ]; then
    as_root "dpkg -i ${WORK_DIR}steam.deb &&
    apt-get install -f &&
    apt-get install steam -y &&
    apt-get install -f "
    log 'Возможно потребуется допил'
  else
    log "Ну сарян, иди сюда и делай сам :-]" "http://store.steampowered.com/about/"
  fi
fi

continue_execution "Устанавливаем openarena 0.8.8?"
if [ $? -eq 0 ]; then
  as_root "apt-get install openarena openarena-data openarena-085-data openarena-088-data"
  complete_log "$(which openarena)" "?#URL#?"
fi
