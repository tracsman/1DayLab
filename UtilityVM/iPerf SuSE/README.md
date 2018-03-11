Put both files into /tmp
Then run:
    
    zypper install libiperf0-3.1.3-50.1.x86_64.rpm
    zypper install iperf-3.1.3-50.1.x86_64.rpm

Note: if the firewall is on, use the following to turn off:

    sudo /sbin/rcSuSEfirewall2 stop
    sudo /sbin/rcSuSEfirewall2 status