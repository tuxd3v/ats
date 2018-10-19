# fanctl

Active Fan Thermal tool, to Control Processor Temperature on RockPro64 Single Board Computer,

But Could be adapted to other boards too..
This tool is system Agnostic.

The Control is Made via SysFS, based in the Lua Scripting Language.
You can Adapt the file fanctl, if you want( its configured  for RockPro64 )

### Characteristics:

#####  Curve Response of PWM to Temperature:

![Response of PWM to Temperature Curve:](https://github.com/tuxd3v/fanctl/blob/master/PWM_curve_response_3.png)

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

### Debian/Ubuntu

### Install Dependencies.
	apt-get install lua5.3 lua5.3-dev luarocks gcc make
	
	Nota:
	You can also use git, to download, ( if you want to install manually..step 3. ).

######    If doesn't exist, then create the Symbolic Link:
	ln -s /usr/bin/lua5.3 /usr/bin/lua
######    Provide Lua with locations of needed Libraries.
cat \<\<HERE \>\> /etc/luarocks/config.lua'\n'
variables={'\n'
        UNISTD_INCDIR   = "/usr/include",'\n'
        LUALIB_INCDIR   = "/usr/include/lua5.3",'\n'
        LAUXLIB_INCDIR  = "/usr/include/lua5.3",'\n'
        LUA_INCDIR      = "/usr/include/lua5.3",'\n'
        LUA53_LIBDIR    = "/usr/lib/aarch64-linux-gnu"'\n'
}'\n'
HERE'\n'

### Install fanctl

####      Several independent Options:

######    1. Install from master( last code, but more prone to errors.. )
	luarocks build  https://raw.githubusercontent.com/tuxd3v/fanctl/master/fanctl-master-0.rockspec

######    2. Install by release, check in Releases tab( ie: v0.1.6 ):
	luarocks build  https://raw.githubusercontent.com/tuxd3v/fanctl/master/fanctl-0.1-6.rockspec

######    3. Compile/Install/Remove manually, using make ( need to download first the code ie: with git, by browser).
	make
	make install
	
    After instalation, remove the downloaded code
	make purge

#### After install, verify the end of the output for something like:
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

