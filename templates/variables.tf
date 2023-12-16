// variable "aws_access_key" {
//   description = "AWS Access Key"
//   type        = string
//   sensitive   = true
// }
// variable "aws_secret_key" {
//   description = "AWS Secret Key"
//   type        = string
//   sensitive   = true
// }

resource "null_resource" "git_clone_repo" {

  provisioner "local-exec" {
    # Clone the Git repository into the root directory
    command     = "git clone https://github.com/MelloSec/Sorrowset-TC2.git && pwd && ls"
    working_dir = "${path.module}"
  }
}

resource "null_resource" "cd_and_run_playbook" {

  provisioner "local-exec" {
    # Change to the "ansible-init" directory and run the playbook
    command     = "cd ${path.module}/ansible-init/Sorrowset-TC2/ansible-init && ansible-playbook -i inventory.ini deploy.yml"
    working_dir = "${path.module}"
  }
}



variable "ec2_img" {
  description = "Ec2 Image Name"
  type        = string
  default     = "ubuntu-20.04"
}

variable "ssh_public_key_location" {
  description = "SSH Public Key File"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}