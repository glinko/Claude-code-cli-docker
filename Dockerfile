FROM ubuntu:24.04

# Предотвращение интерактивных запросов
ENV DEBIAN_FRONTEND=noninteractive

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
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Создание пользователя с sudo правами
RUN useradd -m -s /bin/bash claude && \
    echo "claude ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Переключение на пользователя claude для установки
USER claude
WORKDIR /home/claude

# Создание директорий
RUN mkdir -p /home/claude/.local/bin /home/claude/.config/claude /home/claude/workspace

# Установка Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash

# Настройка PATH в .bashrc
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> /home/claude/.bashrc

# Настройка PATH для текущего окружения
ENV PATH="/home/claude/.local/bin:${PATH}"

# Установка bash с загрузкой .bashrc по умолчанию
CMD ["/bin/bash", "-l"]
