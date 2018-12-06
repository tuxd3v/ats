
/* I/O */
#include <stdio.h>
/* for sleep/usleep */
#include <unistd.h>

/* LuaC */
#include <lua5.3/lua.h>
#include <lua5.3/lauxlib.h>
#include <lua5.3/lualib.h>

#include "include/debug.h"
#include "include/ats.h"


int main( int argc, char ** argv ){
	int i;
	/* Create a Lua new State */
	lua_State *L = luaL_newstate();
	lua_checkstack ( L, 10000 );
	/*lua_getglobal(L,"_VERSION");*/

	stackTrace( L );

	/* Load the standard Lua libraries. */
	luaL_openlibs( L );

	/* Put the ats.conf table into the stack. */
	if( luaL_dofile( L, "etc/ats.conf" ) ){
		printf( "Could not load ats config.. " );
		lua_close( L );
		return 1;
	}
	lua_setglobal(L, "SYSTEM");
	lua_settop(L, 0);
	stackTrace( L );
	
	lua_getglobal(L, "SYSTEM");
	stackTrace( L );
	/*lua_getfield(L, -1, "BOARD");*/
	/*lua_call(L, 0, 0);*/
	
	stackTrace( L );
	/* Start Fan, by 2 different PWM duty cycle Power Steps ..
	tsetPwm( 130 );
	usleep( 200000 );
	tsetPwm( 190 );
	sleep( 1 );
	*/

	if( tinitCore( L ) ){
		/* push true to stack for loop */
		lua_pushboolean ( L, 1 );
		tloop( L );
	}
	/* Free space from Lua State L */
	lua_close(L);

	return 0;
}
