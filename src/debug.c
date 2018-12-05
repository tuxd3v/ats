
/* I/O */
#include <stdio.h>

#include <lua5.3/lua.h>
#include <lua5.3/lauxlib.h>
#include <lua5.3/lualib.h>

#include "../include/debug.h"

char stackTrace( lua_State *L ){
	int i;
	int top = lua_gettop( L );
	printf( "---- Begin Stack ----\n" );
	printf( "Stack size: %i\n\n", top );
	for ( i = top; i >= 1; i-- ){
		int t = lua_type( L, i );
		switch ( t ){
			case LUA_TSTRING:
				printf( "%i -- (%i) ---- `%s'", i, i - ( top + 1 ), lua_tostring( L, i ) );
				break;

			case LUA_TBOOLEAN:
				printf( "%i -- (%i) ---- %s", i, i - ( top + 1 ), lua_toboolean( L, i ) ? "true" : "false" );
				break;

			case LUA_TNUMBER:
				printf( "%i -- (%i) ---- %g", i, i - ( top + 1 ), lua_tonumber( L, i ) );
				break;

			default:
				printf( "%i -- (%i) ---- %s", i, i - ( top + 1 ), lua_typename( L, t ) );
				break;
		}
		printf( "\n" );
	}
	printf( "---- End S tack ----\n" );
	printf( "\n" );
	return 0;
}
