#----------------------------------------------#
# Configure FJcloud-V Compute resource
#----------------------------------------------#

# Compute Instance
resource "nifcloud_instance" "compute" {
  count             = var.compute_instance_number
  instance_id       = "${format("${var.compute_name_prefix}%02d", count.index + 1)}"
  image_id          = data.nifcloud_image.os_image.id
  key_name          = nifcloud_key_pair.tfkey.key_name
  security_group    = nifcloud_security_group.compute[tostring(count.index % length(var.az))].group_name
  instance_type     = var.compute_instance_type
  accounting_type   = var.compute_accounting_type

  # azの数を確認して、動作を分岐する
  availability_zone = length(var.az) > 1 ? lookup(var.az, count.index % length(var.az)) : lookup(var.az, "0")

  network_interface {
    network_id = "net-COMMON_GLOBAL"
  }

  network_interface {
    network_id = local.network_ids[count.index]
    ip_address = var.use_private_lan ? local.compute_ip_addresses[count.index] : null
  }
  depends_on = [null_resource.compute_dependency]
}

# Dummy resource for compute_dependecy for Private LAN DHCP issue:
# api error Client.Inoperable.Network.NoExistEnableDhcp: No enabled Dhcp exists on the network
resource "null_resource" "compute_dependency" {
  count = var.use_private_lan ? 1 : 0
  depends_on = [nifcloud_router.router]
}

# Compute Security Group
resource "nifcloud_security_group" "compute" {
  for_each          = local.az_transformed
  # security group名にはazを付ける
  group_name        = "${var.compute_name_prefix}Sg${each.value}"
  availability_zone = var.az[each.key]

  # failed reading: operation error computing: DescribeSecurityGroups, http: ContentLength=242 with Body length 0
  # response issue, sleep 30 secs.
  provisioner "local-exec" {
    command = "sleep 30"
  }
}

# Security Group rule: ルール自体は varsファイルで定義する
# 定義したルールを変換する。
locals {
  sg_rules = flatten([
    for sg_key, sg in nifcloud_security_group.compute : [
      for rule in var.compute_security_group_rules : {
        key = "${sg_key}-${rule.name}"
       value = {
          sg_name = sg.group_name
          from_port = rule.from_port
          to_port = rule.from_port
          protocol = rule.protocol
          cidr_ip = rule.cidr_ip
        }
      }
    ]
  ])
}
resource "nifcloud_security_group_rule" "rules" {
  for_each = { for rule in local.sg_rules : rule.key => rule.value }

  security_group_names = [each.value.sg_name]
  type                 = "IN"
  from_port            = each.value.from_port
  to_port              = each.value.from_port
  protocol             = each.value.protocol
  cidr_ip              = each.value.cidr_ip
  depends_on           = [nifcloud_security_group.compute]
}


