# Define the application IDs for Visual C++ Redistributable packages, including older versions
$appIds = @(
    "Python.Python.3.12",
    "Oracle.JDK.17",
    "Git.Git",
    "Microsoft.VisualStudioCode"
)

# Function to check if an application is installed
function Check-Install {
    param (
        [string]$appId
    )
    $listApp = winget list --exact --query "$appId"
    if ($listApp -match $appId) {
        Write-Host "Skip: $appId (already installed)"
    } else {
        Write-Host "Install: $appId"
        winget install -e -h --accept-source-agreements --accept-package-agreements --id $appId
    }
}

# Loop through each application ID and check/install
foreach ($appId in $appIds) {
    Check-Install -appId $appId
}
