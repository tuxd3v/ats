
## Lua-dev Dependencies Related
#
DEPS		:= lua5.3
# Lua-dev header PATHs
IDIR		:= /usr/include/lua5.3
ifeq (,$(wildcard $(IDIR)/.))
        $(error Lua Include Folder: $(IDIR), **NOT Detected**, ABORTING..)
endif

## ATS Shared Library
#
NAME		:= ats
MAJOR		:= 0
MINOR		:= 9
VERSION		:= $(MAJOR).$(MINOR)

# Compiller Options
#
CC		:= gcc
# In future, -march=armv8-a+simd+crypto+crc -ansi -Wno-long-long
CFLAGS		:= -march=armv8-a+crc -mtune=cortex-a72.cortex-a53 -fPIC -Wall -Werror -O3 -g -I$(IDIR) # Compiler Flags, armv8-a+crc, tune for Big.Litle a72+a53
TEST_CFLAGS     := -march=armv8-a+crc -mtune=cortex-a72.cortex-a53 -O3 -g -I$(IDIR)

LDFLAGS		:= -shared -Wl,-soname,$(NAME).so.$(MAJOR) -l$(DEPS) # Linker Flags
TEST_LDFLAGS	:= -L/usr/lib/aarch64-linux-gnu -l$(DEPS) -lm -ldl

## ATS Installation ENVIRONMENT PATHs
#
# Shared Library Module
ifndef LDIR
        LDIR	:= /usr/local/lib/lua/5.3
endif
ifeq (,$(wildcard $(LDIR)/.))
$(LDIR):
	@mkdir -pv $(LDIR);
        $(info ATS Module Folder: $(LDIR), created..)
endif
# ATS Binary
ifndef BINDIR
	# LuaRocks Paths or Makefile ONLY?
        $(info Make is Working ..)
        ifneq (,$(wildcard /lib/systemd/system/.))
                BINDIR := /usr/local/sbin
        else ifneq (,$(wildcard /etc/init.d/.))
                BINDIR := /etc/init.d
        endif
        LUAROCKS := 0
else
        $(info LuaRocks is Working ..)
        LUAROCKS := 1
endif
ifeq (,$(wildcard $(BINDIR)/.))
        $(error ATS Binary Folder: $(BINDIR), **NOT Detected**, ABORTING..)
endif
# ATS Config File
ifndef CONFDIR
        CONFDIR	:= /etc
endif
ifeq (,$(wildcard $(CONFDIR)/.))
        $(error ATS Config Folder: $(CONFDIR), **NOT Detected**, ABORTING..)
endif
# ATS Service File
ifndef SERVICEDIR
	# The great SysVinit or ..SystemD ?
        ifneq (,$(wildcard /lib/systemd/system/.))
                $(info SystemD Detected ..)
                SERVICEDIR := /lib/systemd/system
                SYSVINIT   := 0
        else ifneq (,$(wildcard /etc/init.d/.))
                        $(info SysVinit Detected ..)
                        SERVICEDIR := /etc/init.d
                        BINDIR     := $(SERVICEDIR)
                        SYSVINIT   := 1
        endif
else
	# The great SysVinit or ..SystemD ?
        ifneq (,$(wildcard /lib/systemd/system/.))
                $(info SystemD Detected ..)
                SYSVINIT   := 0
        else ifneq (,$(wildcard /etc/init.d/.))
                $(info SysVinit Detected ..)
                SYSVINIT   := 1
        endif
endif
ifeq (,$(wildcard $(SERVICEDIR)/.))
        $(error ATS Service Folder: $(SERVICEDIR), **NOT Detected**, ABORTING..)
endif


## ATS source/headers.. Code Related
#
ATS_SRCS	:= ats.c
ATS_HDRS	:= debug.h $(ATS_SRCS:.c=.h)
DEBUG_SRCS	:= debug.c
DEBUG_HDRS	:= $(DEBUG_SRCS:.c=.h)

TEST_SRCS	:= test.c
TEST_HDRS	:= $(ATS_HDRS)


# Objects
#OBJS		:= $(SRCS:.c=.o)
ATS_OBJS	:= $(ATS_SRCS:.c=.o)
DEBUG_OBJS	:= $(DEBUG_SRCS:.c=.o)

TEST_OBJS	:= $(TEST_SRCS:.c=.o)


## Binaries
#TEST
TEST_BIN	:= main


# project c/h/lua  relative paths
SRCS_PATH	:= src
HDRS_PATH	:= include
# Project c/h relative paths.to/file.name
ATS_SRCS	:= $(addprefix $(SRCS_PATH)/,$(ATS_SRCS))
ATS_HDRS	:= $(addprefix $(HDRS_PATH)/,$(ATS_HDRS))
DEBUG_SRCS	:= $(addprefix $(SRCS_PATH)/,$(DEBUG_SRCS))
DEBUG_HDRS	:= $(addprefix $(HDRS_PATH)/,$(DEBUG_HDRS))
# for testing ats purposes( with a C frontend.. )
TEST_HDRS	:= $(addprefix $(HDRS_PATH)/,$(TEST_HDRS))

# Project systemd service relative path
SERVICE_PATH	:= systemd
# Project config service relative path
CONFIG_PATH	:= etc


# TARGETs
.PHONY: all
all   : $(NAME).so.$(VERSION)

#$(OBJS): $(SRCS) $(HDRS)
#	$(CC) -c $(CFLAGS) -o $@ $<
$(DEBUG_OBJS): $(DEBUG_SRCS) $(DEBUG_HDRS)
	$(CC) -c $(CFLAGS) -o $@ $<

$(ATS_OBJS): $(ATS_SRCS) $(ATS_HDRS)
	$(CC) -c $(CFLAGS) -o $@ $<


