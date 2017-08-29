Try {
    $uri = 'https://raw.githubusercontent.com/tracsman/1DayLab/DontLook/UtilityVM/ChromeSetup.exe'
    $Local = "Z:\"  + "Desktop\" + "ChromeSetup.exe"
    $webClient = new-object System.Net.WebClient
    Write-Host "From: $uri"
    Write-Host "To: $Local"
    $webClient.DownloadFile( $uri, $Local )
    }
\\hanatdi.com\Home\jon.ormond\Desktop
Catch {
    Write-Warning "Something bad happened with the download. Most likely either files are missing or you don't have internet access. Please try again, or contact your administrator."
    Return
    }
