param(
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$EC2NAME,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$USERNAME
)

# Check and create .\Deploy\inventory directory if it doesn't exist
$deployPath = ".\Deploy"
if (-not (Test-Path -Path $deployPath)) {
    New-Item -ItemType Directory -Path $deployPath
}

# Copy inventory.yml template to .\Deploy\inventory
$templatePath = ".\templates\inventory\inventory.yml"
$deployFilePath = Join-Path $deployPath "inventory.yml"
Copy-Item -Path $templatePath -Destination $deployFilePath -Force

# Copy requirements.yml template to .\Deploy
$templateRequirementsPath = ".\templates\requirements.yml"
$deployRequirementsFilePath = Join-Path $deployPath "requirements.yml"
Copy-Item -Path $templateRequirementsPath -Destination $deployRequirementsFilePath -Force

# Copy ansible.cfg template to .\Deploy
$templateAnsibleCfgPath = ".\templates\ansible.cfg"
$deployAnsibleCfgFilePath = Join-Path $deployPath "ansible.cfg"
Copy-Item -Path $templateAnsibleCfgPath -Destination $deployAnsibleCfgFilePath -Force

# Copy deploy.yml template to .\Deploy
$templateDeployPath = ".\templates\deploy.yml"
$deployFilePath = Join-Path $deployPath "deploy.yml"
Copy-Item -Path $templateDeployPath -Destination $deployFilePath -Force


# Function to replace placeholder in file
function Replace-PlaceholderInFile {
    param($filePath, $placeholder, $value)
    Write-Output "replacing $placeholder with $value"
    (Get-Content $filePath) -replace "<<<$placeholder>>>", $value | Set-Content $filePath
}
# Replace placeholders with parameter values
Replace-PlaceholderInFile -filePath $deployFilePath -placeholder "EC2NAME" -value $EC2NAME
Replace-PlaceholderInFile -filePath $deployFilePath -placeholder "USERNAME" -value $USERNAME

# Usage Example
# $params = @{
#     EC2NAME = "myec2vm"
#     USERNAME = "adminuser"
# }
# $params | .\Gen-Config.ps1
