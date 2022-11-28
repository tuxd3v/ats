
/* I/O */
#include <stdio.h>

/* for sleep/usleep*/
#include <unistd.h>
/* for symlink checks */
#include <sys/stat.h>
#include <sys/types.h>
/* atoi()*/
#include <stdlib.h>
/* for ceil() */
#include <math.h>

/* LuaC */
#include <lua5.3/lua.h>
#include <lua5.3/lauxlib.h>
#include <lua5.3/lualib.h>

#include "../include/debug.h"
#include "../include/ats.h"


/* Structure to hold all relevant information about ATS 
*
* Set ATS Constants..
*
* Datasheet has limits ] -20°C, ~80°C [
* CPU should be a emergency shutdown close to 85°C..
* For Safety Reasons we operate bellow, shutting down at 70°C
*/
ats_t ats;

/*** Variables used for Temperature/PWM/Timers..
**/

/** Temperature Value( CPU or GPU ), which one is greater... */
signed char temp;
/** Initial Fan Pwm Value set in ats Lua file.. */
unsigned char pwm = 190;

/* Timer Pointers to all pre-calculated values... */
unsigned char *Pratio		= ats.profile.pwm_ratio + 30;
unsigned short int *Qtimer	= ats.profile.quiet_timers +30;
unsigned short int *Rtimer	= ats.profile.run_timers + 30;

/*** CTL Variables..
**/
char * thermal_ctl[ 2 ] = { NULL };
char * pwm_ctl	= NULL;

/*** Thermal values readed..
**/

/** CPU  Thermal Zone / GPU Thermal Zone, variables used by this backend */
signed char thermal_[2];

/** File Descriptors for stdout **/
FILE * fstdout = NULL;

/* Function to set quiet,run timers and pwm ratios */
static void setTriggers( ats_t *self ){
	fprintf( fstdout, "info:'Pratio' timers\n" );
	signed char i;
	/* to get pwm float char*/
	char number[11];
	/* Temperature limits */
	const signed char max		= self->ABSOLUTE_MAX_THERMAL_TEMP;
	const signed char min		= self->ABSOLUTE_MIN_THERMAL_TEMP;

	const signed char max_plus	= ( max + 10 );
	const signed char min_plus	= ( min - 10 );

	const signed char max_continuous_thermal_temp	= self->profile.MAX_CONTINUOUS_THERMAL_TEMP;
	const signed char min_continuous_thermal_temp	= self->profile.MIN_CONTINUOUS_THERMAL_TEMP;
	
	fprintf( fstdout, "info:    'Pratio[ %d - %d [' = %d\n", min, min_continuous_thermal_temp, self->ABSOLUTE_MIN_PWM );
	for ( i = min_plus; i <= max_plus; ++i ){

		if( i < min_continuous_thermal_temp ){

			Pratio[ i ] = self->ABSOLUTE_MIN_PWM;
			//Bellow -10°C, heat up the CPU[ -20°C, +80°C ]
			if( i <= -10 ){
				Qtimer[ i ]	= 360;
				Rtimer[ i ]	= 0;

			} else if( i <= 0 ){
				Qtimer[ i ]	= 300;
				Rtimer[ i ]	= 1;

			} else if( i <= 10 ){
				Qtimer[ i ]	= 250;
				Rtimer[ i ]	= 2;

			} else if( i <= 35 ){
				Qtimer[ i ]	= 190;
				Rtimer[ i ]	= 3;

			} else {
				Qtimer[ i ]	= 120;
				Rtimer[ i ]	= 5;

			}
		} else if( i >= min_continuous_thermal_temp && i <= max_continuous_thermal_temp ){

			/* Calculate PWM values based on functions with diferent pwm 'Response Curves' */
			/* *( pwm_ratio0 + i ) = self->profile.getProfile_pwm( self, i ); */
			
			/* Get float to String, then convert String to integer*/
			snprintf( number, 6, "%3.2f", ( float ) ( self->profile.MIN_PWM + ( ( ( self->profile.MAX_PWM - self->profile.MIN_PWM ) * 1.0 ) / ( self->profile.MAX_CONTINUOUS_THERMAL_TEMP - self->profile.MIN_CONTINUOUS_THERMAL_TEMP ) ) * ( i - self->profile.MIN_CONTINUOUS_THERMAL_TEMP ) ) );
			Pratio[ i ] =  ( unsigned char ) atoi( number );
			fprintf( fstdout, "info:    'Pratio[ %d ]'       = %d\n", i, Pratio[ i ] );
			
			if ( i <= 45 ){
				Qtimer[ i ]	= 90;
				Rtimer[ i ]	= 10;

	  		} else if( i <= 50 ){
				Qtimer[ i ]	= 50;
				Rtimer[ i ]	= 20;

	  		}else if( i <= 55 ){
				Qtimer[ i ]	= 40;
				Rtimer[ i ]	= 30;

	  		} else if( i <= 60 ){
				Qtimer[ i ]	= 10;
				Rtimer[ i ]	= 60;
			}
		} else if( i > max_continuous_thermal_temp ){

			Pratio[ i ] = self->ABSOLUTE_MAX_PWM;

			if( i < ( max - 5 ) ){
				Qtimer[ i ]	= 6;
				Rtimer[ i ]	= 120;

			}else{
				Qtimer[ i ]	= 3;
				Rtimer[ i ]	= 160;
			}
		}
	}
	fprintf( fstdout, "info:    'Pratio[ %d - %d ['  = %d\n", max_continuous_thermal_temp, max, self->ABSOLUTE_MAX_PWM );
}

