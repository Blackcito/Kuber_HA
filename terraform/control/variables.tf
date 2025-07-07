variable "control_count"     { default = 3 }
variable "control_memory"    { default = 2048 }
variable "control_cpu"       { default = 2 }

variable "worker_count"      { default = 3 }
variable "worker_memory"     { default = 2048 }
variable "worker_cpu"        { default = 2 }

variable "proxy_count"      { default = 2 }      # Número de instancias proxy
variable "proxy_memory"     { default = 1024 }   # Memoria para proxies
variable "proxy_cpu"        { default = 1 }      # CPUs para proxies

variable "domain"            { default = "midominio.org" }
variable "diskSize"          { default = 25 }
variable "path_to_image"     { default = "/home/jose/vmstore/images" }

variable "network_configs_con" {
  type    = list(string)
  default = ["network_config_con1.cfg", "network_config_con2.cfg", "network_config_con3.cfg", "network_config_con4.cfg"]
}

variable "network_config_wo" {
  type    = list(string)
  default = ["network_config_wo1.cfg", "network_config_wo2.cfg","network_config_wo3.cfg"]
}

variable "network_config_px" {
  type    = list(string)
  default = ["network_config_px1.cfg", "network_config_px2.cfg"]
}