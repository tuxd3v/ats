#! /usr/bin/env lua

-- This program sets pwm of Active thermal Solution for RockPro64
--
-- Nota :
-- Temperature can be more than real because of self heating
----------------------------------------------------------------------
-- Copyright (c) 2018 Carlos Domingues, aka tuxd3v <tuxd3v@sapo.pt>
-- 

---- Tests Done
--
-- This tool was tested 24x7, for more than 3 months, under Full Load, with:
-- < Minimal Debian Strech release > by ayufan

---- Require ATS module, to dynamic lynk against..
--
require( "ats" );

----
---- Thermal Global Variables
---

---  Path Locations for Control..
--

-- CPU Thermal Zone[ String ]
THERMAL0_CTL	= "N/A";
-- GPU Thermal Zone[ String ]
THERMAL1_CTL	= "N/A";
-- FAN Control[ String ]
FAN_CTL		= "N/A";


--- Profile Content
--

PROFILE = {
	-- Speed up the process of obtaining math.ceil()
	ceil				= math.ceil,
	
	--- Temperature Control Constants
	--

	-- Max Temperatue Allowed on CPU, Above this Threshold, machine will shutdown
	ABSOLUTE_MAX_THERMAL_TEMP	= 70,
	-- Max Temperature Allowed for adjusting fan pwm( On this threshold, and above, fan is always on MaxValue )
	MAX_CONTINUOUS_THERMAL_TEMP	= 60,
	-- Min Temperature  threshold to activate Fan
	MIN_THERMAL_TEMP		= 39,
	
	--- PWM Parameters Constants
	--
	
	-- Min PWM value, to Stop Fan.
	STOP_FAN_PWM			= 0,
	-- Max PWM value possible
	MAX_FAN_PWM			= 255,
	-- Adjust conform your Fan specs, some neds greater values, others work with less current( currently not being used .. )
	MIN_FAN_PWM			= 30,
	
	--- Active Solution, 2 profiles[ smallerfan, tallerfan ]
	--
	-- Chose Fan Profile,
	--  profile1 - smaller fan( ~10 mm taller )
	--  profile2 - talller fan( ~20 mm taller )
	FANSPEC				= "profile1",
	
	-- Function to calculate pwm values, using interpolated methods, based on profile
	getProfile_pwm	= function ( self, x )
				local p = self.FANSPEC
				if( p == "profile1" )
				then
					return self.ceil( 40 + ( 215 / 21 ) * ( x - 39 ) )
				elseif( p == "profile2" )
				then
					return self.ceil( 40 + ( 215 / 31 ) * ( x - 39 ) )
				end
	end,
	-- Function get pwm ratio
	getPratio	= function( self, t )
				return self.pwm_ratio[ t ]
	end,
	-- Function to get quiet timers, during which fan will stop
	getQtimer	= function( self, t )
				return self.quiet_timers[ t ]
	end,
	-- Function to get run timers, during which fan will run
	getRtimer	= function( self, t )
				return self.run_timers[ t ]
	end,
	-- Function to set quiet,run timers and pwm values
	setTriggers	= function( self, x )
				for i = x,( self.ABSOLUTE_MAX_THERMAL_TEMP + 10 ),1
				do
					if( i < self.MIN_THERMAL_TEMP )
					then
						self.pwm_ratio[ i ]		= self.STOP_FAN_PWM
						if( i <= 35 )
						then
							self.quiet_timers[ i ]	= 180
							self.run_timers[ i ]	= 6
							
						else
							self.quiet_timers[ i ]	= 120
							self.run_timers[ i ]	= 6
						end
					elseif( i >= self.MIN_THERMAL_TEMP and i <= self.MAX_CONTINUOUS_THERMAL_TEMP )
					then
						-- Calculate PWM values based on 2 functions with diferent pwm 'Response Curves'
						self.pwm_ratio[ i ]		= self.getProfile_pwm( self, i )
						if ( i <= 45 )
				  		then
							self.quiet_timers[ i ]	= 90
							self.run_timers[ i ]	= 10
							
				  		elseif( i <= 50 )
				  		then
							self.quiet_timers[ i ]	= 50
							self.run_timers[ i ]	= 20
							
				  		elseif( i <= 55 )
				  		then
							self.quiet_timers[ i ]	= 40
							self.run_timers[ i ]	= 30
							
				  		elseif( i <= 60 )
				  		then
							self.quiet_timers[ i ]	= 10
							self.run_timers[ i ]	= 60
							
				  		end
	  				elseif ( i > self.MAX_CONTINUOUS_THERMAL_TEMP )
	  				then
	  					self.pwm_ratio[ i ]	= self.MAX_FAN_PWM
	  					
	  					if( i < ( self.ABSOLUTE_MAX_THERMAL_TEMP - 5 ) )
						then
							self.quiet_timers[ i ]	= 6
							self.run_timers[ i ]	= 120
						else
							self.quiet_timers[ i ]	= 3
							self.run_timers[ i ]	= 160
						end
					end
				end
	end,
	-- PWM ratio, calculated based on interpolated values inside normal envelope, and some other values outside[ Global table of integer types ]
	pwm_ratio	= {},
	-- Sleep timer( in seconds ), sleeping with Fan Stoped[ Global table of integer types ]
	quiet_timers	= {},
	-- Sleep timer( in seconds ), used for sleeping with Fan Running[ Global table of integer types ]
	run_timers	= {}
}

