#!/bin/sh

# Создаем конфигурационный файл unbound
cat > /etc/unbound/unbound.conf <<EOF
server:
    verbosity: ${UNBOUND_VERBOSITY}
    interface: ::0
    interface: 0.0.0.0
    access-control: 0.0.0.0/0 allow
    access-control: ::0/0 allow
    do-ip6: ${UNBOUND_DO_IP6}
    module-config: "${UNBOUND_MODULE_CONFIG}"
    dns64-prefix: ${UNBOUND_DNS64_PREFIX}
    dns64-synthall: ${UNBOUND_DNS64_SYNTHALL}
    prefetch: ${UNBOUND_PREFETCH}
    cache-min-ttl: ${UNBOUND_CACHE_MIN_TTL}
    cache-max-ttl: ${UNBOUND_CACHE_MAX_TTL}

forward-zone:
    name: "."
    forward-addr: ${UNBOUND_FORWARD_ADDR1}
    forward-addr: ${UNBOUND_FORWARD_ADDR2}
EOF

# Проверяем конфигурацию
unbound-checkconf /etc/unbound/unbound.conf

# Запускаем unbound в foreground режиме
exec unbound -d