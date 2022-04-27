variable "db_vm_names" { type = list(string) }
variable "zones" { type = list(string) }
variable "subnetwork" { type = string }
variable "network_name" { type = string }
variable "app_name" { type = string }
variable "db-ip" { type = list(string) }
variable "machine_type" { type = string }
variable "region" { type = string }
variable "resource_group" { type = list(string) }
variable "lb_subnet_cidr" { type = string }
variable "lb_subnet_name" { type = string }
variable "lb_ip_name" { type = string }
variable "lb_ip" { type = string }
variable "lb_name" { type = string }
variable "lb_service_label" { type = string }
variable "backend_name" { type = string }
variable "health_check_name" { type = string }


  