/**
* Function to initialize ATS Backend
*/
static int initCore_c( lua_State *L ){
	double number;
	/* Get Lua Frontend STDout descriptor.. */
	lua_getglobal( L, "io" );
	lua_pushstring(L, "stdout");
	lua_gettable(L, -2);
	/*fstdout = *(FILE **)lua_touserdata(L, -1);*/
	fstdout = ((luaL_Stream *)lua_touserdata(L, -1))->f;
	lua_pop(L, 2);

	/* Theoretically speaking, we received a Table...is this a table? */
	if ( lua_istable( L, -1 ) ) {
		fprintf( fstdout, "info:'SYSTEM' Table\n" );

		/* Looking up based on the key */
		/* Add key we're interested in to the stack*/
		lua_pushstring( L, "BOARD" );
		lua_gettable( L, -2 );
		if ( lua_istable( L, -1 ) ) {
			fprintf( fstdout, "info:    'BOARD' Table\n" );
			/* Put on top, key NAME*/
			lua_pushstring( L, "NAME" );
			/* Get on top, value pair for key NAME*/
			lua_gettable( L, -2 );
			/* Get NAME value */
			ats.NAME = lua_tostring( L, -1 );
			fprintf( fstdout, "info:        'NAME' = %s\n", ats.NAME );
			/* Free Stack NAME Value*/
			lua_pop( L, 1 );

			/* Put on top, key CPU*/
			lua_pushstring(L,"CPU");
			/* Get on top, value pair for key NAME*/
			lua_gettable( L, -2 );
			/* Get CPU value */
			ats.CPU = lua_tostring( L, -1 );
			fprintf( fstdout, "info:        'CPU'  = %s\n", ats.CPU );
			/* Free BOARD TABLE from Stack top*/
			lua_pop( L, 2 );
		} else {
			/* Free BOARD TABLE key from Stack top*/
			lua_pop( L, 1 );

			fprintf( fstdout, "warn:    UPS.. there are problems with SYSTEM config table.\n     Expecting a BOARD table..\n     Check your /etc/ats.conf file..\n     A trace follows bellow:\n" );
			stackTrace( fstdout, L );

			/* push false on stack( return false to lua ) */
			lua_pushboolean ( L, 0 );
			return 1;
		}
		/* Put on top, key THERMAL0_CTL */
		lua_pushstring( L,"THERMAL0_CTL" );
		/* Get on top, value pair for key THERMAL0_CTL*/
		lua_gettable( L, -2 );
		/* Get THERMAL0_CTL value */
		ats.THERMAL0_CTL = lua_tostring( L, -1 );
		fprintf( fstdout, "info:    'THERMAL0_CTL' = %s\n", ats.THERMAL0_CTL );
		/* Free Stack THERMAL0_CTL Value*/
		lua_pop( L, 1 );

		/* Put on top, key THERMAL1_CTL */
		lua_pushstring( L,"THERMAL1_CTL" );
		/* Get on top, value pair for key THERMAL1_CTL*/
		lua_gettable( L, -2 );
		/* Get THERMAL1_CTL value */
		ats.THERMAL1_CTL = lua_tostring( L, -1 );
		fprintf( fstdout, "info:    'THERMAL1_CTL' = %s\n", ats.THERMAL1_CTL );
		/* Free Stack THERMAL1_CTL Value*/
		lua_pop( L, 1 );

		/* Put on top, key PWM_CTL */
		lua_pushstring( L, "PWM_CTL" );
		/* Get on top, value pair for key PWM_CTL*/
		lua_gettable( L, -2 );
		/* Get PWM_CTL value */
		ats.PWM_CTL = lua_tostring( L, -1 );
		fprintf( fstdout, "info:    'PWM_CTL'      = %s\n", ats.PWM_CTL );
		/* Free Stack PWM_CTL Value*/
		lua_pop( L, 1 );

		/* ATS Limits */
		ats.ABSOLUTE_MAX_THERMAL_TEMP	= 70;
		ats.ABSOLUTE_MIN_THERMAL_TEMP	= -20;
		ats.ABSOLUTE_MAX_PWM		= 255;
		ats.ABSOLUTE_MIN_PWM		= 0;

		/* Put on top, key MAX_CONTINUOUS_THERMAL_TEMP */
		lua_pushstring( L, "MAX_CONTINUOUS_THERMAL_TEMP" );
		/* Get on top, value pair for key MAX_CONTINUOUS_THERMAL_TEMP*/
		lua_gettable( L, -2 );
		/* Get MAX_CONTINUOUS_THERMAL_TEMP value */
		number = lua_tonumber( L, -1 );
		if( number > ats.ABSOLUTE_MIN_THERMAL_TEMP && number < ats.ABSOLUTE_MAX_THERMAL_TEMP ){
			ats.profile.MAX_CONTINUOUS_THERMAL_TEMP = ( signed char ) number;
			fprintf( fstdout, "info:    'MAX_CONTINUOUS_THERMAL_TEMP' = %d\n", ats.profile.MAX_CONTINUOUS_THERMAL_TEMP );
		} else {
			fprintf( fstdout, "warn:    'MAX_CONTINUOUS_THERMAL_TEMP' outside range] %d, %d [\n         'MAX_CONTINUOUS_THERMAL_TEMP' = %d\n",
													ats.ABSOLUTE_MIN_THERMAL_TEMP,
													ats.ABSOLUTE_MAX_THERMAL_TEMP, 60 );
			ats.profile.MAX_CONTINUOUS_THERMAL_TEMP = 60;
		}
		/* Free Stack MAX_CONTINUOUS_THERMAL_TEMP Value*/
		lua_pop(L,1);

		/* Put on top, key MIN_CONTINUOUS_THERMAL_TEMP */
		lua_pushstring( L, "MIN_CONTINUOUS_THERMAL_TEMP" );
		/* Get on top, value pair for key MIN_CONTINUOUS_THERMAL_TEMP*/
		lua_gettable( L, -2 );
		/* Get MIN_CONTINUOUS_THERMAL_TEMP value */
		number = lua_tonumber( L, -1 );
		if( number > ats.ABSOLUTE_MIN_THERMAL_TEMP && number < ats.ABSOLUTE_MAX_THERMAL_TEMP ){
			ats.profile.MIN_CONTINUOUS_THERMAL_TEMP = ( signed char ) number;
			fprintf( fstdout, "info:    'MIN_CONTINUOUS_THERMAL_TEMP' = %d\n", ats.profile.MIN_CONTINUOUS_THERMAL_TEMP );
		} else {
			fprintf( fstdout, "warn:    'MIN_CONTINUOUS_THERMAL_TEMP' outside range] %d, %d [\n         'MIN_CONTINUOUS_THERMAL_TEMP' = %d\n",
													ats.ABSOLUTE_MIN_THERMAL_TEMP,
													ats.ABSOLUTE_MAX_THERMAL_TEMP, 40 );
			ats.profile.MIN_CONTINUOUS_THERMAL_TEMP = 40;
		}
		/* Free Stack MIN_CONTINUOUS_THERMAL_TEMP Value*/
		lua_pop( L, 1 );

		/* Put on top, key MAX_PWM */
		lua_pushstring( L, "MAX_PWM" );
		/* Get on top, value pair for key MAX_PWM*/
		lua_gettable( L, -2 );
		/* Get MAX_PWM value */
		number = lua_tonumber( L, -1 );
		if( number > ats.ABSOLUTE_MIN_PWM && number <= ats.ABSOLUTE_MAX_PWM ){
			ats.profile.MAX_PWM = ( unsigned char ) number;
			fprintf( fstdout, "info:    'MAX_PWM' = %d\n", ats.profile.MAX_PWM );
		} else {
			fprintf( fstdout, "warn:    'MAX_PWM' outside range] %d, %d ]\n         'MAX_PWM' = %d\n",ats.ABSOLUTE_MIN_PWM, ats.ABSOLUTE_MAX_PWM,
													ats.ABSOLUTE_MAX_PWM );
			ats.profile.MAX_PWM = ats.ABSOLUTE_MAX_PWM;
		}
		/* Free Stack MAX_PWM Value*/
		lua_pop( L, 1 );

		/* Put on top, key MIN_PWM */
		lua_pushstring( L, "MIN_PWM" );
		/* Get on top, value pair for key MIN_PWM*/
		lua_gettable( L, -2 );
		/* Get MIN_PWM value */
		number = lua_tonumber( L, -1 );
		if( number > ats.ABSOLUTE_MIN_PWM && number < ats.ABSOLUTE_MAX_PWM ){
			ats.profile.MIN_PWM = ( unsigned char ) number;
			fprintf( fstdout, "info:    'MIN_PWM' = %d\n", ats.profile.MIN_PWM );
		} else {
			fprintf( fstdout, "warn:    'MIN_PWM' outside range] %d, %d [\n         'MIN_PWM' = %d\n", ats.ABSOLUTE_MIN_PWM, ats.ABSOLUTE_MAX_PWM, 40 );
			ats.profile.MIN_PWM = 40;
		}
		/* Free Stack MIN_PWM Value*/
		lua_pop( L, 1 );

		/* Put on top, key ALWAYS_ON */
		lua_pushstring( L, "ALWAYS_ON" );
		/* Get on top, value pair for key ALWAYS_ON*/
		lua_gettable( L, -2 );
		/* Get ALWAYS_ON value on ats structure */
		ats.profile.ALWAYS_ON = ( unsigned char ) lua_toboolean( L, -1 );
		if( ! ats.profile.ALWAYS_ON ){
			fprintf( fstdout, "info:    'ALWAYS_ON' = false\n");
		}else {
			fprintf( fstdout, "info:    'ALWAYS_ON' = true\n");
		}
		/* Free Stack ALWAYS_ON Value*/
		lua_pop( L, 1 );

		/* Put on top, key PROFILE_NAME */
		lua_pushstring( L, "PROFILE_NAME" );
		/* Get on top, value pair for key PROFILE_NAME*/
		lua_gettable( L, -2 );
		/* Get PROFILE_NAME value */
		ats.profile.name = lua_tostring( L, -1 );
		fprintf( fstdout, "info:    'PROFILE_NAME' = %s\n", ats.profile.name );
		/* Free Stack PROFILE_NAME Value*/
		lua_pop( L, 1 );

		/* Put on top, key PROFILE_NR */
		lua_pushstring( L, "PROFILE_NR" );
		/* Get on top, value pair for key PROFILE_NR*/
		lua_gettable( L, -2 );
		/* Get PROFILE_NR value */
		number = lua_tonumber( L, -1 );
		if( number >= 0 && number < 3 ){
			ats.profile.nr = ( unsigned char ) number;
			fprintf( fstdout, "info:    'PROFILE'      = %d\n", ats.profile.nr );
		} else {
			fprintf( fstdout, "warn:    'PROFILE' outside range[ %d, %d ]\n     'MIN_PWM' = %d\n", 0, 2, 0 );
			ats.profile.nr = 0;
		}
		/* Free Stack PROFILE Value*/
		lua_pop( L, 1 );

		ats.setTriggers = setTriggers;
		ats.setTriggers( &ats );
		
		/* Return true on stack */
		lua_pushboolean ( L, 1 );
	} else {
		fprintf( fstdout, "warn:UPS.. there are problems with SYSTEM config table.\n     Expecting a SYSTEM table..\n     Check your /etc/ats.conf file..\n     A trace follows bellow:\n" );
		stackTrace( fstdout, L );
		
		/* push false on stack( return false to lua ) */
		lua_pushboolean ( L, 0 );
	}
	/* return one value on the stack */
	return 1;
}

