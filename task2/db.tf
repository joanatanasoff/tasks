variable "db_name" {
  description = "Name of the DB" 
  default = "iaas-db" 
}
variable "region" {
  description = "Region of the resource"
  default = "fra1" 
}

resource "digitalocean_database_cluster" "db_cluster" {
  name       = var.db_name
  engine     = "mysql"
  version    = "8"
  size       = "db-s-1vcpu-1gb"
  region     = var.region
  node_count = 1
}

output "db_host" {
  value = digitalocean_database_cluster.db_cluster.host
}

output "db_port" {
  value = digitalocean_database_cluster.db_cluster.port
}

output "db_password" {
  value = digitalocean_database_cluster.db_cluster.password
  sensitive = true
}

output "db_user" {
  value = digitalocean_database_cluster.db_cluster.user
}