#$(NAME).so.$(VERSION): $(OBJS)
$(NAME).so.$(VERSION): $(DEBUG_OBJS) $(ATS_OBJS)
	$(CC) $(LDFLAGS) -o $@ $^


## For testing and debugging ATS
# Not needed for end ATS Binary
.PHONY: test
test  : $(TEST_BIN)


$(TEST_OBJS): $(TEST_SRCS) $(TEST_HDRS)
	$(CC) -c $(TEST_CFLAGS) -o $@ $<


$(TEST_BIN): $(DEBUG_OBJS) $(ATS_OBJS) $(TEST_OBJS)
	$(CC)  -o $@ $^ $(TEST_LDFLAGS)


.PHONY:	install
install: remove
	$(info Install ATS Service File ..........: ats.service in '$(SERVICEDIR)')
	@if [ ${SYSVINIT} -eq 0 ];then															\
		install --preserve-timestamps --owner=root --group=root --mode=640 --target-directory=${SERVICEDIR} ${SERVICE_PATH}/ats.service;	\
	fi
	$(info Install ATS Config ................: ats.config in '$(CONFDIR)')
	@install --preserve-timestamps --owner=root --group=root --mode=640 --target-directory=${CONFDIR} ${CONFIG_PATH}/ats.conf
	$(info Install ATS Tool ..................: ats in '$(BINDIR)')
	@install --preserve-timestamps --owner=root --group=root --mode=550 --target-directory=${BINDIR} ${SRCS_PATH}/ats
	$(info Install new ATS Library ...........: ${NAME}.so.${VERSION} in '${LDIR}')
	@install --preserve-timestamps --owner=root --group=root --mode=440 --target-directory=${LDIR} ${NAME}.so.${VERSION}
	$(info Creating soname symLink ........: ${NAME}.so in '${LDIR}')
	@if [ ${LUAROCKS} -eq 0 ];then					\
		ln -s ${LDIR}/${NAME}.so.${VERSION} ${LDIR}/${NAME}.so;	\
	fi
	@if [ ${LUAROCKS} -eq 1 ];then											\
		if [ ${SYSVINIT} -eq 0 ];then										\
			echo "Creating Service symLink .......: ats.service in '/lib/systemd/system'";			\
			ln -s ${SERVICEDIR}/ats.service /lib/systemd/system/ats.service;				\
			echo "Creating Binary symLink ........: ats in '/usr/local/sbin/ats'";				\
			ln -s ${BINDIR}/ats /usr/local/sbin/ats;							\
		fi;													\
		if [ ${SYSVINIT} -eq 1 ];then										\
			echo "Creating Service symLink .......: ats in '/usr/local/sbin/ats'";				\
			ln -s ${BINDIR}/ats /etc/init.d/ats;								\
		fi;													\
		echo "Creating Config symLink ........: ats.conf in '/etc/ats.conf'";					\
		ln -s ${CONFDIR}/ats.conf /etc/ats.conf;								\
		echo "Creating SharedObject symLink ..: ${NAME}.so.${VERSION} in '/usr/local/lib/lua/5.3'";		\
		ln -s ${LDIR}/${NAME}.so.${VERSION} /usr/local/lib/lua/5.3/${NAME}.so;					\
	fi
	@if [ ${SYSVINIT} -eq 1 ];then			\
		chkconfig --add ats;			\
		chkconfig --level 12345 ats on;		\
		echo "Starting ATS Service..";		\
		/etc/init.d/ats start;			\
	fi
	@if [ ${SYSVINIT} -eq 0 ];then			\
		systemctl enable ats;			\
		echo "Starting ATS Service..";		\
		systemctl start ats;			\
		sleep 1 && systemctl status ats;	\
	fi


.PHONY:	clean
clean:
	@if [ -f ${DEBUG_OBJS} ];then		\
		rm -v ${DEBUG_OBJS};		\
	fi
	@if [ -f ${ATS_OBJS} ];then		\
		rm -v ${ATS_OBJS};		\
	fi
	@if [ -f ${NAME}.so.${VERSION} ];then	\
		rm -v ${NAME}.so.${VERSION};	\
	fi
	@if [ -f ${TEST_OBJS} ];then		\
		rm -v ${TEST_OBJS};		\
	fi
	@if [ -f $(TEST_BIN) ];then		\
		rm -v $(TEST_BIN);		\
	fi

.PHONY: remove
remove:
	@if [ ${SYSVINIT} -eq 0 ];then															\
		if [ -L "/var/run/systemd/units/invocation:ats.service" ] || [ -L "/sys/fs/cgroup/systemd/system.slice/ats.service/tasks" ];then	\
			echo "Stopping SystemD ATS Service ..";												\
			systemctl stop ats;														\
			journalctl -u ats --rotate 1> /dev/null 2>&1;											\
		fi;																	\
		echo "Searching for Previous Install, and remove it:";											\
		sync && sleep 1 && rm -vf /etc/ats.conf && rm -vf /lib/systemd/system/ats.service && rm -vf /usr/local/sbin/ats && rm -vf /usr/local/lib/lua/5.3/ats.so*;	\
	fi
	@if [ ${SYSVINIT} -eq 1 ];then															\
		echo "Stopping SysVinit ATS Service ..";												\
		/etc/init.d/ats stop;															\
		chkconfig --level 12345 ats off;													\
		chkconfig --del ats;															\
		sync;																	\
		rm -vf /etc/ats.conf															\
		rm -vf /etc/init.d/ats															\
		rm -vf /usr/local/lib/lua/5.3/ats.so*;													\
	fi

.PHONY: purge
purge:
	cd / && rm -rf ${OLDPWD}/ats
