param(
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$BUCKETREGION,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$VAULTNAME,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$VAULTGROUP
)

# Check and create .\Deploy directory if it doesn't exist
$deployPath = ".\Deploy"
if (-not (Test-Path -Path $deployPath)) {
    New-Item -ItemType Directory -Path $deployPath
}

# Copy providers.tf template to .\Deploy
$templatePath = ".\templates\providers.tf"
$deployFilePath = Join-Path $deployPath "providers.tf"
Copy-Item -Path $templatePath -Destination $deployFilePath -Force

# Function to replace placeholder in file
function Replace-PlaceholderInFile {
    param($filePath, $placeholder, $value)
    (Get-Content $filePath) -replace "<<<$placeholder>>>", $value | Set-Content $filePath
}

# Replace placeholders with parameter values
if ($BUCKETREGION) { Replace-PlaceholderInFile -filePath $deployFilePath -placeholder "BUCKETREGION" -value $BUCKETREGION }
if ($VAULTNAME) { Replace-PlaceholderInFile -filePath $deployFilePath -placeholder "VAULTNAME" -value $VAULTNAME }
if ($VAULTGROUP) { Replace-PlaceholderInFile -filePath $deployFilePath -placeholder "VAULTGROUP" -value $VAULTGROUP }

# Pipeline Usage Example
# $params = @{
#     BUCKETREGION = "us-east-1"
#     VAULTNAME = "myKeyVault"
#     VAULTGROUP = "myResourceGroup"
# }
# $params | .\Gen-Providers.ps1
