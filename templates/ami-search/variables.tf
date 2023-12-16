variable "os" {
   description = "The os reference to search for"
}

variable "amis_primary_owners" {
   description = "Force the ami Owner, could be (self) or specific (id)"
   default     = ""
}

variable "amis_os_map_regex" {
  description = "Map of regex to search amis"
  type = map

  default = {
    "ubuntu"       = "^ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-.*"
    "ubuntu-14.04" = "^ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-.*"
    "ubuntu-16.04" = "^ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-.*"
    "ubuntu-18.04" = "^ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-.*"
    "ubuntu-18.10" = "^ubuntu/images/hvm-ssd/ubuntu-cosmic-18.10-amd64-server-.*"
    "ubuntu-19.04" = "^ubuntu/images/hvm-ssd/ubuntu-disco-19.04-amd64-server-.*"
    "ubuntu-20.04" = "^ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-.*"
  }
}

variable "amis_os_map_owners" {
  description = "Map of amis owner to filter only official amis"
  type = map
   default = {
      "ubuntu"       = "099720109477" #CANONICAL
      "ubuntu-14.04" = "099720109477" #CANONICAL
      "ubuntu-16.04" = "099720109477" #CANONICAL
      "ubuntu-18.04" = "099720109477" #CANONICAL
      "ubuntu-18.10" = "099720109477" #CANONICAL
      "ubuntu-19.04" = "099720109477" #CANONICAL
      "ubuntu-20.04" = "099720109477" #CANONICAL
  }
}