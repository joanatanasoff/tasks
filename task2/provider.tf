terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {
    description = "DigitalOcean API Token" 
}
variable "pvt_key" {
    description = "Private SSH Key" 
    default = "~/.ssh/do/id_rsa_do"
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "terraform" {
  name = "iaas_test"
}