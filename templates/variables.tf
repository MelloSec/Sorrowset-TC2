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