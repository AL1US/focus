#!/bin/bash

# Проверка на права root
if [ "$EUID" -ne 0 ]; then
    echo "Пожалуйста, запустите установщик от имени суперпользователя:"
    echo "sudo ./install.sh"
    exit 1
fi

echo "Установка утилиты Focus..."

# 1. Копируем файл в системный бинарный путь и даем права
cp focus /usr/local/bin/focus
chmod +x /usr/local/bin/focus

# 2. Настройка алиасов
# Находим реального пользователя, который запустил sudo, и его домашнюю папку
REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
ALIAS_LINE="alias focus='sudo focus'"

echo "Настройка алиасов для пользователя $REAL_USER..."

# Функция для добавления алиаса
add_alias() {
    local shell_rc="$1"
    if [ -f "$shell_rc" ]; then
        # Проверяем, есть ли уже такой алиас в файле
        if ! grep -q "^$ALIAS_LINE" "$shell_rc"; then
            echo "" >> "$shell_rc"
            echo "# Алиас для утилиты Focus" >> "$shell_rc"
            echo "$ALIAS_LINE" >> "$shell_rc"
            
            # Убеждаемся, что права на файл остались у пользователя, а не у root
            chown "$REAL_USER":"$REAL_USER" "$shell_rc"
            echo " [+] Алиас добавлен в $shell_rc"
        else
            echo " [=] Алиас уже существует в $shell_rc"
        fi
    fi
}

# Пробуем добавить в конфиги zsh и bash (на случай, если будете менять оболочку)
add_alias "$USER_HOME/.zshrc"
add_alias "$USER_HOME/.bashrc"

echo "----------------------------------------"
echo "Готово! Утилита успешно установлена."
echo ""
echo "Чтобы алиас заработал прямо сейчас в текущем окне, выполните:"
echo "  source ~/.zshrc"
echo ""
echo "После этого просто пишите:"
echo "  focus add vk.com"
echo "  focus unlock 10"
