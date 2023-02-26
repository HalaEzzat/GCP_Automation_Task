# Define the provider
provider "google" {
  credentials = file("forescout-378422-33ceee65856f.json")
  project = var.projectID
  region  = var.region
  zone    = var.zone
}

# controller machine
resource "google_compute_instance" "controller" {
  name         = "controller"
  machine_type = var.vmType
  tags         = ["controller"]
  boot_disk {
    initialize_params {
      image = var.imageName
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.subnet.name
    access_config { //public ip address
      nat_ip = google_compute_address.controller_ip_address.address
    }
  }
  
  # metadata_startup_script = file("startup.sh")
   metadata = {
    ssh-keys = "${var.ssh_user}:${file("${var.ssh_public_key_path}")}"
  }

  depends_on = [google_compute_firewall.target_sg_inbound,google_compute_instance.target]
}

//target machine
resource "google_compute_instance" "target" {
  name         = "target"
  machine_type = "e2-micro"
  tags         = ["target"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }
  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.subnet.name
    network_ip = google_compute_address.target_ip_address.address
  }
  metadata={
   ssh-keys = "${var.ssh_user}:${file("${var.ssh_public_key_path}")}"
  }
 depends_on = [google_compute_firewall.target_sg_inbound]
}


#Configure the target machine
resource "null_resource" "configure_target" {

  #add the key pair for 'forescot' user and the inventory and the playbook to the controller instance
   provisioner "file" {
    connection {
      type = "ssh"
      user = "${var.ssh_user}"
      private_key = "${file("${var.ssh_private_key_path}")}"
      host = google_compute_address.controller_ip_address.address
      agent = false
      timeout = "5m"
    }
    source      = "./startup"
    destination = "/tmp/forescout"
  }

 
  # run ansible playbook to config the target vm 
    provisioner "remote-exec" {
      connection {
      type = "ssh"
      user = "${var.ssh_user}"
      private_key = "${file("${var.ssh_private_key_path}")}"
      host = google_compute_address.controller_ip_address.address
      agent = false
      timeout = "5m"
    }
     inline = [
      "sudo chmod 600 /tmp/forescout/${var.ssh_private_key_path}",
      "sudo scp -i /tmp/forescout/${var.ssh_private_key_path} -r /tmp/forescout/ssh/ ${var.ssh_user}@target:/tmp/forescout",#copy the key pair for the 'forescout' user to target machine
      "curl -o ${var.pcap_file_name} ${var.pcap_file_url} && sudo scp -i /tmp/forescout/${var.ssh_private_key_path} ${var.pcap_file_name} ${var.ssh_user}@target:/tmp/",#install the pcap file and copy it to target machine
      "sudo apt-add-repository -y ppa:ansible/ansible",# add ansible pkg to be installed on the controller instance
      "sudo apt -y update",# update apt to see the pkg
      "sudo apt install -y ansible",#install ansible
      "sudo ansible-playbook -i /tmp/forescout/inventory /tmp/forescout/playbook.yml",#run the playbook
     ]
   }
 
  depends_on = [google_compute_instance.controller,google_compute_instance.target]
}