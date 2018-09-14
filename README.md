# fanctl

Active Fan Thermal tool, to Control Processor Temperature on RockPro64 Single Board Computer,

But Could be adapted to other boards too..
This tool is system Agnostic.

The Control is Made via SysFS, based in the Lua Scripting Language.
You can Adapt the file fanctl, if you want( its configured  for RockPro64 )

### Characteristics:

#####  Curve Response of PWM to Temperature:

![Response of PWM to Temperature Curve:](https://github.com/tuxd3v/fanctl/blob/master/PWM_curve_response.png)

##### Explanation:
    
	1. Temp < 39 Degrees Celsius,
		Fan will Stop

	2. 39 <= Temp <= 60 Degrees Celsius,
	    Fan is Adjusted, acordingly like in the Chart, 'PWM Response to Temperature'

	3. 60 < Temp < 70 Degrees Celsius,
		Fan set do Maximum Value..

	4. Temp >= 70 Degrees Celsius,
		System will shutdown in 10 Seconds..
		
		Nota:
		RockChip has done its tests on a Board, at 80C,they rate it as the maximum.
		But that temps are not good to maintain Continuously,
		So I decided to take some precaution measures here, shutting down at 70 Degrees Celsius.



## Requirements:

### Debian/Ubuntu

### Install Dependencies.
	apt-get install lua5.3 lua5.3-dev gcc make git
	
	Nota:
	Git needed only to get the Code,( If you download with another tool, ignore it.. )

######    Then made the Symbolic Link:
	ln -s /usr/bin/lua5.3 /usr/bin/lua

### Download/Compile/Configure/Install fanctl
######    If you Have already fanctl Running with a previous release, then:
	systemctl stop fanctl
	
######    Change to /root Dir, then Go to Releases, get last one, by tag( ie: v0.1.4 ):
	cd /root && git clone --branch v0.1.4 https://github.com/tuxd3v/fanctl.git && cd fanctl
	make
	make install
	make clean

#### Enable and Start Service
	systemctl enable fanctl && systemctl start fanctl

#### Check the Status
	systemctl status fanctl

	● fanctl.service - Active Thermal Fan Service
	   Loaded: loaded (/lib/systemd/system/fanctl.service; enabled; vendor preset: enabled)
	   Active: active (running) since Thu 2018-09-13 20:29:54 WEST; 3s ago
	 Main PID: 29133 (lua)
		Tasks: 1 (limit: 4915)
	   CGroup: /system.slice/fanctl.service
		       └─29133 lua /usr/sbin/fanctl

	Sep 13 20:29:54 rockpro64 systemd[1]: Started Active Thermal Fan Service.


That's it!!!

