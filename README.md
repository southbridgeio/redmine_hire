[![Build Status](https://travis-ci.org/southbridgeio/redmine_hire.svg?branch=master)](https://travis-ci.org/southbridgeio/redmine_hire)

# redmine_hire

The plugin works only with Russian website hh.ru, and does not support other services.

Плагин предназначен для автоматизации работы с откликами сайта hh.ru.

Плагин синхронизирует отклики по вашим вакансиям и создает на основе их задачи в Redmine.
Для каждого отклика + соискателя создается отдельная задача c данными о вакансии и соискателе.

Помогите нам сделать этот плагин лучше, сообщая во вкладке [Issues](https://github.com/southbridgeio/redmine_hire/issues) обо всех проблемах, с которыми вы столкнётесь при его использовании. Мы готовы ответить на все ваши вопросы, касающиеся этого плагина.

**Важно! Для работы плагина необходим [платный доступ](https://github.com/hhru/api/blob/master/docs/employer_payable_methods.md) к методам API**

## Установка

### Требования

* **Ruby 2.3+**
* **Redmine 3.1+**
* Плагин устанавливается стандартно:

```
cd {REDMINE_ROOT}
git clone https://github.com/southbridgeio/redmine_hire.git plugins/redmine_hire
bundle install
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

## Настройка плагина

1) Перед началом работы необходимо сконфигурировать настройки плагина ```/settings/plugin/redmine_hire```

* HH Employer ID, Client ID, Client Secret - ID работодателя и данные для oauth-авторизации. Можно получить в личном [кабинете](https://dev.hh.ru/admin)
* Project Name - имя проекта в котором будут создаваться задачи.
* Issue Status Name - имя статуса для задач.
* Issue Tracker Name - имя трекера для задач.
* Issue Author Login - логин для автора задач (если не указан - автор будет Anonim).
* Redmine API Key - ключ для Redmine API. Можно получить в настройках учетных записей Redmine.

2) Нужно задать в личном кабинете HH Redirect URI в виде `https://your.host/redmine_hire/oauth`

3) После сохранения корректных настроек на странице настроек плагина появится ссылка "Авторизовать приложение". Необходимо по ней перейти, чтобы получить access-token для дальнейшей работы.

## Запуск синхронизации с HH API и создание задач
При синхронизации будут получены вакансии и созданы задачи из откликов соискателей.
### rake
Выполните rake команду в папке Redmine

```rake redmine_hire:hh_api_sync_active``` - синхронизирует все активные вакансии.

```rake redmine_hire:hh_api_sync_archived``` - синхронизирует все архивные вакансии (можете перед запуском установить статус для архивных задач в настройках плагина).

```rake redmine_hire:hh_api_rollback``` - удалит все созданные задачи для установленного проекта (если что-то пошло не так).

### whenever
Вы можете использовать whenever для периодического запуска синхронизации.

Просто добавьте ```rake redmine_hire:hh_api_sync_active``` в ваш schedule.rb

### sidekiq-cron

Если у вас определится гем Sidekiq-cron, то в настройках будет дополнительное поле - HH Api Sync Cron, в которое можете поместить строку с синтаксисом cron (например - ```*/5 * * * *```) и ссылка для активации расписания.

## Интеграция с плагином redmine_contacts_helpdesk
[Helpdesk](https://www.redmineup.com/pages/help/helpdesk) - документация плагина.

Плагин готов для работы с Helpdesk. Если у вас установлен этот плагин, задачи будут создавать через API Helpdesk с созданием и привязкой к задаче контакта, с данными (email, first_name, last_name) из резюме соискателя.

## Быстрый отказ соискателю
Плагин предоставляет возможность отправить соисателю быстрый отказ через HH API, если отклик имеет ссылку на быстрый отказ.
* При редактировании задачи доступен чекбокс - "Отправить отказ".
* Также есть ссылка на верхней панели задачи.

Если вы используете Sidekiq, то отказ будет отправлен асинхронно.

## Contributing
Всегда будем рады вашим pull request.

Для запуска тестов, запустите из папки Redmine:
```bundle exec rake redmine:plugins:test NAME=redmine_hire```

## Автор плагина

Плагин разработан [Southbridge](https://southbridge.io)

