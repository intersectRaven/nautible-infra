module "vnet" {
  source                  = "./modules/vnet"
  pjname                  = var.pjname
  location                = var.location
  vnet_cidr               = var.vnet.vnet_cidr
  subnet_cidrs            = var.vnet.subnet_cidrs
  subnet_names            = var.vnet.subnet_names
  inbound_http_port_range = var.vnet.inbound_http_port_range
}

module "app" {
  source   = "./modules/app"
  pjname   = var.pjname
  location = var.location
}

# インターネット公開申請するまで、外部公開しない
# module "static_web" {
#   source                        = "./modules/staticweb"
#   pjname                        = var.pjname
#   location                      = var.location
#   static_web_index_document     = var.static_web.index_document
#   static_web_error_404_document = var.static_web.error_404_document
# }

module "acr" {
  source   = "./modules/acr"
  pjname   = var.pjname
  location = var.location
}

module "aks" {
  source                                        = "./modules/aks"
  pjname                                        = var.pjname
  location                                      = var.location
  vnet_subnet_id                                = module.vnet.subnet_ids[0]
  aci_subnet_id                                 = module.vnet.subnet_ids[1]
  aci_subnet_name                               = var.vnet.subnet_names[1]
  aks_kubernetes_version                        = var.aks.kubernetes_version
  aks_node_vm_size                              = var.aks.node.vm_size
  aks_node_os_disk_size_gb                      = var.aks.node.os_disk_size_gb
  aks_node_max_count                            = var.aks.node.max_count
  aks_node_min_count                            = var.aks.node.min_count
  aks_node_count                                = var.aks.node.node_count
  aks_node_availability_zones                   = var.aks.node.availability_zones
  aks_max_pods                                  = var.aks.max_pods
  aks_log_analytics_workspace_retention_in_days = var.aks.log_analytics_workspace_retention_in_days
  acr_id                                        = module.acr.acr_id
}

# インターネット公開申請するまで、外部公開しない
# module "front_door" {
#   source                              = "./modules/frontdoor"
#   pjname                              = var.pjname
#   location                            = var.location
#   front_door_session_affinity_enabled = var.frontdoor.session_affinity_enabled
#   static_web_primary_web_host         = module.static_web.static_web_primary_web_host
#   istio_ig_lb_ip                      = var.frontdoor.istio_ig_lb_ip
#   service_api_path_pattern            = var.frontdoor.service_api_path_pattern
# }

module "dns" {
  source                        = "./modules/dns"
  pjname                        = var.pjname
  location                      = var.location
  vnet_id                       = module.vnet.vnet_id
  privatelink_keyvault_enable   = var.dns.privatelink_keyvault_enable
  privatelink_cosmosdb_enable   = var.dns.privatelink_cosmosdb_enable
  privatelink_servicebus_enable = var.dns.privatelink_servicebus_enable
  privatelink_redis_enable      = var.dns.privatelink_redis_enable
}