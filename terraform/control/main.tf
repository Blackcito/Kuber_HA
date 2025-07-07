# 1. IMAGEN BASE
resource "libvirt_volume" "jammy_base" {
  name   = "jammy-base"
  pool   = "pool"
  source = "${var.path_to_image}/jammy-server-cloudimg-amd64.img"
  format = "qcow2"
}

# 2. CONFIGURACIÓN DINÁMICA
locals {
  nodes = [
    { role = "control", count = var.control_count },
    { role = "worker",  count = var.worker_count },
    { role = "proxy",   count = var.proxy_count }   # Nuevo rol
  ]

  vm_list = flatten([
    for node in local.nodes : [
      for i in range(node.count) : {
        role  = node.role
        index = i + 1
      }
    ]
  ])

  vms = {
    for vm in local.vm_list : "${vm.role}-${vm.index}" => vm
  }

  network_paths = {
    for key, vm in local.vms :
    key => "${path.module}/config/${
      vm.role == "control" ? var.network_configs_con[vm.index - 1] : 
      vm.role == "worker"  ? var.network_config_wo[vm.index - 1] : 
      var.network_config_px[vm.index - 1]  # Nueva configuración para proxy
    }"
  }

  network_rendered = {
    for key, p in local.network_paths :
    key => templatefile(p, {
      hostname = key
      role     = local.vms[key].role
      index    = local.vms[key].index
      domain   = var.domain
    })
  }
}

# 3. VOLUMENES OS IMAGE
resource "libvirt_volume" "os_image" {
  for_each = local.vms
  name           = "${each.key}-os_image"
  pool           = "pool"
  base_volume_id = libvirt_volume.jammy_base.id
  format         = "qcow2"
}

# 4. REDIMENSIONAMIENTO
resource "null_resource" "resize_volume" {
  for_each   = local.vms
  depends_on = [libvirt_volume.os_image]
  provisioner "local-exec" {
    command = "sudo qemu-img resize ${libvirt_volume.os_image[each.key].id} ${var.diskSize}G"
  }
}

# 5. USER DATA
data "template_file" "user_data" {
  for_each = local.vms
  template = file("${path.module}/config/cloud_init.cfg")
  vars = {
    hostname   = each.key
    fqdn       = "${each.key}.${var.domain}"
    public_key = file("~/.ssh/id_ed25519.pub")
  }
}

data "template_cloudinit_config" "config" {
  for_each       = local.vms
  gzip           = false
  base64_encode  = false

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.user_data[each.key].rendered
  }
}

# 6. CLOUD-INIT DISK
resource "libvirt_cloudinit_disk" "commoninit" {
  for_each       = local.vms
  name           = "${each.key}-commoninit.iso"
  pool           = "pool"
  user_data      = data.template_cloudinit_config.config[each.key].rendered
  network_config = local.network_rendered[each.key]
}

# 7. VOLUMENES LONGHORN
resource "libvirt_volume" "longhorn1" {
  for_each = { for k, v in local.vms : k => v if v.role != "proxy" }
  name     = "${each.key}-longhorn1"
  pool     = "pool"
  format   = "qcow2"
  size     = 30 * 1024 * 1024 * 1024
}
resource "libvirt_volume" "longhorn2" {
  for_each = { for k, v in local.vms : k => v if v.role != "proxy" }
  name     = "${each.key}-longhorn2"
  pool     = "pool"
  format   = "qcow2"
  size     = 30 * 1024 * 1024 * 1024
}

# 8. DOMINIOS (VMs)
resource "libvirt_domain" "node" {
  for_each = local.vms

  name   = each.key
  memory = each.value.role == "control" ? var.control_memory : each.value.role == "worker"  ? var.worker_memory : var.proxy_memory
  vcpu   = each.value.role == "control" ? var.control_cpu : each.value.role == "worker"  ? var.worker_cpu : var.proxy_cpu

  # Disco OS (obligatorio para todas)
  disk { volume_id = libvirt_volume.os_image[each.key].id }

  # Discos Longhorn SOLO para control y worker
  dynamic "disk" {
    for_each = each.value.role != "proxy" ? [1] : []
    content {
      volume_id = libvirt_volume.longhorn1[each.key].id
    }
  }
  dynamic "disk" {
    for_each = each.value.role != "proxy" ? [1] : []
    content {
      volume_id = libvirt_volume.longhorn2[each.key].id
    }
  }

  network_interface { network_name = "manage" }
  network_interface { network_name = "netstack" }

  cloudinit = libvirt_cloudinit_disk.commoninit[each.key].id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}
