variable "pjname" {}
variable "region" {}
variable "cloudfront_origin_dns_name" {
  default = ""
}
variable "service_api_path_pattern" {}
variable "vpc_cidr" {}
variable "private_subnet_cidrs" {}
variable "public_subnet_cidrs" {}
variable "nat_instance_type" {}
variable "create_iam_resources" {}
variable "eks_cluster_version" {}
variable "eks_ng_desired_size" {}
variable "eks_ng_max_size" {}
variable "eks_ng_min_size" {}
variable "eks_ng_instance_type" {}
variable "eks_default_ami_type" {}
variable "eks_default_disk_size" {}
variable "eks_cluster_endpoint_private_access" {}
variable "eks_cluster_endpoint_public_access" {}
variable "eks_cluster_endpoint_public_access_cidrs" {}
variable "eks_fargate_selectors" {}
variable "eks_cluster_addons_coredns_version" {}
variable "eks_cluster_addons_vpc_cni_version" {}
variable "eks_cluster_addons_kube_proxy_version" {}
variable "eks_albc_security_group_cloudfront_prefix_list_id" {}
variable "oidc" {}