/* Get Thernal Values[ integer ] */
static void getThermal(){
	signed int value;
	/* 2 thermal zones */
	unsigned char i;
	FILE * fthermal= NULL;

	for ( i = 0; i < 2; i++ ){
		fthermal = fopen( thermal_ctl[ i ], "r" );
		if( fthermal != NULL ){

			/* Read thermal_{ 0, 1 } 5 chars has a integer.. TODO: compare speed has reading 2 chars to a buffer and then atoi()..*/
			if ( fscanf( fthermal, "%d", &value ) != 0 )
				thermal_[ i ] = ( signed char ) ceil( value / 1000 );

			if( fclose( fthermal ) != 0 )
				thermal_[ i ] = ats.profile.MAX_CONTINUOUS_THERMAL_TEMP;
		}else{
			thermal_[ i ] = ats.profile.MAX_CONTINUOUS_THERMAL_TEMP;
		}
	}
	/* Use  Biggest Thermal Value from THERMAL_{0,1} for temp var*/
	if( thermal_[ 0 ] > thermal_[ 1 ] )
		temp = thermal_[ 0 ];
	else
		temp = thermal_[ 1 ];
}
/*** Set Fan PWM value[ unsigned char ]
**/ 
static void setPwm( unsigned char  value ){
	FILE * pwm1 = NULL;
	if( ! pwm && value != 0){
		/* When stopped, it needs more power to start...give him 0.2 seconds to rotate poles a bit, so that would be better for aplying bigger push,
		 * In This Way, initial peak current needed to start fan is lower..
		 */
		/* to force recursion, and update PWM, in case of fail PWM is set to zero bellow, so that it will try again, in second call .. */
		pwm = 1;

		setPwm( 130 );
		usleep( 200000 );
		setPwm( 190 );
		sleep( 1 );
	}
	pwm1 = fopen( pwm_ctl, "w" );
	if ( pwm1 != NULL ){
		if( fprintf( pwm1, "%d", value ) != 0 )
			pwm = value;
		/* could be dangerous...if not able to close the file open descriptor...will loop recursivelly until resources exausted.. FIXME */ 
		if ( fclose( pwm1 ) != 0 )
			pwm = 0;
	}else{
		  pwm = 0;
	}
}

