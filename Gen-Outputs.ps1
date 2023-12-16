param(
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$DOMAINNAME,
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$EC2NAME

)

# Check and create .\Deploy directory if it doesn't exist
$deployPath = ".\Deploy"
if (-not (Test-Path -Path $deployPath)) {
    New-Item -ItemType Directory -Path $deployPath
}

# Copy main.tf template to .\Deploy
$templatePath = ".\templates\outputs.tf"
$deployFilePath = Join-Path $deployPath "outputs.tf"
Copy-Item -Path $templatePath -Destination $deployFilePath -Force

# Function to replace placeholder in file
function Replace-PlaceholderInFile {
    param($filePath, $placeholder, $value)
    Write-Output "replacing $placeholder with $value"
    (Get-Content $filePath) -replace "<<<$placeholder>>>", $value | Set-Content $filePath
}

# Replace placeholders with parameter values
Replace-PlaceholderInFile -filePath $deployFilePath -placeholder "DOMAINNAME" -value $DOMAINNAME
Replace-PlaceholderInFile -filePath $deployFilePath -placeholder "EC2NAME" -value $EC2NAME

# Pipeline Usage Example
# $params = @{
#     DOMAINNAME = "exampledomain"
# }
# $params | .\Gen-Main.ps1
