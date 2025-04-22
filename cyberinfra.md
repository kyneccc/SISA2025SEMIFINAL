Ваша задача заключается в том, чтобы структурировать и описать процесс работы с киберинфраструктурой на межрегиональном этапе. Я помогу вам создать более организованный и понятный документ, который будет содержать все необходимые шаги для подключения, создания сетей, инстансов и настройки балансировщика нагрузки. Вот как можно представить этот процесс:

---

# Работа с КиберИнфраструктурой на Межрегиональном Этапе

## 1. Подключение к КиберИнфраструктуре

Для подключения к системе необходимо задать переменные окружения, которые будут использоваться для аутентификации:

```bash
export OS_AUTH_URL=<адрес киберинфраструктуры>:5000
export OS_PROJECT_NAME="<имя проекта>"
export OS_PROJECT_DOMAIN_NAME="<имя доменного проекта>"
export OS_USER_DOMAIN_NAME="<имя домена>"
export OS_USERNAME="<пользователь>"
export OS_PASSWORD="<пароль>"
```

Эти переменные позволяют OpenStack CLI взаимодействовать с API киберинфраструктуры.

---

## 2. Создание Сетевой Инфраструктуры

### 2.1 Создание сети
Создайте сеть, которая будет использоваться для внутреннего или внешнего взаимодействия:

```bash
openstack network create <имя сети> --insecure
```

### 2.2 Создание подсети
Подсеть определяет диапазон IP-адресов и шлюз для сети:

```bash
openstack subnet create \
  --subnet-range <диапазон IP-адресов> \
  --gateway <IP-адрес шлюза> \
  --network <имя сети> \
  <имя подсети> \
  --insecure
```

Пример:
```bash
openstack subnet create \
  --subnet-range 192.168.1.0/24 \
  --gateway 192.168.1.1 \
  --network Internal-net \
  internal-subnet \
  --insecure
```

### 2.3 Добавление подсети в роутер
Чтобы обеспечить маршрутизацию между сетями, добавьте подсеть в роутер:

```bash
openstack router add subnet <имя роутера> <имя подсети> --insecure
```

---

## 3. Создание Инстансов

### 3.1 Создание ключа для доступа
Создайте SSH-ключ для безопасного доступа к инстансам:

```bash
openstack keypair create \
  --public-key <путь к публичному ключу> \
  <имя ключа> \
  --insecure
```

Пример:
```bash
openstack keypair create \
  --public-key ~/.ssh/id_rsa.pub \
  Cloud-ADM \
  --insecure
```

### 3.2 Создание портов для инстансов
Каждый инстанс может быть подключен к нескольким сетям через порты. Создайте порты для каждого инстанса:

```bash
openstack port create \
  --network <имя сети> \
  --fixed-ip ip-address=<IP-адрес> \
  <имя порта> \
  --insecure
```

Пример:
```bash
openstack port create \
  --network External-net \
  --fixed-ip ip-address=10.0.0.2 \
  hap1ex \
  --insecure
```

### 3.3 Создание инстансов
Создайте инстансы, указав параметры, такие как образ, тип диска, ключ и порты:

```bash
openstack server create \
  --flavor <тип инстанса> \
  --image <образ> \
  --boot-from-volume <размер диска> \
  --key-name <имя ключа> \
  --port <имя порта> \
  <имя инстанса> \
  --insecure
```

Пример:
```bash
openstack server create \
  --flavor tiny \
  --image alt-p10-cloud-x86_64.qcow2 \
  --boot-from-volume 10 \
  --key-name Cloud-ADM \
  --port hap1ex \
  Cloud-HA01 \
  --insecure
```

---

## 4. Настройка Балансировщика Нагрузки

### 4.1 Создание порта для балансировщика
Создайте порт, который будет использоваться балансировщиком:

```bash
openstack port create \
  --fixed-ip ip-address=<IP-адрес> \
  --network <имя сети> \
  lbex \
  --insecure
```

### 4.2 Создание балансировщика
Создайте балансировщик нагрузки, указав VIP-порт:

```bash
openstack loadbalancer create \
  --vip-port lbex \
  --name <имя балансировщика> \
  --insecure \
  --wait
```

### 4.3 Создание слушателей
Настройте слушателей для обработки HTTP и HTTPS трафика:

```bash
openstack loadbalancer listener create \
  --name <имя слушателя> \
  --protocol <протокол> \
  --protocol-port <порт> \
  <имя балансировщика> \
  --insecure \
  --wait
```

Пример:
```bash
openstack loadbalancer listener create \
  --name http \
  --protocol HTTP \
  --protocol-port 80 \
  Cloud-LB \
  --insecure \
  --wait
```

### 4.4 Создание пулов
Создайте пулы для распределения трафика:

```bash
openstack loadbalancer pool create \
  --name <имя пула> \
  --protocol <протокол> \
  --listener <имя слушателя> \
  --lb-algorithm ROUND_ROBIN \
  --insecure \
  --wait
```

### 4.5 Добавление участников пула
Добавьте участников пула (инстансы) для обработки запросов:

```bash
openstack loadbalancer member create \
  --address <IP-адрес участника> \
  --protocol-port <порт> \
  <имя пула> \
  --insecure \
  --wait
```

Пример:
```bash
openstack loadbalancer member create \
  --address 10.0.0.2 \
  --protocol-port 80 \
  http \
  --insecure \
  --wait
```

### 4.6 Создание Floating IP
Назначьте плавающий IP-адрес балансировщику:

```bash
openstack floating ip create \
  --port lbex \
  <имя внешней сети> \
  --insecure
```

---
