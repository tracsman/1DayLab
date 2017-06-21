function Get-LinkPerformance {
    # Temp
    #
    # 1. Evaluate and Set input parameters
    # 2. Initialize
    # 3. Validate PSPing connectivity (two ping)Error Stop
    # 4. Validate iPerf3 connectivity (two ping)Error Stop
    # 5. Clear old log data
    # 6. Main Test Loop
    #    6.1 Start iPerf if required
    #    6.2 Start PSPing
    #    6.3 Wait for jobs to finish
    # 7. Parse each job file for data
    # 8. Output results

    # Feature Backlog
    # Correct invalid warning about the Jon.IPerf3 job not found, ignore if not found

    # File links
    # https://live.sysinternals.com/psping.exe 
    # https://iperf.fr/download/windows/iperf-3.1.3-win64.zip

    <#
    .SYNOPSIS
        Run a series of iPerf load tests and PSPing TCP pings concurrently between a local source and a remote host
        running iPerf3 in server mode. Seven tests of increasing load are performed and results are output at the
        conclusion of the test.

    .DESCRIPTION
        Run a series of iPerf load tests and PSPing TCP pings concurrently between a local source and a remote host
        running iPerf3 in server mode. Seven tests of increasing load are performed and results are output at the
        conclusion of the test.

        The remote server must be running iPerf3 in server mode; e.g iPerf3 -s

        On the local server from which this function is run, vaious parameters can be used to affect the testing.
        The output is a combination of both the load test and the latency test while the perf test is running.
        Each row of output represtents the summation of a given test, the follow test conditions are run:
         - No load, a PSPing TCP test without iPerf3 running, a pure latency test
         - 1 Session, a PSPIing TCP test with iPerf3 running a single thread of load
         - 6 Sessions, a PSPing TCP test with iPerf3 running a six thread load test
         - 16 Sessions, a PSPing TCP test with iPerf3 running a 16 thread load test
         - 16 Sessions with 1Mb window, a PSPing TCP test with iPerf3 running a 16 thread load test with a 1Mb window
         - 32 Sessions, a PSPing TCP test with iPerf3 running a 32 thread load test

         For each test iPerf is kicked off and allowed to run for 10 seconds to establish the load and allow it to level
         Then PSPing is kicked off to record latency during the load test.
         Results from each test are stored in a text file in user profile directory ($env:USERPROFILE)

         Output for each test is displayed in a table with the following columns:
          - Name: The name of the test for these values, eg No load, 1 session, etc
          - Bandwidth: The average bandwidth achieved by iPerf for the given test
          - Loss: percentage of packet lost during the PSPing test
          - P50 Latency: the 50th percentile of latency seen during the test

          If the Verbose option (-Verbose) is used:
          - P90 Latency: the 90th percentile of latency seen during the test
          - P95 Latency: the 95th percentile of latency seen during the test
          - Min Latency: the minumum TCP ping latency seen during the test
          - Max Latency: the maximum TCP ping latency seen during the test

    .PARAMETER RemoteHost
        This parameter is required and is the Remote Host IP Address. This host must be running iPerf3 in server mode and
        be listening on either port 22 (SSH) for Linux hosts or 3389 (RDP) for Windows hosts.

    .PARAMETER HostType
        This optional parameter signifies the operating system of the REMOTE host. Valid values are "Windows" or "Linux".
        It is assumed that if the remote host is Linux that port 22 is open for the PSPing, if Windows PSPing will use
        the RDP port 3389

    .PARAMETER TestSeconds
        This optional parameter signifies the duration of PSPing test in seconds. It is an integer value (whole number).
        The range of valid values is 60 - 3600 seconds (1 minute - 1 hour). The default value is 60.

    .EXAMPLE
        Get-LinkPerformance -RemoteHost 10.0.0.1

        # Get network performance stats from a windows server at 10.0.0.1 for 6 one minute tests (default host type
        (Windows) and test duration (60 seconds) )

    .EXAMPLE
        Get-LinkPerformance -RemoteHost 10.0.0.1 -HostType Linux -TestSeconds 3600

        # Get network performance stats from a Linux server at 10.0.0.1 for 6 one-hour tests (3600 seconds)

    .EXAMPLE
        (Get-AzureVM -ServiceName 'myServiceName' -Name 'myVMName').IpAddress | Get-LinkPerformance

        # Pull VNet IP address from a VM in Azure and pipe it to the Get-AzureNetworkAvailability cmdlet

    .LINK
        https://github.com/Azure/NetworkMonitoring

    .NOTES
        This script will run against a remote server that must be running iPerf3 in server mode with firewall ports
        open to allow iPerf and the approprate PSPing port (22 or 3389). If the remote server is a windows machine
        an easy way to ensure proper configuration is to install the LinkPerformance tool on that remote machine and
        then run iPerf3 in server mode (iperf3 -s)
        More information can be found at https://github.com/Azure/NetworkMonitoring

    #>
    
    # 1. Evaluate and Set input parameters
    [cmdletBinding()]
    Param(
       [Parameter(ValueFromPipeline=$true,
                  Mandatory=$true,
                  HelpMessage='Enter IP Address of Remote Azure VM')]
       [ipaddress]$RemoteHost,
       [ValidateSet(“Windows”,”Linux”)]
       [string]$HostType="Windows",
       [ValidateRange(60,3600)] 
       [int]$TestSeconds=60
    )

    # 2. Initialize
    $Verbose = $VerbosePreference -ne [System.Management.Automation.ActionPreference]::SilentlyContinue
    $FileArray = "P00", "P01", "P06", "P16", "P17", "P32"
    #$FileArray = "P01"

    Write-Host "Ensure iPerf is running in server mode on remote host."
    Pause
    
    # 3. Validate PSPing connectivity (two ping)Error Stop

    # 4. Validate iPerf3 connectivity (two ping)Error Stop

    # Clear old run files
    If (Test-Path "$env:USERPROFILE\P*ping.log"){Remove-Item "$env:USERPROFILE\P*ping.log"}
    If (Test-Path "$env:USERPROFILE\P*perf.log"){Remove-Item "$env:USERPROFILE\P*perf.log"}

    # File Loop
    ForEach ($FilePrefix in $FileArray) {
        switch($FilePrefix) {
            "P00" {$Threads = 00; $TestName = "Stage 1 of 6: No Load Ping Test..."}
            "P01" {$Threads = 01; $TestName = "Stage 2 of 6: Single Thread Test..."}
            "P06" {$Threads = 06; $TestName = "Stage 3 of 6: 6 Thread Test..."}
            "P16" {$Threads = 16; $TestName = "Stage 4 of 6: 16 Thread Test..."}
            "P17" {$Threads = 16; $TestName = "Stage 5 of 6: 16 Thread Test with 1Mb window..."}
            "P32" {$Threads = 32; $TestName = "Stage 6 of 6: 32 Thread Test..."}
            default {Write-Error "Invalid FilePrefix, execution stopping!"; Return}
        } # End Switch

        # Decalare Test Starting
        Write-Host (Get-Date)' - ' -NoNewline
        Write-Host $TestName -ForegroundColor Cyan

        # Start iPerf
        $FileName=$env:USERPROFILE+"\"+$FilePrefix+"perf.log"
        Switch($FilePrefix) {
            "P00" {}
            "P17" {
                $iPerfJob = Start-Job -ScriptBlock {C:\tools\iperf3.exe -c $args[0] -t 70 -i 0 -P $args[1]  -w1M --logfile $args[2]} -Name 'Jon.iPerf3' -ArgumentList "$RemoteHost", "$Threads", "$FileName"
                Sleep -Seconds 5}
            default {
                $iPerfJob = Start-Job -ScriptBlock {C:\tools\iperf3.exe -c $args[0] -t 70 -i 0 -P $args[1] --logfile $args[2]} -Name 'Jon.iPerf3' -ArgumentList "$RemoteHost", "$Threads", "$FileName"
                Sleep -Seconds 5}
        } # End Switch
    
        # Start PSPing
        $FileName=$env:USERPROFILE+"\"+$FilePrefix+"ping.log"
        $HostPort = $RemoteHost+":3389"
        $iPerfJob = Start-Job -ScriptBlock {C:\tools\psping.exe -n 60s -4 $args[0] > $args[1]} -Name 'Jon.PSPing' -ArgumentList "$HostPort", "$FileName"

        # Wait for jobs to finish
        If ($FilePrefix -eq "P00") {$time=62}
        Else {$time = 71} # End If

        foreach($i in (1..$time)) {
            $percentage = $i / $time
            $remaining = New-TimeSpan -Seconds ($time - $i)
            $message = "{0:p0} complete, remaining time {1}" -f $percentage, $remaining
            Write-Progress -Activity $message -PercentComplete ($percentage * 100) -CurrentOperation $TestName
            Start-Sleep 1
        } # End For
        While ((Get-Job -Name "Jon.iPerf3" | Where State -eq 'Running').Count -gt 0) {
            Write-Host "Waiting for iPerf run to finish..."
            Sleep 2
        } # End While
    } # End For
 
    Write-Host "All Done!" -ForegroundColor Cyan

    # Test Loop
    $TestResults=@()

    # File Loop
    ForEach ($FilePrefix in $FileArray) {
        switch($FilePrefix) {
            "P00" {$TestName = "No Load"}
            "P01" {$TestName = "1 Session"}
            "P06" {$TestName = "6 Sessions"}
            "P16" {$TestName = "16 Sessions"}
            "P17" {$TestName = "16 Sessions with 1Mb window"}
            "P32" {$TestName = "32 Sessions"}
            default {}
        }

        # Line Loop
        $FileName = $env:USERPROFILE + "\" + $FilePrefix + "ping.log"
        $Loss = "Error"
        $Ping = "Error"
        Try {
            $Lines = Get-Content $FileName -ErrorAction Stop
            ForEach ($Line in $Lines) {
                If ($Line -like "*Sent*") {
                    $Loss = $Line.Substring($Line.IndexOf("(",0)+1,$Line.IndexOf(")",0)-$Line.IndexOf("(",0)-1)
                } # End If
                If ($Line -like "*Minimum*") {
                    $Ping = $Line.Substring($Line.IndexOf("=", $Line.IndexOf("Average",0))+2)
                } # End If
            } # End For
        } # End Try
        Catch {Write-Warning "Error reading or processing file: $FileName"}

        $FileName = $env:USERPROFILE + "\" + $FilePrefix + "perf.log"
        $TPut = "Error"
        If ($FilePrefix -eq "P00") {
             $TPut = "N/A"}
        Else {
            Try {
                $Lines = Get-Content $FileName -ErrorAction Stop
                ForEach ($Line in $Lines) {
                    If ($FilePrefix -eq "P01") {If (($Line -like "*receiver*")) {$TPut = $Line.Substring(38,17).Trim()} #End If
                    }
                    Else {
                        If (($Line -like "*SUM*" -and $Line -like "*receiver*")) {$TPut = $Line.Substring(38,17).Trim()} #End If
                    } # End Else
                } # End For
            } # End Try
            Catch {Write-Warning "Error reading or processing file: $FileName"}
        } # End If

        $Test = New-Object -TypeName PSObject
        $Test | Add-Member -Name 'Name' -MemberType NoteProperty -Value $TestName
        $Test | Add-Member -Name 'Bandwidth' -MemberType NoteProperty -Value $TPut
        $Test | Add-Member -Name 'Loss' -MemberType NoteProperty -Value $Loss
        $Test | Add-Member -Name 'P50' -MemberType NoteProperty -Value $PingP50
        $Test | Add-Member -Name 'P90' -MemberType NoteProperty -Value $PingP90
        $Test | Add-Member -Name 'P95' -MemberType NoteProperty -Value $PingP95
        $Test | Add-Member -Name 'Min' -MemberType NoteProperty -Value $PingMin
        $Test | Add-Member -Name 'Max' -MemberType NoteProperty -Value $PingMax
        
        $TestResults += $Test
    }

    If ($VerbosePreference) {$TestResults}
    Else {$TestResults | Select Name, Bandwidth, Loss, P50}
    

} # End Function

Get-LinkPerformance -RemoteHost 10.100.20.21
