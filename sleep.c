/*
    Sleep Functions to avoit fork & exec of sleep Operating system tool utilities
*/

#include <unistd.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

/* 
* unistd.h don't provide a msleep function( provide usleep ), but still,
* avoid namming convenctions from unistd.h, providing a termination "_c" on function name
*/
static int msleep_c( lua_State *L ){
	long msecs = lua_tointeger( L, -1 );
	usleep( 1000 * msecs );
	return 0;   /* No items returned */
}

/* 
* unistd.h provide a sleep function,
* Avoid namming convenctions from unistd.h, providing a termination "_c" on function name
*/
static int sleep_c( lua_State *L ){
	long secs = lua_tointeger( L, -1 );
	sleep( secs );
	return 0;   /* No items returned */
}

/* Register both functions */
int luaopen_sleep( lua_State *L ){
	lua_register( L, "msleep", msleep_c );  
	lua_register( L, "sleep", sleep_c );
	return 0;
}

