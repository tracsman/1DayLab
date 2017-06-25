function Install-LinkPerformance{
    # 1. Warning check
    # 2. Initialize
    # 3. Create C:\ACTTools dir
    # 4. Check for iPerf files
    #    4.1 If either are needed, download, extract
    # 5. Check for PSPing
    #    5.1 If needed, download
    # 6. Check other files
    # 7. Pull from GitHub if needed
    # 8. Kill PSPing popup
    # 9. Open Firewall rules

    Param([switch]$Force=$false)

    # 1. Warning check
    If (-not $Force) {
        Write-Host
        Write-Host "                               " -BackgroundColor Black
        Write-Host "  ***************************  " -ForegroundColor Red -BackgroundColor Black
        Write-Host "  ***                     ***  " -ForegroundColor Red -BackgroundColor Black
        Write-Host "  ***" -ForegroundColor Red -BackgroundColor Black -NoNewline
        Write-Host "    !!!Warning!!!    " -ForegroundColor Yellow -BackgroundColor Black -NoNewline
        Write-host "***  "  -ForegroundColor Red -BackgroundColor Black
        Write-Host "  ***                     ***  " -ForegroundColor Red -BackgroundColor Black
        Write-Host "  ***************************  " -ForegroundColor Red -BackgroundColor Black
        Write-Host "                               " -BackgroundColor Black
        Write-Host 
        Write-Host "  This script will install 3rd party products: iPerf3 and PSPing" -ForegroundColor Cyan
        Write-Host "  As well as open firewall port 5201 and allow ICMPv4" -ForegroundColor Cyan
        Write-Host
        $foo = Read-Host -Prompt "Are you sure you wish to continue? [y]"
        If ($foo -ne "y" -and $foo -ne "") {Return}
    
        } # End If


    # 2. Initialize
    $ToolPath = "C:\ACTTools\"

    # 3. Create C:\ACTTools dir
    If (-Not (Test-Path $ToolPath)){New-Item -ItemType Directory -Force -Path $ToolPath | Out-Null}


    # 4. Check for iPerf files
    # Yes I know I should make the file pull (and other things) a callable function, but lazy is ok sometimes
    If (-Not (Test-Path $ToolPath"iperf3.exe") -or -Not (Test-Path $ToolPath"cygwin1.dll")){
        # 4.1 If either are needed, download, extract
        $File = $ToolPath + "iperf-3.1.3-win64.zip"
        Try {
            $webClient = new-object System.Net.WebClient
            $webClient.DownloadFile('https://iperf.fr/download/windows/iperf-3.1.3-win64.zip', $File)
            }
        Catch {
            Write-Host
            Write-Warning "Something bad happened with the iPerf download. Most likely either files are missing at the source or this host doesn't have internet access."
            Write-Host
            Write-Host "You can manually add the files and rerun this Install script."
            Write-Host "To manually install iPerf3:"
            Write-Host "  1. Download files from https://iperf.fr/download/windows/iperf-3.1.3-win64.zip"
            Write-Host "  2. Extract zipped files (iPerf3.exe and cygwin1.dll) to $ToolPath"
            Write-Host "  3. With those files in place, rerun this install script."
            Write-Host
            Return
            } # End Try

        Try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::ExtractToDirectory($File, $ToolPath)
            move-item -path ($ToolPath + "iperf-3.1.3-win64\*.*") -destination $ToolPath -Force
            Remove-Item -Path ($ToolPath + "iperf-3.1.3-win64\") -Force
            Remove-Item -Path $File -Force
            }
        Catch {
            Write-Host
            Write-Warning "Something bad happened Unzipping and moving the iPerf files. Most likely .Net or other required subsystem files are not loaded."
            Write-Host
            Write-Host "You can manually add the files and rerun this Install script."
            Write-Host "To manually install iPerf3:"
            Write-Host "  1. Find $File"
            Write-Host "  2. Extract zipped files (iPerf3.exe and cygwin1.dll) to $ToolPath (not a subdirectory!)"
            Write-Host "  3. With those files in place, rerun this install script."
            Write-Host
            Return
        } # End Try

        } # End If


    # 5. Check for PSPing
    If (-Not (Test-Path $ToolPath"psping.exe")){
        # 5.1 If needed, download
        $File = $ToolPath + "psping.exe"
        Try {
            $webClient = new-object System.Net.WebClient
            $webClient.DownloadFile('https://live.sysinternals.com/psping.exe', $File)
            }
        Catch {
            Write-Host
            Write-Warning "Something bad happened with the PSPing download. Most likely either files are missing at the source or this host doesn't have internet access."
            Write-Host
            Write-Host "You can manually add the file and rerun this Install script."
            Write-Host "To manually install PSPing:"
            Write-Host "  1. Download the file from https://live.sysinternals.com/psping.exe"
            Write-Host "  2. Move the psping.exe file to the $ToolPath directory."
            Write-Host "  3. With psping.exe in place, rerun this install script."
            Write-Host
            Return
            } # End Try
        } # End If

    # 6. Check other files
    $FileName = @()
    If (-Not (Test-Path ($ToolPath + "Install-LinkPerformance.ps1"))){$FileName += 'Install-LinkPerformance.ps1'}
    If (-Not (Test-Path ($ToolPath + "Get-LinkPerformance.ps1"))){$FileName += 'Get-LinkPerformance.ps1'}
    If (-Not (Test-Path ($ToolPath + "iPerf-fw-rules.ps1"))){$FileName += 'iPerf-fw-rules.ps1'}
    #If (-Not (Test-Path ($ToolPath + "README.md"))){$FileName += 'README.md'}

    # 7. Pull from GitHub if needed
    If ($FileName.Count -gt 0) {
        Try {
            $uri = 'https://raw.githubusercontent.com/tracsman/1DayLab/DontLook/PerfTest/'
            ForEach ($File in $FileName) {
                $webClient = new-object System.Net.WebClient
                $webClient.DownloadFile( $uri + $File, $ToolPath + $File )
                } #End ForEach
            }
        Catch {
            Write-Host
            Write-Warning "Something bad happened pulling files from GitHub. Most likely either files are missing at the source or this host doesn't have internet access."
            Write-Host
            Write-Host "You can manually add the four files and rerun this Install script."
            Write-Host "To manually install the files:"
            Write-Host "  1. Go to https://github.com/tracsman/1DayLab/tree/DontLook/PerfTest"
            Write-Host "  2. Download the files in that directory to the local $ToolPath directory."
            Write-Host "  3. With these files in place, rerun this install script."
            Write-Host
            Return
            } # End Try
        } # End If

    # 8. Kill PSPing popup
    $cmd = $ToolPath + "psping.exe -accepteula | Out-Null"
    Invoke-Expression -Command $cmd

    # 9. Open Firewall rules
    If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
        {Start-Process powershell -Verb runAs -ArgumentList ($ToolPath + "iPerf-fw-rules.ps1")}
    Else {Invoke-Expression -Command ($ToolPath + "iPerf-fw-rules.ps1")}

} # End Function

Install-LinkPerformance -Force
