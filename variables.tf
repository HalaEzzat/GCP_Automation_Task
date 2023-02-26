variable "ssh_public_key_path" {
  type    = string
}
variable "ssh_user" {
  type    = string
}
variable "projectID" {
  type    = string
}

variable "region" {
  type    = string
}

variable "vmType" {
  type    = string
  default = "e2-micro"
}

variable "imageName" {
  type    = string
  default = "ubuntu-os-cloud/ubuntu-2004-lts"
}

variable "ssh_private_key_path" {
  type    = string
}

variable "pcap_file_name" {
  type    = string
  default = "smallFlows.pcap"
}

variable "pcap_file_url" {
  type    = string
  default = "https://s3.amazonaws.com/tcpreplay-pcap-files/smallFlows.pcap"
}

variable "zone" {
  type    = string
}

variable "forescout_ssh_public_key_path"{
  type=string
}
variable "forescout_ssh_private_key_path"{
  type=string
}