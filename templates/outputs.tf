output "ec2_complete_public_dns" {
  description = "The public DNS name assigned to the instance."
  value       = module.<<<EC2NAME>>>.*.public_dns
}

output "ec2_complete_public_ip" {
  description = "The public IP address assigned to the instance."
  value = module.<<<EC2NAME>>>[0].public_ip
}

locals {
  namecheap_record_list = [for r in namecheap_domain_records.<<<DOMAINNAME>>>.record : r]
}

output "namecheap_dns_record" {
  description = "The DNS record set on Namecheap."
  value = {
    domain = namecheap_domain_records.<<<DOMAINNAME>>>.domain
    record = local.namecheap_record_list[0]
  }
}