--- Thermal values readed..
--

-- CPU  Thermal Zone[ Integer ], Initial value
THERMAL_0	= PROFILE.MAX_CONTINUOUS_THERMAL_TEMP
-- GPU Thermal Zone [ Integer ], Initial value
THERMAL_1	= PROFILE.MAX_CONTINUOUS_THERMAL_TEMP

-- Temperature Value( CPU or GPU ), Initial value 65°C
TEMP		= THERMAL_0 + 6
-- Fan Pwm Value[ Integer ], Initial value
FAN_PWM		= PROFILE.STOP_FAN_PWM


----
---- Core Functions
---

--- Find Device sysfs location
--
function getConditions()
	local open   = io.open
 	local handle = open( THERMAL0_CTL , "r")
	if ( handle ~= nil )
	then
		handle:close()
	else
		THERMAL0_CTL = "ERROR"
		return 1
	end
 	handle = open( THERMAL1_CTL , "r")
	if ( handle ~= nil )
	then
		handle:close()
	else
		THERMAL1_CTL = "ERROR"
		return 1
	end
 	handle = open( FAN_CTL , "r")
	if ( handle ~= nil )
	then
		handle:close()
	else
		FAN_CTL		= "ERROR"
		return 1
	end
	return 0
end

--- Set Fan PWM value[ integer ]
-- 
function setFanpwm( value )
    local RETURN = "N/A"
	local handle = io.open( FAN_CTL , "w")
	if ( handle ~= nil )
	then
		RETURN = handle:write( value, "" )
		handle:close()
		if( RETURN ~= nil and RETURN ~= "N/A" )
		then
			getFanpwm()
			if( tonumber( FAN_PWM ) == value )
			then
				FAN_PWM = value
				return 0
			end
		end
    end
    FAN_PWM = 0
    return 1
end

--- Get Fan PWM value[ integer ]
-- 
function getFanpwm()
	local RETURN	= "N/A";
	local handle	= io.open( FAN_CTL , "r")
	if ( handle ~= nil )
	then
		RETURN = handle:read("*a")
		handle:close()
		if( RETURN ~= nil and RETURN ~= "N/A" )
		then
			FAN_PWM = tonumber( RETURN )
			return 0
		end
	end
	FAN_PWM	= 255
	return 
end

