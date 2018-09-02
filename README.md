# fanctl

Active Fan Thermal tool to Control Processor Temperature to #### RockPro64,

But Could be adapted to other boards too..
This tool is system Agnostic.

The Control is Made via SysFS, based in the Lua Scripting Language.

You can Adapt the file fanctl, if you want( its configured  for #### RockPro64 )
to adjust your paths on SysFs

Characteristics:

	1. Temp < 45 Degrees Celsius,
		Fan will Stop

	2. 45 <= TEMP <= 62 , Temp is Adjusted

	3. 70 > Temp <= 63 Degrees Celsius,
		system will UnderClock Frequencies

	4. Temp > 70 Degrees Celsius,
		System will shutdown in 10 Seconds..


## Requirements:
	Only a Single Dependence,
	The Lua 5.3 Runtime.


### Debian/Ubuntu

### Install Dependencies.
	apt-get install lua5.3

##### Then made the Symbolic Link:
	ln -s /usr/bin/lua5.3 /usr/bin/lua


### Configure fanctl

####  Copy Fanctl to /usr/sbin/
	cp fanctl /usr/sbin/ && chmod 550 /usr/sbin/fanctl && chown root: /usr/sbin/fanctl

#### Copy the Systemd Service file to Destination Folder
	cp fanctl.service /lib/systemd/system

#### Tell systemd to enable Service
	systemctl enable fanctl

#### Start the Service
	systemctl start fanctl


That's it!!!

