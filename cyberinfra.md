# Заметки для работы с киберинфраструктурой на межригиональном этапе
## Подключение
``` bash
export OS_AUTH_URL=адрес киберинфраструктуры+5000 port
export OS_PROJECT_NAME="имя проекта в котором работает пользователь"
export OS_PROJECT_DOMAIN_NAME="имя доменного проекта"
export OS_USER_DOMAIN_NAME="имя домена"
export OS_USERNAME="пользователь"
export OS_PASSWORD=пароль
```
## Сети 
### Создание сети
``` bash
 openstack network create имя сети
```
по факту тут ничего интересного нет, основные опции будут заданы в следущем шаге
#### Создание подсети
вот тут начинается самое интересное
``` bash
openstack subnet create  --subnet-range 192.168.123.0/24 --gateway 192.168.123.1  --network  netname  namesubnet --insecure
```
#### После создание подсети необходимо их добавить в роутер 
``` bash
openstack router add subnet <Имя роутера> <Имя подсети> --insecure
```
## Создание инстанса в КиберИнфраструктуре




