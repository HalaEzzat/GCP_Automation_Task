# Define the VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "vpc-network"
  auto_create_subnetworks = false
}

# Define the subnet for the instances
resource "google_compute_subnetwork" "subnet" {
  name          = "subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc_network.self_link
  depends_on=[google_compute_network.vpc_network]
}

//routing for the gateway
resource "google_compute_router" "router" {
  name    = "my-router"
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.vpc_network.id
  depends_on=[google_compute_network.vpc_network]
}
//nat gateway for the controller public ip
resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
  depends_on=[google_compute_router.router,google_compute_address.controller_ip_address]
}
//controller public ip address
resource "google_compute_address" "controller_ip_address" {
  name   = "controller-ip-address"
  region = var.region
}

# //target private ip
resource "google_compute_address" "target_ip_address" {
  name         = "target-ip-address"
  subnetwork   = google_compute_subnetwork.subnet.name
  address_type = "INTERNAL"
  region       = var.region
  depends_on=[google_compute_subnetwork.subnet]
}

//controller firewall rule for outbound trrafic
resource "google_compute_firewall" "controller_sg_outbound" {
  name      = "controller-sg-outbound"
  network   = google_compute_network.vpc_network.self_link
  direction = "EGRESS"
  allow {
    protocol = "tcp"
  }
  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["controller"]
  depends_on=[google_compute_network.vpc_network]
}

//controller firewall rule for inbound trrafic
resource "google_compute_firewall" "controller_sg_inbound" {
  name    = "controller-sg-inbound"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["controller"]
  depends_on=[google_compute_network.vpc_network]
}


//target firewall rule for inbound trrafic
resource "google_compute_firewall" "target_sg_inbound" {
  name    = "target-sg-inbound"
  network = google_compute_network.vpc_network.self_link
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  # source_ranges=["10.0.0.0/24"]

  source_tags = ["controller"]
  target_tags = ["target"]
  depends_on=[google_compute_network.vpc_network,google_compute_address.target_ip_address]
}