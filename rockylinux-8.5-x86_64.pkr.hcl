variable "build_directory" {
  default = "./build"
}

variable "script_directory" {
  default = "./scripts"
}

variable "boot_wait" {
  default = "5s"
}

variable "cpus" {
  default = 2
}

variable "disk_size" {
  default = 12288
}

variable "headless" {
  default = true
}

variable "http_directory" {
  default = "./http"
}

variable "iso_url" {
  type = string
  default = "https://download.rockylinux.org/pub/rocky/8.5/isos/x86_64/Rocky-8.5-x86_64-dvd1.iso"
}

variable "iso_checksum" {
  type = string
  default = "0081f8b969d0cef426530f6d618b962c7a01e71eb12a40581a83241f22dfdc25"
}

variable "kickstart_file" {
  type = string
  default = "ks.cfg"
}

variable "memory" {
  default = 1024
}

variable "username" {
  default = "vagrant"
}

variable "provider_name" {
  default = "virtualbox"
}

variable "ssh_timeout" {
  default = "60m"
}

source "virtualbox-iso" "vagrant" {

  vm_name = "rockylinux-8.5-x86_64"

  boot_command = [
    "<up><tab><wait>",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.kickstart_file}<enter><wait>",
  ]
  boot_wait            = var.boot_wait
  cpus                 = var.cpus
  memory               = var.memory
  disk_size            = var.disk_size
  guest_additions_path = "VBoxGuestAdditions_{{.Version}}.iso"
  guest_additions_url  = ""
  guest_os_type        = "RedHat_64"
  hard_drive_interface = "sata"
  headless             = var.headless
  http_directory       = var.http_directory
  iso_url              = var.iso_url
  iso_checksum         = var.iso_checksum
  output_directory     = "${var.build_directory}/packer-rockylinux-8.5-x86_64-virtualbox"
  shutdown_command     = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_port             = "22"
  ssh_timeout          = var.ssh_timeout
  ssh_username         = var.username
  ssh_password         = var.username
  virtualbox_version_file = ".vbox_version"

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--vrde", "off"],
    ["modifyvm", "{{.Name}}", "--graphicscontroller", "vmsvga"],
    ["modifyvm", "{{.Name}}", "--vram", "128"],
    ["modifyvm", "{{.Name}}", "--accelerate3d", "off"],
    ["modifyvm", "{{.Name}}", "--usb", "on"],
    ["modifyvm", "{{.Name}}", "--audio", "none"],
    ["modifyvm", "{{.Name}}", "--nictype1", "82540EM"],
    ["modifyvm", "{{.Name}}", "--nictype2", "82540EM"],
	  ["modifyvm", "{{.Name}}", "--nic1", "nat"],
	  ["modifyvm", "{{.Name}}", "--natnet1", "default"],
  	["modifyvm", "{{.Name}}", "--nic2", "hostonly"],
    ["modifyvm", "{{.Name}}", "--cableconnected2", "off"],
    ["modifyvm", "{{.Name}}", "--hostonlyadapter2", "vboxnet0"]
  ]

}

build {
  sources = ["sources.virtualbox-iso.vagrant"]

  provisioner "shell" {
    environment_vars = [
      "HOME_DIR=/home/vagrant",
    ]
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
    expect_disconnect =  true
    scripts = [
      "${var.script_directory}/kernel.sh",
      "${var.script_directory}/sshd.sh",
      "${var.script_directory}/networking.sh",
      "${var.script_directory}/vagrant.sh",
      "${var.script_directory}/virtualbox.sh",
      "${var.script_directory}/puppet.sh",
      "${var.script_directory}/cleanup.sh",
      "${var.script_directory}/minimize.sh"
    ]
  }
  post-processors {  
    post-processor "vagrant" {
      output = "${var.build_directory}/rockylinux-8.5.{{.Provider}}.box"
      provider_override   = "virtualbox"
    }

    post-processor "checksum" {
      checksum_types = ["sha256"]
      output = "${var.build_directory}/rockylinux-8.5-virtualbox.box.checksum"
    }
  }

}
