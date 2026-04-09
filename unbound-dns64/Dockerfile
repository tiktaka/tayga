# Используем базовый образ Alpine
#FROM alpine:latest
FROM alpine:latest

# Устанавливаем переменные окружения
ENV \
    UNBOUND_VERBOSITY=1 \
    UNBOUND_DO_IP6=yes \
    UNBOUND_MODULE_CONFIG="dns64 validator iterator" \
    UNBOUND_DNS64_PREFIX="2001:db8:1:ffff::/96" \
    UNBOUND_DNS64_SYNTHALL=yes \
    UNBOUND_PREFETCH=no \
    UNBOUND_CACHE_MIN_TTL=3600 \
    UNBOUND_CACHE_MAX_TTL=86400 \
    UNBOUND_FORWARD_ADDR1="1.1.1.1" \
    UNBOUND_FORWARD_ADDR2="8.8.4.4"

# Устанавливаем unbound
RUN apk add --no-cache unbound

# Копируем скрипт входа
COPY docker-entry.sh /
RUN /bin/chmod +x /docker-entry.sh

# Открываем порты DNS
EXPOSE 53/tcp
EXPOSE 53/udp

# Запускаем скрипт входа
ENTRYPOINT ["/docker-entry.sh"]