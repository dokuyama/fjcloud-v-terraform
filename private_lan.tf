#----------------------------------------------#
# Configure the Private LAN relative settings
#----------------------------------------------#
resource "nifcloud_private_lan" "priv_lan" {
    count = length(local.create_private_lan)

    accounting_type   = var.privlan_accounting_type
    availability_zone = local.create_private_lan[count.index]
    cidr_block        = "${local.priv_lan_cidr_blocks_prefix[count.index]}.0${var.priv_lan_cidr_block_suffix}"
    description       = null
    private_lan_name  = "${var.privlan_name_prefix}${upper(substr(local.create_private_lan[count.index], 0, 1))}${substr(local.create_private_lan[count.index], 1, 3)}${upper(substr(local.create_private_lan[count.index], 5, 2))}"
}

# Dedicated Private LAN require router(dhcp)
resource "nifcloud_router" "router" {
    count = length(local.create_private_lan)

    accounting_type            = var.rt_accounting_type
    availability_zone          = local.create_private_lan[count.index]
    description                = var.rt_description
    name                       = "${var.rt_name_prefix}${upper(substr(local.create_private_lan[count.index], 0, 1))}${substr(local.create_private_lan[count.index], 1, 3)}${upper(substr(local.create_private_lan[count.index], 5, 2))}"
    nat_table_id               = var.rt_nat_table_id
    route_table_id             = var.rt_route_table_id
    type                       = var.rt_type

    network_interface {
        dhcp            = false
        dhcp_config_id  = null
        dhcp_options_id = null
        ip_address      = null
        network_id      = "net-COMMON_GLOBAL"
        network_name    = null
    }
    network_interface {
        dhcp            = var.rt_priv_lan_dhcp
        dhcp_config_id  = var.rt_priv_lan_dhcp_config_id
        dhcp_options_id = var.rt_priv_lan_dhcp_options_id
        network_id      = nifcloud_private_lan.priv_lan[count.index].id
        network_name    = var.rt_priv_lan_network_name
    }

    # api error Client.Inoperable.Network.NoExistEnableDhcp: No enabled Dhcp exists on the network
    # response issue, sleep 30 secs.
    provisioner "local-exec" {
      command = "sleep 30"
    }

}


