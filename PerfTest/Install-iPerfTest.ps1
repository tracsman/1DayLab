# Temp
# Initalize
# Check/create Tools dir
# Check for iPerf files
    # If either are needed, download, extract
# Check for PSPing
    # If needed, download
# Check other files
# Pull whats needed
# Kill popups
# Open Firewall rules





# 1. Create C:\ExRTools
# 2. Copy iPerf and PSPing
# 3. Kill PSPing popup
# 4. Open Firewall rules
# 5. Update path <<stretch>>

# 1. Initialize
$ToolPath = "C:\ExRTools"

# 1. Create C:\ExRTools
If (-Not (Test-Path $ToolPath)){New-Item -ItemType Directory -Force -Path $ToolPath | Out-Null}

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
C:\Tools\psping.exe -accepteula | Out-Null

# 4. Open Firewall rules
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    {Start-Process powershell -Verb runAs -ArgumentList $ToolPath + "iPerf-fw-rules.ps1"
    Break}
