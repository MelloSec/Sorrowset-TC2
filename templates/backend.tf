terraform {
  backend "s3" {
    bucket         = "<<<BUCKET>>>"
    key            = "<<<BUCKETKEY>>>/terraform.tfstate"
    region         = "<<<BUCKETREGION>>>"
    endpoint       = "<<<BUCKETENDPOINT>>>.digitaloceanspaces.com"
    access_key = "(((DOSPACEACCESS)))"
    secret_key = "(((DOSPACEKEY)))"
    skip_credentials_validation = true
    skip_metadata_api_check = true    
  }
}
