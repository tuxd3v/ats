# fanctl

Active Fan Thermal tool, to Control Processor Temperature on RockPro64 Single Board Computer,

But Could be adapted to other boards too..
This tool is system Agnostic.

The Control is Made via SysFS, based in the Lua Scripting Language.
You can Adapt the file fanctl, if you want( its configured  for RockPro64 )

Characteristics:


	1. Temp < 40 Degrees Celsius,
		Fan will Stop

	2. 40 <= Temp <= 62 Degrees Celsius,
	    Fan is Adjusted, acordingly like in the Chart, 'Active Fan Thermal Envelope'   --- >                        ![alt text](https://github.com/tuxd3v/fanctl/master/ative_fan_thermal_envelope.png) 

	3. 63 <= Temp < 70 Degrees Celsius,
		Fan set do Maximum Value..

	4. Temp >= 70 Degrees Celsius,
		System will shutdown in 10 Seconds..
		
		Nota:
		RockChip as done its tests on a Board at 80 or 85C, but that temps are not good to maintain Continously,
		And so I decided to take some precation mesures here..


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

#### Enable and Start Service
	systemctl enable fanctl && systemctl start fanctl

#### Check the Status
	systemctl status fanctl

	root@rockpro64:# systemctl status fanctl
	● fanctl.service - Active Thermal Fan Service
	   Loaded: loaded (/lib/systemd/system/fanctl.service; enabled; vendor preset: enabled)
	   Active: active (running) since Sat 2018-09-01 23:23:49 WEST; 3h 0min ago
	 Main PID: 704 (lua)
		Tasks: 3 (limit: 4915)
	   CGroup: /system.slice/fanctl.service
		       ├─  704 lua /usr/sbin/fanctl
		       ├─19575 sh -c sleep 5
		       └─19576 sleep 5
	Sep 01 23:23:49 rockpro64 systemd[1]: Started Active Thermal Fan Service.


That's it!!!

