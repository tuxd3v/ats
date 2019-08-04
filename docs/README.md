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
* [Donations](#donations)
* [Credits](#credits)

### Characteristics:
----
#####  Curve Response of PWM to Temperature:

![Response of PWM to Temperature Curve:](https://github.com/tuxd3v/ats/blob/master/docs/response_curve.png)

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
   ```
4. ```lua
    -20°C >= Temp >= 70°C,
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
 * Install Automatically( method 1,2 in 'Install' section bellow )
   ```lua
   apt-get install lua5.3 lua5.3-dev gcc make
   update-alternatives --install /usr/bin/lua lua /usr/bin/lua5.3 1
   update-alternatives --install /usr/bin/luac luac /usr/bin/luac5.3 1
   apt-get install luarocks
   ```
 * Install Manually( method 3, in 'Install' section bellow )
   ```lua
   apt-get install lua5.3 lua5.3-dev gcc make
   
   Nota:
   You can also add git, to download the code..
   ```

### Install/Remove
----
Several independent Options: Master, Release and Manual.

##### 1. Using Luarocks 
 a. ###### Install from master( last code, but more prone to errors.. )
    * `luarocks build  https://raw.githubusercontent.com/tuxd3v/ats/master/ats-master-0.rockspec`

 b. ###### Install by release, check in Releases tab( ie: v0.2.0 ):
    * `luarocks build  https://raw.githubusercontent.com/tuxd3v/ats/master/ats-0.2-0.rockspec`

 c. ###### Remove using LuaRocks
    * `luarocks remove ats`

###### 2. Compile/Install/Remove manually, using make ( need to download first the code ie: with git, by browser).
 1. Run 'all' target
    *  `make`
 2. Run 'install' target
    * `make install`
 3. Run 'purge' target( the downloaded code is removed, **not** the installed one.. )
    * `make purge`
 4. Run 'remove' target( remove ats from system )
    * `make remove`

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

#### Run Test/Adjust Values
----
You can execute in **test mode**( to see state values, and configuration ),
and also edit '**/etc/ats.conf**', to tune for your Cooling-System, or preferences..

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

### Donations
----
ATS project, is been made availlable by me, has a way to have a active cooling tool, for Our SBCs..

If you want to help this project, consider a donation..
```lua
 - Magi Address    : 96H3wSX8e5sqJ1tHpXjhJrppKhsLQEWFMz
 - Monero Address  : 47gzrS7JU5E7tUF9YcdgXw68DhbJokuHTWKSr42LcmU4RTFFvCoU8W7NDjauef5kGQY5WRZXfoVWENutt3afKv9YDufEgJx
 - AEON Address    : WmtL2wph84vb5inWpMoXFucwBmDtF4BsLLjWvP4LEd435tvjpfcUTjegSXKnrT3FjATzo8X8ouSwVArooxmauniP2TLKCXQdc
 - VertCoin Address: vtc1qmck0q88enwneha75cpfcys6eyst4rnsr8h2uk8
 - Ryo Address     : RYoKsxn7kT4DZVagVtmTuT5wwvrQ2f38pJ8AcE2jcUyogcNVFZ2syeN
 - BitCoin Address : 1GuBhkustzsCLUbFhRLcppp9Pf4KW9TxXQ
 - Ethereum Address: d468db56e89c883C4046D50A2261D5CE4dF4eFCD
```
### Credits
----
ATS             : tuxd3v

Fan Icon	: `[ freepik ] | https://www.flaticon.com/authors/freepik`
