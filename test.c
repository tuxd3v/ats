
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
	stackTrace( L );

	/* Load the standard Lua libraries. */
	luaL_openlibs( L );

	lua_getglobal(L,"_G");
	/* Put on top, key io */
	lua_pushstring( L, "io" );
	/* Get on top, value pair for key MAX_PWM*/
	lua_gettable( L, -2 );
	/*lua_getglobal(L, "io");*/
	/*lua_getfield(L, -1, "_G");*/
	/* Put on top, key MAX_PWM */
	lua_pushstring( L, "stdout" );
	/* Get on top, value pair for key MAX_PWM*/
	lua_gettable( L, -2 );
	stackTrace( L );
	lua_typename( L, 1 );
	
	/*lua_getfield(L, -1, "BOARD");*/
	/*lua_call(L, 0, 0);*/

	/* Free space from Lua State L */
	lua_close(L);

	return 0;
}
