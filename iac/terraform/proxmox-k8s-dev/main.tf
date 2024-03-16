terraform {
  required_version = "~> 1.6"

  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc1"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://proxmox0.local:8006/api2/json"
  pm_tls_insecure = true
}

locals {
  vm_template  = "alma8-cloudinit"
  storage_name = "ceph"
}

module "k8s_cluster" {
  source  = "gitlab.com/devops9483002/proxmox-kubernetes-cluster/proxmox"
  version = "0.5.0"

  # General
  cluster_name     = "devops-toolkit-dev"
  qemu_agent       = true
  os_type          = "cloud-init"
  cloudinit_user   = "devops"
  cloudinit_sshkey = file("~/.ssh/id_rsa.pub")
  cloudinit_cdrom  = "ceph"
  hastate          = "started"
  ipconfig0_cidr   = "24"
  ipconfig0_gw     = "192.168.1.1"
  nameserver       = "192.168.1.1"

  # Master
  master_vm_template = local.vm_template
  master_sockets     = 2
  master_cores       = 6
  master_memory      = 8192
  master_disk_size   = 100

  master_mapping = [
    {
      node         = "proxmox1"
      storage_name = local.storage_name
      hagroup      = "Prio1"
      ipconfig0_ip = "192.168.1.80"
    }
  ]

  # Worker
  worker_vm_template = local.vm_template
  worker_sockets     = 2
  worker_cores       = 12
  worker_memory      = 32768
  worker_disk_size   = 250

  worker_mapping = [
    {
      node         = "proxmox1"
      storage_name = local.storage_name
      hagroup      = "Prio1"
      ipconfig0_ip = "192.168.1.81"
    },
    {
      node         = "proxmox2"
      storage_name = local.storage_name
      hagroup      = "Prio2"
      ipconfig0_ip = "192.168.1.82"
    },
    {
      node         = "proxmox3"
      storage_name = local.storage_name
      hagroup      = "Prio3"
      ipconfig0_ip = "192.168.1.83"
    }
  ]
}