/* pooling loop */
static int loop_c( lua_State *L ){
	unsigned char instant_ratio;
	signed char absolute_max_thermal_temp = ats.ABSOLUTE_MAX_THERMAL_TEMP;
	signed char absolute_min_thermal_temp = ats.ABSOLUTE_MIN_THERMAL_TEMP;
	unsigned int verbose = lua_toboolean ( L, -1 );
	/* Free Stack verbose boolean Value*/
	lua_pop( L, 1 );
	
	/* CTL Variables */
	thermal_ctl[ 0 ]	= ( char * ) ats.THERMAL0_CTL;
	thermal_ctl[ 1 ]	= ( char * ) ats.THERMAL1_CTL;
	pwm_ctl			= ( char * ) ats.PWM_CTL;

	/* At beguining force timers for max thermal temp, so that, ATS will start check quickly the real temps.. */
	temp = absolute_max_thermal_temp;

	/* Looping cycle.. */
	if( ! ats.profile.ALWAYS_ON ){
		for(;;){
			if( verbose )
				printf( "Stopping for[ seconds ]............... %d\nCPU Temperature[ max 70 °C ].......... %d\nGPU Temperature[ max 70 °C ].......... %d\nFan PWM Duty Cycle value[ 0 - 255 ]... %d\n--------------------\n",
																												Qtimer[ temp ],
																												thermal_[ 0 ],
																												thermal_[ 1 ],
																												pwm );
			/* Sleeping with Fan OFF, until next cicle */
			sleep( Qtimer[ temp ] );

			/* Aquire  { CPU, GPU } -> THERMAL_{ 0, 1 } values */
			getThermal();

			instant_ratio = Pratio[ temp ];

			/* If temp doesn't change...don't update it..*/
			if( instant_ratio != pwm )
				setPwm( instant_ratio );

			/* Temp Above Threshold to ShutDown.. */
			if( temp <= absolute_min_thermal_temp || temp >= absolute_max_thermal_temp ){
				/*  Temp is Critically Above 'ABSOLUTE_MAX_THERMAL_TEMP' */
				/* push false on stack( return false to lua ) */
				lua_pushboolean ( L, 0 );
				break;
			}
			if( verbose )
				printf( "Running for[ seconds ]................ %d\nCPU Temperature[ max 70 °C ].......... %d\nGPU Temperature[ max 70 °C ].......... %d\nFan PWM Duty Cycle value[ 0 - 255 ]... %d\n--------------------\n",
																												Rtimer[ temp ],
																												thermal_[ 0 ],
																												thermal_[ 1 ],
																												pwm );
			/* Sleeping with Fan ON until next cycle */
			sleep( Rtimer[ temp ] );

			/* Stop Fan */
			setPwm( 0 );
		}
	}else{
		for(;;){

			/* Aquire  { CPU, GPU } -> THERMAL_{ 0, 1 } values */
			getThermal();

			instant_ratio = Pratio[ temp ];

			/* If temp doesn't change...don't update it..*/
			if( instant_ratio != pwm )
				setPwm( instant_ratio );

			/* Temp Above Threshold to ShutDown.. */
			if( temp <= absolute_min_thermal_temp || temp >= absolute_max_thermal_temp ){
				/*  Temp is Critically Above 'ABSOLUTE_MAX_THERMAL_TEMP' */
				/* push false on stack( return false to lua ) */
				lua_pushboolean ( L, 0 );
				break;
			}
			if( verbose )
				printf( "Running for[ seconds ]................ %d\nCPU Temperature[ max 70 °C ].......... %d\nGPU Temperature[ max 70 °C ].......... %d\nFan PWM Duty Cycle value[ 0 - 255 ]... %d\n--------------------\n",
																												Rtimer[ temp ],
																												thermal_[ 0 ],
																												thermal_[ 1 ],
																												pwm );
			/* Sleeping with Fan ON until next cycle */
			sleep( Rtimer[ temp ] );
		}
	}
	return 1;
}

