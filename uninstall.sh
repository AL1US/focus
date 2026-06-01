#!/bin/bash

# Проверка на права root
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

# 1. Очистка /etc/hosts (удаляем весь блок Focus)
if grep -q "$MARKER_START" "$HOSTS_FILE"; then
    sed -i "/$MARKER_START/,/$MARKER_END/d" "$HOSTS_FILE"
    echo " [+] Блок Focus удален из $HOSTS_FILE"
fi

# 2. Удаление конфигурации
if [ -f "$CONF_FILE" ]; then
    rm -f "$CONF_FILE"
    echo " [+] Конфигурационный файл удален"
fi

# 3. Удаление исполняемого файла
if [ -f "$BIN_FILE" ]; then
    rm -f "$BIN_FILE"
    echo " [+] Исполняемый файл удален"
fi

# 4. Удаление алиасов у реального пользователя
REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

remove_alias() {
    local shell_rc="$1"
    if [ -f "$shell_rc" ]; then
        # Удаляем строку с алиасом и комментарий над ней
        sed -i "/alias focus='sudo focus'/d" "$shell_rc"
        sed -i "/# Алиас для утилиты Focus/d" "$shell_rc"
        echo " [+] Алиас удален из $shell_rc"
    fi
}

remove_alias "$USER_HOME/.zshrc"
remove_alias "$USER_HOME/.bashrc"

echo "----------------------------------------"
echo "Готово! Утилита Focus полностью удалена из системы."
echo "Чтобы алиас перестал работать в текущем окне, выполните:"
echo "  unalias focus 2>/dev/null || true"
