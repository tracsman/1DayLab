$uri = 'https://raw.githubusercontent.com/tracsman/1DayLab/DontLook/UtilityVM/ChromeSetup.exe'
$Local = "Z:\"  + "Desktop\" + "ChromeSetup.exe"
$webClient = new-object System.Net.WebClient
$webClient.DownloadFile( $uri, $Local )

