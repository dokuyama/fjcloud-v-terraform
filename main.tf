#----------------------------------------------#
# Configure the FJcloud-V Provider
#----------------------------------------------#
terraform {
  required_providers {
    nifcloud = {
      source = "nifcloud/nifcloud"
    }
  }
}

provider "nifcloud" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
}

#----------------------------------------------#
# Configure the Common Services
#----------------------------------------------#
data "nifcloud_image" "os_image" {
  image_name = var.os_image_name
}

resource "nifcloud_key_pair" "tfkey" {
  key_name   = var.keypair_name
  public_key = var.public_key
}

# az の文字列から命名に利用する文字列を作成
locals {
  az_transformed = {
    for key, value in var.az :
    key => join("", [
      substr(upper(replace(value, "-", "")), 0, 1),     // 最初の文字を大文字に変換
      substr(replace(value, "-", ""), 1, 3),            // 次の3文字をそのまま取得
      upper(substr(replace(value, "-", ""), 4, 1)),     // 4文字目を大文字に変換
      substr(replace(value, "-", ""), 5, length(replace(value, "-", "")) - 5)  // 残りの文字をそのまま取得
    ])
  }

  # Create a list of availability zones to be used
  create_private_lan = var.use_private_lan ? var.az : {}

  # Create a list of Private LAN CIDR blocks
  cidr_blocks = var.use_private_lan ? (var.use_private_bridge ? ["${var.priv_lan_common_cidr_block_prefix}.0/24"] : [
    for i, az in var.az :
    "10.${substr(az, 5, 2)}.0.0/24"
  ]) : []

  # set valiable for Web Server Network Interface(Private LAN)
  network_ids = [
    for i in range(var.compute_instance_number) :
    var.use_private_lan ? nifcloud_private_lan.priv_lan[i % length(local.create_private_lan)].id : "net-COMMON_PRIVATE"
  ]
  compute_ip_addresses = [
    for i in range(var.compute_instance_number) :
    var.use_private_lan ? (var.use_private_bridge ? "${var.priv_lan_common_cidr_block_prefix}.${10 + i + 1}" : "10.${substr(var.az[i % length(var.az)], 5, 2)}.0.${10 + i + 1}") : null
  ]

  # Private IP Addr CIDR Prefix
  # if var.use_private_bridge defined, use priv_lan_common_cidr_block_prefix
  priv_lan_cidr_blocks_prefix = {
    for i, az in var.az :
    i => var.use_private_bridge ? var.priv_lan_common_cidr_block_prefix : "10.${substr(az, 5, 2)}.0"
  }

  # RDB relative
  db_security_group_names = {
    for key, value in var.az :
    value => lower("${var.rdb_sg_group_name_prefix}${replace(upper(substr(value, 0, 1)), "-", "")}${replace(substr(value, 1, length(value) - 1), "-", "")}")
  }

  db_network_id = var.use_private_lan ? nifcloud_private_lan.priv_lan[0].id : null

  rdb_virtual_private_address = var.use_private_lan ? (var.use_private_bridge ? "${var.priv_lan_common_cidr_block_prefix}.${var.rdb_private_addr_suffix}" : "10.${substr(var.rdb_availability_zone, 5, 2)}.0.${var.rdb_private_addr_suffix}") : null
  rdb_master_private_address = var.use_private_lan ? (var.use_private_bridge ? "${var.priv_lan_common_cidr_block_prefix}.${var.rdb_private_addr_suffix + 1}" : "10.${substr(var.rdb_availability_zone, 5, 2)}.0.${var.rdb_private_addr_suffix + 1}") : null
  rdb_slave_private_address = var.use_private_lan ? (var.use_private_bridge ? "${var.priv_lan_common_cidr_block_prefix}.${var.rdb_private_addr_suffix + 2}" : "10.${substr(var.rdb_availability_zone, 5, 2)}.0.${var.rdb_private_addr_suffix + 2}") : null

}

