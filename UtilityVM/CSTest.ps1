
# Update Init.txt with Company Number
$FileContent = "CompanyID=" + $CompanyID + "`nSubID=" + $SubID
Out-File -FilePath ".\Scripts\Init.txt" -Encoding ascii -InputObject $FileContent -Force

# Copy, paste, run on local VM (Adjust local path as needed)
$uri = 'https://raw.githubusercontent.com/tracsman/1DayLab/DontLook/UtilityVM/MicrosoftEdgeSetup.exe'
$Local = ".\Scripts\MicrosoftEdgeSetup.exe"
$webClient = new-object System.Net.WebClient
$webClient.DownloadFile( $uri, $Local )
