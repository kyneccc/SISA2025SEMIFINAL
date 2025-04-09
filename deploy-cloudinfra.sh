#!/bin/bash
source /home/altlinux/bin/cloudinit.conf

openstack keypair create --public-key /home/altlinux/.ssh/id_rsa.pub Cloud-ADM --insecure

openstack network create External-net --insecure
openstack subnet create --subnet-range 10.0.0.0/24 --gateway 10.0.0.6  --network  External-net  exsub --insecure
openstack network create Internal-net --insecure
openstack subnet create --subnet-range 192.168.10.0/26 --gateway 192.168.10.62  --network Internal-net  insub --insecure

openstack router add subnet Cloud-RTR exsub --insecure
openstack router add subnet Cloud-RTR insub  --insecure

#HAP
openstack port create --network External-net --fixed-ip ip-address=10.0.0.2 hap1ex --insecure
openstack port create --network Internal-net --fixed-ip ip-address=192.168.10.10 hap1in --insecure
openstack port create --network Management-net --fixed-ip ip-address=192.168.10.65 hap1mg --insecure
openstack server create --flavor tiny  --port hap1ex --port hap1mg  --port hap1in --image alt-p10-cloud-x86_64.qcow2 --boot-from-volume 10 --key-name Cloud-ADM Cloud-HA01 --insecure

openstack port create --network External-net --fixed-ip ip-address=10.0.0.30 hap2ex --insecure
openstack port create --network Internal-net --fixed-ip ip-address=192.168.10.2 hap2in --insecure
openstack port create --network Management-net --fixed-ip ip-address=192.168.10.66 hap2mg --insecure
openstack server create --flavor tiny  --port hap2ex --port hap2mg  --port hap2in --image alt-p10-cloud-x86_64.qcow2 --boot-from-volume 10 --key-name Cloud-ADM Cloud-HA02 --insecure

#WEB
openstack port create --network Internal-net --fixed-ip ip-address=192.168.10.3 web1in --insecure
openstack port create --network Management-net --fixed-ip ip-address=192.168.10.67 web1mg --insecure
openstack server create --flavor start --port web1mg  --port web1in --image alt-p10-cloud-x86_64.qcow2 --boot-from-volume 10 --key-name Cloud-ADM Cloud-WEB01 --insecure

openstack port create --network Internal-net --fixed-ip ip-address=192.168.10.4 web2in --insecure
openstack port create --network Management-net --fixed-ip ip-address=192.168.10.68 web2mg --insecure
openstack server create --flavor start --port web2mg  --port web2in --image alt-p10-cloud-x86_64.qcow2 --boot-from-volume 10 --key-name Cloud-ADM Cloud-WEB02 --insecure

#DB
openstack port create --network Internal-net --fixed-ip ip-address=192.168.10.5 db1in --insecure
openstack port create --network Management-net --fixed-ip ip-address=192.168.10.69 db1mg --insecure
openstack server create --flavor start --port db1mg  --port db1in --image alt-p10-cloud-x86_64.qcow2 --boot-from-volume 10 --key-name Cloud-ADM Cloud-DB01 --insecure

openstack port create --network Internal-net --fixed-ip ip-address=192.168.10.6 db2in --insecure
openstack port create --network Management-net --fixed-ip ip-address=192.168.10.70 db2mg --insecure
openstack server create --flavor start --port db2mg  --port db2in --image alt-p10-cloud-x86_64.qcow2 --boot-from-volume 10 --key-name Cloud-ADM Cloud-DB02 --insecure


#Cоздаем порт
openstack port create --fixed-ip ip-address=10.0.0.10 --network External-net lbex --insecure
#Создаем лоадбалансер
openstack loadbalancer create --vip-port lbex --name Cloud-LB --insecure --wait
#Создание listener
openstack loadbalancer  listener create --name https --protocol HTTPS --protocol-port 443 Cloud-LB --insecure --wait
openstack loadbalancer  listener create --name http --protocol HTTP --protocol-port 80 Cloud-LB --insecure --wait
#создание пулов
openstack loadbalancer pool create --name https  --protocol HTTPS  --listener https --lb-algorithm ROUND_ROBIN --insecure --wait
openstack loadbalancer pool create --name http  --protocol HTTP  --listener http --lb-algorithm ROUND_ROBIN --insecure --wait

#создание  member
openstack loadbalancer member create --address 10.0.0.2 --protocol-port 80  http  --insecure --wait
openstack loadbalancer member create --address 10.0.0.2 --protocol-port 443 https  --insecure --wait
openstack loadbalancer member create --address 10.0.0.30 --protocol-port 80  http  --insecure --wait
openstack loadbalancer member create --address 10.0.0.30 --protocol-port 443 https  --insecure --wait
openstack floating ip create --port lbex Public  --insecure
