Try {
    $uri = 'https://raw.githubusercontent.com/tracsman/1DayLab/DontLook/UtilityVM/ChromeSetup.exe'
    $Local = $env:USERPROFILE + "\Desktop\" + "ChromeSetup.exe"
    $webClient = new-object System.Net.WebClient
    Write-Host "From: $uri"
    Write-Host "To: $Local"
    $webClient.DownloadFile( $uri, $Local )
    }

Catch {
    Write-Warning "Something bad happened with the download. Most likely either files are missing or you don't have internet access. Please try again, or contact your administrator."
    Return
    }
