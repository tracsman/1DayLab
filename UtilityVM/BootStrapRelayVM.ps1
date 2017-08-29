
$FileName = @()
$FileName += 'putty.exe'
$FileName += 'ChromeSetup.exe'

Try {
    $File = 'ChromeSetup.exe'
    $uri = 'https://raw.githubusercontent.com/tracsman/1DayLab/DontLook/PerfTest/'
    $LocPath = $env:USERPROFILE + "\Desktop\"

    ForEach ($File in $FileName) {
        $webClient = new-object System.Net.WebClient
        $webClient.DownloadFile( $uri + $File, $LocPath + $File )
        }
    }
Catch {
    Write-Warning "Something bad happened with the download. Most likely either files are missing or you don't have internet access. Please try again, or contact your administrator."
    Return
    }
