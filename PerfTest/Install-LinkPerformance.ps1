# 1. Warning check
# 2. Initialize
# 3. Create C:\ACTTools dir
# 4. Check for iPerf files
#    4.1 If either are needed, download, extract
# 5. Check for PSPing
#    5.1 If needed, download
# 6. Check other files
#    6.1 Pull from GitHub if needed
# 7. Kill PSPing popup
# 8. Open Firewall rules

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
    Write-Host "  This script will install 3rd party products: iPerf3 and PSPing"
    Write-Host "  As well as open firewall port 5201 and allow ICMPv4"
    Write-Host
    $foo = Read-Host -Prompt "Are you sure you wish to continue? [y]"
    If ($foo -ne "y" -and $foo -ne "") {"I'm scared!";Return}
    
    } # End If


# 2. Initialize
$ToolPath = "C:\ACTTools\"

# 3. Create C:\ACTTools dir
If (-Not (Test-Path $ToolPath)){New-Item -ItemType Directory -Force -Path $ToolPath | Out-Null}


# 4. Check for iPerf files






#    4.1 If either are needed, download, extract
# 5. Check for PSPing
#    5.1 If needed, download
# 6. Check other files
#    6.1 Pull from GitHub if needed
# 7. Kill PSPing popup
# 8. Open Firewall rules



# 2. Copy iPerf and PSPing
$FileName = @()
If (-Not (Test-Path $ToolPath + "PSPing.exe")){$FileName += 'psping.exe'}
If (-Not (Test-Path $ToolPath + "cygwin1.dll")){$FileName += 'cygwin1.dll'}
If (-Not (Test-Path $ToolPath + "iperf3.exe")){$FileName += 'iperf3.exe'}
If (-Not (Test-Path $ToolPath + "iPerf-fw-rules.ps1")){$FileName += 'iPerf-fw-rules.ps1'}
If (-Not (Test-Path $ToolPath + "iPerfTest.ps1")){$FileName += 'iPerfTest.ps1'}

If ($FileName.Count -gt 0) {
    Try {
        $uri = 'https://raw.githubusercontent.com/tracsman/1DayLab/DontLook/PerfTest/'
        ForEach ($File in $FileName) {
            $webClient = new-object System.Net.WebClient
            $webClient.DownloadFile( $uri + $File, $ToolPath + $File )
        }
    }
    Catch {
        Write-Warning "Something bad happened with the download. Most likely either files are missing or you don't have internet access. Please try again, or contact your administrator."
        Return
    }

}

# 3. Kill PSPing popup
C:\ACTTools\psping.exe -accepteula | Out-Null

# 4. Open Firewall rules
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    {Start-Process powershell -Verb runAs -ArgumentList $ToolPath + "iPerf-fw-rules.ps1"
    Break}
