Cron Scripts
==============
Use these to call functions at certain intervals
###Recommended Crontab
```shell
* * * * * sh /root/scripts/impulse_dhcpdgen
* * * * * sh /root/scripts/impulse_dhcpdload > /dev/null
0 0 * * 0 sh /root/scripts/impulse_dhcpdclean > /dev/null
0 0 * * * sh /root/scripts/impulse_notifyexpire > /dev/null
0 0 * * * sh /root/scripts/impulse_expire > /dev/null
0 0 * * * sh /root/scripts/impulse_logclean > /dev/null
```
