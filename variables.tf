#----------------------------------------------#
# Configure the FJcloud-V Provider
#----------------------------------------------#
variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "jp-east-1"
}
variable "keypair_name" {
  default = "terraformkey"
  description = "length 6-32, alphabet only"
}
variable "public_key" {}

variable "az" {
  default = {
    "0" = "east-11"
  }
}

#----------------------------------------------#
# Configure FJcloud-V Compute resource
#----------------------------------------------#
variable "compute_name_prefix" {}
variable "compute_instance_number" {
  default = 1
}
variable "compute_instance_type" {
  default = "e2-mini"
}
variable "compute_accounting_type" {
  default = "2"
  description = "1 = par month, 2 = par hour"
}
variable "os_image_name" {}
variable "compute_security_group_rules" {
  default = [
    { name      = "PASS_ANY", from_port = 0, protocol  = "ANY", cidr_ip   = "0.0.0.0/0" }
  ]
}

#----------------------------------------------#
# Configure FJcloud-V LoadBalancer resource
#----------------------------------------------#
variable "create_l4_loadbalancer" {
  default = false
}
variable "ssl_certificate" {}
variable "ssl_key" {}
variable "ssl_ca" {}
variable "ssl_description" {}

variable "l4lb_accounting_type" {
  default = "2"
  description = "1 = par month, 2 = par hour"
}
variable "l4lb_balancing_type" {
  default = 1
  description = "1 = RoundRobin, 2 LeastConn"
}
variable "l4lb_instance_port" {}
variable "l4lb_ip_version" {
  default = "v4"
}
variable "l4lb_load_balancer_name" {}
variable "l4lb_load_balancer_port" {}
variable "l4lb_network_volume" {
  default = 10
}
variable "l4lb_session_stickiness_policy_enable" {
  default = true
}
variable "l4lb_session_stickiness_policy_expiration_period" {
  default = 10
  description = "stickiness_policy_expiration_period : minutes"
}
variable "l4lb_health_check_interval" {
  default = 5
}
variable "l4lb_health_check_target" {}
variable "l4lb_healthy_threshold" {
  default = 1
}
variable "l4lb_unhealthy_threshold" {
  default = 3
}
variable "l4lb_sorry_page_enable" { 
  default = true
}
variable "l4lbssl_load_balancer_port" {}


#----------------------------------------------#
# Configure FJcloud-V RDB resource
#----------------------------------------------#
variable "create_rdb" {
  default = false
}
variable "rdb_accounting_type" {
  default = "2"
  description = "1 = par month, 2 = par hour"
}
variable "rdb_allocated_storage" {
  default = 50
}
variable "rdb_availability_zone" {
  default = "east-11"
}
variable "rdb_db_name" {}
variable "rdb_engine" {}
variable "rdb_engine_version" {}
variable "rdb_port" {}
variable "rdb_identifier" {}
variable "rdb_instance_class" {
  default = "db.e-small"
}
variable "rdb_maintenance_window" {
  default = "mon:17:00-mon:17:30"
}
variable "rdb_multi_az" {
  default = false
}
variable "rdb_parameter_group_name" {}
variable "rdb_publicly_accessible" {
  default = false
}
variable "rdb_storage_type" {
  default = 2
  description = "0 (High-Speed Storage), 1 (Flash Drive), 2 (Standard Flash Storage), or 3 (High-Speed Flash Storage). The default is 0"
}
variable "rdb_username" {}
variable "rdb_password" {}
variable "rdb_backup_retention_period" {
  default = 3
}
variable "rdb_backup_window" {
  default = "16:00-16:30"
}
# RDB Parameter Group
variable "rdb_pg_description" {
  default = null
}
variable "rdb_pg_family" {}
variable "rdb_pg_name" {}
variable "rdb_pg_parameters" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}
# RDB Security Group
variable "rdb_sg_group_name_prefix" {}
variable "rdb_private_addr_suffix" {
  default = ""
}

#----------------------------------------------#
# Configure the Private LAN relative settings
#----------------------------------------------#
variable "use_private_lan" {
  default = false
}
variable "privlan_accounting_type" {
  default = 2
  description = "1 = par month, 2 = par hour"
}
variable "privlan_description" {
  default = null
}
variable "privlan_name_prefix" {}
variable "priv_lan_cidr_block_suffix" {
  default = "/24"
}

variable "use_private_bridge" {
  default = false
}
variable "priv_lan_common_cidr_block_prefix" {
  default = "10.20.0"
}

variable "use_private_router" {
  default = false
}
variable "rt_accounting_type" {
  default = 2
  description = "1 = par month, 2 = par hour"
}
variable "rt_description" {
  default = null
}
variable "rt_name_prefix" {}
variable "rt_nat_table_id" {
  default = null
}
variable "rt_route_table_id" {
  default = null
}
variable "rt_type" {
  default = "small"
}
variable "rt_priv_lan_dhcp" {
  default = true
}
variable "rt_priv_lan_dhcp_config_id" {
  default = null
}
variable "rt_priv_lan_dhcp_options_id" {
  default = null
}
variable "rt_priv_lan_network_name" {
  default = null
}
#variable "" {}


