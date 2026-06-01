#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Пожалуйста, запустите установщик от имени суперпользователя:"
    echo "sudo ./install.sh"
    exit 1
fi

echo "Установка утилиты Focus..."

cp focus /usr/local/bin/focus
chmod +x /usr/local/bin/focus

# Универсальный поиск пользователя и его домашней папки
REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(eval echo "~$REAL_USER")
ALIAS_LINE="alias focus='sudo focus'"

echo "Настройка алиасов для пользователя $REAL_USER..."

add_alias() {
    local shell_rc="$1"
    if [ -f "$shell_rc" ]; then
        if ! grep -q "^$ALIAS_LINE" "$shell_rc"; then
            echo "" >> "$shell_rc"
            echo "# Алиас для утилиты Focus" >> "$shell_rc"
            echo "$ALIAS_LINE" >> "$shell_rc"
            
            # Меняем только владельца, не трогая группу (безопасно для macOS и Linux)
            chown "$REAL_USER" "$shell_rc"
            echo " [+] Алиас добавлен в $shell_rc"
        else
            echo " [=] Алиас уже существует в $shell_rc"
        fi
    fi
}

add_alias "$USER_HOME/.zshrc"
add_alias "$USER_HOME/.bashrc"

echo "----------------------------------------"
echo "Готово! Утилита успешно установлена."
echo "Выполните: source ~/.zshrc"
