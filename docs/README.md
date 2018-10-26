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
* [Credits](#credits)


### Characteristics:
----
#####  Curve Response of PWM to Temperature:

![Response of PWM to Temperature Curve:](https://github.com/tuxd3v/ats/blob/master/docs/PWM_curve_response_3.png)

##### Explanation:
    
1. ```lua
   Temp < 39°C,
     Fan will Stop
   ```
2. ```lua
   39°C <= Temp <= 60°C,
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
	RockChip has done its tests on a Board, at 80°C,they rate the CPU at 125°C absolute maximum(  were junction temperature will start to cause damage permanetly )..
	For Permanent use they rate it at 85 °C max( also it should make a emergency shutdown at around 85°C ).

	But this temps are not good to maintain Continuously( they also make some provisions to that in the datasheet.. ),
	So I decided to take some precaution measures here, shutting down at 70°C, for the sake of reliability.
	Honestly speaking, you should not get past 60, in continuous environment..



## Requirements:
----
To use ATS: First, you need to install its depedencies..

### Debian/Ubuntu

###### 1. Install Dependencies.
 * `apt-get install lua5.3 lua5.3-dev luarocks gcc make`
 
	Nota:
	You can also use git, to download, ( if you want to install manually..step 3. ).

 * `ln -s /usr/bin/lua5.3 /usr/bin/lua`

 * Provide Lua with locations of needed Libraries( needed only, if you install by steps 1, or 2 ..**see Install** section below ).
   ```sh
   cat <<HERE >> /etc/luarocks/config.lua
   variables={
		UNISTD_INCDIR   = "/usr/include",
		STAT_INCDIR	= "/usr/include/aarch64-linux-gnu",
		TYPES_INCDIR	= "/usr/include/aarch64-linux-gnu",
		LUALIB_INCDIR   = "/usr/include/lua5.3",
		LAUXLIB_INCDIR  = "/usr/include/lua5.3",
		LUA_INCDIR      = "/usr/include/lua5.3",
		LUA53_LIBDIR    = "/usr/lib/aarch64-linux-gnu"
   }
   HERE
   ```

### Install
----
Several independent Options: Master, Release and Manual.

###### 1. Install from master( last code, but more prone to errors.. )
 * `luarocks build  https://raw.githubusercontent.com/tuxd3v/ats/master/ats-master-0.rockspec`

###### 2. Install by release, check in Releases tab( ie: v0.1.6 ):
 * `luarocks build  https://raw.githubusercontent.com/tuxd3v/ats/master/ats-0.1-6.rockspec`

###### 3. Compile/Install/Remove manually, using make ( need to download first the code ie: with git, by browser).
 1. Run 'all' target
    *  `make`
 2. Run 'install' target
    * `make install`
 3. Run 'purge' target( the downloaded code is removed, **not** the installed one.. )
    * `make purge`

#### After install, verify the end of the output for something like:
	systemctl status ats

	● ats.service - Active Thermal Fan Service
	   Loaded: loaded (/lib/systemd/system/ats.service; enabled; vendor preset: enabled)
	   Active: active (running) since Thu 2018-09-13 20:29:54 WEST; 3s ago
	 Main PID: 29133 (lua)
		Tasks: 1 (limit: 4915)
	   CGroup: /system.slice/ats.service
		       └─29133 lua /usr/sbin/ats

	Sep 13 20:29:54 rockpro64 systemd[1]: Started Active Thermal Fan Service.

#### Run Test
----
You can execute in **test mode**( to see state values ),

1. Stop the service first:
 * `service ats stop`
2. Start in test mode( 2 similar options, **pick only one** .. to exit, just press ctrl+c keys ):
 * `ats --test`
 * `ats -t`
3. After tests, start as a service:
 * `service ats start`
4. Check if service started
 * `service ats status`

### Credits
----
ATS             : tuxd3v

Fan Icon	: `[ freepik ] | https://www.flaticon.com/authors/freepik`

