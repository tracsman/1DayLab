# Must be run as admin

# Turn On ICMPv4
Try {Get-NetFirewallRule -Name Allow_ICMPv4_in -ErrorAction Stop | Out-Null}
Catch {New-NetFirewallRule -DisplayName "Allow ICMPv4" -Name Allow_ICMPv4_in -Action Allow -Enabled True -Profile Any -Protocol ICMPv4 | Out-Null}

# Turn On iPerf3
Try {Get-NetFirewallRule -Name Allow_iPerf3_in -ErrorAction Stop | Out-Null}
Catch {New-NetFirewallRule -DisplayName "Allow iPerf3" -Name Allow_iPerf3_in -Action Allow -Enabled True -Profile Any -Protocol TCP -LocalPort 5201 | Out-Null}
