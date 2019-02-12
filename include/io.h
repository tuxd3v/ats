
#ifndef IO_H_
#define IO_H_

typedef struct IO io_t;
typedef struct BACKEND backend_t;

typedef enum CTL_TYPE ctl_t;
typedef enum DIRECTION direction_t;

/* Functions to each facility, sysfs,i2c, etc*/
struct IO {
	backend_t backendIn[ 3 ];
	backend_t backendOut[ 2 ];
	void *( *init )(  );			/* init set atributed functions and IO's for each facility */
	void ( *setPwm )( unsigned char );	/* Function to set pwm */
	void ( *getThermal )( void );		/* Function to get Thermal Values */
	void ( *close )( void * );		/* close and free memry... at least from now, *NOT* needed */
};
/* Description of one backend*/
struct BACKEND {
	const ctl_t type;			/* name of the backend used */	
	const direction_t direction;
	unsigned char nr;
	char *name;
	signed char map_to[ 3 ];
};
/* Control Facility */
enum CTL_TYPE {
	SYSTEM_SYSFS, 	/* OnSystem Driver via SysFs export */
	ONBOARD_I2C,	/* OnBoard i2c chip sensor, no SysFs, no Driver */
	ONBOARD_GPIO,	/* OnBoard pwm GPIO Mapped, implicit resources for functionality, but No Driver, no SYSFS */
	FOREIGN_GPIO	/* OnBoard GPIO Pin MApped, no resources for functionality, No Driver, no SYSFS, ( ie: BitBanging i2c,pwm ) */
};

/* Direction type, IF input or output */
enum DIRECTION {
	OUTPUT,
	INPUT
};

/** don't know yet why I need this.. Im only designing a preface out of my mind..
	enum input {
		PARSER_ERR_OK,
		PARSER_ERR_SYSTEM,
		PARSER_ERR_INVALID_FILE,
		PARSER_ERR_WRONLY,
		PARSER_ERR_RDONLY
	};
*/
extern backend_t io;
endif
