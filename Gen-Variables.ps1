param(
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$SSH_PUBLIC_KEY_LOCATION
)

# Check and create .\Deploy directory if it doesn't exist
$deployPath = ".\Deploy"
if (-not (Test-Path -Path $deployPath)) {
    New-Item -ItemType Directory -Path $deployPath
}

# Copy variables.tf template to .\Deploy
$templatePath = ".\templates\variables.tf"
$deployFilePath = Join-Path $deployPath "variables.tf"
Copy-Item -Path $templatePath -Destination $deployFilePath -Force

# Function to replace placeholder in file
function Replace-PlaceholderInFile {
    param($filePath, $placeholder, $value)
    Write-Output "replacing $placeholder with $value"
    (Get-Content $filePath) -replace "<<<$placeholder>>>", $value | Set-Content $filePath
}

# Replace placeholders with parameter values if provided
 
Replace-PlaceholderInFile -filePath $deployFilePath -placeholder "ssh_public_key_location" -value $SSH_PUBLIC_KEY_LOCATION 


# Pipeline Usage Example
# $params = @{
#     SSH_PUBLIC_KEY_LOCATION = "C:\\path\\to\\public_key.pub"
# }
# $params | .\Gen-Variables.ps1
