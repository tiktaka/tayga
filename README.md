# Tayga NAT64 Docker Container Build

This repository provides instructions on how to build multi-architecture Docker containers for Tayga (a NAT64 implementation).

## Building the Docker Container

The following steps outline how to build the Tayga Docker container images for different architectures (arm, arm64, amd64) using Docker Buildx and save them as tar files.

1.  Install Docker and Buildx plugins:
    ```bash
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ```
2.  List existing buildx builders:
    ```bash
    docker buildx ls
    ```
3.  Install QEMU emulators for multi-architecture builds (requires `--privileged`):
    ```bash
    docker run --privileged --rm tonistiigi/binfmt --install all
    ```
4.  Build the container image for ARM architecture (v7):
    ```bash
    docker buildx build --no-cache --platform arm --output=type=docker -t tayga-arm-2 .
    ```
    (Note: The '.' assumes your Dockerfile is in the current directory)
5.  Build the container image for ARM64 (aarch64):
    ```bash
    docker buildx build --no-cache --platform arm64 --output=type=docker -t tayga-arm64-2 .
    ```
6.  Build the container image for AMD64:
    ```bash
    docker buildx build --no-cache --platform amd64 --output=type=docker -t tayga-amd64-2 .
    ```
7.  Save the built images to tar files. These files can then be uploaded to your target device (like Mikrotik RouterOS).
    ```bash
    docker save tayga-arm-2 > /tmp/tayga-arm-2.tar
    docker save tayga-arm64-2 > /tmp/tayga-arm64-2.tar
    docker save tayga-amd64-2 > /tmp/tayga-amd64-2.tar
    ```
    Choose the appropriate tar file based on your target device's architecture.

8. Settings on MikroTik RouterOS
    ```RouterOS
        /interface veth
        add address=172.17.0.2/24,2001:db8:0:ffff::2/64 gateway=172.17.0.1 gateway6=2001:db8:0:ffff::1 name=veth1
        
        /interface bridge add name=containers
        /interface bridge port add bridge=containers interface=veth1
        /ip address add address=172.17.0.1/24 interface=containers network=172.17.0.0
        
        /container
        add envlist=tayga interface=veth1 logging=yes workdir=/ file=tayga-arm-1.tar
        /container envs
        add key=TAYGA_CONF_IPV4_ADDR list=tayga value=172.18.20.1
        add key=TAYGA_CONF_DYNAMIC_POOL list=tayga value=172.18.0.0/20
        add key=TAYGA_CONF_PREFIX list=tayga value=2001:db8:1:ffff::/96
        add key=TAYGA_IPV6_ADDR list=tayga value=2001:db8:0:ffff::2
        
        /ipv6 route 
        add disabled=no dst-address=2001:db8:1:ffff::/96 gateway=2001:db8:0:ffff::2 routing-table=main suppress-hw-offload=no
        
        /ipv6 address
        add address=2001:db8:0:ffff::1/64 advertise=no interface=containers
        
        /ip route 
        add disabled=no distance=1 dst-address=172.18.0.0/20 gateway=172.17.0.2 routing-table=main scope=30 suppress-hw-offload=no target-scope=10
        
        /ip firewall nat
        add action=masquerade chain=srcnat src-address=172.18.0.0/20
    ```

---

# Сборка Docker Контейнера Tayga NAT64

Этот репозиторий содержит инструкции по сборке Docker контейнеров для Tayga (реализация NAT64) для различных архитектур.

## Сборка Docker Контейнера

Следующие шаги описывают, как собрать образы Docker контейнера Tayga для различных архитектур (arm, arm64, amd64) с использованием Docker Buildx и сохранить их в tar-файлы.

1.  Установите Docker и плагины Buildx:
    ```bash
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ```
2.  Просмотрите существующие buildx билдеры:
    ```bash
    docker buildx ls
    ```
3.  Установите эмуляторы QEMU для сборки под разные архитектуры (требуется `--privileged`):
    ```bash
    docker run --privileged --rm tonistiigi/binfmt --install all
    ```
4.  Соберите образ контейнера для архитектуры ARM (v7):
    ```bash
    docker buildx build --no-cache --platform arm --output=type=docker -t tayga-arm-2 .
    ```
    (Примечание: '.' предполагает, что ваш Dockerfile находится в текущей директории)
5.  Соберите образ контейнера для ARM64 (aarch64):
    ```bash
    docker buildx build --no-cache --platform arm64 --output=type=docker -t tayga-arm64-2 .
    ```
6.  Соберите образ контейнера для AMD64:
    ```bash
    docker buildx build --no-cache --platform amd64 --output=type=docker -t tayga-amd64-2 .
    ```
7.  Сохраните собранные образы в tar-файлы. Эти файлы затем могут быть загружены на ваше целевое устройство (например, Mikrotik RouterOS).
    ```bash
    docker save tayga-arm-2 > /tmp/tayga-arm-2.tar
    docker save tayga-arm64-2 > /tmp/tayga-arm64-2.tar
    docker save tayga-amd64-2 > /tmp/tayga-amd64-2.tar
    ```
    Выберите подходящий tar-файл в зависимости от архитектуры вашего целевого устройства.

8. Настройка в MikroTik RouterOS
    ```RouterOS
        /interface veth
        add address=172.17.0.2/24,2001:db8:0:ffff::2/64 gateway=172.17.0.1 gateway6=2001:db8:0:ffff::1 name=veth1
        
        /interface bridge add name=containers
        /interface bridge port add bridge=containers interface=veth1
        /ip address add address=172.17.0.1/24 interface=containers network=172.17.0.0
        
        /container
        add envlist=tayga interface=veth1 logging=yes workdir=/ file=tayga-arm-1.tar
        /container envs
        add key=TAYGA_CONF_IPV4_ADDR list=tayga value=172.18.20.1
        add key=TAYGA_CONF_DYNAMIC_POOL list=tayga value=172.18.0.0/20
        add key=TAYGA_CONF_PREFIX list=tayga value=2001:db8:1:ffff::/96
        add key=TAYGA_IPV6_ADDR list=tayga value=2001:db8:0:ffff::2
        
        /ipv6 route 
        add disabled=no dst-address=2001:db8:1:ffff::/96 gateway=2001:db8:0:ffff::2 routing-table=main suppress-hw-offload=no
        
        /ipv6 address
        add address=2001:db8:0:ffff::1/64 advertise=no interface=containers
        
        /ip route 
        add disabled=no distance=1 dst-address=172.18.0.0/20 gateway=172.17.0.2 routing-table=main scope=30 suppress-hw-offload=no target-scope=10
        
        /ip firewall nat
        add action=masquerade chain=srcnat src-address=172.18.0.0/20
    ```

        
