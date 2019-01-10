rockspec_format	= "1.0"
package		= "ats"
version		= "0.2-0"
description = {
	summary		= "Active Thermal Service",
	detailed	= [[
		This tool, provide support for Rockpro64, Active thermal Service( Fan Control ).
	]],
	homepage	= "https://github.com/tuxd3v/ats",
	license		= "See License..",
	maintainer	= "tuxd3v <tuxd3v@sapo.pt>"
}
source = {
	url		= "https://github.com/tuxd3v/ats/archive/v0.2.0.tar.gz",
	file		= "ats-0.2.0.tar.gz",
	dir		= "ats-0.2.0"
}
dependencies = {
	supported_platforms	= "linux",
	"lua >= 5.3"
	--[["lua-dev >= 5.3"
		he doesn't know what is lua5.3-dev, needed to provide "lualib.h","lauxlib.h","lua.h" headers to build shared library..
		Anny way, that package is provided by apt-get( Operating System Pkg Manager ), Luarocks doesn't know about, but no problem..
		Because dependency check is provided in table var 'external_dependencies' bellow..
	]]
}
build = {
	type			= "make",
	makefile		= "Makefile",
	build_target		= "all",
	build_pass		= true,
	build_variables		= {},
	install_target		= "install",
	install_pass		= true,
	install_variables	= { BINDIR="/usr/local/lib/luarocks/rocks/" .. package .. "/" .. version, CONFDIR="/usr/local/lib/luarocks/rocks/" .. package .. "/" .. version, LDIR="/usr/local/lib/luarocks/rocks/" .. package .. "/" .. version, SERVICEDIR="/usr/local/lib/luarocks/rocks/" .. package .. "/" .. version },
	variables		= {},
	modules			= { ats = "src/ats.c" }
}

