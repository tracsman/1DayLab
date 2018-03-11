# 1. Initialize
$ToolPath = "C:\Bin\"

# 2. Create C:\Bin
If (-Not (Test-Path $ToolPath)){New-Item -ItemType Directory -Force -Path $ToolPath | Out-Null}

# 3. Load file names to copy
$FileName = @()
If (-Not (Test-Path $ToolPath + "ChromeSetup.exe")){$FileName += 'ChromeSetup.exe'}
If (-Not (Test-Path $ToolPath + "WinSCP-5.9.3-Setup.exe")){$FileName += 'WinSCP-5.9.3-Setup.exe'}
If (-Not (Test-Path $ToolPath + "Wireshark-win64-2.2.4.exe")){$FileName += 'Wireshark-win64-2.2.4.exe'}
If (-Not (Test-Path $ToolPath + "ipscan24.exe")){$FileName += 'ipscan24.exe'}
If (-Not (Test-Path $ToolPath + "pingplotter_install.exe")){$FileName += 'pingplotter_install.exe'}
If (-Not (Test-Path $ToolPath + "putty.exe")){$FileName += 'putty.exe'}

# 4. Copy files from GitHUb
If ($FileName.Count -gt 0) {
    Try {
        $uri = 'https://raw.githubusercontent.com/tracsman/1DayLab/DontLook/UtilityVM/'
        ForEach ($File in $FileName) {
            $webClient = new-object System.Net.WebClient
            $webClient.DownloadFile( $uri + $File, $ToolPath + $File )
        }
    }
    Catch {
        Write-Warning "Something bad happened with the download. Most likely either files are missing or you don't have internet access. Please try again, or contact your administrator."
        Return
    } # End Try
} # End If

# 5. Move Putty front and center
If (-Not (Test-Path (([Environment]::GetFolderPath("Desktop")) + "\Putty.exe"))){Copy-Item $ToolPath+"Putty.exe" -Destination ([Environment]::GetFolderPath("Desktop")) }

