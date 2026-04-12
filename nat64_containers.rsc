# PATHS
:global "containers_dir" "/nvme_usb/containers"

# BRIDGE settings
:global "bridge_name" "containers-bridge"
:global "bridge_address4" "172.17.0.1"
:global "bridge_mask4" "24"
:global "bridge_address6_prefix" "2001:db8:0:ffff::"
:global "bridge_address6" "2001:db8:0:ffff::1"
:global "bridge_mask6" "64"
:global "bridge_network4" "$"bridge_address4"/$"bridge_mask4""
:global "bridge_network6" "$"bridge_address6"/$"bridge_mask6""

# TAYGA settings
:global "tayga_veth_name" "veth-tayga"
:global "tayga_address4" "172.17.0.2"
:global "tayga_network4" "$"tayga_address4"/$"bridge_mask4""
:global "tayga_address6" "2001:db8:0:ffff::2"
:global "tayga_network6" "$"tayga_address6"/$"bridge_mask6""

# UNBOUND settings
:global "unbound_veth_name" "veth-unbound"
:global "unbound_address4" "172.17.0.3"
:global "unbound_network4" "$"unbound_address4"/$"bridge_mask4""
:global "unbound_address6" "2001:db8:0:ffff::3"
:global "unbound_network6" "$"unbound_address6"/$"bridge_mask6""

/interface veth
add address="$"tayga_network4",$"tayga_network6"" gateway=$"bridge_address4" gateway6=$"bridge_address6" name=$"tayga_veth_name"
add address="$"unbound_network4",$"unbound_network6"" gateway=$"bridge_address4" gateway6=$"bridge_address6" name=$"unbound_veth_name"

/interface bridge add name=$"bridge_name"
/interface bridge port add bridge=$"bridge_name" interface=$"tayga_veth_name"
/interface bridge port add bridge=$"bridge_name" interface=$"unbound_veth_name"

/ip address add address=$"bridge_network4" interface=$"bridge_name"

/ip route 
add disabled=no distance=1 dst-address=172.18.0.0/20 gateway=$"tayga_address4" routing-table=main scope=30 suppress-hw-offload=no target-scope=10

/ip firewall nat
add action=masquerade chain=srcnat src-address=172.18.0.0/20

/ipv6 address
add address=$"bridge_network6" advertise=no interface=$"bridge_name"

/ipv6 route 
add disabled=no dst-address=2001:db8:1:ffff::/96 gateway=$"tayga_address6" routing-table=main suppress-hw-offload=no

/container config
set registry-url=https://ghcr.io

/container
add envlists=tayga interface=$"tayga_veth_name" logging=yes name=tayga-nat64 workdir=/ remote-image=ghcr.io/tiktaka/tayga root-dir="$"containers_dir"/tayga/data"
add envlists=unbound interface=$"unbound_veth_name" logging=yes name=unbound-dns64 workdir=/ remote-image=ghcr.io/tiktaka/unbound-dns64 root-dir="$"containers_dir"/unbound-dns64/data"

/container envs
add key=TAYGA_CONF_IPV4_ADDR list=tayga value=172.18.20.1
add key=TAYGA_CONF_DYNAMIC_POOL list=tayga value=172.18.0.0/20
add key=TAYGA_CONF_PREFIX list=tayga value=2001:db8:1:ffff::/96

/container envs
add key=UNBOUND_CACHE_MAX_TTL list=unbound value=86400
add key=UNBOUND_CACHE_MIN_TTL list=unbound value=3600
add key=UNBOUND_DNS64_PREFIX list=unbound value=2001:db8:1:ffff::/96
add key=UNBOUND_DNS64_SYNTHALL list=unbound value=yes
add key=UNBOUND_DO_IP6 list=unbound value=yes
add key=UNBOUND_FORWARD_ADDR1 list=unbound value=8.8.8.8
add key=UNBOUND_FORWARD_ADDR2 list=unbound value=1.1.1.1
add key=UNBOUND_MODULE_CONFIG list=unbound value="dns64 validator iterator"