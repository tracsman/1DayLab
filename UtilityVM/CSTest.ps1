"v6"
# Check for folder, create if not found
$ToolPath = ".\Scripts" 
If (-Not (Test-Path $ToolPath)){New-Item -ItemType Directory -Force -Path $ToolPath | Out-Null}


# Update Init.txt with Company Number
If (-Not (Test-Path $ToolPath\Init.txt)){
    $FileContent = "CompanyID=" + $CompanyID + "`nSubID=" + $SubID
    Out-File -FilePath "$ToolPath\Init.txt" -Encoding ascii -InputObject $FileContent -Force
}

# Download lab files
$FileName = @()
$FileName += 'WorkshopStep1.ps1'
$FileName += 'WorkshopStep2.ps1'
$FileName += 'WorkshopStep3.ps1'
$FileName += 'WorkshopStep4.ps1'
$FileName += 'WorkshopStep5.ps1'
$FileName += 'WorkshopStep6.ps1'
$FileName += 'WorkshopStep7.ps1'
$uri = 'https://raw.githubusercontent.com/tracsman/vdcWorkshop/master/Firewall/Scripts/PowerShell/'
ForEach ($File in $FileName) {
    Invoke-WebRequest -Uri "$uri$File" -OutFile "$ToolPath\$File"
}
