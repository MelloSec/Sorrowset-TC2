param(
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$DOMAINNAME,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$DOMAINSUFFIX,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$EC2NAME,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$EC2SIZE,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string]$SSH_PUBLIC_KEY_LOCATION
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
if ($DOMAINSUFFIX) { Replace-PlaceholderInFile -filePath $deployFilePath -placeholder "DOMAINSUFFIX" -value $DOMAINSUFFIX }
if ($EC2NAME) { Replace-PlaceholderInFile -filePath $deployFilePath -placeholder "EC2NAME" -value $EC2NAME }
if ($EC2SIZE) { Replace-PlaceholderInFile -filePath $deployFilePath -placeholder "EC2SIZE" -value $EC2SIZE }
if ($SSH_PUBLIC_KEY_LOCATION) { Replace-PlaceholderInFile -filePath $deployFilePath -placeholder "SSH_PUBLIC_KEY_LOCATION" -value $SSH_PUBLIC_KEY_LOCATION }

# Pipeline Usage Example
# $params = @{
#     DOMAINNAME = "exampledomain"
#     DOMAINSUFFIX = "com"
#     EC2NAME = "myec2"
#     EC2SIZE = "t2.micro"
#     SSH_PUBLIC_KEY_LOCATION = "C:\\path\\to\\public_key.pub"
# }
# $params | .\Gen-Main.ps1
