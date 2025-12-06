#!/bin/bash

# Скрипт быстрой установки Claude Code Console в Docker
# Для Ubuntu 24.04 с установленным Docker

set -e

echo "================================================"
echo "Claude Code Console - Docker Setup"
echo "================================================"
echo ""

# Проверка наличия Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен. Установите Docker и запустите скрипт снова."
    exit 1
fi

# Проверка наличия docker-compose
if ! command -v docker-compose &> /dev/null; then
    echo "⚠️  docker-compose не найден. Устанавливаю..."
    sudo apt-get update
    sudo apt-get install -y docker-compose
fi

echo "✅ Docker и docker-compose найдены"
echo ""

# Создание директории для проекта
PROJECT_DIR="$HOME/claude-code-console"
echo "📁 Создание директории проекта: $PROJECT_DIR"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Создание Dockerfile
echo "📝 Создание Dockerfile..."
cat > Dockerfile << 'EOF'
FROM ubuntu:24.04

# Установка необходимых пакетов
RUN apt-get update && apt-get install -y \
    curl \
    git \
    vim \
    nano \
    wget \
    sudo \
    python3 \
    python3-pip \
    nodejs \
    npm \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Создание пользователя с sudo правами
RUN useradd -m -s /bin/bash claude && \
    echo "claude ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Установка Claude Code Console
RUN curl -fsSL https://storage.googleapis.com/claude-code/install.sh | sh

# Переключение на пользователя claude
USER claude
WORKDIR /home/claude

# Настройка PATH для Claude Code Console
ENV PATH="/home/claude/.local/bin:${PATH}"

# Создание директории для персистентной конфигурации
RUN mkdir -p /home/claude/.config/claude

# Установка bash как оболочки по умолчанию
CMD ["/bin/bash"]
EOF

# Создание docker-compose.yml
echo "📝 Создание docker-compose.yml..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  claude-code-console:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: claude-code-console
    hostname: claude-dev
    stdin_open: true
    tty: true
    volumes:
      - claude-config:/home/claude/.config/claude
      - claude-workspace:/home/claude/workspace
    environment:
      - TERM=xterm-256color
    restart: unless-stopped
    command: /bin/bash

volumes:
  claude-config:
    driver: local
  claude-workspace:
    driver: local
EOF

echo "✅ Файлы созданы"
echo ""

# Сборка и запуск контейнера
echo "🏗️  Сборка Docker образа (это может занять несколько минут)..."
docker-compose build

echo ""
echo "🚀 Запуск контейнера..."
docker-compose up -d

echo ""
echo "================================================"
echo "✅ Установка завершена!"
echo "================================================"
echo ""
echo "Следующие шаги:"
echo ""
echo "1. Подключитесь к контейнеру:"
echo "   docker exec -it claude-code-console /bin/bash"
echo ""
echo "2. Выполните аутентификацию:"
echo "   claude auth login"
echo ""
echo "3. Начните работу:"
echo "   claude"
echo ""
echo "Управление контейнером:"
echo "  Остановить:  docker-compose stop"
echo "  Запустить:   docker-compose start"
echo "  Перезапуск:  docker-compose restart"
echo "  Логи:        docker-compose logs -f"
echo "  Удалить:     docker-compose down"
echo ""
echo "Директория проекта: $PROJECT_DIR"
echo "================================================"
