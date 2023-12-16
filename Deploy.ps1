param(
    # Define all parameters that might be used
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$BUCKET,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$BUCKETKEY,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$BUCKETREGION,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$BUCKETENDPOINT,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$VMNAME,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$AZREGION,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$VAULTNAME,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$VAULTGROUP,

    # [Parameter(ValueFromPipelineByPropertyName = $true)]
    # [string]$SCRIPTURL,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$DOMAINNAME,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$DOMAINSUFFIX,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$EC2NAME,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$EC2SIZE,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$SSH_PUBLIC_KEY_LOCATION,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$USERNAME,

    [switch]$genKeyVault
)

# Define a helper function to run each script
# function Run-ScriptWithParams {
#     param($ScriptPath, $Params)
#     & $ScriptPath @Params
# }

# Prepare parameter sets for each script
$ParamsKeyVault = @{
    VAULTNAME = $VAULTNAME
    VAULTGROUP = $VAULTGROUP
}

$ParamsBackend = @{
    BUCKET = $BUCKET
    BUCKETKEY = $BUCKETKEY
    BUCKETREGION = $BUCKETREGION
    BUCKETENDPOINT = $BUCKETENDPOINT
}

$ParamsMain = @{
    DOMAINNAME = $DOMAINNAME
    DOMAINSUFFIX = $DOMAINSUFFIX
    EC2NAME = $EC2NAME
    EC2SIZE = $EC2SIZE
    SSH_PUBLIC_KEY_LOCATION = $SSH_PUBLIC_KEY_LOCATION
}

$ParamsProviders = @{
    BUCKETREGION = $BUCKETREGION
    VAULTNAME = $VAULTNAME
    VAULTGROUP = $VAULTGROUP
}

# $ParamsVariables = @{
#     SCRIPTURL = $SCRIPTURL
# }

$ParamsInventory = @{
    EC2NAME = $EC2NAME
    USERNAME = $USERNAME
}

$ParamsOutputs = @{ 
   DOMAINNAME = $DOMAINNAME
   EC2NAME = $EC2NAME
}

function Run-ScriptWithParams {
    param($ScriptPath, $Params)
    Write-Output "Running $ScriptPath." 
    & $ScriptPath @Params
}




# Run the scripts with the correct parameter sets
if ($genKeyVault) {
    Run-ScriptWithParams ".\Gen-KeyVault.ps1" $ParamsKeyVault
}

Run-ScriptWithParams ".\Gen-Backend.ps1" $ParamsBackend
Run-ScriptWithParams ".\Gen-Main.ps1" $ParamsMain
Run-ScriptWithParams ".\Gen-Providers.ps1" $ParamsProviders
Run-ScriptWithParams ".\Gen-Variables.ps1" $ParamsVariables
Run-ScriptWithParams ".\Gen-Outputs.ps1" $ParamsOutputs
# Run-ScriptWithParams ".\Gen-Inventory.ps1" $ParamsInventory

# Change directory to .\Deploy and run terraform init
# Check and create .\Deploy directory if it doesn't exist
$deployPath = ".\Deploy"
if (-not (Test-Path -Path $deployPath)) {
    New-Item -ItemType Directory -Path $deployPath -Force
}

Set-Location -Path $deployPath
Copy-Item -Path "..\templates\roles" -Destination . -Recurse -Force
Copy-Item -Path "..\templates\modules" -Destination . -Recurse -Force
# Copy-Item -Path ".\templates\ami-search" -Destination $deployPath -Recurse -Force

terraform init

### S3 Version
# $AWS_ACCESS_KEY_ID = Read-Host "Enter DigitalOcean S3 Key ID" -AsSecureString

# $AWS_SECRET_ACCESS_KEY = Read-Host "Enter DigitalOcean S3 Secret Access Key" -AsSecureString

# # Convert SecureString to Plain Text (for temporary use)
# $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($AWS_ACCESS_KEY_ID)
# $PlainAWS_ACCESS_KEY_ID = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($AWS_SECRET_ACCESS_KEY)
# $PlainAWS_SECRET_ACCESS_KEY = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# # Configure AWS CLI
# aws configure set aws_access_key_id $PlainAWS_ACCESS_KEY_ID --profile digitalocean
# aws configure set aws_secret_access_key $PlainAWS_SECRET_ACCESS_KEY --profile digitalocean
# aws configure set default.region us-east-1 --profile digitalocean

# $env:AWS_PROFILE="digitalocean"
# # export AWS_PROFILE=digitalocean

# Initialize and copy tf to backend
# terraform init -force-copy
# terraform plan
# terraform apply --auto-approve

# # Prompt for AWS access keys
# $AWS_ACCESS_KEY_ID = Read-Host "Enter AWS Access Key ID" -AsSecureString
# $AWS_SECRET_ACCESS_KEY = Read-Host "Enter AWS Secret Access Key" -AsSecureString

# # Convert SecureString to Plain Text (for temporary use)
# $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($AWS_ACCESS_KEY_ID)
# $PlainAWS_ACCESS_KEY_ID = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($AWS_SECRET_ACCESS_KEY)
# $PlainAWS_SECRET_ACCESS_KEY = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# # Configure AWS CLI
# aws configure set aws_access_key_id $PlainAWS_ACCESS_KEY_ID
# aws configure set aws_secret_access_key $PlainAWS_SECRET_ACCESS_KEY
# aws configure set default.region $BUCKETREGION

# # Initialize and copy tf to backend
# terraform init -force-copy
# terraform plan

# Usage
# Define your parameters in a hashtable with placeholder values
# $params = @{
#     BUCKET = "your-bucket-name"
#     BUCKETKEY = "your-bucket-key"
#     BUCKETREGION = "your-bucket-region"
#     BUCKETENDPOINT = "your-bucket-endpoint"
#     EC2NAME = "your-ec2-instance-name"
#     EC2SIZE = "your-ec2-instance-size"
#     USERNAME = "your-username"
#     AZREGION = "your-azure-region"
#     VAULTNAME = "your-vault-name"
#     VAULTGROUP = "your-vault-group"
#     genKeyVault = $true  # Set to $false if you don't want to generate Key Vault
#     DOMAINNAME = "your-domain-name"
#     DOMAINSUFFIX = "your-domain-suffix"
#     SSH_PUBLIC_KEY_LOCATION = "path-to-your-ssh-public-key"
# }

# # Run the Deploy script with the parameters from the hashtable
# .\Deploy.ps1 @params