
/* I/O */
#include <stdio.h>

/* atoi()*/
#include <stdlib.h>
/* for ceil() */
#include <math.h>

/*** CTL Variables..
**/
char * thermal_ctl[ 3 ] = { NULL };
char * pwm_ctl	= NULL;

/*** Thermal values readed..
**/

/** CPU  Thermal Zone / GPU Thermal Zone, variables used by this backend */
signed char thermal_[ 3 ];

/** File Descriptors for stdout **/
FILE * fstdout = NULL;

/* Get Thernal Values[ integer ] */
static void sysfs_getThermal(){
	signed int value;
	/* nr of thermal zones */
	unsigned char i;
	FILE * fthermal = NULL;

	for ( i = 0; i < ats.THERMAL_CTL_NR; i++ ){
		fthermal = fopen( thermal_ctl[ i ], "r" );
		if( fthermal != NULL ){

			/* Read thermal_{ 0, 1, 2 } 5 chars has a integer.. TODO: compare speed has reading 2 chars to a buffer and then atoi()..*/
			if ( fscanf( fthermal, "%d", &value ) )
				thermal_[ i ] = ( signed char ) ceil( value / 1000 );

			/* If fclose() could NOT clode fd, return != 0 */
			if( fclose( fthermal ) )
				thermal_[ i ] = ats.profile.MAX_CONTINUOUS_THERMAL_TEMP;

		}else{
			thermal_[ i ] = ats.profile.MAX_CONTINUOUS_THERMAL_TEMP;
		}
		/* Get Biggest Thermal temp */
		if( thermal_[ i ] > temp )
			temp = thermal_[ i ];
	}
}
/*** Set Fan PWM value[ unsigned char ]
**/ 
static void sysfs_setPwm( unsigned char  value ){
	FILE * pwm1 = NULL;
	if( ! pwm ){
		/* When stopped, it needs more power to start...give him 0.2 seconds to rotate poles a bit, so that would be bether for aplying bigger push,
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
