// vSphere Variables

vsphere_endpoint            = "192.168.1.4"
vsphere_insecure_connection = true
vsphere_datacenter          = "Datacenter"
vsphere_cluster             = "cluster-01"
vsphere_network             = "VM Network"
vsphere_host                = "esxi1.local"
vsphere_datastore           = "host1_datastore1"
vsphere_folder_path         = "Templates"
convert_to_template         = true

// Virtual Machine Variables

vm_name              = "k8s-dev-alma8"
vm_username          = "ansible"
private_ssh_key_path = "~/.ssh/id_rsa"
public_ssh_key_path  = "~/.ssh/id_rsa.pub"
vm_cpu               = 2     # Optional
vm_ram               = 2048  # Optional
vm_disk_size         = 20480 # Optional
