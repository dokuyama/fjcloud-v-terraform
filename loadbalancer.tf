#----------------------------------------------#
# Configure FJcloud-V LoadBalancer resource
#----------------------------------------------#

# Upload SSL Certificate
resource "nifcloud_ssl_certificate" "ssl_certificate" {
  count       = var.create_l4_loadbalancer ? 1 : 0
  certificate = file("${var.ssl_certificate}")
  key         = file("${var.ssl_key}")
  # ca          = file("${var.ssl_ca}")
  description = "${var.ssl_description}"
}

# Loadbalancer (L4) Settings
resource "nifcloud_load_balancer" "l4lb" {
  count                                     = var.create_l4_loadbalancer ? 1 : 0
  accounting_type                             = var.l4lb_accounting_type
  balancing_type                              = var.l4lb_balancing_type
  instance_port                               = var.l4lb_instance_port
  instances                                   = nifcloud_instance.compute[*].id
  ip_version                                  = var.l4lb_ip_version
  load_balancer_name                          = var.l4lb_load_balancer_name
  load_balancer_port                          = var.l4lb_load_balancer_port
  # Traffic Mbps
  network_volume                              = var.l4lb_network_volume
  session_stickiness_policy_enable            = var.l4lb_session_stickiness_policy_enable
  # cookie sticky session expiretion period (minutes)
  session_stickiness_policy_expiration_period = var.l4lb_session_stickiness_policy_expiration_period
  # SSL offload
  ssl_certificate_id                          = null
  # 暗号化タイプ
  policy_type                                 = "standard"
  # Health Check Settings
  health_check_interval                       = var.l4lb_health_check_interval
  health_check_target                         = var.l4lb_health_check_target
  healthy_threshold                           = var.l4lb_healthy_threshold
  unhealthy_threshold                         = var.l4lb_unhealthy_threshold
  # ACL
  # Example: 
  #filter                                      = [
  #    "203.179.84.176/29",
  #    "218.219.153.168/29",
  #    "218.41.230.87",
  #]
  filter                                      = []
  # filter_type: 1 = allow, 2 = deny
  filter_type                                 = "1"
  sorry_page_enable                           = var.l4lb_sorry_page_enable
  sorry_page_status_code                      = 200

  # api error Client.InvalidParameterNotFound.LoadBalancer: The LoadBalancerName 'testlb' does not exist
  # response issue, sleep 30 secs.
  provisioner "local-exec" {
    command = "sleep 30"
  }
}

# HTTPS (SSL Accelleration) Setting
resource "nifcloud_load_balancer_listener" "l4lb" {
  count                 = var.create_l4_loadbalancer ? 1 : 0
  balancing_type        = var.l4lb_balancing_type
  filter                = []
  filter_type           = "1"
  health_check_interval = var.l4lb_health_check_interval
  health_check_target   = var.l4lb_health_check_target
  healthy_threshold     = var.l4lb_healthy_threshold
  unhealthy_threshold   = var.l4lb_unhealthy_threshold
  instance_port         = var.l4lb_instance_port
  instances             = nifcloud_instance.compute[*].id
  load_balancer_name    = var.l4lb_load_balancer_name
  load_balancer_port    = var.l4lbssl_load_balancer_port
  policy_type           = "standard"
  ssl_certificate_id    = nifcloud_ssl_certificate.ssl_certificate[0].id
  depends_on            = [nifcloud_load_balancer.l4lb]
}

