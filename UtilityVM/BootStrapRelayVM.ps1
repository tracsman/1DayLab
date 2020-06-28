# Copy, paste, run on local VM (Adjust local path as needed)
$uri = 'https://raw.githubusercontent.com/tracsman/1DayLab/DontLook/UtilityVM/MicrosoftEdgeSetup.exe'
$Local = "$HOME\Desktop\MicrosoftEdgeSetup.exe"
$webClient = new-object System.Net.WebClient
$webClient.DownloadFile( $uri, $Local )

