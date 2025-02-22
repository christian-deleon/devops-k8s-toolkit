terraform {
  required_version = "~> 1.6"

  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.5.1"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
    }
  }
}

provider "vsphere" {
  vsphere_server       = "vcenter.lan"
  allow_unverified_ssl = true
  user                 = var.vsphere_username
  password             = var.vsphere_password
}

locals {
  vm_template = "k8s-dev-alma8"
}

module "k8s_cluster" {
  source  = "gitlab.com/devops9483002/vmware-kubernetes-cluster/vmware"
  version = "~> 1.2.2"

  datacenter      = "Datacenter"
  compute_cluster = "cluster-01"
  network         = "VM Network"
  create_folder   = true
  folder_path     = "K8s-Development"
  cluster_name    = "k8s-dev"

  # Master
  master_vm_template = local.vm_template
  master_cores       = 6
  master_memory      = 8192
  master_disk_size   = 100

  master_mapping = [
    {
      host      = "esxi1.lan"
      datastore = "host1_datastore1"
    },
    {
      host      = "esxi2.lan"
      datastore = "host2_datastore1"
    },
    {
      host      = "esxi3.lan"
      datastore = "host3_datastore1"
    }
  ]

  # Worker
  worker_vm_template = local.vm_template
  worker_cores       = 8
  worker_memory      = 16384
  worker_disk_size   = 250

  worker_mapping = [
    {
      host      = "esxi1.lan"
      datastore = "host1_datastore1"
    },
    {
      host      = "esxi2.lan"
      datastore = "host2_datastore1"
    },
    {
      host      = "esxi3.lan"
      datastore = "host3_datastore1"
    }
  ]
}
