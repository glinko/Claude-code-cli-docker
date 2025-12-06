# Claude Code Console в Docker через Portainer

## Быстрый старт

### Вариант 1: Через Portainer UI

1. **Создайте новый Stack в Portainer:**
   - Откройте Portainer
   - Перейдите в `Stacks` → `Add stack`
   - Назовите stack: `claude-code-console`

2. **Загрузите файлы:**
   - Выберите `Upload` и загрузите `docker-compose.yml`
   - ИЛИ скопируйте содержимое `docker-compose.yml` в Web Editor

3. **Добавьте Dockerfile:**
   - В разделе `Build method` выберите `Repository`
   - Укажите путь к папке с Dockerfile или используйте вариант 2

### Вариант 2: Через Git repository (рекомендуется)

1. Создайте Git репозиторий с файлами `Dockerfile` и `docker-compose.yml`

2. В Portainer:
   - `Stacks` → `Add stack`
   - Выберите `Repository`
   - Укажите URL вашего репозитория
   - Укажите путь к docker-compose.yml (обычно просто `/`)
   - Нажмите `Deploy the stack`

### Вариант 3: Через командную строку на сервере

1. **Создайте директорию для проекта:**
```bash
mkdir -p ~/claude-code-console
cd ~/claude-code-console
```

2. **Скопируйте Dockerfile и docker-compose.yml в эту директорию**

3. **Запустите контейнер:**
```bash
docker-compose up -d --build
```

## Первый запуск и аутентификация

1. **Подключитесь к контейнеру:**

Через Portainer:
- `Containers` → найдите `claude-code-console`
- Нажмите `>_ Console`
- Выберите `/bin/bash`
- Нажмите `Connect`

Через командную строку:
```bash
docker exec -it claude-code-console /bin/bash
```

2. **Выполните аутентификацию:**
```bash
claude auth login
```

3. **Следуйте инструкциям:**
   - Откроется браузер для аутентификации
   - Войдите в свой аккаунт Claude
   - Подтвердите доступ
   - После успешной аутентификации вернитесь в терминал

4. **Проверьте статус:**
```bash
claude auth status
```

## Использование Claude Code Console

### Основные команды:

```bash
# Запуск Claude Code Console
claude

# Помощь
claude --help

# Проверка версии
claude --version

# Выход из аутентификации (если нужно)
claude auth logout
```

### Работа с проектами:

```bash
# Перейдите в рабочую директорию
cd ~/workspace

# Создайте новый проект
mkdir my-project
cd my-project

# Запустите Claude Code Console
claude
```

## Управление контейнером через Portainer

### Остановка контейнера:
- `Containers` → выберите контейнер → `Stop`

### Запуск контейнера:
- `Containers` → выберите контейнер → `Start`

### Перезапуск контейнера:
- `Containers` → выберите контейнер → `Restart`

### Логи:
- `Containers` → выберите контейнер → `Logs`

## Персистентность данных

Контейнер использует Docker volumes для сохранения:
- **claude-config**: Конфигурация и токены аутентификации
- **claude-workspace**: Ваши проекты и файлы

Даже после удаления и пересоздания контейнера:
- Аутентификация сохранится
- Все файлы в `/home/claude/workspace` сохранятся

## Просмотр volumes в Portainer:
- `Volumes` → найдите `claude-code-console_claude-config` и `claude-code-console_claude-workspace`

## Резервное копирование

### Экспорт volume:
```bash
docker run --rm -v claude-code-console_claude-config:/data -v $(pwd):/backup ubuntu tar czf /backup/claude-config-backup.tar.gz -C /data .
```

### Импорт volume:
```bash
docker run --rm -v claude-code-console_claude-config:/data -v $(pwd):/backup ubuntu tar xzf /backup/claude-config-backup.tar.gz -C /data
```

## Troubleshooting

### Проблема: Аутентификация не сохраняется
**Решение:** Проверьте, что volume `claude-config` создан и подключен:
```bash
docker volume inspect claude-code-console_claude-config
```

### Проблема: Claude Code Console не найден
**Решение:** Пересоберите образ:
```bash
docker-compose build --no-cache
docker-compose up -d
```

### Проблема: Нет доступа к браузеру для аутентификации
**Решение:** 
1. Используйте SSH с X11 forwarding
2. ИЛИ выполните аутентификацию на локальной машине и скопируйте конфиг:
```bash
# На локальной машине
tar czf claude-config.tar.gz ~/.config/claude/

# Скопируйте на сервер и импортируйте в volume
```

## Дополнительные возможности

### Монтирование локальных проектов:
Раскомментируйте в `docker-compose.yml`:
```yaml
volumes:
  - ./projects:/home/claude/projects
```

### Установка дополнительных инструментов:
```bash
# Войдите в контейнер
docker exec -it claude-code-console /bin/bash

# Установите нужные пакеты
sudo apt-get update
sudo apt-get install -y <package-name>
```

## Обновление Claude Code Console

```bash
# Войдите в контейнер
docker exec -it claude-code-console /bin/bash

# Обновите Claude
curl -fsSL https://storage.googleapis.com/claude-code/install.sh | sh
```

## Безопасность

- Контейнер работает от пользователя `claude` (не root)
- Все конфиденциальные данные хранятся в Docker volumes
- Аутентификация через subscription безопаснее API ключей

## Полезные ссылки

- [Документация Claude Code](https://docs.claude.com)
- [Документация Docker](https://docs.docker.com)
- [Документация Portainer](https://docs.portainer.io)
