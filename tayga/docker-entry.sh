#!/bin/sh

# eneble forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
# Create Tayga directories.
mkdir -p ${TAYGA_CONF_DATA_DIR} ${TAYGA_CONF_DIR}

# Configure Tayga
cat >${TAYGA_CONF_DIR}/tayga.conf <<EOF
tun-device nat64
ipv4-addr ${TAYGA_CONF_IPV4_ADDR}
prefix ${TAYGA_CONF_PREFIX}
dynamic-pool ${TAYGA_CONF_DYNAMIC_POOL}
data-dir ${TAYGA_CONF_DATA_DIR}
EOF

# Setup Tayga networking
tayga -c ${TAYGA_CONF_DIR}/tayga.conf --mktun
ip link add name nat64 type bridge
ip link set nat64 up
ip addr add  ${TAYGA_CONF_IPV4_ADDR} dev nat64
ip addr add ${TAYGA_CONF_PREFIX} dev nat64
ip route add ${TAYGA_CONF_DYNAMIC_POOL} dev nat64
ip route add ${TAYGA_CONF_PREFIX} dev nat64

# Run Tayga
tayga -c ${TAYGA_CONF_DIR}/tayga.conf -d
