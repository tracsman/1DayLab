Write-Host "1"
$FileName = @()
$FileName += 'putty.exe'
$FileName += 'ChromeSetup.exe'
Write-Host "2"
Try {
    $uri = 'https://raw.githubusercontent.com/tracsman/1DayLab/DontLook/UtilityVM/'
    $LocPath = $env:USERPROFILE + "\Desktop\"
Write-Host "3"
    ForEach ($File in $FileName) {
        Write-Host $uri + $File
        Write-Host $LocPath + $File 
        $webClient = new-object System.Net.WebClient
        Write-Host "4"
        $webClient.DownloadFile( $uri + $File, $LocPath + $File )
        }
    }
Catch {
    Write-Host "End"
    Write-Warning "Something bad happened with the download. Most likely either files are missing or you don't have internet access. Please try again, or contact your administrator."
    Return
    }