/*** Sleep Functions
**/

/* 
* unistd.h don't provide a msleep function( provide usleep ), but still,
* Avoid to name convenctions from unistd.h, providing a termination "_c" on function name
*/
static int mSleep_c( lua_State *L ){
	long msecs = lua_tointeger( L, -1 );
	usleep( 1000 * msecs );
	return 0;
}
/* 
* unistd.h provide a sleep function,
* Avoid to name  convenctions from unistd.h, providing a termination "_c" on function name
*/
static int sSleep_c( lua_State *L ){
	long secs = lua_tointeger( L, -1 );
	sleep( secs );
	return 0;
}

/*
* Check if a a SymLink exists,
* add "_c" on declaration
*/
static int chkSymlink_c( lua_State *L ){
	struct stat buffer;
	if ( lstat( lua_tostring( L, -1 ), &buffer ) == 0 ) {
		lua_pushboolean ( L, 1 );
	}else{
		lua_pushnil( L );
	}
	return 1;
}

/* Register the functions
* checkSymlink
* msleep
* sleep
*/
int luaopen_ats( lua_State *L ){
	lua_register( L, "initCore", initCore_c );
	lua_register( L, "loop", loop_c );

	lua_register( L, "chkSymlink", chkSymlink_c );
	lua_register( L, "mSleep", mSleep_c );
	lua_register( L, "sSleep", sSleep_c );
	return 0;
}
/*
static const luaL_Reg Map [] = {
	{ "initCore", initCore_c },
	{ "chkSymlink", chkSymlink_c },
	{ "mSleep", mSleep_c },
	{ "sSleep", sSleep_c },
	{ NULL, NULL }
};
*/
/* Register the Functions in Lua State 
int luaopen_ats ( lua_State *L ) { 
	luaL_register( L, "LUA_ATS", Map );
	void luaL_newlib ( L, const luaL_Reg l[]
	return 1;
}
*/

/*********************** LUA C API Test.c Frontend **************************
**/

/**
* Function to initialize ATS Backend
*/
int tinitCore( lua_State *L ){
	return initCore_c( L );
}

/* pooling loop */
int tloop( lua_State *L ){
	return loop_c( L );
}