--- Get Thernal Values[ integer ]
--
function getThermal()
	local RETURN = "N/A";
	local open	= io.open
	local handler = open( THERMAL0_CTL, "r" )
	if ( handler ~= nil )
	then
		RETURN = handler:read( "*a" )
		handler:close()
		if( RETURN ~= nil and RETURN ~= "N/A" )
		then
			THERMAL_0 = tonumber( RETURN  // 1000 )
		else
			THERMAL_0 = MAX_CONTINUOUS_THERMAL_TEMP
		end
	else
			THERMAL_0 = MAX_CONTINUOUS_THERMAL_TEMP
	end
	RETURN = "N/A";
	handler = open( THERMAL1_CTL, "r" )
	if ( handler ~= nil )
	then
		RETURN = handler:read( "*a" )
		handler:close()
		if( RETURN ~= nil and RETURN ~= "N/A" )
		then
			THERMAL_1 = tonumber( RETURN  // 1000 )
			return 0
		else
			THERMAL_1 = MAX_CONTINUOUS_THERMAL_TEMP
		end
	else
		THERMAL_1 = MAX_CONTINUOUS_THERMAL_TEMP
	end
	return 1
end

--- Function to ShutDown..
--  Temp Above 'ABSOLUTE_MAX_THERMAL_TEMP'
function shutDown( seconds )
	os.execute( "sleep " .. seconds .. " && shutdown -h +0 \"Warning: Temperature **ABOVE** 'ABSOLUTE MAX THERMAL TEMP' ( " .. ABSOLUTE_MAX_THERMAL_TEMP .. "°C )\" &")
	io.write( string.format( "Warning: SHUTTING DOWN in 10s\n" ) )
	io.write( string.format( "Warning: Temperature **ABOVE** 'ABSOLUTE MAX THERMAL TEMP' (" .. ABSOLUTE_MAX_THERMAL_TEMP .. "°C )\n" ) )
	io.write( string.format( "Warning: Temperature **ABOVE** 'ABSOLUTE MAX THERMAL TEMP' (" .. ABSOLUTE_MAX_THERMAL_TEMP .. "°C )\n\nType 'shutdown -c' to cancel...\n" ) )
	io.write( string.format( "exit 1\n" ) )
end

----
---- Variables and Functions to Deamonize.
---

-- Will be used with SysVinit systems..
function createLock()
	local RETURN = "N/A"
	local handle = io.open( "/var/lock/fanctl.lock" , "r")
	if ( handle == nil )
	then
		handle:close()
		RETURN = os.execute("echo $BASHPID;")
		ppid   = tonumber( RETURN )
		handle = io.open( "/var/lock/fanctl.lock" , "w")
		handle:write( RETURN .. "" )
		handle:close()
		return 0
	end
	handle:close()
	return 1
end

----
---- MAIN ----
---

--[[ By Experience, without Underclock, with cpufreq Scalling 'Ondemand',
   And with all CPUs at 100%, the temperature should not grow more than ~57/58C,
   But it depends of the HeatSink used and also the Fan characteristics..and the environment around..
   
   Nota:
   For Safety Reasons,
   It Starts with 'MAX_CONTINUOUS_THERMAL_TEMP' limit, in the worst case cenario, we could not be able to read correctly the temps initially...
   
   In the absence of proper Active Thermal Solution, to cool down( weak or dead fan? ),
   It will adjust temps only until 'ABSOLUTE_MAX_THERMAL_TEMP' were reached, were then, it Shutdown in 10s( for safety reasons.. )
]]

----
---- Check Configurations
--

-- if( createLock() == 1 ){
--	print( "fanctl is already running.." )
--	print( "exit 1" )
--	os.exit(1);
--}

-- Assigning SysFs Locations for control..
THERMAL0_CTL	= "/sys/class/thermal/thermal_zone0/temp"
THERMAL1_CTL	= "/sys/class/thermal/thermal_zone1/temp"
FAN_CTL		= "/sys/class/hwmon/hwmon0/pwm1"

-- Max Temperature Allowed on CPU, Above this Threshold, machine will shutdown
ABSOLUTE_MAX_THERMAL_TEMP	= 70

-- Check in Initial conditions are valid
-- By that we mean if ATS, can properly support Active Thermal System, on the present SysFs..
if( getConditions() == 1 )
then
	io.write( string.format("getConditions: Warning, Values { THERMAL0_CTL, THERMAL1_CTL, FAN_CTL }: %s, %s, %s\n", THERMAL0_CTL, THERMAL1_CTL, FAN_CTL ))
	io.write( string.format("exit 1\n"))
	os.exit( 1 )
end

-- Start Fan, by 2 diferent PWM duty cycle Power Steps .. 
setFanpwm( 130 )
msleep( 200 )
setFanpwm( 190 )

-- Build triggers - arg: minimal Temp[ INTEGER ]
-- PWM duty Cycle
-- PWM		= P( TEMP )
-- Fan Stop	= Q( TEMP )
-- Fan Active	= R( TEMP )
-- min: -20 °C ..see datasheet
PROFILE:setTriggers( -20 )

----
---- Loop to Active Control Temps..
---

--- Check if fanctl is already running as a service..
--
if ( arg[1] == "--test" or arg[1] == "-t" )
then
	if ( checkSymlink( "/var/run/systemd/units/invocation:ats.service" ) ~= true )
	then
		local INSTANT_RATIO
--		local pwm_ratio = PROFILE.pwm_ratio
--		local quiet	= PROFILE.quiet
--		local run	= PROFILE.run
		while true
		do
			io.write( string.format( "Stopping for[ seconds ]............... %d\nCPU Temperature[ max 70 °C ].......... %d\nGPU Temperature[ max 70 °C ].......... %d\nFan PWM Duty Cycle value[ 0 - 255 ]... %d\n--------------------\n", PROFILE:getQtimer( TEMP ), THERMAL_0, THERMAL_1, FAN_PWM ) )
			-- Sleeping with Fan OFF, until nesxt cicle
			sleep( PROFILE:getQtimer( TEMP ) )

			-- Aquire  { CPU, GPU } -> THERMAL_{ 0, 1 } values
			getThermal()
			-- Use  Biggest Thermal Value from THERMAL_{0,1}
			if( THERMAL_0 > THERMAL_1 ) then TEMP = THERMAL_0 else TEMP = THERMAL_1 end

			-- Get PWM_RATIO from Table
			INSTANT_RATIO = PROFILE:getPratio( TEMP )

			-- If temp doesnt change...don't update it..
			if( INSTANT_RATIO ~= FAN_PWM )
			then
				if( FAN_PWM < 1 )
				then
					-- When stopped, it needs more power to start...
					setFanpwm( 130 )
					msleep( 200 )
					setFanpwm( 190 )
					sleep( 1 )
				end
				setFanpwm( INSTANT_RATIO )
			end

			-- Temp Above Threshold to ShutDown..
			if( TEMP >= ABSOLUTE_MAX_THERMAL_TEMP )
			then
				-- Temp is Critically Above 'ABSOLUTE_MAX_THERMAL_TEMP'
				shutDown( 10 )
			end
			io.write( string.format( "Running for[ seconds ]................ %d\nCPU Temperature[ max 70 °C ].......... %d\nGPU Temperature[ max 70 °C ].......... %d\nFan PWM Duty Cycle value[ 0 - 255 ]... %d\n--------------------\n", PROFILE:getRtimer( TEMP ), THERMAL_0, THERMAL_1, FAN_PWM ) )
			-- Sleeping with Fan ON until next cycle
			sleep( PROFILE:getRtimer( TEMP ) )
			-- Stop Fan
			setFanpwm( 0 )
		end
	else
		print "Stop fanctl Service first [ service fanctl stop ].."
	end
else
	local INSTANT_RATIO
--	local pwm_ratio = PROFILE.pwm_ratio
--	local quiet	= PROFILE.quiet
--	local run	= PROFILE.run
	while true
	do
		-- Sleeping with Fan OFF, until next cicle
		sleep( PROFILE:getQtimer( TEMP ) )

		-- Aquire  { CPU, GPU } -> THERMAL_{ 0, 1 } values
		getThermal()
		-- Use  Biggest Thermal Value from THERMAL_{0,1}
		if( THERMAL_0 > THERMAL_1 ) then TEMP = THERMAL_0 else TEMP = THERMAL_1 end

		-- Get PWM_RATIO from Table
		INSTANT_RATIO = PROFILE:getPratio( TEMP ) 

		-- If temp doesnt change...don't update it..
		if( INSTANT_RATIO ~= FAN_PWM )
		then
			if( FAN_PWM < 1 )
			then
				-- When stopped, it needs more power to start...
				setFanpwm( 130 )
				msleep( 200 )
				setFanpwm( 190 )
				sleep( 1 )
			end
			setFanpwm( INSTANT_RATIO )
		end

		-- Temp Above Threshold to ShutDown..
		if( TEMP >= ABSOLUTE_MAX_THERMAL_TEMP )
		then
			-- Temp is Critically Above 'ABSOLUTE_MAX_THERMAL_TEMP'
			shutDown( 10 )
		end

		-- Sleeping with Fan ON until next cycle
		sleep( PROFILE:getRtimer( TEMP ) )

		-- Stop Fan
		setFanpwm( 0 )
	end
end
os.exit( 1 );