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


BASHRC="$HOME/.bashrc"
log "Настройка консоли" "Файл $BASHRC"
continue_execution "Переписать переменную 'PS1'?"
if [ $? -eq 0 ]; then
  echo PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[00m\][\A]: \[\033[01;34m\]\w\[\033[00m\] \$ ' >> $BASHRC
  log 'Готово'
fi


ROOT_BASHRC="/root/.bashrc"
log "Настройка консоли ROOT" "Файл $ROOT_BASHRC"
continue_execution "Переписать переменную 'PS1'?"
if [ $? -eq 0 ]; then
  echo PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]' >> $ROOT_BASHRC
  log 'Готово'
fi


log "Установка базового набора программ" "консольные"
log "  Будут установлены следующие программы:"
PROGRAMM_INSTALL="htop wget curl"
log "  ${PROGRAMM_INSTALL}"
continue_execution "Устанавливаем?"
if [ $? -eq 0 ]; then
  as_root "apt-get update && apt-get install ${PROGRAMM_INSTALL} -y"
  log 'Готово'
fi


log "Установка базового набора программ" "GUI"
log "  Будут установлены следующие программы:"
PROGRAMM_INSTALL="geany guake multisystem inkscape gimp vlc"
log "  ${PROGRAMM_INSTALL}"
continue_execution "Устанавливаем?"
if [ $? -eq 0 ]; then
  as_root "apt-add-repository 'deb http://liveusb.info/multisystem/depot all main' &&
  wget -q http://liveusb.info/multisystem/depot/multisystem.asc -O- | apt-key add - &&
  apt-get update &&
  apt-get install ${PROGRAMM_INSTALL} -y"
  log 'Готово'
fi


continue_execution "Устанавливаем google-chrome-stable (GUI)?"
if [ $? -eq 0 ]; then
  log 'Начинаю загрузку...'
  wget -O "${WORK_DIR}google-chrome-stable.deb" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb 2>/dev/null
  as_root "dpkg -i ${WORK_DIR}google-chrome-stable.deb && apt-get install -f"
  complete_log "$(which google-chrome)" "https://www.google.com/chrome/browser/desktop/index.html"
fi


continue_execution "Устанавливаем telegram (GUI)?"
if [ $? -eq 0 ]; then
  log 'Начинаю загрузку...'
  wget -O ${WORK_DIR}telegram.tar.xz https://telegram.org/dl/desktop/linux 2>/dev/null
  if [ $? ]; then
    tar -xf ${WORK_DIR}telegram.tar.xz
    mkdir -p ~/.Telegram
    mv ${WORK_DIR}Telegram/* ~/.Telegram/
    chmod +x ~/.Telegram/Telegram
    ~/.Telegram/Telegram
    log 'Готово'
  else
    log "Ну сарян, иди сюда и делай сам :-]" "https://desktop.telegram.org/"
  fi
fi
