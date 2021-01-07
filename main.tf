terraform {
  required_providers {
    aws = {
      source  = "hashicorp/google"
      version = "~> 3.51"
    }
  }
}

# data "template_file" "user_data" {
#   template = file("../../provision.sh")
#   vars = {
#     ORACLE_PASSWORD = ""
#   }
# }

# set Environment variable TF_VAR_gcp_access_key.
# use gcp access token.
variable "gcp_access_key" {}

# set Environment variable TF_VAR_billing_account_id.
# use gcp access token.
variable "billing_account_id" {}


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

# provisioner "local-exec" {
#   command = "genuuid  > /tmp/terraform-$(data).txt || "
#   interpreter = ["bash", "-e"]
# }

resource "google_project" "hello_terraform" {
  name       = "hello-terraform"
  project_id = "hello-terraform2wrew5biu23125"

   billing_account = var.billing_account_id
  
}

resource "google_project_service" "project" {
  count   = length(var.gcp_service_list)
  project = google_project.hello_terraform.project_id
   
  service = var.gcp_service_list[count.index]
  disable_dependent_services = false
}

# google

# resource "google_project_iam_policy" "project_iam" {
#   project     = google_project.hello_terraform.project_id
#   policy_data = data.google_iam_policy.admin_iam_policy.policy_data
# }

# data "google_iam_policy" "admin_iam_policy" {
#   binding {
#     role = "roles/editor"

#     # serviceAccount:terraform@${GCP_PROJECT_ID}.iam.gserviceaccount.com
#     members = [
#       "serviceAccount:${google_service_account.sa.account_id}@${google_project.hello_terraform.project_id}.iam.gserviceaccount.com",
#     ]
#   }
# }

resource "google_service_account" "sa" {
  # account_id   = "terraform@${google_project.hello_terraform.project_id}.iam.gserviceaccount.com"
  # account_id   = "serviceAccount:terraform"
  account_id   = "terraform"
  display_name = "Terraform service account"
  project = google_project.hello_terraform.project_id
}

resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = google_service_account.sa.name
  role               = "roles/editor"

  members = [
    "serviceAccount:${google_service_account.sa.account_id}@${google_project.hello_terraform.project_id}.iam.gserviceaccount.com",
  ]
}

resource "google_service_account_key" "mykey" {
  service_account_id = google_service_account.sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}


# google_compute_security_policy
# resource "kubernetes_secret" "google-application-credentials" {
#   metadata = {
#     name = "google-application-credentials"
#   }
#   data {
#     credentials.json = "${base64decode(google_service_account_key.mykey.private_key)}"
#   }
# }

# resource "google_service_account_iam_policy" "admin-account-iam" {
#   service_account_id = google_service_account.sa.name
#   policy_data        = data.google_iam_policy.admin_iam_policy.policy_data
# }

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
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    foo = "bar"
    # ssh-keys = var.gce_ssh_user}:file("~/.ssh/id_rsa.pub")
  }

  # metadata_startup_script = "echo hi > /test.txt"

  service_account {
    email = google_service_account.sa.email
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }

}
