@echo off
:: Disconnect the drive if it already exists to avoid errors

net use Z: /delete /y
net use K: /delete /y
::net use K: /delete /y

@echo off
::TRUENAS - 192.168.0.111 == TRUENAS
net use Z: \\TRUENAS\Shared\ 1q2w3e /user:TRUENAS\myan /persistent:yes
::net use Y: \\TRUENAS\Shared\myan\ 1q2w3e /user:192.168.0.111\myan /persistent:yes
::net use T: \\TRUENAS\Shared\kt\ 1q2sw3e /user:192.168.0.111\kt /persistent:yes
echo Drive Z: has been mapped successfully.

@echo off
net use M: \\192.168.0.201\myan 1q2w3e /user:192.168.0.201\myan /persistent:yes

@echo off
:: macmini 2014 1T SSD
net use K: \\192.168.0.200\kt\ 1q2w3e /user:192.168.0.200\kt /persistent:yes
echo Drive K: has been mapped successfully.




