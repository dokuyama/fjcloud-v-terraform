#----------------------------------------------#
# Configure FJcloud-V RDBresource
#----------------------------------------------#
# use Common Private LAN
resource "nifcloud_db_instance" "rdb_common_priv_lan" {
    count                   = var.create_rdb && !var.use_private_lan ? 1 : 0
    accounting_type         = var.rdb_accounting_type
    allocated_storage       = var.rdb_allocated_storage
    availability_zone       = var.rdb_availability_zone
    db_name                 = var.rdb_db_name
    db_security_group_name  = local.db_security_group_names[var.rdb_availability_zone]
    engine                  = var.rdb_engine
    engine_version          = var.rdb_engine_version
    port                    = var.rdb_port
    identifier              = var.rdb_identifier
    instance_class          = var.rdb_instance_class
    maintenance_window      = var.rdb_maintenance_window
    multi_az                = var.rdb_multi_az
    parameter_group_name    = var.rdb_parameter_group_name
    publicly_accessible     = var.rdb_publicly_accessible
    storage_type            = var.rdb_storage_type
    username                = var.rdb_username
    password                = var.rdb_password
    backup_retention_period = var.rdb_backup_retention_period
    backup_window           = "16:00-16:30"
    ca_cert_identifier      = "rdb-ca-2023"
    network_id              = local.db_network_id

    depends_on = [nifcloud_db_security_group.rdb]
}
# use Dedicated Private LAN
resource "nifcloud_db_instance" "rdb_dedicated_priv_lan" {
    count                   = var.create_rdb && var.use_private_lan ? 1 : 0
    accounting_type         = var.rdb_accounting_type
    allocated_storage       = var.rdb_allocated_storage
    availability_zone       = var.rdb_availability_zone
    db_name                 = var.rdb_db_name
    db_security_group_name  = local.db_security_group_names[var.rdb_availability_zone]
    engine                  = var.rdb_engine
    engine_version          = var.rdb_engine_version
    port                    = var.rdb_port
    identifier              = var.rdb_identifier
    instance_class          = var.rdb_instance_class
    maintenance_window      = var.rdb_maintenance_window
    multi_az                = var.rdb_multi_az
    parameter_group_name    = var.rdb_parameter_group_name
    publicly_accessible     = var.rdb_publicly_accessible
    storage_type            = var.rdb_storage_type
    username                = var.rdb_username
    password                = var.rdb_password
    backup_retention_period = var.rdb_backup_retention_period
    backup_window           = "16:00-16:30"
    ca_cert_identifier      = "rdb-ca-2023"
    network_id              = local.db_network_id
    virtual_private_address = "${local.rdb_virtual_private_address}${var.priv_lan_cidr_block_suffix}"
    master_private_address  = "${local.rdb_master_private_address}${var.priv_lan_cidr_block_suffix}"
    slave_private_address   = "${local.rdb_slave_private_address}${var.priv_lan_cidr_block_suffix}"

    depends_on = [nifcloud_db_security_group.rdb]
}

resource "nifcloud_db_parameter_group" "rdb" {
  count       = var.create_rdb ? 1 : 0
  description = var.rdb_pg_description
  family      = var.rdb_pg_family
  name        = var.rdb_pg_name

  dynamic "parameter" {
    for_each = var.rdb_pg_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}

# security group名にはazを付ける
# DBの接続は、Computeに付与したsgのメンバーから許可される
resource "nifcloud_db_security_group" "rdb" {
  for_each          = var.create_rdb ? local.az_transformed : {}
  availability_zone = var.az[each.key]
  description       = null
  # DB SG must be lower case only...
  group_name        = lower("${var.rdb_sg_group_name_prefix}${each.value}")

  rule {
    cidr_ip             = null
    security_group_name = "${var.compute_name_prefix}Sg${each.value}"
  }
  dynamic "rule" {
    for_each = local.cidr_blocks
    content {
      cidr_ip = rule.value
    }
  }

  # api error Client.InvalidParameterNotFound.DBSecurityGroup: DBSecurityGroup not found
  # 404 response issue, sleep 30 secs.
  provisioner "local-exec" {
    command = "sleep 30"
  }
}


