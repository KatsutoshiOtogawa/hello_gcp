terraform {
  required_providers {
    aws = {
      source  = "hashicorp/google"
      version = "~> 3.51"
    }
  }
}

# set Environment variable TF_VAR_gcp_access_key.
# use gcp access token.
variable "gcp_access_key" {}

# set Environment variable TF_VAR_billing_account_id.
# use gcp project enable payment.
variable "billing_account_id" {}

# set Environment variable TF_VAR_gce_ssh_user.
# default install,billing gmail username ex) *awesomename*@gmail.com
# use gcp access token.
variable "gce_ssh_user" {}


provider "google" {
    credentials = var.gcp_access_key
    region = "us-central1"
}

data "google_client_openid_userinfo" "me" {
}

variable "gcp_service_list" {
    default = [
        "compute.googleapis.com"
        ,"cloudbilling.googleapis.com" 
    ]
}

resource "google_project" "hello_terraform" {
  name       = "hello-terraform"
  project_id = "hello-terraform16"

  billing_account = var.billing_account_id
  
}

resource "google_project_service" "project" {
  count   = length(var.gcp_service_list)
  project = google_project.hello_terraform.project_id
   
  service = var.gcp_service_list[count.index]
  disable_dependent_services = false
}

resource "google_service_account" "sa" {
  account_id   = "terraform"
  display_name = "Terraform service account"
  project = google_project.hello_terraform.project_id
}

resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = google_service_account.sa.name

  # editors role contain roles/compute.osAdminLogin priviledge
  role               = "roles/editor"


  members = [
    "serviceAccount:${google_service_account.sa.account_id}@${google_project.hello_terraform.project_id}.iam.gserviceaccount.com",
  ]
}

resource "google_service_account_key" "mykey" {
  service_account_id = google_service_account.sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

# register ssh public_key
resource "google_os_login_ssh_public_key" "cache" {
  user =  data.google_client_openid_userinfo.me.email
  project = google_project.hello_terraform.project_id
  key = file("~/.ssh/id_rsa.pub")
}

resource "google_compute_instance" "default" {
  name         = "test"
  machine_type = "f1-micro"
  project = google_project.hello_terraform.project_id
  zone         = "us-central1-a"
  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  // Local SSD disk
  # scratch_disk {
  #   # f1-micro is not support SCSI
  #   interface = "SCSI"
  # }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    # enable-oslogin = "TRUE"
    ssh-keys = "${var.gce_ssh_user}:${file("~/.ssh/id_rsa.pub")}"
  }

  # metadata_startup_script = "echo hi > /test.txt"

  service_account {
    email = google_service_account.sa.email

    scopes = [
      "compute-rw"
      ,"storage-rw"
    ]
  }

}

resource "null_resource" "testinstance" {

  depends_on = [
    google_compute_instance.default
  ]

  connection {
            host = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
            type = "ssh"
            user = var.gce_ssh_user
            private_key = file("~/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    script = "provision.sh"
    
  }
}

output "public_ip_address" {
  value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}

# output "public_dns_name" {
#   value = aws_eip.main_eip.public_dns
# }

output "instance_id" {
  value = google_compute_instance.default.id
}