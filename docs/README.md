# ATS - Active Thermal Service

Active Fan Thermal Service tool, to Control Processor Temperature on RockPro64 Single Board Computer,

But Could be adapted to other boards too..
This tool is system Agnostic.

The Control is Made via SysFS, based in the Lua Scripting Language.
You can Adapt the file ats, if you want( its configured  for RockPro64 )

### Characteristics:

#####  Curve Response of PWM to Temperature:

![Response of PWM to Temperature Curve:](https://github.com/tuxd3v/ats/blob/master/docs/PWM_curve_response_3.png)

##### Explanation:
    
	1. Temp < 39°C,
		Fan will Stop

	2. 39°C <= Temp <= 60°C,
		Fan is Adjusted, acordingly like in the Chart, 'PWM Curve Response'

	3. 60°C < Temp < 70°C,
		Fan set do Maximum Value..

	4. Temp >= 70°C,
		System will shutdown in 10 Seconds..
		
	Nota:
	RockChip has done its tests on a Board, at 80°C,they rate it as the maximum.
	But that temps are not good to maintain Continuously,
	So I decided to take some precaution measures here, shutting down at 70°C.



## Requirements:
To use ATS,
First, you need to install its depedencies..

### Debian/Ubuntu

###### 1. Install Dependencies.
 * `apt-get install lua5.3 lua5.3-dev luarocks gcc make`
   ```
   Nota:
   `You can also use git, to download, ( if you want to install manually..step 3. ).
   ```

 * `ln -s /usr/bin/lua5.3 /usr/bin/lua`

 * Provide Lua with locations of needed Libraries( needed only, if you install by steps 1, or 2 ..**see Install** section below ).
   ```sh
   cat <<HERE >> /etc/luarocks/config.lua
   variables={
           UNISTD_INCDIR   = "/usr/include",
           LUALIB_INCDIR   = "/usr/include/lua5.3",
           LAUXLIB_INCDIR  = "/usr/include/lua5.3",
           LUA_INCDIR      = "/usr/include/lua5.3",
           LUA53_LIBDIR    = "/usr/lib/aarch64-linux-gnu"
   }
   HERE
   ```

### Install ATS

#### Several independent Options:

###### 1. Install from master( last code, but more prone to errors.. )
 * `luarocks build  https://raw.githubusercontent.com/tuxd3v/ats/master/ats-master-0.rockspec`

###### 2. Install by release, check in Releases tab( ie: v0.1.6 ):
 * `luarocks build  https://raw.githubusercontent.com/tuxd3v/ats/master/ats-0.1-6.rockspec`

###### 3. Compile/Install/Remove manually, using make ( need to download first the code ie: with git, by browser).
 * make
 * make install

 After instalation, remove the downloaded code
 * make purge

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

#### Run Some tests..
###### You can run some tests( to see state values ),
1. Stop the service first:
* `service ats stop`
2. Start in test mode( 2 equal options, **pick only one** .. to exit, just press ctrl+c keys ):
* `ats --test`
* `ats -t`
3. After tests, start as a service:
* `service ats start`
4. Check if service started
* `service ats status`



That's it!!!

