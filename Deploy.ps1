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

    [switch]$genKeyVault,

    [bool]$s3enabled = $false
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

function Replace-PlaceholderInFile {
    param($filePath, $placeholder, $value)
    Write-Output "Replacing $placeholder with $value"
    (Get-Content $filePath) -replace "\(\(\($placeholder\)\)\)", $value | Set-Content $filePath
}

# Run the scripts with the correct parameter sets
if ($genKeyVault) {
    Run-ScriptWithParams ".\Gen-KeyVault.ps1" $ParamsKeyVault
}

if($s3enabled) {
    Run-ScriptWithParams ".\Gen-Backend.ps1" $ParamsBackend
}

function Run-ScriptWithParams {
    param($ScriptPath, $Params)
    Write-Output "Running $ScriptPath." 
    & $ScriptPath @Params
}


Run-ScriptWithParams ".\Gen-Main.ps1" $ParamsMain
Run-ScriptWithParams ".\Gen-Providers.ps1" $ParamsProviders
Run-ScriptWithParams ".\Gen-Variables.ps1" $ParamsVariables
Run-ScriptWithParams ".\Gen-Outputs.ps1" $ParamsOutputs
# Run-ScriptWithParams ".\Gen-Inventory.ps1" $ParamsInventory

# Change directory to .\Deploy and run terraform init
# Check and create .\Deploy directory if it doesn't exist
$deployPath = ".\Deploy"
# if(Test-Path $deployPath) { Remove-Item $deployPath -Recurse -Force}
Remove-Item $deployPath\* -Recurse -Force

if (-not (Test-Path -Path $deployPath)) {
    New-Item -ItemType Directory -Path $deployPath -Force
}

Set-Location -Path $deployPath
Copy-Item -Path "..\templates\roles" -Destination . -Recurse -Force
Copy-Item -Path "..\templates\modules" -Destination . -Recurse -Force
# Copy-Item -Path ".\templates\ami-search" -Destination $deployPath -Recurse -Force



if($s3enabled)
{
    
    Write-Output "Placeholder for backend version"
    Prompt for DigitalOcean Spaces credentials
    $doAccessKey = Read-Host "Enter your DigitalOcean Spaces Access Key" -AsSecureString
    $doSecretKey = Read-Host "Enter your DigitalOcean Spaces Secret Key" -AsSecureString

    # Convert Secure Strings to Plain Text
    $ptr1 = [System.Runtime.InteropServices.Marshal]::SecureStringToGlobalAllocUnicode($doAccessKey)
    $doAccessKeyPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($ptr1)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeGlobalAllocUnicode($ptr1)

    $ptr2 = [System.Runtime.InteropServices.Marshal]::SecureStringToGlobalAllocUnicode($doSecretKey)
    $doSecretKeyPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($ptr2)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeGlobalAllocUnicode($ptr2)

    # Replace placeholders in deploy\backend.tf
    $backendFilePath = ".\backend.tf"
    Replace-PlaceholderInFile $backendFilePath "DOSPACEACCESS" $doAccessKeyPlainText
    Replace-PlaceholderInFile $backendFilePath "DOSPACEKEY" $doSecretKeyPlainText



    # # Set up AWS CLI profile for DigitalOcean Spaces
    # aws configure set aws_access_key_id $doAccessKeyPlainText --profile digitalocean
    # aws configure set aws_secret_access_key $doSecretKeyPlainText --profile digitalocean
    # aws configure set region $BUCKETREGION --profile digitalocean 


    # $doAccessKey = Read-Host "Enter your DigitalOcean Spaces Access Key" 
    # $doSecretKey = Read-Host "Enter your DigitalOcean Spaces Secret Key" 
    
    # # Set up AWS CLI profile for DigitalOcean Spaces
    # aws configure set aws_access_key_id $doAccessKey --profile digitalocean
    # aws configure set aws_secret_access_key $doSecretKey --profile digitalocean
    # aws configure set region $BUCKETREGION --profile digitalocean 

    # # Use the Profile with Terraform
    # $Env:AWS_PROFILE = "digitalocean"
    # terraform init -migrate-state
    terraform init -reconfigure

    $Env:AWS_PROFILE = "default"  # or your regular AWS profile name
    terraform plan


    # Clearing Environment Variable
    # Remove-Variable -Name AWS_PROFILE -Scope Local

    # Reset to default AWS profile if necessary
    # $Env:AWS_PROFILE = "default"

}
else{
    
    terraform init -reconfigure
    terraform plan
}


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