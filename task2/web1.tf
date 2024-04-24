resource "digitalocean_droplet" "web1" {
  image = "ubuntu-23-10-x64"
  name = "web1"
  region = "fra1"
  size = "s-1vcpu-1gb"
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]
  


  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file(var.pvt_key)
    timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
        "export PATH=$PATH:/usr/bin",
        "sudo apt update",
        # install apache2
        "sudo apt install -y apache2",
        # install php 
        "sudo apt install -y php libapache2-mod-php",
        # install my-sql extension
        "sudo apt install -y php-mysql",
        # install mysql-cli
        "sudo apt install mysql-client-core-8.0"

    ]
  }

  provisioner "file" {
    source = "index.php"
    destination = "/var/www/html/index.php"
  }

    provisioner "file" {
    source = "query.sql"
    destination = "/root/query.sql"
  }

    provisioner "file" {
    source = "apache_monitoring.sh"
    destination = "/root/apache_monitoring.sh"
  }
  
  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # export DB variables
      "export DB_HOST='${digitalocean_database_cluster.db_cluster.host}'",
      "export DB_PORT='${digitalocean_database_cluster.db_cluster.port}'",
      "export DB_PASSWORD='${digitalocean_database_cluster.db_cluster.password}'",
      "export DB_USER='${digitalocean_database_cluster.db_cluster.user}'",
      "export WEB_SERVER=web1",
      # create a table and insert some records 
      "sudo mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD < /root/query.sql",
      # modify the apache to prefer php files over html 
      "sudo sed -i 's/index.html/index.php index.html/' /etc/apache2/mods-enabled/dir.conf",
      # restart apache 
      "sudo systemctl restart apache2",
      # replace variables in index.php
      "perl -i -pe 's/dbserver_replace/$ENV{DB_HOST}/g' /var/www/html/index.php",
      "perl -i -pe 's/dbport_replace/$ENV{DB_PORT}/g' /var/www/html/index.php",
      "perl -i -pe 's/dbpassword_replace/$ENV{DB_PASSWORD}/g' /var/www/html/index.php",
      "perl -i -pe 's/dbuser_replace/$ENV{DB_USER}/g' /var/www/html/index.php",
      "perl -i -pe 's/webserver_replace/$ENV{WEB_SERVER}/g' /var/www/html/index.php",
      # make the scirpt +x & add cronjob for apache2 monitoring
      "chmod +x /root/apache_monitoring.sh",
      "echo '*/2 * * * * root /root/apache_monitoring.sh >> /var/log/apache_restart.log 2>&1' | sudo tee /etc/cron.d/apache_restart",
      "sudo systemctl restart cron"

      




    ]
  }
}