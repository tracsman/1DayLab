# 1. Start iPerf in server mode on remote host
# 2. Set Remote Host ip address
# 3. Run script
# 4. Scrape data from log files

# Feature Backlog
# Add Param for remote hostAdd Param for Win/Linux (default Win, port 3389)Add Param for Duration (default 60 seconds)
# Check for FW rulesApply if not found
# Check for Tools dirDownload if not found
# Check for bitsDownload if not found
# Validate PSPing connectivity (two ping)Error Stop
# Validate iPerf3 connectivity (two ping)Error Stop
# Correct invalid warning about the Jon.IPerf3 job not found, ignore if not found


$RemoteHost = "10.100.20.21"
$FileArray = "P00", "P01", "P06", "P16", "P17", "P32"
#$FileArray = "P01"

Write-Host "Ensure iPerf is running in server mode on remote host."
Pause

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
    $Test | Add-Member -Name 'Latency' -MemberType NoteProperty -Value $Ping
    $Test | Add-Member -Name 'Loss' -MemberType NoteProperty -Value $Loss
    $Test | Add-Member -Name 'Bandwidth' -MemberType NoteProperty -Value $TPut
    $TestResults += $Test
}

$TestResults
