Put file into /tmp
Then run:
    
    rpm -i iperf3-3.1.3-1.fc24.x86_64.rpm

Check Firewall:

    systemctl status firewalld

Note: if the firewall is on , use the following to turn off:

    iptables-save
    service firewalld stop
