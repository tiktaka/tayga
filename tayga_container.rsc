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