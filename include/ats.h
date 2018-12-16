#ifndef ATS_H_
#define ATS_H_

/* new habits ..
#include <inttypes.h> */
/* ********************************  Declarations ******************** */

typedef struct System	ats_t;
	typedef struct Cooling	profile_t;

/* Lua 5.3 doesn't have luaL_Reg, so we put here a define for it..*/
/* #define luaL_reg     luaL_Reg */

/* Struct to Hold Profile Name*/
struct Cooling {
	const char * name;
	unsigned char nr;

	/*** Temperature Control Constants
	**/

	/* Max Temperature Allowed for adjusting fan pwm( On this threshold, and above, fan is always on MaxValue ) */
	signed char MAX_CONTINUOUS_THERMAL_TEMP;
	/* Min Temperature threshold to activate Fan*/
	signed char MIN_CONTINUOUS_THERMAL_TEMP;

	/*** PWM Control Constants
	**/
	
	/* Adjust conform your Fan specs, some neds greater values, others work with less current( currently not being used .. ) */
	unsigned char MAX_PWM;
	/* Adjust conform your Fan specs, some neds greater values, others work with less current( currently not being used .. ) */
	unsigned char MIN_PWM;

	/*** ON_OFF Cycling Control Constants
	**/
	unsigned char ALWAYS_ON;

	/*** Timers and Instant_PWM_ratio( TEMP )
	**/

	/* PWM ratio, calculated based on interpolated values inside normal envelope, and some other values outside[ Global table of integer types ] */
	unsigned char 		pwm_ratio[ 111 ];
	/* Sleep timer( in seconds ), sleeping with Fan Stoped[ Global table of integer types ]*/
	unsigned short int 	quiet_timers[ 111 ];
	/**Run timer( in seconds ), used for sleeping with Fan Running[ Global table of integer types ]*/
	unsigned short int 	run_timers[ 111 ];

	/* Function to calculate pwm values, using interpolated methods, based on temperature and profile{ 1, 2, 3 } */
	/* unsigned char ( *getProfile_pwm ) ( ats_t *, unsigned char ); */
};
/*static unsigned char getProfile_pwm( ats_t *, unsigned char );*/

struct System {

	/*** Board Specs..
	**/
	
	/* Board Name */
	const char *NAME;
	/** OnBoard CPU*/
	const char *CPU;
	/** OnBoard Thermal Ctrl Zones*/
	unsigned char THERMAL_CTL_NR;
	/** OnBoard Pwm Ctrl Zones*/
	unsigned char PWM_CTL_NR;

	/***  Assigning SysFs Locations for control..
	**/

	/* CPU Thermal Zone[ String ] */
	const char *THERMAL0_CTL;
	/** GPU Thermal Zone[ String ] */
	const char *THERMAL1_CTL;
	/** Other Thermal Zone[ String ] */
	const char *THERMAL2_CTL;
	/** FAN Control[ String ] */
	const char *PWM_CTL;
	/** FAN Control[ String ] */
	const char *PWM2_CTL;

	/*** Temperature Control Constants
	**
	* Max Temperatue Allowed on CPU, Above/Below this Threshold, machine will shutdown
	* Datasheet states ABSOLUTE_MAXIMUN [ -20, 85 [
	* For Safety resons and reliability [ -20, 70 ]
	*/
	signed char	ABSOLUTE_MAX_THERMAL_TEMP;
	signed char	ABSOLUTE_MIN_THERMAL_TEMP;

	/*** PWM Parameters Constants
	**
	* Max PWM value possible
	*/
	unsigned char	ABSOLUTE_MAX_PWM;
	/* Min PWM value, to Stop Fan.*/
	unsigned char	ABSOLUTE_MIN_PWM;

	/* Profile Description, used by the Fan...it would be set in /etc/ats.conf ..*/
	profile_t 		profile;

	/* Function to set quiet, run timers and pwm ratios */
	void ( *setTriggers ) ( ats_t * );
};
static void setTriggers( ats_t * );
/*
enum parser_err {
	PARSER_ERR_OK,
	PARSER_ERR_SYSTEM,
	PARSER_ERR_INVALID_FILE,
	PARSER_ERR_WRONLY,
	PARSER_ERR_RDONLY
};
*/
/* and -pedantic */

/*Functions to be used by LuaC backend */
static void getThermal( void );
static void setPwm( unsigned char );


/* functions to be used by Lua frontend.. */
static int initCore_c( lua_State * );
static int loop_c( lua_State * );
static int sSleep_c( lua_State * );
static int mSleep_c( lua_State * );
static int chkSymlink_c( lua_State * );

/* Functions to be used by CTest frontend.. */
int tinitCore( lua_State * );
int tloop( lua_State * );

#endif
