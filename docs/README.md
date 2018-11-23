# <p align="bottom"><img height="50" width="50" src="https://github.com/tuxd3v/ats/blob/master/docs/fan.svg" /> | ATS - Active Thermal Service</p>
---
Active Fan Thermal Service tool, to Control Processor Temperature on RockPro64 Single Board Computer,

But could be adapted to other boards too..
This tool is system Agnostic.

The Control is Made via SysFS, based in the Lua Scripting Language.
You can Adapt the file ats, if you want( its configured  for RockPro64 )


#### Table of contents
* [Characteristics](#characteristics)
* [Requirements](#requirements)
* [Install](#install)
* [Run Test](#run-test)
* [Version](#check-ats-version)
* [Credits](#credits)

### Characteristics:
----
#####  Curve Response of PWM to Temperature:

![Response of PWM to Temperature Curve:](https://github.com/tuxd3v/ats/blob/master/docs/PWM_curve_response_3.png)

##### Explanation:
    
1. ```lua
   Temp < 40°C,
     Fan will Stop
   ```
2. ```lua
   40°C <= Temp <= 60°C,
     Fan is Adjusted, acordingly like in the Chart, 'PWM Curve Response'
   ```
3. ```lua
   60°C < Temp < 70°C,
     Fan set to Maximum Value..
4. ```lua
   Temp >= 70°C,
     System will shutdown in 10 Seconds..
   ```
	Nota:
	
	RockChip has done its tests on a Board, at 80°C,
	They rate the CPU at -20°C <= Absolute Maximum <= 85°C( 125°C were junction temperature will start to cause damage permanently )..
	The CPU should make a emergency shutdown at around 85°C, so better operate lower..

	For reliability, high temperatures are not good to maintain Continuously( Rockchip also make some provisions to that in the datasheet.. ),
	So I decided to take some precaution measures here, shutting down at 70°C, for the sake of reliability..



## Requirements:
----
To use ATS: First, you need to install its depedencies..

### Debian/Ubuntu

###### 1. Install Dependencies.
   * `apt-get install lua5.3 lua5.3-dev luarocks gcc make`

	Nota:
	You can also use git, to download, ( if you want to install manually..step 3. ).
   * `ln -s /usr/bin/lua5.3 /usr/bin/lua`

### Install
----
Several independent Options: Master, Release and Manual.

###### 1. Install from master( last code, but more prone to errors.. )
   * `luarocks build  https://raw.githubusercontent.com/tuxd3v/ats/master/ats-master-0.rockspec`

###### 2. Install by release, check in Releases tab( ie: v0.1.8 ):
   * `luarocks build  https://raw.githubusercontent.com/tuxd3v/ats/master/ats-0.1-8.rockspec`

###### 3. Compile/Install/Remove manually, using make ( need to download first the code ie: with git, by browser).
 1. Run 'all' target
    *  `make`
 2. Run 'install' target
    * `make install`
 3. Run 'purge' target( the downloaded code is removed, **not** the installed one.. )
    * `make purge`

#### After install, verify the end of the output for something like:
	systemctl status ats

	● ats.service - ATS - Active Thermal Service
	   Loaded: loaded (/lib/systemd/system/ats.service; enabled; vendor preset: enabled)
	   Active: active (running) since Fri 2018-11-23 01:43:10 WET; 47s ago
	 Main PID: 21040 (lua)
	    Tasks: 1 (limit: 4642)
	   CGroup: /system.slice/ats.service
		   └─21040 lua /usr/local/sbin/ats

	Nov 23 01:43:10 rockpro64 systemd[1]: Started ATS - Active Thermal Service.

#### Run Test
----
You can execute in **test mode**( to see state values ),

 1. Stop the service first:
    * `service ats stop`
 2. Start in test mode( 2 similar options, **pick only one** .. to exit, just press ctrl+c keys ):
    * `ats -t`
    * `ats --test`
 3. After tests, start as a service:
    * `service ats start`
 4. Check if service started
    * `service ats status`

#### Check ATS version
----
Check which version you have installed:
 * `ats -v`
 * `ats --version`
 
### Credits
----
ATS             : tuxd3v

Fan Icon	: `[ freepik ] | https://www.flaticon.com/authors/freepik`

