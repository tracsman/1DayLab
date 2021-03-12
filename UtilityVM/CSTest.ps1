# Start nicely
Write-Host
Write-Host (Get-Date)' - ' -NoNewline
Write-Host "Initializing workshop environment, estimated total time < 1 minute" -ForegroundColor Cyan

# Check for folder, create if not found
Write-Host
Write-Host (Get-Date)' - ' -NoNewline
Write-Host "Creating Scripts Folder" -ForegroundColor Cyan
$ScriptPath = ".\Scripts" 
If (-Not (Test-Path $ScriptPath)){New-Item -ItemType Directory -Force -Path $ScriptPath | Out-Null}

# Create and fill Init.txt
Write-Host
Write-Host (Get-Date)' - ' -NoNewline
Write-Host "Creating Init File" -ForegroundColor Cyan
If (-Not (Test-Path $ScriptPath\Init.txt)){
    $FileContent = "SubID=00000000-0000-0000-0000-000000000000" + "`nShortRegion=westus2" + "`nRGName=FWLab"
    Out-File -FilePath "$ScriptPath\Init.txt" -Encoding ascii -InputObject $FileContent -Force
}

# Download lab files
Write-Host
Write-Host (Get-Date)' - ' -NoNewline
Write-Host "Downloading PowerShell Scripts" -ForegroundColor Cyan
$FileName = @()
$FileName += 'WorkshopStep1.ps1'
$FileName += 'WorkshopStep2.ps1'
$FileName += 'WorkshopStep3.ps1'
$FileName += 'WorkshopStep4.ps1'
$FileName += 'WorkshopStep5.ps1'
$FileName += 'WorkshopStep6.ps1'
$uri = 'https://raw.githubusercontent.com/tracsman/vdcWorkshop/master/Firewall/Scripts/PowerShell/'
ForEach ($File in $FileName) {
    Invoke-WebRequest -Uri "$uri$File" -OutFile "$ScriptPath\$File" | Out-Null
}

# Validate Environment
Write-Host
Write-Host (Get-Date)' - ' -NoNewline
Write-Host "Validating environment:" -ForegroundColor Cyan
$ErrorBit=$False

Write-Host "  Checking Script Folder...." -NoNewline
If (-Not (Test-Path $ScriptPath)){
    Write-Host "Folder not found" -ForegroundColor Red
    Write-Host "                            Rerun the intial script"
    Return
} Else {
    Write-Host "Good" -ForegroundColor Green
}

Write-Host "  Checking Init File........" -NoNewline
If (-Not (Test-Path $ScriptPath\Init.txt)){
    Write-Host "File Not Found" -ForegroundColor Red
    Write-Host "                            Rerun the intial script"
    Return
} Else {
    Write-Host "Good" -ForegroundColor Green
}

Write-Host "  Validating File Variables:"
If (Test-Path -Path $ScriptPath\init.txt) {
        Get-Content $ScriptPath\init.txt | Foreach-Object{
        $var = $_.Split('=')
        Try {New-Variable -Name $var[0].Trim() -Value $var[1].Trim() -ErrorAction Stop}
        Catch {Set-Variable -Name $var[0].Trim() -Value $var[1].Trim()}}}

Write-Host "    Checking SubID.........." -NoNewline
Try {$Sub = (Set-AzContext -Subscription $SubID -ErrorAction Stop).Subscription}
Catch {
    Write-Host "SubID not valid or unauthorized" -ForegroundColor Red
    Write-Host "                            Update SubID in the Init.txt file"
    $ErrorBit=$true
}
If ($ErrorBit) {Write-Host "                            " -NoNewline;$ErrorBit=$False}
Write-Host "Valid, Context: $($Sub.Name)" -ForegroundColor Green

Write-Host "    Checking Region........." -NoNewline
If ($null -eq (Get-AzLocation | Where-Object Location -eq $ShortRegion)) {
    Write-Host "ShortRegion not valid or unauthorized" -ForegroundColor Red
    Write-Host "                            Update ShortRegion in the Init.txt file"
} Else {
    Write-Host "Valid" -ForegroundColor Green
}

Write-Host "    Checking RG Name........" -NoNewline
If ($RGName.Length -le 3) {"Bad short or don't exist"}
ElseIf ($RGName -contains " ") {"Bad Space"}
Write-Host "Valid" -ForegroundColor Green

Write-Host "  Checking Script Files....." -NoNewline
Try {
    Test-Path $ScriptPath\WorkshopStep1.ps1 -ErrorAction Stop
    Test-Path $ScriptPath\WorkshopStep2.ps1 -ErrorAction Stop
    Test-Path $ScriptPath\WorkshopStep3.ps1 -ErrorAction Stop
    Test-Path $ScriptPath\WorkshopStep4.ps1 -ErrorAction Stop
    Test-Path $ScriptPath\WorkshopStep5.ps1 -ErrorAction Stop
    Test-Path $ScriptPath\WorkshopStep6.ps1 -ErrorAction Stop
}
Catch {
    Write-Host "One or more script files Not Found" -ForegroundColor Red
    Write-Host "                            Rerun the intial script"
    Return
}
Write-Host "All present" -ForegroundColor Green

# End nicely
Write-Host (Get-Date)' - ' -NoNewline
Write-Host "Environment initialization completed successfully" -ForegroundColor Green
Write-Host
