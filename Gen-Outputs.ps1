param(
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$DOMAINNAME
)

# Check and create .\Deploy directory if it doesn't exist
$deployPath = ".\Deploy"
if (-not (Test-Path -Path $deployPath)) {
    New-Item -ItemType Directory -Path $deployPath
}

# Copy main.tf template to .\Deploy
$templatePath = ".\templates\main.tf"
$deployFilePath = Join-Path $deployPath "main.tf"
Copy-Item -Path $templatePath -Destination $deployFilePath -Force

# Function to replace placeholder in file
function Replace-PlaceholderInFile {
    param($filePath, $placeholder, $value)
    (Get-Content $filePath) -replace "<<<$placeholder>>>", $value | Set-Content $filePath
}

# Replace placeholders with parameter values
if ($DOMAINNAME) { Replace-PlaceholderInFile -filePath $deployFilePath -placeholder "DOMAINNAME" -value $DOMAINNAME }

# Pipeline Usage Example
# $params = @{
#     DOMAINNAME = "exampledomain"
# }
# $params | .\Gen-Main.ps1
