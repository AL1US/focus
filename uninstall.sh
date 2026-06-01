#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Пожалуйста, запустите скрипт от имени суперпользователя:"
    echo "sudo ./uninstall.sh"
    exit 1
fi

echo "Удаление утилиты Focus..."

HOSTS_FILE="/etc/hosts"
CONF_FILE="/etc/focus.conf"
BIN_FILE="/usr/local/bin/focus"
MARKER_START="# --- FOCUS START ---"
MARKER_END="# --- FOCUS END ---"

sed_in_place() {
    if [ "$(uname -s)" = "Darwin" ]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

if grep -q "$MARKER_START" "$HOSTS_FILE"; then
    sed_in_place "/$MARKER_START/,/$MARKER_END/d" "$HOSTS_FILE"
    echo " [+] Блок Focus удален из $HOSTS_FILE"
fi

if [ -f "$CONF_FILE" ]; then
    rm -f "$CONF_FILE"
    echo " [+] Конфигурационный файл удален"
fi

if [ -f "$BIN_FILE" ]; then
    rm -f "$BIN_FILE"
    echo " [+] Исполняемый файл удален"
fi

REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(eval echo "~$REAL_USER")

remove_alias() {
    local shell_rc="$1"
    if [ -f "$shell_rc" ]; then
        sed_in_place "/alias focus='sudo focus'/d" "$shell_rc"
        sed_in_place "/# Алиас для утилиты Focus/d" "$shell_rc"
        echo " [+] Алиас удален из $shell_rc"
    fi
}

remove_alias "$USER_HOME/.zshrc"
remove_alias "$USER_HOME/.bashrc"

echo "----------------------------------------"
echo "Готово! Утилита Focus полностью удалена из системы."
