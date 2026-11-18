# Server Infrastructure Automation

Это ansible проект для автоматизированной подготовки сервера Linux: базовая настройка и усиление безопасности сервера, установка Docker и развёртывание стека мониторинга.

Проект проверен на моём личном VPS, на котором параллельно размещены другие сервисы и приложения. Это позволило проверить автоматизацию не только в тестовой среде, но и на реально используемом сервере.

# Мой сервер: https://shanteve.tech

## Возможности
### `common` — базовая настройка сервера
- обновление пакетов и установка основных системных утилит;
- настройка SSH: запрет входа для root и отключение парольной аутентификации;
- настройка UFW с политикой запрета входящих подключений по умолчанию;
- установка и настройка Fail2ban для защиты SSH;
- опциональная настройка автоматической установки обновлений безопасности.

### `docker` — контейнерная инфраструктура
- установка Docker Engine и Docker Compose Plugin из официального репозитория Docker;
- настройка Docker daemon: `live-restore` и ротация логов контейнеров;
- добавление пользователя Ansible в группу `docker`.

### `monitoring` — мониторинг сервера и контейнеров
Стек разворачивается через Docker Compose, а конфигурационные файлы генерируются из Jinja2-шаблонов.

| Компонент | Назначение |
|---|---|
| Prometheus | Сбор и хранение метрик |
| Grafana | Визуализация метрик и dashboards |
| Node Exporter | Метрики операционной системы и VPS |
| cAdvisor | Метрики Docker-контейнеров |
| Blackbox Exporter | Проверка доступности HTTP- и TCP-endpoints |
| Alertmanager | Приём и группировка alert’ов от Prometheus |

Дополнительно настроены правила оповещения о высокой загрузке CPU и RAM, нехватке места на диске и недоступности проверяемых endpoints. Grafana автоматически получает Prometheus в качестве источника данных. Данные Prometheus, Grafana и Alertmanager сохраняются в Docker volumes.

Порты Prometheus, Grafana и Alertmanager по умолчанию привязаны к `127.0.0.1`, поэтому сервисы не публикуются напрямую на внешнем интерфейсе сервера. Это специально сделано для обеспечения безопасности.
Для доступа к сервисам мониторинга с вашего компьютера нужно прокинуть SSH туннели

## Структура проекта

```text
server-infrastructure/
└── ansible/
    ├── ansible.cfg
    ├── requirements.yml
    ├── inventory/
    │   ├── hosts.yml
    │   └── group_vars/all/
    │       ├── vars.yml
    │       └── vault.yml
    ├── playbooks/
    │   ├── bootstrap.yml
    │   ├── docker.yml
    │   └── monitoring.yml
    └── roles/
        ├── common/
        ├── docker/
        └── monitoring/
```

## Запуск

**Требования:** Ansible на управляющей машине, SSH-доступ к целевому серверу.
Для выполнения playbook’ов требуется доступ с `sudo`.

1. Установите необходимые коллекции:

   ```bash
   ansible-galaxy collection install -r requirements.yml
   ```

2. Укажите адрес своего сервера в `inventory/hosts.yml` и пользователя + путь на его приватный ключ `inventory/group_vars/all/vars.yml`.

3. Создайте зашифрованные переменные с учётными данными Grafana:
   1. В папке inventory/group_vars/all запишите свои данные в файл vault.example.yml
   2. Переименуйте vault.example.yml vault.yml
   3. Зашифруйте секреты
   ```bash
   ansible-vault encrypt inventory/group_vars/all/vault.yml
   ```
   4. Сохраните пароль от секретов
   ```bash
   echo "your_vault_password" > .vault_pass
   chmod 600 .vault_pass
   ```

4. Проверьте доступность сервера:

   ```bash
   ansible servers -m ping
   ```

5. Запустите playbook’и последовательно:

   ```bash
   ansible-playbook playbooks/bootstrap.yml
   ansible-playbook playbooks/docker.yml
   ansible-playbook playbooks/monitoring.yml
   ```

## Технологии

`Ansible` · `YAML` · `Jinja2` · `Docker` · `Docker Compose` · `Prometheus` · `Grafana` · `Node Exporter` · `cAdvisor` · `Blackbox Exporter` · `Alertmanager` · `UFW` · `Fail2ban` · `Ansible Vault`