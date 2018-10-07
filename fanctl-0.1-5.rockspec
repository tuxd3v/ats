rockspec_format="1.0"
package = "fanctl"
version = "0.1-5"
description = {
	summary	= "Active Thermal Service",
	detailed		= [[
		This tool, provide support for Rockpro64, Active thermal Service( Fan Control ).
	]],
	homepage	= "https://github.com/tuxd3v/fanctl",
	license		= "See License..",
	maintainer	= "tuxd3v <tuxd3v@sapo.pt>"
}
source = {
	url			= "git://github.com/tuxd3v/fanctl",
	branch		= "master",
}
dependencies = {
	supported_platforms	= "linux"
}
build = {
	type			= "make",
	makefile			= "Makefile",
	build_target		= "all",
	build_pass		= true,
	build_variables	= {},
	install_target		= "install",
	install_pass		= true,
	install_variables	= {},
	variables		= {},
	modules			= { sleep = "src/sleep.c" }
}
