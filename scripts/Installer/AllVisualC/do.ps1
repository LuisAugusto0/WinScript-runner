# Define the application IDs for Visual C++ Redistributable packages, including older versions
$appIds = @(
    "Microsoft.VCRedist.2005.x64",
    "Microsoft.VCRedist.2005.x86",
    "Microsoft.VCRedist.2008.x64",
    "Microsoft.VCRedist.2008.x86",
    "Microsoft.VCRedist.2010.x64",
    "Microsoft.VCRedist.2010.x86",
    "Microsoft.VCRedist.2012.x64",
    "Microsoft.VCRedist.2012.x86",
    "Microsoft.VCRedist.2013.x64",
    "Microsoft.VCRedist.2013.x86",
    "Microsoft.VCRedist.2015+.x64",
    "Microsoft.VCRedist.2015+.x86"
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
