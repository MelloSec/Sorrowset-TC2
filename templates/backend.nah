terraform {
  backend "s3" {
    bucket         = "<<<BUCKET>>>"
    key            = "<<<BUCKETKEY>>>\terraform.tfstate"
    region         = "<<<BUCKETREGION>>>"
    endpoint       = "<<<BUCKETENDPOINT>>>.digitaloceanspaces.com"  # Replace with the appropriate endpoint for your region
    # access_key = ""
    # secret_key = ""
    skip_credentials_validation = true
    skip_metadata_api_check = true    
  }
}