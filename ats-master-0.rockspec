rockspec_format			= "1.0"
package					= "ats"
version					= "master-0"
description = {
	summary	= "Active Thermal Service",
	detailed		= [[
		This tool, provide support for Rockpro64, Active thermal Service( Fan Control ).
	]],
	homepage	= "https://github.com/tuxd3v/ats",
	license		= "See License..",
	maintainer	= "tuxd3v <tuxd3v@sapo.pt>"
}
source = {
	url			= "git://github.com/tuxd3v/ats",
	branch		= "master"
}
dependencies = {
	supported_platforms	= "linux",
	"lua >= 5.3"
	--[["lua-dev >= 5.3"
			he doesn't know what is lua5.3-dev, needed to provide "lualib.h","lauxlib.h","lua.h" headers do build shared library..
	]]
}
external_dependencies = {
	platforms = {
		linux = {
			UNISTD				= { header	= "unistd.h"		},
			LUALIB				= { header	= "lualib.h"		},
			LAUXLIB				= { header	= "lauxlib.h"		},
			LUA					= { header	= "lua.h"			},
			LUA53				= { library	= "liblua5.3.so"	}
		}
	}
}
build = {
	type				= "make",
	makefile			= "Makefile",
	build_target		= "all",
	build_pass			= true,
	build_variables		= {},
	install_target		= "install",
	install_pass		= true,
	install_variables	= {},
	variables			= {},
	modules				= { ats = "src/ats.c" }
}
