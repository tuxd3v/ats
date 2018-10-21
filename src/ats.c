/*
    Sleep Functions to avoit fork & exec of sleep Operating system tool utilities
*/

#include <unistd.h>

#include <sys/stat.h>
#include <sys/types.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

/* 
* unistd.h don't provide a msleep function( provide usleep ), but still,
* Avoid to name convenctions from unistd.h, providing a termination "_c" on function name
*/
static int msleep_c( lua_State *L )
{
	long msecs = lua_tointeger( L, -1 );
	usleep( 1000 * msecs );
	return 0;   /* No items returned */
}

/* 
* unistd.h provide a sleep function,
* Avoid to name  convenctions from unistd.h, providing a termination "_c" on function name
*/
static int sleep_c( lua_State *L )
{
	long secs = lua_tointeger( L, -1 );
	sleep( secs );
	return 0;   /* No items returned */
}
/*
* Check if a a SymLink exists,
* add "_c" on declaration
*/
static int symlink_exists_c( lua_State *L )
{
	/* unfortunatly, to hold the struct on lstat syscall..*/
	struct stat buffer;
	/* Get Top lua stack element, and pass const pointer to lstat */
	if ( ! lstat( lua_tostring( L, -1 ), &buffer ) ) {
		/* Push the result into the stack*/
		lua_pushboolean ( L, 1 );
	}else{
		/* Push nil into stack*/
		lua_pushnil(L);
	}
	/* Return the number of return values pushed onto the stack.*/
    return 1;
}


/* Register the functions */
int luaopen_ats( lua_State *L )
{
	lua_register( L, "symlink_exists", symlink_exists_c );
	lua_register( L, "msleep", msleep_c );
	lua_register( L, "sleep", sleep_c );
	return 0;
}
