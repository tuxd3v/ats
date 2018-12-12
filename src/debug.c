
/* I/O */
#include <stdio.h>

#include <lua5.3/lua.h>
#include <lua5.3/lauxlib.h>
#include <lua5.3/lualib.h>

#include "../include/debug.h"

char stackTrace( FILE *fstdout, lua_State *L ){
	int i;
	int top = lua_gettop( L );
	fprintf( fstdout, "---- Begin Stack ----\n" );
	fprintf( fstdout, "Stack size: %i\n\n", top );
	for ( i = top; i >= 1; i-- ){
		int t = lua_type( L, i );
		switch ( t ){
			case LUA_TSTRING:
				fprintf( fstdout, "%i -- (%i) ---- `%s'", i, i - ( top + 1 ), lua_tostring( L, i ) );
				break;

			case LUA_TBOOLEAN:
				fprintf( fstdout, "%i -- (%i) ---- %s", i, i - ( top + 1 ), lua_toboolean( L, i ) ? "true" : "false" );
				break;

			case LUA_TNUMBER:
				fprintf( fstdout, "%i -- (%i) ---- %g", i, i - ( top + 1 ), lua_tonumber( L, i ) );
				break;

			default:
				fprintf( fstdout, "%i -- (%i) ---- %s", i, i - ( top + 1 ), lua_typename( L, t ) );
				break;
		}
		fprintf( fstdout, "\n" );
	}
	fprintf( fstdout, "---- End Stack ----\n\n" );
	return 0;
}
