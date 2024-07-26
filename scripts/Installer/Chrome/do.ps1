# Define the application ID you want to check and install
$appId = "Google.Chrome"

# Get the list of installed applications
$listApp = winget list --exact --query "$appId"

# Check if the application is installed
if ($listApp -match $appId) {
    Write-Host "Skip: $appId (already installed)"
} else {
    Write-Host "Install: $appId"
    winget install -e -h --accept-source-agreements --accept-package-agreements --id $appId
}
